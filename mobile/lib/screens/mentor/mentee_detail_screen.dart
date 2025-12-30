import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  List<dynamic> _allLogbooks = [];
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final id = widget.menteeData['id'];

    // Ambil data logbook (Client-side filter)
    final res = await LogbookService.getAllLogbook(limit: 100);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _allLogbooks =
              res.data!.where((l) => l.pesertaMagangId == id).toList();
          _allLogbooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      });
    }
  }

  List<dynamic> _getFilteredLogbooks() {
    return _allLogbooks.where((log) {
      try {
        final logDate = DateTime.parse(log.tanggal);
        return logDate.year == _selectedMonth.year &&
            logDate.month == _selectedMonth.month;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + months, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mentee = widget.menteeData;
    final filteredLogs = _getFilteredLogbooks();
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(title: 'Detail Peserta', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. HEADER PROFIL
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
                    backgroundImage: mentee['avatar'] != null
                        ? NetworkImage(mentee['avatar'])
                        : null,
                    child: mentee['avatar'] == null
                        ? Text((mentee['nama'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryColor))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mentee['nama'] ?? 'Nama Tidak Diketahui',
                    textAlign: TextAlign.center,
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

            const SizedBox(height: 24),

            // 2. JUDUL SECTION
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

            // 3. NAVIGASI BULAN (Full Width / Melebar ke Kanan Kiri)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20), // Padding dari layar HP
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppThemes.darkOutline
                          : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Mentok Kanan Kiri
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _changeMonth(-1),
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : Colors.grey.shade700,
                    ),
                    Text(
                      monthStr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => _changeMonth(1),
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),

            // 4. TOTAL SUMMARY
            const SizedBox(height: 8),
            Text(
              'Total ${filteredLogs.length} kegiatan logbook',
              style: TextStyle(
                  fontSize: 13,
                  color: AppThemes.hintColor,
                  fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 16),

            // 5. LIST DATA
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32), child: LoadingIndicator())
                : filteredLogs.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 48,
                                color: AppThemes.hintColor.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada logbook di bulan ini',
                              style: TextStyle(color: AppThemes.hintColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return LogBookCard(
                            log: log,
                            isDark: isDark,
                            onEdit: () {},
                            onDelete: () {},
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
