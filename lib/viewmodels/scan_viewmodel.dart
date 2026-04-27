import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../providers/scan_provider.dart';
import '../core/models/app_state.dart';
import '../core/models/scan_model.dart';
import '../core/models/authentication_result.dart';

class ScanViewModel extends ChangeNotifier {
  final ScanProvider _scanProvider = ScanProvider();

  ScanProvider get scanProvider => _scanProvider;
  AppState get state => _scanProvider.state;
  String? get errorMessage => _scanProvider.errorMessage;
  XFile? get capturedImage => _scanProvider.capturedImage;
  AuthenticationResult? get authenticationResult =>
      _scanProvider.authenticationResult;
  List<ScanModel> get recentScans => _scanProvider.recentScans;
  CameraController? get cameraController => _scanProvider.cameraController;
  bool get isCameraInitialized => _scanProvider.isCameraInitialized;
  bool get isLoading => _scanProvider.state == AppState.loading;
  bool get hasImage => _scanProvider.capturedImage != null;
  bool get hasResult => _scanProvider.authenticationResult != null;
  String? get lastScanId {
    if (_scanProvider.authenticationResult == null) {
      return null;
    }
    return _scanProvider.authenticationResult?.scanId;
  }

  ScanViewModel() {
    _scanProvider.addListener(_onScanProviderUpdate);
  }

  void _onScanProviderUpdate() {
    notifyListeners();
  }

  // Initialize camera
  Future<bool> initializeCamera() async {
    return await _scanProvider.initializeCamera();
  }

  // Capture image
  Future<bool> captureImage() async {
    return await _scanProvider.captureImage();
  }

  // Retake image
  void retakeImage() {
    _scanProvider.retakeImage();
  }

  // Authenticate image
  Future<bool> authenticateImage() async {
    return await _scanProvider.authenticateImage();
  }

  // Load recent scans
  Future<void> loadRecentScans({int limit = 20}) async {
    await _scanProvider.loadRecentScans(limit: limit);
  }

  // Get scan by ID
  Future<ScanModel?> getScanById(String scanId) async {
    return await _scanProvider.getScanById(scanId);
  }

  // Delete scan
  Future<bool> deleteScan(String scanId, String imageUrl) async {
    return await _scanProvider.deleteScan(scanId, imageUrl);
  }

  // Switch camera
  Future<bool> switchCamera() async {
    return await _scanProvider.switchCamera();
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    await _scanProvider.setFlashMode(mode);
  }

  // Dispose camera
  Future<void> disposeCamera() async {
    await _scanProvider.disposeCamera();
  }

  // Clear error
  void clearError() {
    _scanProvider.clearError();
  }

  // Get result message
  String getResultMessage() {
    if (authenticationResult == null) return '';

    if (authenticationResult!.isAuthenticated) {
      return authenticationResult!.message ??
          'Image authenticated successfully';
    } else {
      return authenticationResult!.message ?? 'Authentication failed';
    }
  }

  // Get confidence percentage
  String getConfidencePercentage() {
    if (authenticationResult?.confidenceScore == null) return 'N/A';
    return '${(authenticationResult!.confidenceScore! * 100).toStringAsFixed(1)}%';
  }

  @override
  void dispose() {
    _scanProvider.removeListener(_onScanProviderUpdate);
    _scanProvider.dispose();
    super.dispose();
  }
}
