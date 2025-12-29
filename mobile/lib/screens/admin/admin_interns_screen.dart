import 'package:flutter/material.dart';

import '../../services/intern_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_indicator.dart';

class AdminInternsScreen extends StatefulWidget {
  const AdminInternsScreen({super.key});

  @override
  State<AdminInternsScreen> createState() => _AdminInternsScreenState();
}

class _AdminInternsScreenState extends State<AdminInternsScreen> {
  List<Map<String, dynamic>> _interns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterns();
  }

  Future<void> _loadInterns() async {
    setState(() => _isLoading = true);
    final response = await InternService.getAllInterns();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _interns = response.data!;
          _isLoading = false;
        });
      } else {
        GlobalSnackBar.show(response.message, isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Peserta?',
        content:
            'Anda yakin ingin menghapus data $name? Data yang dihapus tidak bisa dikembalikan.',
        primaryButtonText: 'Hapus',
        primaryButtonColor: AppThemes.errorColor,
        secondaryButtonText: 'Batal',
        onPrimaryButtonPressed: () async {
          Navigator.pop(context); // Tutup dialog konfirmasi

          // Tampilkan loading sederhana
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()));

          final success = await InternService.deleteIntern(id);

          if (context.mounted) {
            Navigator.pop(context); // Tutup dialog loading
            if (success) {
              GlobalSnackBar.show('Peserta berhasil dihapus', isSuccess: true);
              _loadInterns(); // Refresh list
            } else {
              GlobalSnackBar.show('Gagal menghapus peserta', isError: true);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(title: 'Kelola Peserta', showBackButton: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GlobalSnackBar.show('Fitur tambah peserta via Admin segera hadir',
              isInfo: true);
        },
        backgroundColor: AppThemes.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(message: "Memuat Peserta..."))
          : _interns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 48,
                          color: AppThemes.hintColor.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data peserta',
                        style: TextStyle(
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _interns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final intern = _interns[index];
                    return _buildInternCard(intern, isDark);
                  },
                ),
    );
  }

  Widget _buildInternCard(Map<String, dynamic> intern, bool isDark) {
    // Tentukan status color
    final status = intern['status']?.toString().toUpperCase() ?? 'NONAKTIF';
    final isActive = status == 'AKTIF';
    final nama = intern['nama'] ?? 'Tanpa Nama';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppThemes.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
                Text(
                  intern['divisi'] ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isActive
                            ? AppThemes.successColor
                            : AppThemes.errorColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppThemes.successColor
                          : AppThemes.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppThemes.errorColor),
            onPressed: () => _confirmDelete(intern['id'], nama),
          ),
        ],
      ),
    );
  }
}
