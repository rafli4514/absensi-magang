import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart'; // Pastikan import ini yang dipakai
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _generateQR() async {
    setState(() => _isLoading = true);
    try {
      final response = await SettingsService.generateQRCode(type: 'masuk');

      if (response.success && response.data != null) {
        final base64String = response.data!['qrCode'];
        setState(() {
          _qrCodeBytes = base64Decode(base64String);
          _isLoading = false;
        });
        GlobalSnackBar.show('QR Code Masuk berhasil dibuat', isSuccess: true);
      } else {
        GlobalSnackBar.show(response.message, isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      GlobalSnackBar.show('Gagal generate QR: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC: SIMPAN KE GALERI (MENGGUNAKAN GAL) ---
  Future<void> _saveToGallery() async {
    if (_qrCodeBytes == null) return;

    try {
      // Gal otomatis menangani permission dan saving
      await Gal.putImageBytes(
        _qrCodeBytes!,
        name: "QR_Absen_Masuk_${DateTime.now().millisecondsSinceEpoch}",
      );

      GlobalSnackBar.show('QR Code tersimpan di Galeri', isSuccess: true);
    } on GalException catch (e) {
      // Handle jika user menolak izin atau error lain
      if (e.type == GalExceptionType.accessDenied) {
        GlobalSnackBar.show('Izin penyimpanan ditolak', isWarning: true);
      } else {
        GlobalSnackBar.show('Gagal menyimpan: $e', isError: true);
      }
    } catch (e) {
      GlobalSnackBar.show('Error saving: $e', isError: true);
    }
  }

  // --- LOGIC: SHARE KE WA / SALIN ---
  Future<void> _shareQrCode() async {
    if (_qrCodeBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(_qrCodeBytes!);

      // Share file gambar
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code Absen Masuk - Scan Segera!',
      );
    } catch (e) {
      GlobalSnackBar.show('Gagal membagikan gambar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(title: 'QR Code Absen Masuk', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 1. Area QR Code
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
                    'Tekan tombol buat baru',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Tombol Aksi (Hanya muncul jika QR sudah ada)
            if (_qrCodeBytes != null && !_isLoading) ...[
              Row(
                children: [
                  // Tombol Download
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveToGallery,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Simpan'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppThemes.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Share / WA
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareQrCode,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share / WA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // Warna WA
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 3. Tombol Generate Utama
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
}