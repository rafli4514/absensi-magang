import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/intern_service.dart';
import '../../services/user_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AddUserScreen extends StatefulWidget {
  final dynamic user; // Allow editing existing user (User model)

  const AddUserScreen({super.key, this.user});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isActive = true; // State for Active status

  // Role Selection
  String _selectedRole = 'PESERTA_MAGANG';
  final List<String> _roles = ['PESERTA_MAGANG', 'PEMBIMBING_MAGANG', 'ADMIN'];

  // Controllers Common
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers Peserta Only
  final _namaController = TextEditingController();
  final _idPesertaController = TextEditingController();
  final _divisiController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _mentorController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _isEditing = true;
      _loadUserData(widget.user);
    }
  }

  void _loadUserData(dynamic user) {
    // Determine Role
    String rawRole = (user.role ?? 'peserta_magang').toString().toUpperCase();
    if (_roles.contains(rawRole)) {
      _selectedRole = rawRole;
    }

    _usernameController.text = user.username ?? '';
    // Password ignored during edit init

    // Load Detail based on User fields (which we mapped in User.dart)
    _namaController.text = user.nama ?? '';
    _idPesertaController.text = user.idPesertaMagang ?? '';
    _divisiController.text = user.divisi ?? '';
    _instansiController.text = user.instansi ?? '';
    _nomorHpController.text = user.nomorHp ?? '';
    _mentorController.text = user.namaMentor ?? '';
    _tanggalMulaiController.text = user.tanggalMulai ?? '';
    _tanggalSelesaiController.text = user.tanggalSelesai ?? '';

    // Load Status
    if (user.isActive != null) {
      _isActive = user.isActive;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _idPesertaController.dispose();
    _divisiController.dispose();
    _instansiController.dispose();
    _nomorHpController.dispose();
    _mentorController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = _dateFormat.format(picked);
      });
    }
  }

  // --- ACTIONS --- (New)

  Future<void> _handleToggleStatus() async {
    setState(() => _isLoading = true);
    try {
      // Toggle via API
      final response = await UserService.toggleUserStatus(widget.user.id);
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success) {
            _isActive = !_isActive; // Toggle local state
            GlobalSnackBar.show(
              'User berhasil ${_isActive ? "diaktifkan" : "dinonaktifkan"}',
              isSuccess: true,
            );
          } else {
             GlobalSnackBar.show(response.message, isError: true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalSnackBar.show('Gagal mengubah status: $e', isError: true);
      }
    }
  }

  Future<void> _handleDelete() async {
    // Confirm Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return CustomDialog(
        title: 'Hapus User',
        content: 'Apakah Anda yakin ingin menghapus user ini? Tindakan ini tidak dapat dibatalkan.',
        primaryButtonText: 'Hapus Permanen',
        primaryButtonColor: colorScheme.error,
        onPrimaryButtonPressed: () => Navigator.pop(context, true),
        secondaryButtonText: 'Batal',
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      bool success = false;
      
      // Delete Logic
      if (_selectedRole == 'PESERTA_MAGANG' && widget.user.profileId != null) {
        // Use InternService for cleanup
        success = await InternService.deleteIntern(widget.user.profileId!);
      } else {
        // Use UserService for generic/other roles
        final response = await UserService.deleteUser(widget.user.id);
        success = response.success;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          GlobalSnackBar.show('User berhasil dihapus', isSuccess: true);
          Navigator.pop(context, true); // Close screen & Refresh list
        } else {
          GlobalSnackBar.show('Gagal menghapus user', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalSnackBar.show('Error: $e', isError: true);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = false;
      String? errorMessage;

      if (_isEditing) {
        // --- LOGIC UPDATE ---
        if (_selectedRole == 'PESERTA_MAGANG') {
          // Use InternService.updateIntern
          // Need profileId (PK of PesertaMagang)
          final profileId = widget.user.profileId;
          
          if (profileId == null) {
             throw Exception("ID Profil Peserta tidak ditemukan untuk update");
          }

          final response = await InternService.updateIntern(
            id: profileId,
            nama: _namaController.text.trim(),
            username: _usernameController.text.trim(),
            divisi: _divisiController.text.trim(),
            instansi: _instansiController.text.trim(),
            nomorHp: _nomorHpController.text.trim(),
            tanggalMulai: _tanggalMulaiController.text.trim(),
            tanggalSelesai: _tanggalSelesaiController.text.trim(),
            idPesertaMagang: _idPesertaController.text.trim(),
            namaMentor: _mentorController.text.trim(),
          );
           // Also update password if provided? InternService update doesn't support password yet.
           // Ignore password for now or warn user.
           success = response.success;
           errorMessage = response.message;

        } else {
           // Use UserService.updateUser
           final response = await UserService.updateUser(
             id: widget.user.id,
             username: _usernameController.text.trim(),
             role: _selectedRole,
             password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
           );
           success = response.success;
           errorMessage = response.message;
        }

      } else {
        // --- LOGIC CREATE (Existing) ---
        if (_selectedRole == 'PESERTA_MAGANG') {
          // Gunakan InternService (Full Profile)
          final response = await InternService.createIntern(
            nama: _namaController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            divisi: _divisiController.text.trim(),
            instansi: _instansiController.text.trim(),
            nomorHp: _nomorHpController.text.trim(),
            tanggalMulai: _tanggalMulaiController.text.trim(),
            tanggalSelesai: _tanggalSelesaiController.text.trim(),
            idPesertaMagang: _idPesertaController.text.trim(),
            namaMentor: _mentorController.text.trim(),
          );
          success = response.success;
          errorMessage = response.message;
        } else {
          // Gunakan UserService (Basic User)
          final response = await UserService.createUser(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
            isActive: true,
          );
          success = response.success;
          errorMessage = response.message;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          GlobalSnackBar.show(_isEditing ? 'Data berhasil diperbarui' : 'User berhasil ditambahkan', isSuccess: true);
          Navigator.pop(context, true); // Return true to refresh list
        } else {
          GlobalSnackBar.show(errorMessage ?? 'Gagal menyimpan data',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalSnackBar.show('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Theme setup same)
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final isPeserta = _selectedRole == 'PESERTA_MAGANG';

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Pengguna' : 'Tambah Pengguna', 
        showBackButton: true
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STATUS BAR (Editing Only)
              if (_isEditing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _isActive 
                        ? colors.success.withOpacity(0.1) 
                        : colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isActive 
                          ? colors.success
                          : colorScheme.error,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isActive ? Icons.check_circle : Icons.cancel,
                        color: _isActive ? colors.success : colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isActive ? 'Status: AKTIF' : 'Status: NONAKTIF',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isActive ? colors.success : colorScheme.error,
                              ),
                            ),
                            Text(
                              _isActive 
                                  ? 'User dapat login dan akses aplikasi'
                                  : 'Akses user dibekukan sementara',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        activeColor: colors.success,
                        onChanged: (val) => _handleToggleStatus(),
                      ),
                    ],
                  ),
                ),
              ],

              // Role Dropdown
              _buildSectionTitle('Peran Pengguna'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: _roles.map((role) {
                      String label = role.replaceAll('_', ' ');
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          label,
                          style: TextStyle(
                              fontSize: 14, color: colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Akun'),
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Masukkan username',
                icon: Icons.person_outline,
                validator: Validators.validateUsername,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: _isEditing ? 'Isi untuk ubah password' : 'Masukkan password', // Hint changed logic
                icon: Icons.lock_outline,
                isPassword: true,
                validator: _isEditing ? null : Validators.validatePassword, // Optional if editing
              ),

              if (isPeserta) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Biodata Peserta'),
                CustomTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Nama sesuai KTP',
                  icon: Icons.badge_outlined,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _idPesertaController,
                  label: 'NIM / NISN',
                  hint: 'Nomor Induk',
                  icon: Icons.numbers,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _instansiController,
                  label: 'Instansi / Kampus',
                  hint: 'Asal Sekolah/Kampus',
                  icon: Icons.school_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _divisiController,
                  label: 'Divisi',
                  hint: 'Divisi penempatan',
                  icon: Icons.work_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nomorHpController,
                  label: 'Nomor HP',
                  hint: '08xxxxxxxxxx',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhoneNumber,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _mentorController,
                  label: 'Nama Mentor',
                  hint: 'Nama Pembimbing',
                  icon: Icons.supervisor_account,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _tanggalMulaiController,
                        label: 'Mulai',
                        hint: 'Tgl Mulai',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(_tanggalMulaiController),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _tanggalSelesaiController,
                        label: 'Selesai',
                        hint: 'Tgl Selesai',
                        icon: Icons.event_busy,
                        readOnly: true,
                        onTap: () => _selectDate(_tanggalSelesaiController),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              
              // MAIN SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan User'), // Updated Label
                      ),
              ),

              // DELETE BUTTON (Editing Only)
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hapus User'),
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
