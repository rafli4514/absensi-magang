import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/intern_service.dart';
import '../../services/user_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = false;
      String? errorMessage;

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

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          GlobalSnackBar.show('User berhasil ditambahkan', isSuccess: true);
          Navigator.pop(context, true); // Return true to refresh list
        } else {
          GlobalSnackBar.show(errorMessage ?? 'Gagal menambahkan user',
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
    final colorScheme = Theme.of(context).colorScheme;
    final isPeserta = _selectedRole == 'PESERTA_MAGANG';

    return Scaffold(
      appBar: CustomAppBar(title: 'Tambah Pengguna', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                hint: 'Masukkan password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.validatePassword,
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Simpan User'),
                      ),
              ),
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
