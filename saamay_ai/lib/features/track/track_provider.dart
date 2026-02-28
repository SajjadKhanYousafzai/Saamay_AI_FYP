import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class TrackProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _overallStats = {};
  Map<String, dynamic>? _todayProgress;
  List<Map<String, dynamic>> _weeklyProgress = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get overallStats => _overallStats;
  Map<String, dynamic>? get todayProgress => _todayProgress;
  List<Map<String, dynamic>> get weeklyProgress => _weeklyProgress;

  int get totalMemorized => _overallStats['total_verses_memorized'] ?? 0;
  int get totalPractice => _overallStats['total_practice_sessions'] ?? 0;
  int get totalCorrect => _overallStats['total_correct'] ?? 0;
  int get totalRecitations => _overallStats['total_recitations'] ?? 0;

  double get retentionRate {
    if (totalPractice == 0) return 0;
    return (totalCorrect / totalPractice) * 100;
  }

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _overallStats = await _db.getOverallStats();
      _todayProgress = await _db.getTodayProgress();
      _weeklyProgress = await _db.getWeeklyProgress();
    } catch (e) {
      _error = 'Error loading stats: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
