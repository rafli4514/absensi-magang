import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../navigation/route_names.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'global_context.dart';
import 'ui_utils.dart';

class GlobalErrorHandler {
  static void handle(dynamic error, [BuildContext? context]) {
    final ctx = context ?? GlobalContext.navigatorKey.currentContext;

    // 1. Handle ApiResponse Error (dari Backend)
    if (error is ApiResponse) {
      if (error.statusCode == 401) {
        if (ctx != null) _handleUnauthorized(ctx);
      } else if (error.statusCode == 403) {
        // Access Denied usually needs a Dialog, but we can stick to SnackBar for consistency if preferred
        GlobalSnackBar.show(error.message,
            title: 'Akses Ditolak', isError: true);
      } else if (error.statusCode == 404) {
        GlobalSnackBar.show(error.message, isWarning: true);
      } else if (error.statusCode != null && error.statusCode! >= 500) {
        GlobalSnackBar.show('Terjadi kesalahan server (${error.statusCode})',
            title: 'Server Error', isError: true);
      } else {
        GlobalSnackBar.show(error.message, isError: true);
      }
      return;
    }

    // 2. Handle Network/System Errors
    final String errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('socketexception') ||
        errorMsg.contains('connection refused') ||
        errorMsg.contains('network is unreachable')) {
      // REPLACED AppToast with GlobalSnackBar
      GlobalSnackBar.show(
        "Tidak ada koneksi internet. Periksa jaringan Anda.",
        title: "Koneksi Bermasalah",
        isError: true,
        icon: Icons.wifi_off_rounded,
      );
    } else if (errorMsg.contains('timeout')) {
      GlobalSnackBar.show("Waktu koneksi habis. Silakan coba lagi.",
          title: "Timeout", isWarning: true, icon: Icons.timer_off_rounded);
    } else if (errorMsg.contains('permission')) {
      // Permissions usually need an actionable dialog
      if (ctx != null) {
        AppDialog.show(
          ctx,
          title: 'Izin Diperlukan',
          content: 'Aplikasi memerlukan izin untuk fitur ini. Buka pengaturan?',
          primaryText: 'Buka Pengaturan',
          secondaryText: 'Batal',
          onPrimary: () {
            Navigator.pop(ctx);
            PermissionService.openAppSettings();
          },
        );
      }
    } else {
      // Catch-all generic errors
      GlobalSnackBar.show(
        "Terjadi kesalahan: ${error.toString()}",
        title: "Error",
        isError: true,
      );
    }
  }

  static void _handleUnauthorized(BuildContext context) async {
    final token = await StorageService.getString(AppConstants.tokenKey);

    if (token == null || token.isEmpty) return;

    // Use Dialog for Session Expiry as it forces user action
    AppDialog.show(
      null,
      title: 'Sesi Berakhir',
      content: 'Sesi login Anda telah berakhir. Silakan login kembali.',
      primaryText: 'Login Ulang',
      isError: true,
      dismissible: false,
      onPrimary: () async {
        final navContext = GlobalContext.navigatorKey.currentContext;
        if (navContext != null) {
          await Provider.of<AuthProvider>(navContext, listen: false).logout();
          Navigator.pushNamedAndRemoveUntil(
              navContext, RouteNames.login, (r) => false);
        }
      },
    );
  }
}
