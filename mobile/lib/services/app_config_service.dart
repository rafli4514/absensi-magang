import 'package:multicast_dns/multicast_dns.dart';

class AppConfigService {
  static Future<String> initBaseUrl() async {
    // Coba temukan via mDNS dengan timeout
    try {
      final mdnsUrl = await _discoverViaMdns()
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (mdnsUrl != null) return mdnsUrl;
    } catch (e) {
      print("mDNS discovery failed: $e");
    }

    // Fallback URL (Sesuaikan dengan IP Laptop/Server Anda jika mDNS gagal)
    // Gunakan 10.0.2.2 untuk Emulator Android
    return 'http://192.168.1.35:3000/api';
  }

  static Future<String?> _discoverViaMdns() async {
    MDnsClient? client;
    try {
      client = MDnsClient();
      await client.start();

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
