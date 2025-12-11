import 'package:flutter/material.dart';

import '../../../models/logbook.dart';
import '../../../themes/app_themes.dart';
import 'custom_text_field.dart';

class LogBookFormDialog extends StatefulWidget {
  final LogBook? existingLog;
  final Function(String title, String location, String mentor, String content)
      onSave;

  const LogBookFormDialog({super.key, this.existingLog, required this.onSave});

  @override
  State<LogBookFormDialog> createState() => _LogBookFormDialogState();
}

class _LogBookFormDialogState extends State<LogBookFormDialog> {
  final _formKey = GlobalKey<FormState>(); // Tambahkan form key untuk validasi
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _mentorController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingLog?.title ?? '',
    );
    _locationController = TextEditingController(
      text: widget.existingLog?.location ?? '',
    );
    _mentorController = TextEditingController(
      text: widget.existingLog?.mentorName ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingLog?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _mentorController.dispose();
    _contentController.dispose();
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
                      ? 'Edit Log Book'
                      : 'Tambah Log Book',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Judul Kegiatan
                CustomTextField(
                  controller: _titleController,
                  label: 'Judul Kegiatan',
                  hint: 'Contoh: Instalasi Jaringan',
                  icon: Icons.title_rounded,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Judul tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),

                // 2. Lokasi
                CustomTextField(
                  controller: _locationController,
                  label: 'Lokasi',
                  hint: 'Contoh: Ruang Server Lt. 2',
                  icon: Icons.location_on_rounded,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Lokasi wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // 3. Mentor
                CustomTextField(
                  controller: _mentorController,
                  label: 'Mentor Pendamping',
                  hint: 'Nama mentor',
                  icon: Icons.supervisor_account_rounded,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Nama mentor wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // 4. Detail Keterangan (Multiline)
                CustomTextField(
                  controller: _contentController,
                  label: 'Detail Keterangan',
                  hint: 'Deskripsikan kegiatan yang dilakukan...',
                  icon: Icons.notes_rounded,
                  maxLines: 4,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Keterangan tidak boleh kosong'
                      : null,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(
                            _titleController.text,
                            _locationController.text,
                            _mentorController.text,
                            _contentController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
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
