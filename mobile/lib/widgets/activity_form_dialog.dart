import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Sesuaikan import model ini dengan struktur foldermu
import '../models/activity.dart';
import '../models/enum/activity_status.dart';
import '../models/enum/activity_type.dart';
import '../themes/app_themes.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? existingActivity; // Jika null = Mode Tambah
  final Function(
    String kegiatan,
    String deskripsi,
    DateTime tanggal,
    ActivityType type,
    ActivityStatus status,
  )
  onSave;

  const ActivityFormDialog({
    super.key,
    this.existingActivity,
    required this.onSave,
  });

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kegiatanController;
  late TextEditingController _deskripsiController;
  late DateTime _selectedDate;
  late ActivityType _selectedType;
  late ActivityStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data (default atau dari existing data buat Edit)
    _kegiatanController = TextEditingController(
      text: widget.existingActivity?.kegiatan ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.existingActivity?.deskripsi ?? '',
    );

    // Parsing tanggal string 'YYYY-MM-DD' balik ke DateTime jika edit
    if (widget.existingActivity != null) {
      try {
        _selectedDate = DateTime.parse(widget.existingActivity!.tanggal);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    _selectedType = widget.existingActivity?.type ?? ActivityType.meeting;
    _selectedStatus = widget.existingActivity?.status ?? ActivityStatus.pending;
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      title: Text(
        widget.existingActivity == null ? 'Tambah Aktivitas' : 'Edit Aktivitas',
        style: TextStyle(
          color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Nama Kegiatan', _kegiatanController, isDark),
                const SizedBox(height: 16),
                _buildTextField(
                  'Deskripsi Singkat',
                  _deskripsiController,
                  isDark,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Date Picker
                Text(
                  "Tanggal",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: TextStyle(
                            color: isDark
                                ? AppThemes.darkTextPrimary
                                : AppThemes.onSurfaceColor,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppThemes.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown Type
                _buildDropdown<ActivityType>(
                  label: "Tipe Aktivitas",
                  value: _selectedType,
                  items: ActivityType.values,
                  onChanged: (val) => setState(() => _selectedType = val!),
                  isDark: isDark,
                  itemLabel: (e) => e.toString().split('.').last.toUpperCase(),
                ),
                const SizedBox(height: 16),

                // Dropdown Status
                _buildDropdown<ActivityStatus>(
                  label: "Status",
                  value: _selectedStatus,
                  items: ActivityStatus.values,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                  isDark: isDark,
                  itemLabel: (e) => e.toString().split('.').last.toUpperCase(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal', style: TextStyle(color: AppThemes.hintColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemes.primaryColor,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _kegiatanController.text,
                _deskripsiController.text,
                _selectedDate,
                _selectedType,
                _selectedStatus,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppThemes.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    required bool isDark,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark
                  ? AppThemes.darkSurface
                  : AppThemes.surfaceColor,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    itemLabel(e),
                    style: TextStyle(
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
