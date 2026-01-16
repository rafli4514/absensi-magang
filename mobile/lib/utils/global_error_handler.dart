import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../navigation/route_names.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_dialog.dart'; // Gunakan CustomDialog
import 'global_context.dart';
import 'ui_utils.dart';

class GlobalErrorHandler {
  static void handle(dynamic error, [BuildContext? context]) {
    final ctx = context ?? GlobalContext.navigatorKey.currentContext;

    if (error is ApiResponse) {
      if (error.statusCode == 401) {
        if (ctx != null) _handleUnauthorized(ctx);
      } else if (error.statusCode == 403) {
        GlobalSnackBar.show(error.message,
            title: 'Akses Ditolak', isError: true);
      } else if (error.statusCode == 404) {
        GlobalSnackBar.show(error.message, isWarning: true);
      } else if (error.statusCode != null && error.statusCode! >= 500) {
        GlobalSnackBar.show('Terjadi kesalahan server (${error.statusCode})',
            title: 'Kesalahan Server', isError: true);
      } else {
        GlobalSnackBar.show(error.message, isError: true);
      }
      return;
    }

    final String errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('socketexception') ||
        errorMsg.contains('connection refused') ||
        errorMsg.contains('network is unreachable')) {
      GlobalSnackBar.show(
        "Tidak ada koneksi internet.",
        title: "Koneksi Bermasalah",
        isError: true,
        icon: Icons.wifi_off_rounded,
      );
    } else if (errorMsg.contains('timeout')) {
      GlobalSnackBar.show("Waktu koneksi habis.",
          title: "Waktu Habis", isWarning: true, icon: Icons.timer_off_rounded);
    } else if (errorMsg.contains('permission')) {
      if (ctx != null) {
        // Ganti AppDialog ke CustomDialog (buat helper atau pakai langsung)
        showDialog(
          context: ctx,
          builder: (context) => CustomDialog(
            title: 'Izin Diperlukan',
            content:
                'Aplikasi memerlukan izin untuk fitur ini. Buka pengaturan?',
            primaryButtonText: 'Buka Pengaturan',
            secondaryButtonText: 'Batal',
            onPrimaryButtonPressed: () {
              Navigator.pop(ctx);
              PermissionService.openAppSettings();
            },
          ),
        );
      }
    } else {
      GlobalSnackBar.show("Error: ${error.toString()}",
          title: "Error", isError: true);
    }
  }

  static void _handleUnauthorized(BuildContext context) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: 'Sesi Berakhir',
        content: 'Sesi login Anda telah berakhir. Silakan login kembali.',
        primaryButtonText: 'Login Ulang',
        onPrimaryButtonPressed: () async {
          final navContext = GlobalContext.navigatorKey.currentContext;
          if (navContext != null) {
            await StorageService.removeTokens(); // Explicit secure removal
            // await Provider.of<AuthProvider>(navContext, listen: false).logout(); // Logout already calls remove but let's be safe
            // To avoid circular dep complexity or partial logout, better to use AuthProvider.logout() if it uses secure storage.
            // Let's stick to calling authProvider.logout() but verify that .logout() uses secure storage.
             await Provider.of<AuthProvider>(navContext, listen: false).logout();
            Navigator.pushNamedAndRemoveUntil(
                navContext, RouteNames.login, (r) => false);
          }
        },
      ),
    );
  }
}
