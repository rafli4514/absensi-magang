// lib/screens/qr_scan/qr_scan_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../navigation/route_names.dart';
import '../../services/location_service.dart';
import '../../services/permission_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/indonesian_time.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';

// --- WIDGET JAM DIGITAL TERISOLASI ---
class DigitalClockWidget extends StatefulWidget {
  final TextStyle? style;
  const DigitalClockWidget({super.key, this.style});

  @override
  State<DigitalClockWidget> createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalClockWidget> {
  late Timer _timer;
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    _timeString = IndonesianTime.formatTime(IndonesianTime.now);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _timeString = IndonesianTime.formatTime(IndonesianTime.now);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: widget.style ??
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
// -------------------------------------------

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  bool _showBottomNav = false;
  String _attendanceType = '';
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;
  bool _hasPopped = false;

  OfficeLocationSettings? _locationSettings;
  Map<String, dynamic>? _currentLocation;
  bool _isLocationLoading = false;
  String _locationStatus = 'Mencari lokasi...';

  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _startScan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsOnStart();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _checkPermissionsOnStart().then((_) {
        if (!_isProcessing && !_hasPopped && mounted) {
          _startScan();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _attendanceType = args?['type'] ?? '';
    _loadLocationSettings();
  }

  Future<void> _loadLocationSettings() async {
    if (!mounted) return;
    setState(() => _isLocationLoading = true);

    final response = await LocationService.getLocationSettings();

    if (!mounted) return;
    if (response.success && response.data != null) {
      setState(() {
        _locationSettings = response.data;
        _locationStatus = 'Lokasi Siap';
      });
    } else {
      setState(() {
        _locationStatus = 'Gagal memuat setting lokasi';
      });
    }

    if (mounted) setState(() => _isLocationLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await PermissionService.requestLocationPermission();

    if (!hasPermission) {
      _showPermissionDialog(
        'Izin Lokasi Diperlukan',
        'Harap berikan akses lokasi untuk melakukan presensi.',
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLocationLoading = true;
      _locationStatus = 'Mendeteksi lokasi...';
    });

    _currentLocation = await LocationService.getCurrentLocation();

    if (!mounted) return;
    if (_currentLocation != null) {
      setState(() => _locationStatus = 'Lokasi Terdeteksi');
    } else {
      setState(() => _locationStatus = 'Gagal mendeteksi lokasi');
    }

    if (mounted) setState(() => _isLocationLoading = false);
  }

  // --- LOGIC HELPER ---

  bool _isValidClockOutTime() {
    final now = IndonesianTime.now;
    return now.hour >= 17;
  }

  void _showTimeErrorDialog() {
    final currentTime = IndonesianTime.formatTime(IndonesianTime.now);
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Belum Waktunya Pulang',
        content:
            'Absen pulang hanya tersedia setelah jam 17:00.\nWaktu sekarang: $currentTime',
        primaryButtonText: 'OK',
        primaryButtonColor: AppThemes.warningColor,
        onPrimaryButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showLocationErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: 'Gagal Presensi',
        content: message,
        primaryButtonText: 'Coba Lagi',
        primaryButtonColor: AppThemes.errorColor,
        onPrimaryButtonPressed: () {
          Navigator.pop(context);
          _startScan();
        },
        secondaryButtonText: 'Kembali',
        onSecondaryButtonPressed: () {
          Navigator.pop(context);
          _handleBackButton();
        },
      ),
    );
  }

  void _showPermissionDialog(String title, String message) {
    cameraController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        // Gunakan CustomDialog
        title: title,
        content: message,
        primaryButtonText: 'Buka Pengaturan',
        primaryButtonColor: AppThemes.primaryColor,
        onPrimaryButtonPressed: () async {
          Navigator.pop(context);
          await PermissionService.openAppSettings();
        },
        secondaryButtonText: 'Batal',
        onSecondaryButtonPressed: () {
          Navigator.pop(context);
          _startScan();
        },
      ),
    );
  }

  Future<bool> _validateLocation() async {
    if (_locationSettings == null) {
      _showLocationErrorDialog(
        'Pengaturan lokasi kantor tidak ditemukan. Silakan coba lagi.',
      );
      return false;
    }

    await _getCurrentLocation();
    if (_currentLocation == null) {
      _showLocationErrorDialog(
        'Tidak dapat mendeteksi lokasi Anda. Pastikan GPS aktif.',
      );
      return false;
    }

    final isWithinRadius = await LocationService.isWithinOfficeRadius(
      _locationSettings!,
    );
    if (!isWithinRadius) {
      final distance = LocationService.calculateDistance(
        _currentLocation!['latitude'],
        _currentLocation!['longitude'],
        _locationSettings!.latitude,
        _locationSettings!.longitude,
      );

      _showLocationErrorDialog(
        'Anda berada di luar jangkauan kantor.\n'
        'Jarak: ${distance.toStringAsFixed(0)} meter\n'
        'Radius diizinkan: ${_locationSettings!.radius} meter',
      );
      return false;
    }
    return true;
  }

  void _submitAttendance() async {
    if (_isProcessing || _hasPopped) return;

    if (_attendanceType == 'CLOCK_OUT' && !_isValidClockOutTime()) {
      _showTimeErrorDialog();
      return;
    }

    final isLocationValid = await _validateLocation();
    if (!isLocationValid) return;

    setState(() => _isProcessing = true);

    try {
      final qrValidation = await LocationService.validateQRCode(
        'dummy_qr_data',
      );

      if (!qrValidation.success || !qrValidation.data!.isValid) {
        _showLocationErrorDialog('Kode QR tidak valid atau kadaluwarsa.');
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final attendanceResponse = await LocationService.submitAttendance(
        type: _attendanceType,
        sessionId: qrValidation.data!.sessionId,
        latitude: _currentLocation!['latitude'],
        longitude: _currentLocation!['longitude'],
        locationAddress: _currentLocation!['address'],
      );

      if (attendanceResponse.success) {
        final result = {
          'time': IndonesianTime.formatTime(IndonesianTime.now),
          'type': _attendanceType,
          'location': _currentLocation,
          'success': true,
        };
        _safePop(result);
      } else {
        _showLocationErrorDialog(
          attendanceResponse.message ?? 'Gagal mencatat presensi',
        );
        if (mounted) setState(() => _isProcessing = false);
      }
    } catch (e) {
      _showLocationErrorDialog('Terjadi kesalahan jaringan: ${e.toString()}');
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _safePop(dynamic result) {
    if (_hasPopped || !mounted) return;
    _hasPopped = true;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    } else {
      Navigator.of(
        context,
      ).pushReplacementNamed(RouteNames.home, arguments: result);
    }
  }

  Future<void> _checkPermissionsOnStart() async {
    final permissions = await PermissionService.checkAllPermissions();
    if (!permissions['location']! && mounted) {
      _showPermissionDialog(
        'Izin Lokasi Diperlukan',
        'Aplikasi membutuhkan akses lokasi untuk validasi presensi.',
      );
    }
  }

  // --- CAMERA CONTROLS ---

  void _startScan() {
    if (_isScanning || _isProcessing) return;
    setState(() => _isScanning = true);

    try {
      cameraController.start().catchError((error) {
        if (mounted) setState(() => _isScanning = false);
      });
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _toggleFlash() {
    if (_isProcessing) return;
    setState(() => _isFlashOn = !_isFlashOn);
    cameraController.toggleTorch();
  }

  void _handleBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing || _hasPopped) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });
        cameraController.stop();
        _submitAttendance();
      }
    }
  }

  void _handleBackButton() {
    if (_hasPopped) return;
    _safePop(null);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (_isProcessing || _hasPopped) return;

      cameraController.stop();

      final hasPermission = await PermissionService.requestGalleryPermission();

      if (!hasPermission) {
        _showPermissionDialog(
          'Izin Galeri Diperlukan',
          'Berikan akses galeri untuk memilih kode QR.',
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        _startScan();
      } else {
        _submitAttendance();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal mengambil gambar dari galeri');
        _startScan();
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Error',
        content: message,
        primaryButtonText: 'OK',
        primaryButtonColor: AppThemes.errorColor,
        onPrimaryButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _showBottomNav
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: _handleBackButton,
              ),
            ),
      body: Stack(
        children: [
          // 1. Camera Layer
          Positioned.fill(child: _buildScannerView()),

          // 2. Overlay Layer (Info Badges di Atas + Scanner Box)
          Positioned.fill(child: _buildScannerOverlay(context)),

          // 3. Bottom Controls Layer (KEMBALI KE 3 TOMBOL)
          Positioned(
            left: 0,
            right: 0,
            bottom: _showBottomNav ? 90 : 30,
            child: _buildFloatingButtons(),
          ),

          // 4. Bottom Nav (Optional)
          if (_showBottomNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBottomNav(
                currentRoute: RouteNames.qrScan,
                onQRScanTap: () {
                  setState(() {
                    _showBottomNav = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return MobileScanner(
      controller: cameraController,
      onDetect: _handleBarcodeDetected,
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final scannerSize = size.width * 0.70;

    return Stack(
      children: [
        // --- INFO SECTION (TOP) - Layout Baru ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Row untuk Time (Kanan Atas)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildInfoBadge(
                      icon: Icons.access_time_rounded,
                      color: AppThemes.primaryColor,
                      child: DigitalClockWidget(
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Location Status (Tengah Atas)
                _buildInfoBadge(
                  icon: _isLocationLoading
                      ? Icons.location_searching_rounded
                      : _locationSettings != null
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                  color: _isLocationLoading
                      ? AppThemes.warningColor
                      : _locationSettings != null
                          ? AppThemes.successColor
                          : AppThemes.errorColor,
                  child: Text(
                    _locationStatus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- CENTER SCANNER ---
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scanner Box
              Container(
                width: scannerSize,
                height: scannerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppThemes.primaryColor.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: _animationController.value * scannerSize,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppThemes.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppThemes.primaryColor,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Instructions
              Text(
                'Scan QR Code Presensi',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isProcessing
                    ? 'Memproses data...'
                    : 'Posisikan kode QR di dalam bingkai',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // --- LOADING OVERLAY ---
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mencatat Kehadiran...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Widget Helper untuk Badge Informasi
  Widget _buildInfoBadge({
    required IconData icon,
    required Widget child,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }

  // --- TOMBOL BAWAH: KEMBALI KE 3 TOMBOL (Flash - Scan - Gallery) ---
  Widget _buildFloatingButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingButton(
            icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            label: _isFlashOn ? 'Flash On' : 'Flash Off',
            color: _isFlashOn ? AppThemes.warningColor : AppThemes.primaryColor,
            onPressed: _isProcessing ? () {} : _toggleFlash,
          ),
          _buildFloatingButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            color: AppThemes.primaryColor,
            onPressed: _isProcessing ? () {} : _startScan,
            isLarge: true,
          ),
          _buildFloatingButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            color: AppThemes.infoColor,
            onPressed: _isProcessing ? () {} : _pickImageFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    final bool isDisabled = _isProcessing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLarge ? 70 : 60,
          height: isLarge ? 70 : 60,
          decoration: BoxDecoration(
            color: isDisabled ? color.withOpacity(0.1) : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isDisabled ? color.withOpacity(0.3) : color,
              width: 2,
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
              child: Icon(
                icon,
                color: isDisabled ? color.withOpacity(0.4) : color,
                size: isLarge ? 28 : 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.white.withOpacity(0.5) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
