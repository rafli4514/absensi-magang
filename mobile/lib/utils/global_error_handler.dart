import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../navigation/route_names.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart'; // Import StorageService
import '../utils/constants.dart'; // Import Constants
import 'global_context.dart';
import 'ui_utils.dart';

class GlobalErrorHandler {
  static void handle(dynamic error, [BuildContext? context]) {
    final ctx = context ?? GlobalContext.navigatorKey.currentContext;
    if (ctx == null) return;

    // 1. Handle ApiResponse Error (dari Backend)
    if (error is ApiResponse) {
      if (error.statusCode == 401) {
        _handleUnauthorized(ctx);
      } else if (error.statusCode == 403) {
        AppDialog.show(
          // Pass null jika ctx adalah global context untuk memicu logika aman di AppDialog
          context == null ? null : ctx,
          title: 'Akses Ditolak',
          content: error.message,
          isError: true,
        );
      } else if (error.statusCode == 404) {
        GlobalSnackBar.show(error.message, isWarning: true);
      } else if (error.statusCode != null && error.statusCode! >= 500) {
        GlobalSnackBar.show('Terjadi kesalahan server (${error.statusCode})',
            isError: true);
      } else {
        // Default API Error
        GlobalSnackBar.show(error.message, isError: true);
      }
      return;
    }

    // 2. Handle Network/System Errors
    final String errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('socketexception') ||
        errorMsg.contains('connection refused')) {
      AppToast.show("Tidak ada koneksi internet");
    } else if (errorMsg.contains('timeout')) {
      GlobalSnackBar.show("Koneksi waktu habis. Silakan coba lagi.",
          isWarning: true);
    } else if (errorMsg.contains('permission')) {
      AppDialog.show(
        context == null ? null : ctx,
        title: 'Izin Diperlukan',
        content: 'Aplikasi memerlukan izin untuk fitur ini. Buka pengaturan?',
        primaryText: 'Buka Pengaturan',
        secondaryText: 'Batal',
        onPrimary: () {
          Navigator.pop(ctx);
          PermissionService.openAppSettings();
        },
      );
    } else {
      GlobalSnackBar.show("Terjadi kesalahan yang tidak diketahui",
          isError: true);
    }
  }

  static void _handleUnauthorized(BuildContext context) async {
    // CEK TOKEN DULU: Jangan tampilkan "Sesi Berakhir" jika user memang belum login
    // Ini mencegah popup muncul saat "Invalid Credentials" di halaman Login
    final token = await StorageService.getString(AppConstants.tokenKey);

    if (token == null || token.isEmpty) {
      // Jika tidak ada token, berarti ini error login biasa (salah pass),
      // biarkan LoginScreen yang menanganinya via GlobalSnackBar.
      return;
    }

    AppDialog.show(
      // Gunakan null agar AppDialog menggunakan push route yang aman
      null,
      title: 'Sesi Berakhir',
      content: 'Sesi login Anda telah berakhir. Silakan login kembali.',
      primaryText: 'Login Ulang',
      isError: true,
      dismissible: false,
      onPrimary: () async {
        // Logout & Navigate
        // Kita butuh context untuk Provider, gunakan global navigator context
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
