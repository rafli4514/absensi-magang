import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity.dart';
import '../models/enum/activity_status.dart';
import '../models/enum/activity_type.dart';
import '../themes/app_themes.dart';
import 'custom_text_field.dart'; // Import CustomTextField

class ActivityFormDialog extends StatefulWidget {
  final Activity? existingActivity;
  final Function(
    String kegiatan,
    String deskripsi,
    DateTime tanggal,
    ActivityType type,
    ActivityStatus status,
  ) onSave;

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
  late TextEditingController _dateController; // Controller untuk tanggal
  late DateTime _selectedDate;
  late ActivityType _selectedType;
  late ActivityStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _kegiatanController = TextEditingController(
      text: widget.existingActivity?.kegiatan ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.existingActivity?.deskripsi ?? '',
    );

    if (widget.existingActivity != null) {
      try {
        _selectedDate = DateTime.parse(widget.existingActivity!.tanggal);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    // Init controller tanggal untuk ditampilkan di CustomTextField
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    _selectedType = widget.existingActivity?.type ?? ActivityType.meeting;
    _selectedStatus = widget.existingActivity?.status ?? ActivityStatus.pending;
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _deskripsiController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppThemes.darkTheme : AppThemes.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppThemes.darkOutline : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.existingActivity == null
                        ? 'Tambah Aktivitas'
                        : 'Edit Aktivitas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Nama Kegiatan
                  CustomTextField(
                    controller: _kegiatanController,
                    label: 'Nama Kegiatan',
                    hint: 'Contoh: Meeting Proyek A',
                    icon: Icons.task_alt_rounded,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Deskripsi
                  CustomTextField(
                    controller: _deskripsiController,
                    label: 'Deskripsi Singkat',
                    hint: 'Jelaskan detail aktivitas...',
                    icon: Icons.short_text_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // 3. Date Picker (via CustomTextField ReadOnly)
                  CustomTextField(
                    controller: _dateController,
                    label: 'Tanggal',
                    hint: 'Pilih tanggal',
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),

                  // 4. Dropdown Type
                  _buildDropdown<ActivityType>(
                    label: "Tipe Aktivitas",
                    value: _selectedType,
                    items: ActivityType.values,
                    onChanged: (val) => setState(() => _selectedType = val!),
                    isDark: isDark,
                    itemLabel: (e) =>
                        e.toString().split('.').last.toUpperCase(),
                  ),
                  const SizedBox(height: 16),

                  // 5. Dropdown Status
                  _buildDropdown<ActivityStatus>(
                    label: "Status",
                    value: _selectedStatus,
                    items: ActivityStatus.values,
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                    isDark: isDark,
                    itemLabel: (e) =>
                        e.toString().split('.').last.toUpperCase(),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
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
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk Dropdown agar style-nya mirip CustomTextField
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.transparent : Colors.white,
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor:
                  isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppThemes.primaryColor,
              ),
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    itemLabel(e),
                    style: TextStyle(
                      fontSize: 13,
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
