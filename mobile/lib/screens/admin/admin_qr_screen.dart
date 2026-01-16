import 'dart:async';
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
  // State Variables
  Uint8List? _qrImageBytes;
  DateTime? _expiresAt;
  bool _isLoading = false;
  String? _errorMessage;

  // Timer untuk hitung mundur
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  String _timeLeftString = "00:00";

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- LOGIC: FETCH QR (KHUSUS MASUK) ---
  Future<void> _fetchQrCode() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Hardcode tipe ke 'masuk' sesuai permintaan
      final response = await SettingsService.generateQRCode(type: 'masuk');

      if (mounted) {
        if (response.success && response.data != null) {
          final data = response.data!;

          // 1. Decode Base64 Image dari Backend
          final base64String = data['qrCode'] as String;
          final imageBytes = base64Decode(base64String);

          // 2. Parse Expiry Time
          final expiresAtStr = data['expiresAt'] as String;
          final expiresAt = DateTime.parse(expiresAtStr);

          setState(() {
            _qrImageBytes = imageBytes;
            _expiresAt = expiresAt;
            _isLoading = false;
          });

          // 3. Setup Auto Refresh & Countdown
          _setupTimers(expiresAt);
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
          });
          GlobalSnackBar.show(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal terhubung ke server: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _setupTimers(DateTime expiresAt) {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();

    // Timer Countdown UI (Update setiap detik)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now();
      final difference = expiresAt.difference(now);

      if (difference.isNegative) {
        setState(() => _timeLeftString = "Kadaluarsa");
        timer.cancel();
        // Trigger auto refresh jika kadaluarsa
        _fetchQrCode();
      } else {
        final minutes = difference.inMinutes.toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
        setState(() => _timeLeftString = "$minutes:$seconds");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'QR Code Absensi',
        showBackButton: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. QR CODE DISPLAY CARD ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background Card Putih
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // QR selalu di atas putih agar kontras
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header QR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login_rounded, // Icon Masuk
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SCAN ABSEN MASUK',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Area Gambar QR
                        SizedBox(
                          height: 240,
                          width: 240,
                          child: _isLoading
                              ? const Center(child: LoadingIndicator())
                              : _errorMessage != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: Colors.grey, size: 40),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Gagal memuat QR',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: _fetchQrCode,
                                            child: const Text('Coba Lagi'),
                                          )
                                        ],
                                      ),
                                    )
                                  : _qrImageBytes != null
                                      ? Image.memory(
                                          _qrImageBytes!,
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                        )
                                      : const SizedBox(),
                        ),

                        const SizedBox(height: 24),

                        // Footer (Valid Until)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Valid: $_timeLeftString',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- 2. INSTRUKSI ---
              Text(
                'Tunjukkan QR ini kepada peserta magang.\nKode akan diperbarui otomatis setiap 5 menit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // --- 3. TOMBOL REFRESH MANUAL ---
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchQrCode,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh_rounded),
                  label: Text(_isLoading ? 'Memuat...' : 'Perbarui Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: colorScheme.primary.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
