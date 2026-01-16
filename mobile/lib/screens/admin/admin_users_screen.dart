import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import 'add_user_screen.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = theme.extension<AppColors>()!;

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
        backgroundColor: colorScheme.primary,
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
              ? colorScheme.primary
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
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
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Method: Tampilkan Detail User BottomSheet
  void _showUserDetails(dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final colors = Theme.of(context).extension<AppColors>()!;
        final u = user;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. DRAG HANDLE
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 2. HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      backgroundImage: (u.avatar != null && u.avatar!.isNotEmpty)
                          ? NetworkImage(u.avatar!)
                          : null,
                      child: (u.avatar == null || u.avatar!.isEmpty)
                          ? Text(
                              (u.nama ?? u.username).isNotEmpty
                                  ? (u.nama ?? u.username)[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.nama ?? u.username,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            u.username,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Info Detail Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Role', u.displayRole, Icons.badge_rounded),
                    if (u.divisi != null && u.divisi!.isNotEmpty)
                      _buildDetailRow('Divisi', u.divisi!, Icons.work_rounded),
                    if (u.instansi != null && u.instansi!.isNotEmpty)
                      _buildDetailRow('Instansi', u.instansi!, Icons.school_rounded),
                    _buildDetailRow(
                      'Status',
                      (u.isActive ?? false) ? 'Aktif' : 'Nonaktif',
                      Icons.traffic_rounded,
                      valueColor: (u.isActive ?? false)
                          ? colors.success
                          : colorScheme.error,
                    ),
                    if (u.nomorHp != null && u.nomorHp!.isNotEmpty)
                      _buildDetailRow('Kontak', u.nomorHp!, Icons.phone_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. ACTION BUTTONS (Edit & Close)
              Row(
                children: [
                   Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                         Navigator.pop(context); // Close sheet
                         final result = await Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => AddUserScreen(user: u), // Pass user to edit
                           ),
                         );
                         if (result == true) {
                           _loadUsers(); // Refresh list if updated
                         }
                      },
                      icon: Icon(Icons.edit_rounded, color: colorScheme.onPrimary),
                      label: const Text('Edit User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        foregroundColor: colorScheme.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Kartu User Modern
  Widget _buildUserCard(dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;

    // Extract Data
    final username = user.username ?? 'Unknown';
    final roleRaw = user.role ?? '';
    final isActive = user.isActive ?? false;

    // Tentukan Warna & Ikon Berdasarkan Role
    String roleDisplay = 'User';
    Color roleColor = colorScheme.onSurfaceVariant;
    IconData roleIcon = Icons.person_outline;

    if (user.isAdmin) {
      roleDisplay = 'Administrator';
      roleColor = colorScheme.error; // Merah
      roleIcon = Icons.admin_panel_settings_rounded;
    } else if (user.isPembimbing) {
      roleDisplay = 'Pembimbing';
      roleColor = AppThemes.infoColor; // Biru
      roleIcon = Icons.supervisor_account_rounded;
    } else if (user.isStudent) {
      roleDisplay = 'Peserta Magang';
      roleColor = colors.success; // Hijau
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
          onTap: () => _showUserDetails(user), // Call detail here
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
                        user.nama ?? username, // Use nama if available
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
                                  ? colors.success.withOpacity(0.1)
                                  : colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? colors.success
                                    : colorScheme.error,
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
