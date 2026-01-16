import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/logbook.dart';
import '../models/timeline_activity.dart'; // Keeping for backward compatibility if needed, but we prefer ActivityLog
import '../models/activity_log.dart'; // [NEW]
import '../services/logbook_service.dart';
import '../services/activity_service.dart'; // [NEW]
import '../services/upload_service.dart';

class LogbookProvider with ChangeNotifier {
  // State Variables
  List<LogBook> _allLogBooks = [];
  List<LogBook> _filteredLogBooks = [];
  List<ActivityLog> _activities = []; // [NEW] Real backend activities
  List<TimelineActivity> _timelineActivities = []; // Legacy local derived

  bool _isLoading = false;
  String? _errorMessage;

  // Filter State
  int _selectedWeekIndex = 0;
  DateTime _startDateMagang = DateTime.now();

  // Getters
  List<LogBook> get allLogBooks => _allLogBooks;
  List<LogBook> get filteredLogBooks => _filteredLogBooks;
  List<ActivityLog> get activities => _activities; // [NEW]
  List<TimelineActivity> get timelineActivities => _timelineActivities; // Legacy

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedWeekIndex => _selectedWeekIndex;

  // --- INITIALIZATION ---
  void setStartDate(DateTime start) {
    // Normalize to midnight
    _startDateMagang = DateTime(start.year, start.month, start.day);
  }

  // --- MAIN ACTIONS ---

  // 1. Fetch All Data
  Future<void> fetchLogbooks(String pesertaId) async {
    if (pesertaId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await LogbookService.getAllLogbook(
        pesertaMagangId: pesertaId,
        limit: 100,
      );

      if (response.success && response.data != null) {
        _allLogBooks = response.data!;
        
        // Convert to Timeline Activities (Legacy)
        _updateTimelineActivities();

        // Fetch Real Activities [NEW]
        await fetchActivities();
        
        // Apply current filter

        _applyFilter();
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add Logbook (Optimistic / Realtime Update)
  Future<bool> addLogbook({
    required String pesertaId,
    required String tanggal,
    required String kegiatan,
    required String deskripsi,
    String? durasi,
    String? type,
    String? status,
    XFile? foto,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload Foto if exists
      String? fotoUrl;
      if (foto != null) {
        final uploadResult = await UploadService.uploadImage(foto);
        if (uploadResult['success'] == true) {
          fotoUrl = uploadResult['url'];
        } else {
          throw Exception(uploadResult['message'] ?? 'Gagal upload foto');
        }
      }

      // 2. Send to API
      final response = await LogbookService.createLogbook(
        pesertaMagangId: pesertaId,
        tanggal: tanggal,
        kegiatan: kegiatan,
        deskripsi: deskripsi,
        durasi: durasi,
        type: type,
        status: status,
        fotoKegiatan: fotoUrl,
      );

      if (response.success && response.data != null) {
        // 3. Insert new item at the top of local list
        _allLogBooks.insert(0, response.data!);
        
        // 4. Update derived lists
        _updateTimelineActivities();
        _applyFilter();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 3. Update Logbook
  Future<bool> updateLogbook({
    required LogBook log,
    required String tanggal,
    required String kegiatan,
    required String deskripsi,
    String? durasi,
    String? type,
    String? status,
    XFile? foto,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? fotoUrl = log.fotoKegiatan;
      if (foto != null) {
        final uploadResult = await UploadService.uploadImage(foto);
        if (uploadResult['success'] == true) {
          fotoUrl = uploadResult['url'];
        } else {
          throw Exception(uploadResult['message'] ?? 'Gagal upload foto');
        }
      }

      final response = await LogbookService.updateLogbook(
        id: log.id,
        tanggal: tanggal,
        kegiatan: kegiatan,
        deskripsi: deskripsi,
        durasi: durasi,
        type: type,
        status: status,
        fotoKegiatan: fotoUrl,
      );

      if (response.success && response.data != null) {
        // Replace item in list
        final index = _allLogBooks.indexWhere((item) => item.id == log.id);
        if (index != -1) {
          _allLogBooks[index] = response.data!;
        }

        _updateTimelineActivities();
        _applyFilter();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 4. Delete Logbook
  Future<bool> deleteLogbook(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await LogbookService.deleteLogbook(id);
      if (response.success) {
        _allLogBooks.removeWhere((item) => item.id == id);
        _updateTimelineActivities();
        _applyFilter();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- FILTERS & HELPERS ---

  void setWeekIndex(int index) {
    _selectedWeekIndex = index;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final weekStart = _startDateMagang.add(Duration(days: _selectedWeekIndex * 7));
    // Ensure weekEnd covers the entire last day
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    _filteredLogBooks = _allLogBooks.where((log) {
      try {
        final logDate = DateTime.parse(log.tanggal);
        // Robust comparison: logDate (midnight) should be >= weekStart (midnight) AND <= weekEnd
        // Using subtract(1s) logic from before or just exact comparison logic
        return logDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
               logDate.isBefore(weekEnd);
      } catch (_) {
        return false;
      }
    }).toList();

    // Sort by Date Descending
    _filteredLogBooks.sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  void _updateTimelineActivities() {
    _timelineActivities = _allLogBooks.map((log) {
      return TimelineActivity(
        time: log.tanggal,
        activity: log.kegiatan,
        status: log.status?.displayName ?? 'Pending',
        location: '-',
      );
    }).toList();
    
    // Sort timeline descending
    _timelineActivities.sort((a, b) => b.time.compareTo(a.time));
  }

  // [NEW] Fetch Real Activities
  Future<void> fetchActivities() async {
    try {
      final response = await ActivityService.getTimeline();
      if (response.success && response.data != null) {
        _activities = response.data!;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching activities: $e");
    }
  }

  // [NEW] Export using ActivityService
  Future<void> exportData({
    required String type,
    required String format,
    String? startDate,
    String? endDate,
  }) async {
    await ActivityService.exportData(
      type: type,
      format: format,
      startDate: startDate,
      endDate: endDate,
    );
  }

}
