import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/enum/activity_type.dart';
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

  // State sekarang menggunakan ActivityType
  ActivityType _selectedType = ActivityType.izin;

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

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppThemes.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      // FIX: Gunakan surfaceContainer untuk background dialog
      backgroundColor: colorScheme.surfaceContainer,
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
                    // FIX: Gunakan onSurface untuk warna teks utama
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // --- DROPDOWN JENIS IZIN ---
                Text('Jenis Izin',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        // FIX: Gunakan onSurfaceVariant untuk teks sekunder
                        color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),

                DropdownButtonFormField<ActivityType>(
                  value: _selectedType,
                  // FIX: Gunakan surfaceContainerHigh untuk background dropdown
                  dropdownColor: colorScheme.surfaceContainer,
                  decoration: InputDecoration(
                    // Border handled by InputDecorator theme usually, but explicit here:
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    fillColor: isDark
                        ? colorScheme.surfaceContainerHigh
                        : Colors.white,
                    filled: true,
                  ),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppThemes.primaryColor),
                  items: [
                    _buildDropdownItem(ActivityType.izin, colorScheme),
                    _buildDropdownItem(ActivityType.sakit, colorScheme),
                    _buildDropdownItem(ActivityType.cuti, colorScheme),
                    _buildDropdownItem(ActivityType.pulangCepat, colorScheme),
                    _buildDropdownItem(ActivityType.other, colorScheme),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
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
                              // FIX: Gunakan onSurfaceVariant
                              color: colorScheme.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Mengirim value string ke parent
                          widget.onSubmit(_selectedType.value,
                              _alasanController.text, _startDate, _endDate);
                          Navigator.pop(context);
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

  DropdownMenuItem<ActivityType> _buildDropdownItem(
      ActivityType type, ColorScheme colorScheme) {
    return DropdownMenuItem(
      value: type,
      child: Text(
        type.displayName,
        style: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}
