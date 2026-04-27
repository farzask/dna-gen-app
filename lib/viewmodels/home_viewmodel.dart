import 'package:flutter/material.dart';
import '../providers/home_provider.dart';
import '../core/models/app_state.dart';
import '../core/models/user_model.dart';
import '../core/models/scan_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeProvider _homeProvider = HomeProvider();

  HomeProvider get homeProvider => _homeProvider;
  AppState get state => _homeProvider.state;
  String? get errorMessage => _homeProvider.errorMessage;
  UserModel? get currentUser => _homeProvider.currentUser;
  List<ScanModel> get recentScans => _homeProvider.recentScans;
  bool get isLoading => _homeProvider.state == AppState.loading;
  int get totalScansCount => _homeProvider.totalScansCount;
  int get authenticatedScansCount => _homeProvider.authenticatedScansCount;
  int get failedScansCount => _homeProvider.failedScansCount;
  double get successRate => _homeProvider.successRate;
  Stream<List<ScanModel>>? get scansStream => _homeProvider.scansStream;

  HomeViewModel() {
    _homeProvider.addListener(_onHomeProviderUpdate);
  }

  void _onHomeProviderUpdate() {
    notifyListeners();
  }

  // Load user data
  Future<void> loadUserData() async {
    await _homeProvider.loadUserData();
  }

  // Load recent scans
  Future<void> loadRecentScans({int limit = 10}) async {
    await _homeProvider.loadRecentScans(limit: limit);
  }

  // Refresh data
  Future<void> refreshData() async {
    await _homeProvider.refreshData();
  }

  // Clear error
  void clearError() {
    _homeProvider.clearError();
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get user display name
  String getUserDisplayName() {
    return currentUser?.name ?? 'User';
  }

  @override
  void dispose() {
    _homeProvider.removeListener(_onHomeProviderUpdate);
    _homeProvider.dispose();
    super.dispose();
  }
}
