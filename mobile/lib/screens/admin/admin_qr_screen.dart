import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/settings_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class AdminQrScreen extends StatefulWidget {
  const AdminQrScreen({super.key});

  @override
  State<AdminQrScreen> createState() => _AdminQrScreenState();
}

class _AdminQrScreenState extends State<AdminQrScreen> {
  bool _isLoading = false;
  Uint8List? _qrCodeBytes;
  String _qrType = 'masuk'; // 'masuk' atau 'keluar'

  Future<void> _generateQR() async {
    setState(() => _isLoading = true);
    try {
      final response = await SettingsService.generateQRCode(type: _qrType);

      if (response.success && response.data != null) {
        final base64String = response.data!['qrCode'];
        setState(() {
          _qrCodeBytes = base64Decode(base64String);
          _isLoading = false;
        });
        GlobalSnackBar.show('QR Code berhasil dibuat', isSuccess: true);
      } else {
        GlobalSnackBar.show(response.message, isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      GlobalSnackBar.show('Gagal generate QR: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(title: 'QR Code Generator', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Pilihan Tipe Absensi
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkSurface : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTypeOption('Masuk', 'masuk', isDark),
                  _buildTypeOption('Pulang', 'keluar', isDark),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Area QR Code
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemes.primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppThemes.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: LoadingIndicator(message: 'Membuat QR...'))
                  : _qrCodeBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            _qrCodeBytes!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tekan tombol generate',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 40),

            // 3. Tombol Generate
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateQR,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Buat QR Code Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QR Code ini hanya berlaku selama 5 menit untuk keamanan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppThemes.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, String value, bool isDark) {
    final isSelected = _qrType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _qrType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppThemes.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor),
            ),
          ),
        ),
      ),
    );
  }
}
