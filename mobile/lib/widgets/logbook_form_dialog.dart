import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/enum/activity_status.dart';
import '../../models/enum/activity_type.dart';
import '../../models/logbook.dart';
import '../../themes/app_themes.dart';

class LogBookFormDialog extends StatefulWidget {
  final LogBook? existingLog;
  final Function(String tanggal, String kegiatan, String deskripsi,
      String? durasi, ActivityType? type, ActivityStatus? status) onSave;

  const LogBookFormDialog({super.key, this.existingLog, required this.onSave});

  @override
  State<LogBookFormDialog> createState() => _LogBookFormDialogState();
}

class _LogBookFormDialogState extends State<LogBookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kegiatanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _durasiController;
  late DateTime _selectedDate;
  ActivityType? _selectedType;
  ActivityStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _kegiatanController = TextEditingController(
      text: widget.existingLog?.kegiatan ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.existingLog?.deskripsi ?? '',
    );
    _durasiController = TextEditingController(
      text: widget.existingLog?.durasi ?? '',
    );

    if (widget.existingLog != null && widget.existingLog!.tanggal.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.existingLog!.tanggal);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    _selectedType = widget.existingLog?.type ?? ActivityType.other;
    _selectedStatus = widget.existingLog?.status ?? ActivityStatus.pending;
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _deskripsiController.dispose();
    _durasiController.dispose();
    super.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingLog != null
                      ? 'Edit Log Book' // Translate
                      : 'Tambah Log Book', // Translate
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Tanggal Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal', // Translate
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemes.darkSurfaceElevated
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade300,
                          ),
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
                              size: 20,
                              color: AppThemes.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StyledTextField(
                  label: 'Kegiatan', // Translate
                  icon: Icons.event_note,
                  isDark: isDark,
                  controller: _kegiatanController,
                ),
                const SizedBox(height: 16),
                _StyledTextField(
                  label: 'Deskripsi', // Translate
                  icon: Icons.description,
                  isDark: isDark,
                  maxLines: 4,
                  controller: _deskripsiController,
                ),
                const SizedBox(height: 16),
                _StyledTextField(
                  label: 'Durasi (opsional, contoh: 2 jam)', // Translate
                  icon: Icons.access_time,
                  isDark: isDark,
                  controller: _durasiController,
                ),
                const SizedBox(height: 16),
                // Type Dropdown
                _buildDropdown<ActivityType>(
                  label: 'Tipe Aktivitas', // Translate
                  value: _selectedType,
                  items: ActivityType.values,
                  onChanged: (val) => setState(() => _selectedType = val),
                  isDark: isDark,
                  itemLabel: (e) => e.displayName,
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                _buildDropdown<ActivityStatus>(
                  label: 'Status', // Translate
                  value: _selectedStatus,
                  items: ActivityStatus.values,
                  onChanged: (val) => setState(() => _selectedStatus = val),
                  isDark: isDark,
                  itemLabel: (e) => e.displayName,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal', // Translate
                        style: TextStyle(
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_kegiatanController.text.isNotEmpty &&
                              _deskripsiController.text.isNotEmpty) {
                            widget.onSave(
                              DateFormat('yyyy-MM-dd').format(_selectedDate),
                              _kegiatanController.text,
                              _deskripsiController.text,
                              _durasiController.text.isNotEmpty
                                  ? _durasiController.text
                                  : null,
                              _selectedType,
                              _selectedStatus,
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Simpan'), // Translate
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
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
            fontWeight: FontWeight.w600,
            color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSurfaceElevated : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor:
                  isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
              items: items.map((e) {
                return DropdownMenuItem<T>(
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

class _StyledTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final TextEditingController? controller;

  const _StyledTextField({
    required this.label,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSurfaceElevated : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              prefixIcon: Icon(icon, size: 20, color: AppThemes.hintColor),
              hintText: 'Masukkan $label', // Translate
              hintStyle: TextStyle(
                color: isDark
                    ? AppThemes.darkTextTertiary
                    : AppThemes.hintColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
