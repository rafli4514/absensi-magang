import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/enum/activity_status.dart';
import '../../models/enum/activity_type.dart';
import '../../models/logbook.dart';
import '../../themes/app_themes.dart';
import 'custom_text_field.dart';

class LogBookFormDialog extends StatefulWidget {
  final LogBook? existingLog;
  final Function(
    String tanggal,
    String kegiatan,
    String deskripsi,
    String? durasi,
    ActivityType? type,
    ActivityStatus? status,
    XFile? foto, // CHANGED: File? -> XFile?
  ) onSave;

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
  XFile? _selectedImage; // CHANGED: File? -> XFile?
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _kegiatanController =
        TextEditingController(text: widget.existingLog?.kegiatan ?? '');
    _deskripsiController =
        TextEditingController(text: widget.existingLog?.deskripsi ?? '');
    _durasiController =
        TextEditingController(text: widget.existingLog?.durasi ?? '');

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (!mounted) return; // FIX: Ensure widget is still properly mounted before using setState
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile); // Store XFile directly
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
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
                      ? 'Edit Log Book'
                      : 'Tambah Log Book',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                // Date Picker
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
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(color: colorScheme.onSurface)),
                        Icon(Icons.calendar_today,
                            size: 20, color: AppThemes.primaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _kegiatanController,
                  label: 'Kegiatan',
                  hint: 'Kegiatan harian',
                  icon: Icons.event_note,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi',
                  hint: 'Deskripsi kegiatan',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _durasiController,
                  label: 'Durasi',
                  hint: 'Contoh: 2 Jam',
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 16),
                // Image Picker UI
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        label: const Text('Galeri'),
                      ),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                            'Foto dipilih: ${_selectedImage!.name}', // Use name instead of path split
                            style: TextStyle(
                                fontSize: 12, color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                         // Conditional Rendering for Web vs Mobile
                         kIsWeb
                             ? Image.network(
                                 _selectedImage!.path,
                                 height: 150,
                                 fit: BoxFit.cover,
                                 errorBuilder: (_, __, ___) => const Text("Gagal memuat preview"),
                               )
                             : Image.file(
                                 File(_selectedImage!.path),
                                 height: 150,
                                 fit: BoxFit.cover,
                               ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            _kegiatanController.text,
                            _deskripsiController.text,
                            _durasiController.text,
                            _selectedType,
                            _selectedStatus,
                            _selectedImage, // Pass XFile directly
                          );
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
    );
  }
}
