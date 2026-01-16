import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../navigation/route_names.dart';
import '../../services/leave_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart'; // Import CustomTextField
import '../../widgets/loading_indicator.dart';
import '../../widgets/mentor_bottom_nav.dart';

class MentorValidationScreen extends StatefulWidget {
  const MentorValidationScreen({super.key});

  @override
  State<MentorValidationScreen> createState() => _MentorValidationScreenState();
}

class _MentorValidationScreenState extends State<MentorValidationScreen> {
  List<Map<String, dynamic>> _pendingList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await LeaveService.getLeaves(status: 'PENDING');
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _pendingList = response.data!;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC VALIDASI DENGAN CATATAN ---
  Future<void> _showValidationDialog(String id, bool isApprove) async {
    final noteController = TextEditingController();

    // Tampilkan Dialog Input Catatan
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final colors = Theme.of(context).extension<AppColors>()!;
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          title: Text(
            isApprove ? 'Setujui Pengajuan?' : 'Tolak Pengajuan?',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApprove
                    ? 'Masukkan catatan untuk peserta (opsional):'
                    : 'Berikan alasan penolakan (wajib):',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: noteController,
                label: 'Catatan / Alasan',
                hint: isApprove
                    ? 'Contoh: Hati-hati di jalan'
                    : 'Contoh: Kuota cuti habis',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                if (!isApprove && noteController.text.trim().isEmpty) {
                  GlobalSnackBar.show('Alasan penolakan wajib diisi',
                      isWarning: true);
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isApprove ? colors.success : colorScheme.error,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(isApprove ? 'Setujui' : 'Tolak'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Proses ke Backend
    _processValidation(id, isApprove, noteController.text.trim());
  }

  Future<void> _processValidation(
      String id, bool isApprove, String catatan) async {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: LoadingIndicator()),
    );

    bool success;
    if (isApprove) {
      success = await LeaveService.approveLeave(id, catatan: catatan);
    } else {
      success = await LeaveService.rejectLeave(id, catatan: catatan);
    }

    if (mounted) {
      Navigator.pop(context); // Tutup loading

      if (success) {
        GlobalSnackBar.show(
            isApprove ? 'Pengajuan disetujui' : 'Pengajuan ditolak',
            isSuccess: isApprove,
            isError: !isApprove);
        _loadPendingItems(); // Refresh list
      } else {
        GlobalSnackBar.show('Gagal memproses data', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Validasi Izin',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _pendingList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 64,
                              color: colorScheme.outline.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Semua pengajuan telah divalidasi!',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: _pendingList.length,
                      itemBuilder: (context, index) {
                        final item = _pendingList[index];
                        return _buildValidationCard(item);
                      },
                    ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const MentorBottomNav(
                currentRoute: RouteNames.mentorValidation),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD (UPDATE ACTION BUTTONS) ---
  Widget _buildValidationCard(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final id = item['id'].toString();
    final name = item['pesertaMagang']?['nama'] ?? 'Peserta';
    final tipeRaw = item['tipe'] ?? 'LAINNYA';
    final alasan = item['alasan'] ?? '-';

    // ... Logic tanggal sama seperti sebelumnya ...
    String dateRange = item['tanggalMulai'] ?? '-';
    String durationText = '';
    if (item['tanggalMulai'] != null && item['tanggalSelesai'] != null) {
      try {
        final start = DateTime.parse(item['tanggalMulai']);
        final end = DateTime.parse(item['tanggalSelesai']);
        final diff = end.difference(start).inDays + 1;
        durationText = '$diff Hari';
        final fmt = DateFormat('d MMM');
        dateRange = '${fmt.format(start)} - ${fmt.format(end)}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Bagian Header Nama & Tipe sama seperti sebelumnya) ...
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(name[0],
                    style: TextStyle(color: colorScheme.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface)),
                    Text(tipeRaw,
                        style: TextStyle(
                            fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (durationText.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(durationText,
                      style: TextStyle(
                          fontSize: 11, color: colorScheme.onSurface)),
                )
            ],
          ),
          const SizedBox(height: 12),

          // Alasan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alasan:',
                    style: TextStyle(
                        fontSize: 11, color: colorScheme.onSurfaceVariant)),
                Text(alasan, style: TextStyle(color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('Tanggal: $dateRange',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons (Panggil _showValidationDialog)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showValidationDialog(id, false), // Tolak
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showValidationDialog(id, true), // Setujui
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
