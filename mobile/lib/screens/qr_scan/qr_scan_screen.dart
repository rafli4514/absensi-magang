import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../navigation/route_names.dart';
import '../../services/location_service.dart';
import '../../services/permission_service.dart'; // ADD THIS IMPORT
import '../../themes/app_themes.dart';
import '../../utils/indonesian_time.dart';
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
  bool _hasPopped = false;

  // Untuk waktu real-time
  String _currentTime = '';
  late Timer _timer;

  OfficeLocationSettings? _locationSettings;
  Map<String, dynamic>? _currentLocation;
  bool _isLocationLoading = false;
  String _locationStatus = 'Getting location...';

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
    _loadLocationSettings();
  }

  Future<void> _loadLocationSettings() async {
    setState(() {
      _isLocationLoading = true;
    });

    final response = await LocationService.getLocationSettings();

    if (response.success && response.data != null) {
      setState(() {
        _locationSettings = response.data;
        _locationStatus = 'Location ready';
      });
    } else {
      setState(() {
        _locationStatus = 'Location settings not available';
      });
    }

    setState(() {
      _isLocationLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    // ADD PERMISSION CHECK HERE
    final hasPermission = await PermissionService.requestLocationPermission();

    if (!hasPermission) {
      _showPermissionDialog(
        'Location Access Required',
        'Please grant location access to get your current position',
      );
      return;
    }

    setState(() {
      _isLocationLoading = true;
      _locationStatus = 'Getting your location...';
    });

    _currentLocation = await LocationService.getCurrentLocation();

    if (_currentLocation != null) {
      setState(() {
        _locationStatus = 'Location acquired';
      });
    } else {
      setState(() {
        _locationStatus = 'Failed to get location';
      });
    }

    setState(() {
      _isLocationLoading = false;
    });
  }

  bool _isValidClockOutTime() {
    final now = IndonesianTime.now;
    return now.hour >= 17;
  }

  String _formatTime(DateTime time) {
    return IndonesianTime.formatTime(time);
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = IndonesianTime.formatTime(IndonesianTime.now);
    });
  }

  void _showTimeErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Cannot Clock Out Yet',
        content:
            'Clock out is only available after 17:00.\nCurrent time: $_currentTime',
        primaryButtonText: 'OK',
        primaryButtonColor: AppThemes.warningColor,
        onPrimaryButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showLocationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Location Error',
        content: message,
        primaryButtonText: 'OK',
        primaryButtonColor: AppThemes.errorColor,
        onPrimaryButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ADD THIS NEW METHOD FOR PERMISSION DIALOG
  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool> _validateLocation() async {
    if (_locationSettings == null) {
      _showLocationErrorDialog(
        'Location settings not available. Please try again.',
      );
      return false;
    }

    await _getCurrentLocation();
    if (_currentLocation == null) {
      _showLocationErrorDialog(
        'Cannot get your current location. Please enable location services.',
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
        'You are too far from the office.\n'
        'Distance: ${distance.toStringAsFixed(0)} meters\n'
        'Allowed radius: ${_locationSettings!.radius} meters\n'
        'Office: ${_locationSettings!.officeAddress}',
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
    if (!isLocationValid) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final qrValidation = await LocationService.validateQRCode(
        'dummy_qr_data',
      );

      if (!qrValidation.success || !qrValidation.data!.isValid) {
        _showLocationErrorDialog('Invalid QR code. Please try again.');
        setState(() {
          _isProcessing = false;
        });
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
          'time': _currentTime,
          'type': _attendanceType,
          'location': _currentLocation,
          'success': true,
        };

        _safePop(result);
      } else {
        _showLocationErrorDialog(
          attendanceResponse.message ?? 'Failed to record attendance',
        );
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      _showLocationErrorDialog('Network error: ${e.toString()}');
      setState(() {
        _isProcessing = false;
      });
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

  @override
  void initState() {
    super.initState();
    _startScan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Setup timer untuk update waktu setiap detik
    _currentTime = IndonesianTime.formatTime(IndonesianTime.now);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCurrentTime();
      }
    });

    // ADD PERMISSION CHECK ON STARTUP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsOnStart();
    });
  }

  // ADD THIS NEW METHOD
  Future<void> _checkPermissionsOnStart() async {
    final permissions = await PermissionService.checkAllPermissions();

    if (!permissions['location']! && mounted) {
      _showPermissionDialog(
        'Location Permission Required',
        'Location access is required for attendance recording. '
            'Please grant location permission in app settings.',
      );
    }

    if (!permissions['camera']! && mounted) {
      // Camera permission is usually requested by mobile_scanner automatically
      // But we can show a reminder if needed
      _showPermissionDialog(
        'Camera Permission Required',
        'Camera access is required for scanning QR codes.',
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    _timer.cancel(); // Cancel timer
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
          Positioned.fill(child: _buildScannerView()),
          Positioned.fill(child: _buildScannerOverlay(context)),
          Positioned(
            left: 0,
            right: 0,
            bottom: _showBottomNav ? 80 : 20,
            child: _buildFloatingButtons(),
          ),
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
    if (_hasPopped) return;
    _safePop(null);
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
          SizedBox(height: (size.height - scannerSize - 200) / 2),
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
                const SizedBox(height: 8),

                // Display current time
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemes.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppThemes.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time: $_currentTime',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isLocationLoading
                          ? AppThemes.warningColor
                          : _locationSettings != null
                          ? AppThemes.successColor
                          : AppThemes.errorColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLocationLoading
                            ? Icons.location_searching
                            : _locationSettings != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _isLocationLoading
                            ? AppThemes.warningColor
                            : _locationSettings != null
                            ? AppThemes.successColor
                            : AppThemes.errorColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _locationStatus,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    if (_isProcessing || !_isScanning || _hasPopped) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
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
      if (_isProcessing || _hasPopped) return;

      // ADD PERMISSION CHECK HERE
      final hasPermission = await PermissionService.requestGalleryPermission();

      if (!hasPermission) {
        _showPermissionDialog(
          'Gallery Access Required',
          'Please grant gallery access to pick images',
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
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
