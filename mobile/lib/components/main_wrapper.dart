import 'package:flutter/material.dart';
import '../pages/dashboard.dart';
import '../pages/riwayat_absensi.dart';
import '../pages/laporan_absensi.dart';
import '../pages/profil.dart';
import '../pages/scan_qr_simple.dart';
import 'bottom_navigation.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap tab
  final List<Widget> _pages = [
    const DashboardPage(),        // Beranda
    const RiwayatAbsensiPage(),   // Riwayat
    const ScanQRSimplePage(),     // Scan QR (Simple Version)
    const LaporanAbsensiPage(),   // Laporan
    const ProfilPage(),           // Profil
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// Placeholder pages sudah diganti dengan halaman yang sebenarnya



