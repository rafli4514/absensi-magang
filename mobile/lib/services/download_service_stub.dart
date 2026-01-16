/// Stub implementation - should not be called
/// This file exists for platforms that don't support conditional imports
class DownloadService {
  Future<void> downloadFile({
    required String url,
    required String filename,
    Map<String, String>? headers,
  }) async {
    throw UnsupportedError(
      'Download not supported on this platform. Use conditional imports.',
    );
  }
}

DownloadService getDownloadService() => DownloadService();
