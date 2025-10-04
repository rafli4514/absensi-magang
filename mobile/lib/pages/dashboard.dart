import 'package:flutter/material.dart';
import 'dart:async';
import 'absen_masuk.dart';
import 'absen_keluar.dart';
import 'pengajuan_izin.dart';
import '../services/dashboard_service.dart';
import '../services/auth_service.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Real-time data
  DateTime _currentTime = DateTime.now();
  String _attendanceStatus = 'Belum Absen Masuk';
  Timer? _timer;
  
  DashboardModel? _dashboardData;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
    _loadDashboardData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateAttendanceStatus();
      });
    });
  }

  void _updateAttendanceStatus() {
    // Update status dari API data jika tersedia
    if (_dashboardData?.todayStatus != null) {
      _attendanceStatus = _dashboardData!.todayStatus!;
    } else {
      // Fallback: Simulasi status kehadiran berdasarkan waktu
      final hour = _currentTime.hour;
      if (hour >= 8 && hour < 12) {
        _attendanceStatus = 'Sudah Absen Masuk';
      } else if (hour >= 12 && hour < 13) {
        _attendanceStatus = 'Istirahat';
      } else if (hour >= 13 && hour < 17) {
        _attendanceStatus = 'Kembali Bekerja';
      } else if (hour >= 17) {
        _attendanceStatus = 'Sudah Absen Pulang';
      } else {
        _attendanceStatus = 'Belum Absen Masuk';
      }
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get user data
      final user = await AuthService.getCurrentUser();
      
      // Get dashboard data
      final dashboardResponse = await DashboardService.getDashboard();
      
      if (dashboardResponse.success && dashboardResponse.data != null) {
        setState(() {
          _currentUser = user;
          _dashboardData = dashboardResponse.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _getUserInitials() {
    if (_currentUser?.nama != null && _currentUser!.nama.isNotEmpty) {
      final names = _currentUser!.nama.trim().split(' ');
      if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats Cards (TODAY, TIME, STATUS)
                  _buildQuickStats(),
                  
                  const SizedBox(height: 24),
                  
                  // Jadwal Hari Ini
                  _buildTodaySchedule(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Cards (Keluar & Pengajuan Izin)
                  _buildActionCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Ringkasan Hari Ini
                  _buildTodaySummary(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1976D2),
            Color(0xFF1565C0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/pln-logo-png_seeklogo-355620.png',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${_currentUser?.nama ?? 'User'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text(
                      'Siap memulai hari ini?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }


  Widget _buildStatsCard() {
    final currentDate = '${_currentTime.day} ${_getMonthName(_currentTime.month)}';
    final currentTime = '${_currentTime.hour.toString().padLeft(2, '0')}.${_currentTime.minute.toString().padLeft(2, '0')}';
    
    // Get status color based on current status
    Color statusColor = _getStatusColor(_attendanceStatus);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // TODAY Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ini',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          
          // STATUS Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _attendanceStatus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sudah Absen Masuk':
        return const Color(0xFF4CAF50); // Hijau
      case 'Istirahat':
        return const Color(0xFFFF9800); // Oranye
      case 'Kembali Bekerja':
        return const Color(0xFF2196F3); // Biru
      case 'Sudah Absen Pulang':
        return const Color(0xFFF44336); // Merah
      default:
        return const Color(0xFF20B2AA); // Toska
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }


   Widget _buildTodaySchedule() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16),
       child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinimalScheduleItem('08:00', 'Masuk', Colors.green, true),
              _buildMinimalScheduleItem('12:00', 'Istirahat', Colors.orange, false),
              _buildMinimalScheduleItem('13:00', 'Kembali', Colors.blue, false),
              _buildMinimalScheduleItem('17:00', 'Pulang', Colors.red, false),
            ],
          ),
        ],
      ),
     ),
   );
 }

 Widget _buildMinimalScheduleItem(String time, String title, Color color, bool isActive) {
   return Column(
     children: [
       Container(
         width: 8,
         height: 8,
         decoration: BoxDecoration(
           color: isActive ? color : Colors.grey[300],
           shape: BoxShape.circle,
         ),
       ),
       const SizedBox(height: 4),
       Text(
         time,
         style: TextStyle(
           fontSize: 12,
           fontWeight: FontWeight.w600,
           color: isActive ? color : Colors.grey[600],
         ),
       ),
       Text(
         title,
         style: TextStyle(
           fontSize: 10,
           color: isActive ? color : Colors.grey[500],
         ),
       ),
     ],
   );
 }


   Widget _buildActionCards() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16),
       child: Row(
         children: [
           Expanded(
             child: _buildMinimalActionCard(
               'Masuk',
               Icons.login,
               const Color(0xFF4CAF50),
               () {
                 Navigator.of(context).push(
                   MaterialPageRoute(
                     builder: (context) => const AbsenMasukPage(),
                   ),
                 );
               },
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: _buildMinimalActionCard(
               'Keluar',
               Icons.logout,
               const Color(0xFFFF9800),
               () {
                 Navigator.of(context).push(
                   MaterialPageRoute(
                     builder: (context) => const AbsenKeluarPage(),
                   ),
                 );
               },
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: _buildMinimalActionCard(
               'Izin',
               Icons.event_available,
               const Color(0xFF2196F3),
               () {
                 Navigator.of(context).push(
                   MaterialPageRoute(
                     builder: (context) => const PengajuanIzinPage(),
                   ),
                 );
               },
             ),
           ),
         ],
       ),
     );
   }

   Widget _buildMinimalActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(10),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.05),
               blurRadius: 8,
               offset: const Offset(0, 2),
             ),
           ],
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Icon(
                 icon,
                 size: 20,
                 color: color,
               ),
             ),
             const SizedBox(height: 8),
             Text(
               title,
               style: TextStyle(
                 fontSize: 12,
                 fontWeight: FontWeight.w600,
                 color: color,
               ),
             ),
           ],
         ),
       ),
     );
   }


   Widget _buildTodaySummary() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 20),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text(
             'Ringkasan Hari Ini',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: Color(0xFF333333),
             ),
           ),
           const SizedBox(height: 16),
           Row(
             children: [
               Expanded(
                 child:                  _buildSummaryCard(
                   'Masuk',
                   '---',
                   Icons.login,
                   const Color(0xFF4CAF50),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child:                  _buildSummaryCard(
                   'Keluar',
                   '---',
                   Icons.logout,
                   const Color(0xFFFF9800),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child:                  _buildSummaryCard(
                   'Lokasi',
                   'Kantor',
                   Icons.location_on,
                   const Color(0xFF2196F3),
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }

   Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
     return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
             blurRadius: 10,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Column(
         children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: color.withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(
               icon,
               color: color,
               size: 20,
             ),
           ),
           const SizedBox(height: 8),
           Text(
             title,
             style: const TextStyle(
               fontSize: 12,
               color: Colors.grey,
             ),
           ),
           const SizedBox(height: 2),
           Text(
             value,
             style: const TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: Color(0xFF333333),
             ),
           ),
         ],
       ),
     );
   }



}


