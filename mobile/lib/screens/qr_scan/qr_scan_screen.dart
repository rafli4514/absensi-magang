import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  bool _showBottomNav = false;
  String _attendanceType = '';
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;
  bool _hasPopped = false; // ✅ TAMBAH FLAG INI

  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _attendanceType = args?['type'] ?? '';
  }

  bool _isValidClockOutTime() {
    final now = DateTime.now();
    return now.hour >= 17;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showTimeErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Cannot Clock Out Yet',
        content:
            'Clock out is only available after 17:00.\nCurrent time: ${_formatTime(DateTime.now())}',
        primaryButtonText: 'OK',
        primaryButtonColor: AppThemes.warningColor,
        onPrimaryButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _submitAttendance() {
    if (_isProcessing || _hasPopped) return; // ✅ CEK FLAG

    // Validasi tambahan untuk clock out
    if (_attendanceType == 'CLOCK_OUT' && !_isValidClockOutTime()) {
      _showTimeErrorDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Processing dengan navigation yang aman
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || _hasPopped) return; // ✅ CEK LAGI

      final result = {
        'time': _formatTime(DateTime.now()),
        'type': _attendanceType,
      };

      // ✅ NAVIGATION YANG AMAN
      _safePop(result);
    });
  }

  // ✅ METHOD BARU UNTUK SAFE NAVIGATION
  void _safePop(dynamic result) {
    if (_hasPopped || !mounted) return;

    _hasPopped = true; // SET FLAG SEBELUM POP

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    } else {
      // Fallback jika tidak bisa pop
      Navigator.of(
        context,
      ).pushReplacementNamed(RouteNames.home, arguments: result);
    }
  }

  @override
  void initState() {
    super.initState();
    _startScan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: _showBottomNav
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _handleBackButton,
              ),
            ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Scanner Background - Full Screen
          Positioned.fill(child: _buildScannerView()),

          // Overlay UI - Full Screen
          Positioned.fill(child: _buildScannerOverlay(context)),

          // Floating Action Buttons - Positioned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: _showBottomNav ? 80 : 20,
            child: _buildFloatingButtons(),
          ),

          // Floating Bottom Nav - Conditional visibility
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

  void _handleBackButton() {
    if (_hasPopped) return; // ✅ CEK FLAG
    _safePop(null); // ✅ GUNAKAN SAFE POP
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
    final scannerSize = size.width * 0.75;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          // Top Spacer
          SizedBox(height: (size.height - scannerSize - 200) / 2),

          // Scanner Frame
          Container(
            width: scannerSize,
            height: scannerSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppThemes.primaryColor.withOpacity(0.8),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                // Animated scanning line
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * scannerSize,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppThemes.primaryColor.withOpacity(0.1),
                              AppThemes.primaryColor,
                              AppThemes.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemes.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
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

          // Instructions
          Container(
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'Scan QR Code',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isProcessing
                      ? 'Processing attendance...'
                      : 'Position the QR code within the frame',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Status Indicator
          if (_isProcessing)
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppThemes.successColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppThemes.successColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Recording Attendance...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash Button
          _buildFloatingButton(
            icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            label: _isFlashOn ? 'Flash On' : 'Flash Off',
            color: _isFlashOn ? AppThemes.warningColor : AppThemes.primaryColor,
            onPressed: _isProcessing ? () {} : _toggleFlash,
          ),

          // Scan Button
          _buildFloatingButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            color: AppThemes.primaryColor,
            onPressed: _isProcessing ? () {} : _startScan,
            isLarge: true,
          ),

          // Gallery Button
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
    final bool isDisabled = onPressed == () {};

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

  void _handleBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing || !_isScanning || _hasPopped) return; // ✅ CEK FLAG

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        // AUTO-SUBMIT
        _submitAttendance();
      }
    }
  }

  void _startScan() {
    if (_isScanning || _isProcessing) return;

    setState(() {
      _isScanning = true;
    });

    cameraController.start().catchError((error) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _toggleFlash() {
    if (_isProcessing) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    cameraController.toggleTorch();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (_isProcessing || _hasPopped) return; // ✅ CEK FLAG

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        // AUTO-SUBMIT untuk gallery
        _submitAttendance();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to pick image from gallery');
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
}
