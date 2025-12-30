import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../themes/app_themes.dart';
import 'custom_text_field.dart';

class LeaveFormDialog extends StatefulWidget {
  final Function(String tipe, String alasan, DateTime tanggalMulai,
      DateTime tanggalSelesai) onSubmit;

  const LeaveFormDialog({super.key, required this.onSubmit});

  @override
  State<LeaveFormDialog> createState() => _LeaveFormDialogState();
}

class _LeaveFormDialogState extends State<LeaveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alasanController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedType = 'IZIN';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateText();
  }

  void _updateDateText() {
    if (_startDate.year == _endDate.year &&
        _startDate.month == _endDate.month &&
        _startDate.day == _endDate.day) {
      _dateController.text = DateFormat('dd MMM yyyy').format(_startDate);
    } else {
      _dateController.text =
          "${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}";
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'SAKIT':
        return AppThemes.infoColor;
      case 'IZIN':
        return AppThemes.warningColor;
      case 'ALPHA':
        return AppThemes.errorColor;
      default:
        return AppThemes.neutralColor;
    }
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
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
        _startDate = picked.start;
        _endDate = picked.end;
        _updateDateText();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  'Form Pengajuan Izin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Jenis Izin',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTypeChip('IZIN', 'Izin', isDark),
                    const SizedBox(width: 12),
                    _buildTypeChip('SAKIT', 'Sakit', isDark),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _dateController,
                  label: 'Tanggal',
                  hint: 'Pilih tanggal',
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _pickDateRange,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _alasanController,
                  label: 'Keterangan / Alasan',
                  hint: 'Jelaskan alasan izin...',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                          style: TextStyle(
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.hintColor)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSubmit(_selectedType, _alasanController.text,
                              _startDate, _endDate);
                          Navigator.pop(
                              context); // Tutup dialog setelah submit callback dijalankan
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ajukan'),
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

  Widget _buildTypeChip(String value, String label, bool isDark) {
    final isSelected = _selectedType == value;
    final color = _getTypeColor(value);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDark
                    ? AppThemes.darkSurfaceElevated
                    : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppThemes.darkOutline : Colors.grey.shade300),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
