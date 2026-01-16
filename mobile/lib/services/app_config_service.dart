import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../utils/constants.dart'; // [IMPORT CONSTANTS]

class AppConfigService {
  /// Init Config (Base URL) saat App Start
  static Future<void> init() async {
    final url = await initBaseUrl();
    AppConstants.baseUrl = url;
    debugPrint("🌐 [CONFIG] Base URL set to: $url");
  }
  // =========================================================
  // 🎛️ PENGATURAN MODE PENGEMBANGAN
  // =========================================================
  // Ubah ke [true] jika sedang run di:
  // 1. Chrome / Edge (Web)
  // 2. Android Emulator
  // 3. iOS Simulator
  //
  // Ubah ke [false] jika sedang run di:
  // 1. HP Fisik (Install APK/IPA via kabel USB)
  static const bool _useLocalhost = false;

  /// Fungsi utama untuk mendapatkan Base URL API
  static Future<String> initBaseUrl({bool background = false}) async {
    // Jika background, jangan print terlalu banyak agar log bersih
    if (!background) print("🔍 Menginisialisasi koneksi...");

    // ---------------------------------------------------------
    // 1. CEK KHUSUS WEB BROWSER (PRIORITAS TERTINGGI)
    // ---------------------------------------------------------
    if (kIsWeb) {
      // Browser selalu menganggap 'localhost' adalah komputer host.
      print("🌐 Mode: Web Browser (Localhost)");
      // Pastikan backend (Node.js/Laravel/dll) sudah mengaktifkan CORS!
      return 'http://localhost:3000/api';
    }

    // ---------------------------------------------------------
    // 2. CEK MODE LOCALHOST (EMULATOR / SIMULATOR)
    // ---------------------------------------------------------
    // Kita cek ini SETELAH kIsWeb, karena 'dart:io' (Platform) bisa error di Web.
    if (_useLocalhost) {
      if (Platform.isAndroid) {
        // Android Emulator butuh IP spesial 10.0.2.2 untuk akses localhost laptop
        print("🤖 Mode: Android Emulator");
        return 'http://10.0.2.2:3000/api';
      } else {
        // iOS Simulator atau Desktop App bisa pakai localhost biasa
        print("🍎 Mode: iOS Simulator / Desktop");
        return 'http://localhost:3000/api';
      }
    }

    // ---------------------------------------------------------
    // 3. AUTO DISCOVERY (mDNS) - UNTUK DEVICE FISIK
    // ---------------------------------------------------------
    // Ini berjalan jika _useLocalhost = false.
    // Berguna agar tidak perlu ganti-ganti IP saat pindah WiFi.
    if (!background) print("📡 Mode: Device Fisik - Mencari Server via mDNS...");
    
    // [OPTIMIZATION] Jika background=true (dari Home), kita cari mDNS. 
    // Jika dari AuthGate, kita skip agar cepat.
    
    try {
      final mdnsUrl = await _discoverViaMdns()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (mdnsUrl != null) {
        if (!background) print("✅ Server ditemukan via mDNS: $mdnsUrl");
        return mdnsUrl;
      }
    } catch (e) {
      if (!background) print("⚠️ mDNS Error: $e");
    }

    // ---------------------------------------------------------
    // 4. FALLBACK MANUAL (JIKA SEMUA DI ATAS GAGAL)
    // ---------------------------------------------------------
    // Ganti IP ini sesuai dengan IPv4 Laptop kamu saat ini.
    // Cara cek: 'ipconfig' (Windows) atau 'ifconfig' (Mac/Linux).
    const String fallbackUrl = 'http://10.64.75.71:3000/api';

    print("⚠️ Menggunakan Fallback URL: $fallbackUrl");
    return fallbackUrl;
  }

  // =========================================================
  // 🛠️ FUNGSI BANTUAN mDNS (JANGAN DIUBAH)
  // =========================================================

  static Future<String?> _discoverViaMdns() async {
    MDnsClient? client;
    try {
      client = MDnsClient();
      await client.start();

      // Mencari service _http._tcp (Sesuaikan nama service dengan backend kamu jika beda)
      // Di sini kita mencari service bernama '_myinternplus._tcp.local'
      await for (final ptr in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_myinternplus._tcp.local'),
      )) {
        await for (final srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        )) {
          final ip = await _resolveIp(client, srv.target);
          if (ip != null) {
            return 'http://$ip:${srv.port}/api';
          }
        }
      }
    } catch (_) {
      return null;
    } finally {
      client?.stop();
    }
    return null;
  }

  static Future<String?> _resolveIp(
    MDnsClient client,
    String target,
  ) async {
    await for (final ip in client.lookup<IPAddressResourceRecord>(
      ResourceRecordQuery.addressIPv4(target),
    )) {
      return ip.address.address;
    }
    return null;
  }
}
