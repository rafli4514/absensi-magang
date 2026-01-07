import 'package:multicast_dns/multicast_dns.dart';

class AppConfigService {
  static Future<String> initBaseUrl() async {
    print("🔍 Mencari Server...");

    // 1. Coba mDNS (Auto Discovery) dengan Timeout singkat
    try {
      final mdnsUrl = await _discoverViaMdns()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      if (mdnsUrl != null) {
        print("✅ Server ditemukan via mDNS: $mdnsUrl");
        return 'http://10.0.2.2:3000/api';
      }
    } catch (e) {
      print("⚠️ mDNS Error: $e");
    }

    // 2. FALLBACK MANUAL (JIKA mDNS GAGAL)
    // =========================================================
    // 🔴 GANTI IP DI BAWAH INI SESUAI IP LAPTOP ANDA! 🔴
    // Lihat output terminal backend (npm start) untuk melihat IP yang benar.
    // Contoh: 'http://192.168.1.5:3000/api'
    // =========================================================

    // Ganti '192.168.1.8' dengan IP Laptop kamu saat ini
    const String fallbackUrl = 'http://192.170.100.8:3000/api';

    print("⚠️ Menggunakan Fallback URL: $fallbackUrl");
    return fallbackUrl;
  }

  static Future<String?> _discoverViaMdns() async {
    MDnsClient? client;
    try {
      client = MDnsClient();
      await client.start();

      // Mencari service _http._tcp (Standar mDNS)
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
