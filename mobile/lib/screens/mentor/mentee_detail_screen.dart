import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/logbook.dart';
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
  bool _isLoading = false;
  List<LogBook> _logbooks = [];

  // --- STRUCTURE DATA FILTER ---
  // List Bulan -> List Minggu -> Data Tanggal
  List<Map<String, dynamic>> _monthList = [];

  // State Index Pilihan
  int _selectedMonthIndex = 0;
  int _selectedWeekIndex =
      0; // Index minggu RELATIF terhadap bulan yang dipilih

  String _currentDateRangeLabel = '';

  @override
  void initState() {
    super.initState();
    _generateHierarchy();
    _loadMenteeLogbooks();
  }

  // 1. GENERATE STRUKTUR BULAN & MINGGU (DINAMIS)
  void _generateHierarchy() {
    final startStr = widget.menteeData['tanggalMulai'];
    final endStr = widget.menteeData['tanggalSelesai'];

    if (startStr == null) return;

    try {
      DateTime startDate = DateTime.parse(startStr);
      DateTime endDate = endStr != null
          ? DateTime.parse(endStr)
          : startDate.add(const Duration(days: 90)); // Default 3 bulan

      // Hitung total bulan (kasar) untuk loop
      int totalMonths = ((endDate.difference(startDate).inDays) / 30).ceil();
      if (totalMonths < 1) totalMonths = 1;

      List<Map<String, dynamic>> generatedMonths = [];
      int absoluteWeekCounter =
          1; // Untuk label "Minggu X" secara global (opsional)

      for (int m = 0; m < totalMonths; m++) {
        // Tentukan Range Tanggal Bulan Ini (Per 30 hari atau per kalender)
        // Kita gunakan pendekatan relatif 30 hari agar konsisten dengan "Bulan Ke-N"
        DateTime monthStart = startDate.add(Duration(days: m * 30));
        DateTime monthEnd = monthStart.add(const Duration(days: 29));

        // Cap di tanggal selesai kontrak
        if (monthEnd.isAfter(endDate)) monthEnd = endDate;
        // Stop jika start bulan sudah lewat end date
        if (monthStart.isAfter(endDate)) break;

        List<Map<String, String>> weeksInMonth = [];

        // Generate Minggu di dalam Bulan ini
        DateTime currentWeekStart = monthStart;
        int weekIndexInMonth = 1;

        while (currentWeekStart.isBefore(monthEnd) ||
            currentWeekStart.isAtSameMomentAs(monthEnd)) {
          DateTime currentWeekEnd =
              currentWeekStart.add(const Duration(days: 6));

          // Potong minggu jika nyebrang bulan/kontrak
          if (currentWeekEnd.isAfter(monthEnd)) currentWeekEnd = monthEnd;

          String startFmt = DateFormat('yyyy-MM-dd').format(currentWeekStart);
          String endFmt = DateFormat('yyyy-MM-dd').format(currentWeekEnd);
          String rangeLabel =
              "${DateFormat('d MMM').format(currentWeekStart)} - ${DateFormat('d MMM').format(currentWeekEnd)}";

          weeksInMonth.add({
            'label':
                'Minggu $weekIndexInMonth', // Atau 'Minggu $absoluteWeekCounter'
            'range': rangeLabel,
            'start': startFmt,
            'end': endFmt,
          });

          // Lanjut ke minggu berikutnya
          currentWeekStart = currentWeekStart.add(const Duration(days: 7));
          weekIndexInMonth++;
          absoluteWeekCounter++;
        }

        if (weeksInMonth.isNotEmpty) {
          generatedMonths.add({
            'label': 'Bulan ${m + 1}',
            'weeks': weeksInMonth,
          });
        }
      }

      setState(() {
        _monthList = generatedMonths;
        if (_monthList.isNotEmpty && _monthList[0]['weeks'].isNotEmpty) {
          _currentDateRangeLabel = _monthList[0]['weeks'][0]['range'];
        }
      });
    } catch (e) {
      debugPrint("Error generating hierarchy: $e");
    }
  }

  // 2. LOAD DATA (SESUAI PILIHAN BULAN & MINGGU)
  Future<void> _loadMenteeLogbooks() async {
    final id = widget.menteeData['id'];
    if (id == null || _monthList.isEmpty) return;

    // Safety Check Index
    if (_selectedMonthIndex >= _monthList.length) _selectedMonthIndex = 0;
    final currentWeeks = _monthList[_selectedMonthIndex]['weeks'] as List;
    if (_selectedWeekIndex >= currentWeeks.length) _selectedWeekIndex = 0;

    setState(() => _isLoading = true);

    try {
      final selectedWeekData = currentWeeks[_selectedWeekIndex];

      final response = await LogbookService.getAllLogbook(
        pesertaMagangId: id.toString(),
        startDate: selectedWeekData['start'],
        endDate: selectedWeekData['end'],
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _logbooks = response.data ?? [];
          _isLoading = false;
          _currentDateRangeLabel = selectedWeekData['range'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = widget.menteeData['nama'] ?? 'Peserta';
    final division = widget.menteeData['divisi'] ?? '-';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Detail Peserta',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // --- HEADER PROFIL ---
          _buildHeaderProfile(name, division, colorScheme),

          // --- FILTER CONTAINER ---
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LEVEL 1: BULAN
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _monthList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedMonthIndex;
                      return _buildModernFilterChip(
                        label: _monthList[index]['label'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedMonthIndex = index;
                            _selectedWeekIndex =
                                0; // Reset minggu ke awal saat ganti bulan
                          });
                          _loadMenteeLogbooks();
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 2. LEVEL 2: MINGGU (Dynamic based on Month)
                if (_monthList.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          (_monthList[_selectedMonthIndex]['weeks'] as List)
                              .length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final weeks =
                            _monthList[_selectedMonthIndex]['weeks'] as List;
                        final isSelected = index == _selectedWeekIndex;
                        return _buildModernSubFilterChip(
                          label: weeks[index]['label'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedWeekIndex = index;
                            });
                            _loadMenteeLogbooks();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // --- INFO PERIODE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range_rounded,
                        size: 16, color: AppThemes.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      _currentDateRangeLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.primaryColor),
                    ),
                  ],
                ),
                Text(
                  '${_logbooks.length} Data',
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // --- LIST LOGBOOK ---
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _logbooks.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logbooks.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = _logbooks[index];
                          // READ-ONLY CARD
                          return LogBookCard(
                            log: log,
                            isReadOnly: true,
                            onEdit: null,
                            onDelete: null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeaderProfile(
      String name, String division, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  division,
                  style: TextStyle(
                      fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Utama (Bulan) - Lebih Besar & Menonjol
  Widget _buildModernFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemes.primaryColor
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12), // Pill shape kotak
          border: Border.all(
            color: isSelected ? AppThemes.primaryColor : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemes.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Filter Sub (Minggu) - Lebih Kecil & Halus
  Widget _buildModernSubFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemes.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20), // Pill shape bulat penuh
          border: Border.all(
            color: isSelected
                ? AppThemes.primaryColor
                : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppThemes.primaryColor
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded,
              size: 56, color: colorScheme.outline.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada aktivitas pada periode ini',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
