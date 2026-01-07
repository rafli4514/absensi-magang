import 'package:flutter/material.dart';

import '../../services/intern_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AdminInternsScreen extends StatefulWidget {
  const AdminInternsScreen({super.key});

  @override
  State<AdminInternsScreen> createState() => _AdminInternsScreenState();
}

class _AdminInternsScreenState extends State<AdminInternsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allInterns = [];
  List<Map<String, dynamic>> _filteredInterns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterns();
  }

  Future<void> _loadInterns() async {
    setState(() => _isLoading = true);
    try {
      final response = await InternService.getAllInterns();
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _allInterns = response.data!;
            _filteredInterns = _allInterns;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          GlobalSnackBar.show(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalSnackBar.show('Gagal memuat data: $e', isError: true);
      }
    }
  }

  void _filterInterns(String query) {
    if (query.isEmpty) {
      setState(() => _filteredInterns = _allInterns);
    } else {
      setState(() {
        _filteredInterns = _allInterns.where((intern) {
          final name = (intern['nama'] ?? '').toString().toLowerCase();
          final instansi = (intern['instansi'] ?? '').toString().toLowerCase();
          final search = query.toLowerCase();
          return name.contains(search) || instansi.contains(search);
        }).toList();
      });
    }
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Peserta',
        content:
            'Yakin ingin menghapus $name? Data yang dihapus tidak dapat dikembalikan.',
        primaryButtonText: 'Hapus',
        primaryButtonColor: AppThemes.errorColor,
        onPrimaryButtonPressed: () async {
          Navigator.pop(context);
          await _deleteIntern(id);
        },
        secondaryButtonText: 'Batal',
      ),
    );
  }

  Future<void> _deleteIntern(String id) async {
    // Tampilkan loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await InternService.deleteIntern(id);

    if (mounted) {
      Navigator.pop(context); // Tutup loading
      if (success) {
        GlobalSnackBar.show('Peserta berhasil dihapus', isSuccess: true);
        _loadInterns(); // Refresh list
      } else {
        GlobalSnackBar.show('Gagal menghapus peserta', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Data Peserta Magang',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              label: 'Cari Peserta',
              hint: 'Nama atau Instansi',
              icon: Icons.search_rounded,
              onChanged: _filterInterns,
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _filteredInterns.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data peserta',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredInterns.length,
                        itemBuilder: (context, index) {
                          final intern = _filteredInterns[index];
                          final id = intern['id']?.toString() ?? '';
                          final name = intern['nama'] ?? 'Tanpa Nama';
                          final instansi = intern['instansi'] ?? '-';
                          final divisi = intern['divisi'] ?? '-';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: colorScheme.surfaceContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppThemes.primaryColor.withOpacity(0.1),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: AppThemes.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.school_rounded,
                                          size: 14,
                                          color: colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          instansi,
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.work_rounded,
                                          size: 14,
                                          color: colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        divisi,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppThemes.errorColor),
                                onPressed: () => _confirmDelete(id, name),
                              ),
                              onTap: () {
                                // Opsional: Buka detail peserta jika ada screen-nya
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
