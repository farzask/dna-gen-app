import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../core/models/user_model.dart';
import '../core/models/scan_model.dart';
import '../core/models/app_state.dart';

class HomeProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AppState _state = AppState.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  List<ScanModel> _recentScans = [];
  Stream<List<ScanModel>>? _scansStream;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  List<ScanModel> get recentScans => _recentScans;
  Stream<List<ScanModel>>? get scansStream => _scansStream;

  // Set state
  void _setState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _errorMessage = error;
    _setState(AppState.error);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    _setState(AppState.idle);
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      _setState(AppState.loading);

      final userId = _authService.currentUserId;
      if (userId == null) {
        _setError('User not authenticated');
        return;
      }

      // Load user profile
      _currentUser = await _firestoreService.getUserProfile(userId);

      // Load recent scans
      await loadRecentScans();

      // Initialize scans stream
      _scansStream = _firestoreService.watchUserScans(userId, limit: 20);

      _setState(AppState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load recent scans
  Future<void> loadRecentScans({int limit = 10}) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      _recentScans = await _firestoreService.getUserScans(userId, limit: limit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent scans: $e');
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadUserData();
  }

  // Get total scans count
  int get totalScansCount => _recentScans.length;

  // Get authenticated scans count
  int get authenticatedScansCount =>
      _recentScans.where((scan) => scan.isAuthentic).length;

  // Get failed scans count
  int get failedScansCount =>
      _recentScans.where((scan) => !scan.isAuthentic).length;

  // Get success rate
  double get successRate {
    if (_recentScans.isEmpty) return 0.0;
    return (authenticatedScansCount / totalScansCount) * 100;
  }
}
