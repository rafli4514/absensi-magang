import 'package:flutter/material.dart';

import '../../services/logbook_service.dart';
import '../../themes/app_themes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/logbook_card.dart';

class MenteeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> menteeData;

  const MenteeDetailScreen({super.key, required this.menteeData});

  @override
  State<MenteeDetailScreen> createState() => _MenteeDetailScreenState();
}

class _MenteeDetailScreenState extends State<MenteeDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _historyLogbook = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Load logbook specific to this mentee ID
    // Gunakan ID peserta magang yang dikirim dari halaman sebelumnya
    final id = widget.menteeData['id']; // ID User/Peserta

    // Kita butuh method getLogbookByPesertaId di service, atau filter getAllLogbook
    // Untuk saat ini kita pakai getAllLogbook dengan filter client-side atau query param jika ada
    final res = await LogbookService.getAllLogbook(
        limit: 50); // Tambahkan param pesertaMagangId jika backend support

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          // Filter manual jika backend belum support filter by ID di endpoint ini
          // Asumsi data['pesertaMagang']['id'] == id atau data['pesertaMagangId'] == id
          _historyLogbook =
              res.data!.where((l) => l.pesertaMagangId == id).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mentee = widget.menteeData;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(title: 'Detail Peserta', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
                border: Border(
                    bottom: BorderSide(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
                    child: Text(
                      (mentee['nama'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mentee['nama'] ?? 'Nama Tidak Diketahui',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor),
                  ),
                  Text(
                    mentee['divisi'] ?? 'Divisi Tidak Diketahui',
                    style: TextStyle(
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemes.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Aktif',
                        style: TextStyle(
                            color: AppThemes.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Riwayat Logbook
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Riwayat Logbook',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32), child: LoadingIndicator())
                : _historyLogbook.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Belum ada riwayat logbook',
                            style: TextStyle(color: AppThemes.hintColor)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: _historyLogbook.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = _historyLogbook[index];
                          return LogBookCard(
                            log: log,
                            isDark: isDark,
                            onEdit: () {}, // Pembimbing hanya view
                            onDelete: () {}, // Pembimbing hanya view
                          );
                        },
                      ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
