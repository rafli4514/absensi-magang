import 'package:flutter/material.dart';

import '../../../models/logbook.dart';
import '../../../themes/app_themes.dart';

class LogBookFormDialog extends StatefulWidget {
  final LogBook? existingLog;
  final Function(String title, String location, String mentor, String content)
  onSave;

  const LogBookFormDialog({super.key, this.existingLog, required this.onSave});

  @override
  State<LogBookFormDialog> createState() => _LogBookFormDialogState();
}

class _LogBookFormDialogState extends State<LogBookFormDialog> {
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
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppThemes.darkOutline : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
              _StyledTextField(
                label: 'Judul Kegiatan',
                icon: Icons.event_note,
                isDark: isDark,
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              _StyledTextField(
                label: 'Lokasi (Cth: Lapangan)',
                icon: Icons.place,
                isDark: isDark,
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              _StyledTextField(
                label: 'Mentor Pendamping',
                icon: Icons.person,
                isDark: isDark,
                controller: _mentorController,
              ),
              const SizedBox(height: 16),
              _StyledTextField(
                label: 'Detail Keterangan',
                icon: Icons.description,
                isDark: isDark,
                maxLines: 4,
                controller: _contentController,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
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
                      if (_titleController.text.isNotEmpty &&
                          _contentController.text.isNotEmpty) {
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
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              prefixIcon: Icon(icon, size: 20, color: AppThemes.hintColor),
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: isDark
                    ? AppThemes.darkTextTertiary
                    : AppThemes.hintColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
