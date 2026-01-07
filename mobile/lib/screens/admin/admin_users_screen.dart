import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import '../../services/user_service.dart';
import '../../themes/app_themes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // State untuk Filter
  String _selectedRole = 'SEMUA';

  // Opsi Filter (Sesuai Backend)
  final List<String> _filterOptions = [
    'SEMUA',
    'PESERTA_MAGANG',
    'PEMBIMBING_MAGANG',
    'ADMIN'
  ];

  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Helper untuk Label Tampilan yang Rapi
  String _getFilterLabel(String role) {
    switch (role) {
      case 'SEMUA':
        return 'Semua';
      case 'PESERTA_MAGANG':
        return 'Peserta';
      case 'PEMBIMBING_MAGANG':
        return 'Pembimbing';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    // Jika 'SEMUA', kirim null ke backend agar mengambil semua data
    String? roleQuery;
    if (_selectedRole != 'SEMUA') {
      roleQuery = _selectedRole;
    }

    try {
      final response =
          await UserService.getAllUsers(role: roleQuery, limit: 100);
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _users = response.data!;
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

  Future<void> _navigateToAddUser() async {
    final result = await Navigator.pushNamed(context, RouteNames.addUser);
    if (result == true) {
      _loadUsers(); // Refresh otomatis jika ada user baru
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Manajemen Pengguna',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // --- 1. MODERN FILTER BAR (CHIPS) ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedRole == filter;
                return _buildFilterChip(
                  label: _getFilterLabel(filter),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedRole = filter);
                    _loadUsers();
                  },
                );
              },
            ),
          ),

          // --- 2. USER LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_off_rounded,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada pengguna ditemukan',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 8, 16, 80), // Spasi bawah untuk FAB
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),

      // --- FAB ADD USER ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddUser,
        backgroundColor: AppThemes.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Tambah User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget: Tombol Filter Kapsul
  Widget _buildFilterChip({
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
              ? AppThemes.primaryColor
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppThemes.primaryColor
                : colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemes.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Widget: Kartu User Modern
  Widget _buildUserCard(dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;

    // Extract Data
    final username = user.username ?? 'Unknown';
    final roleRaw = user.role ?? '';
    final isActive = user.isActive ?? false;

    // Tentukan Warna & Ikon Berdasarkan Role
    String roleDisplay = 'User';
    Color roleColor = colorScheme.onSurfaceVariant;
    IconData roleIcon = Icons.person_outline;

    if (roleRaw == 'ADMIN') {
      roleDisplay = 'Administrator';
      roleColor = AppThemes.errorColor; // Merah
      roleIcon = Icons.admin_panel_settings_rounded;
    } else if (roleRaw == 'PEMBIMBING_MAGANG') {
      roleDisplay = 'Pembimbing';
      roleColor = AppThemes.infoColor; // Biru
      roleIcon = Icons.supervisor_account_rounded;
    } else if (roleRaw == 'PESERTA_MAGANG') {
      roleDisplay = 'Peserta Magang';
      roleColor = AppThemes.successColor; // Hijau
      roleIcon = Icons.school_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Buka detail user jika diperlukan
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Ikon dengan Background Warna Role
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(roleIcon, color: roleColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Info User
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            roleDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dot Separator
                          Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: colorScheme.outline,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppThemes.successColor.withOpacity(0.1)
                                  : AppThemes.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Nonaktif',
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
                    ],
                  ),
                ),

                // Panah Kanan (Indikator Klik)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
