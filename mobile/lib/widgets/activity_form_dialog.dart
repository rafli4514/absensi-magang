import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan package ini ada
import 'package:intl/intl.dart';

import '../models/activity.dart';
import '../models/enum/activity_status.dart';
import '../models/enum/activity_type.dart';
import '../themes/app_themes.dart';
import 'custom_text_field.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? existingActivity;
  // Update callback untuk menerima File foto
  final Function(
    String kegiatan,
    String deskripsi,
    DateTime tanggal,
    ActivityType type,
    ActivityStatus status,
    File? foto, // Parameter baru
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
  late TextEditingController _dateController;
  late DateTime _selectedDate;
  late ActivityType _selectedType;
  late ActivityStatus _selectedStatus;

  // State untuk foto
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  // Fungsi ambil gambar
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompresi ringan
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_rounded,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor),
              title: Text('Ambil Foto',
                  style: TextStyle(
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor),
              title: Text('Pilih dari Galeri',
                  style: TextStyle(
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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

                  // 3. Date Picker
                  CustomTextField(
                    controller: _dateController,
                    label: 'Tanggal',
                    hint: 'Pilih tanggal',
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),

                  // --- AREA FOTO ---
                  Text(
                    'Dokumentasi (Opsional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(context, isDark),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppThemes.darkSurfaceElevated
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppThemes.darkOutline
                              : Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 32,
                                  color:
                                      AppThemes.primaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap untuk ambil foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : AppThemes.hintColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Dropdown Type & Status (Sama seperti sebelumnya)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<ActivityType>(
                          label: "Tipe",
                          value: _selectedType,
                          items: ActivityType.values,
                          onChanged: (val) =>
                              setState(() => _selectedType = val!),
                          isDark: isDark,
                          itemLabel: (e) =>
                              e.toString().split('.').last.toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<ActivityStatus>(
                          label: "Status",
                          value: _selectedStatus,
                          items: ActivityStatus.values,
                          onChanged: (val) =>
                              setState(() => _selectedStatus = val!),
                          isDark: isDark,
                          itemLabel: (e) =>
                              e.toString().split('.').last.toUpperCase(),
                        ),
                      ),
                    ],
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
                              _selectedImage, // Kirim foto
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

  // Helper _buildDropdown sama seperti sebelumnya...
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
                      fontSize: 12, // Font sedikit lebih kecil agar muat
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
