/// Platform-aware download service using conditional imports
/// 
/// Usage:
/// ```dart
/// import 'download_service.dart';
/// 
/// await downloadService.downloadFile(
///   url: 'http://api.com/file.pdf',
///   filename: 'report.pdf',
///   headers: {'Authorization': 'Bearer token'},
/// );
/// ```

import 'download_service_stub.dart'
    if (dart.library.html) 'download_service_web.dart'
    if (dart.library.io) 'download_service_mobile.dart';

// Re-export the implementation
export 'download_service_stub.dart'
    if (dart.library.html) 'download_service_web.dart'
    if (dart.library.io) 'download_service_mobile.dart';

/// Singleton accessor for platform-specific download service
final downloadService = getDownloadService();
