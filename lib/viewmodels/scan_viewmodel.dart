// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import '../providers/scan_provider.dart';
// import '../core/models/app_state.dart';
// import '../core/models/scan_model.dart';
// import '../core/models/authentication_result.dart';

// class ScanViewModel extends ChangeNotifier {
//   final ScanProvider _scanProvider = ScanProvider();

//   ScanProvider get scanProvider => _scanProvider;
//   AppState get state => _scanProvider.state;
//   String? get errorMessage => _scanProvider.errorMessage;
//   XFile? get capturedImage => _scanProvider.capturedImage;
//   AuthenticationResult? get authenticationResult =>
//       _scanProvider.authenticationResult;
//   List<ScanModel> get recentScans => _scanProvider.recentScans;
//   CameraController? get cameraController => _scanProvider.cameraController;
//   bool get isCameraInitialized => _scanProvider.isCameraInitialized;
//   bool get isLoading => _scanProvider.state == AppState.loading;
//   bool get hasImage => _scanProvider.capturedImage != null;
//   bool get hasResult => _scanProvider.authenticationResult != null;
//   String? get lastScanId {
//     if (_scanProvider.authenticationResult == null) {
//       return null;
//     }
//     return _scanProvider.authenticationResult?.scanId;
//   }

//   ScanViewModel() {
//     _scanProvider.addListener(_onScanProviderUpdate);
//   }

//   void _onScanProviderUpdate() {
//     notifyListeners();
//   }

//   // Initialize camera
//   Future<bool> initializeCamera() async {
//     return await _scanProvider.initializeCamera();
//   }

//   // Capture image
//   Future<bool> captureImage() async {
//     return await _scanProvider.captureImage();
//   }

//   // Retake image
//   void retakeImage() {
//     _scanProvider.retakeImage();
//   }

//   // Authenticate image
//   Future<bool> authenticateImage() async {
//     return await _scanProvider.authenticateImage();
//   }

//   // Load recent scans
//   Future<void> loadRecentScans({int limit = 20}) async {
//     await _scanProvider.loadRecentScans(limit: limit);
//   }

//   // Get scan by ID
//   Future<ScanModel?> getScanById(String scanId) async {
//     return await _scanProvider.getScanById(scanId);
//   }

//   // Delete scan
//   Future<bool> deleteScan(String scanId, String imageUrl) async {
//     return await _scanProvider.deleteScan(scanId, imageUrl);
//   }

//   // Switch camera
//   Future<bool> switchCamera() async {
//     return await _scanProvider.switchCamera();
//   }

//   // Set flash mode
//   Future<void> setFlashMode(FlashMode mode) async {
//     await _scanProvider.setFlashMode(mode);
//   }

//   // Dispose camera
//   Future<void> disposeCamera() async {
//     await _scanProvider.disposeCamera();
//   }

//   // Clear error
//   void clearError() {
//     _scanProvider.clearError();
//   }

//   // Get result message
//   String getResultMessage() {
//     if (authenticationResult == null) return '';

//     if (authenticationResult!.isAuthenticated) {
//       return authenticationResult!.message ??
//           'Image authenticated successfully';
//     } else {
//       return authenticationResult!.message ?? 'Authentication failed';
//     }
//   }

//   // Get confidence percentage
//   String getConfidencePercentage() {
//     if (authenticationResult?.confidenceScore == null) return 'N/A';
//     return '${(authenticationResult!.confidenceScore! * 100).toStringAsFixed(1)}%';
//   }

//   @override
//   void dispose() {
//     _scanProvider.removeListener(_onScanProviderUpdate);
//     _scanProvider.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../core/models/scan_model.dart';
import '../core/services/backend_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/camera_service.dart';

enum ScanState { idle, capturing, processing, success, error }

class ScanViewModel extends ChangeNotifier {
  final BackendService _backendService;
  final FirestoreService _firestoreService;
  final CameraService _cameraService;

  ScanViewModel({
    required BackendService backendService,
    required FirestoreService firestoreService,
    required CameraService cameraService,
  })  : _backendService = backendService,
        _firestoreService = firestoreService,
        _cameraService = cameraService;

  ScanState _state = ScanState.idle;
  ScanModel? _lastScan;
  String? _errorMessage;
  XFile? _capturedImage;

  ScanState get state => _state;
  ScanModel? get lastScan => _lastScan;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ScanState.capturing || _state == ScanState.processing;
  XFile? get capturedImage => _capturedImage;
  bool get hasImage => _capturedImage != null;
  CameraController? get cameraController => _cameraService.controller;

  // ─── Camera Methods ───────────────────────────────────────────────────────────

  Future<bool> initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ScanState.error);
      return false;
    }
  }

  Future<bool> captureImage() async {
    _setState(ScanState.capturing);
    try {
      _capturedImage = await _cameraService.takePicture();
      _setState(ScanState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ScanState.error);
      return false;
    }
  }

  void retakeImage() {
    _capturedImage = null;
    _lastScan = null;
    _errorMessage = null;
    _setState(ScanState.idle);
  }

  Future<bool> authenticateImage(String userId) async {
    if (_capturedImage == null) {
      _errorMessage = 'No image captured';
      return false;
    }

    _setState(ScanState.processing);
    try {
      final imageFile = File(_capturedImage!.path);
      final verifyResponse = await _backendService.verifyWatermark(image: imageFile);

      final scan = ScanModel.fromVerifyResponse(
        id: '',
        userId: userId,
        imageUrl: _capturedImage!.path,
        json: verifyResponse,
      );

      final savedId = await _firestoreService.saveScanResult(scan);

      _lastScan = ScanModel.fromVerifyResponse(
        id: savedId,
        userId: userId,
        imageUrl: _capturedImage!.path,
        json: verifyResponse,
      );

      debugPrint('Scan saved: $savedId | authentic: ${_lastScan!.isAuthentic} | accuracy: ${_lastScan!.accuracy}');
      _setState(ScanState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('ScanViewModel error: $_errorMessage');
      _setState(ScanState.error);
      return false;
    }
  }

  Future<void> disposeCamera() async {
    await _cameraService.disposeCamera();
  }

  Future<ScanModel?> getScanById(String scanId) async {
    return await _firestoreService.getScanById(scanId);
  }

  // ─── Combined Capture + Verify ────────────────────────────────────────────────

  Future<void> captureAndVerify(String userId) async {
    _setState(ScanState.capturing);
    try {
      final xfile = await _cameraService.takePicture();
      _capturedImage = xfile;

      _setState(ScanState.processing);

      final imageFile = File(xfile.path);
      final verifyResponse = await _backendService.verifyWatermark(image: imageFile);

      final scan = ScanModel.fromVerifyResponse(
        id: '',
        userId: userId,
        imageUrl: xfile.path,
        json: verifyResponse,
      );

      final savedId = await _firestoreService.saveScanResult(scan);

      _lastScan = ScanModel.fromVerifyResponse(
        id: savedId,
        userId: userId,
        imageUrl: xfile.path,
        json: verifyResponse,
      );

      debugPrint('Scan saved: $savedId | authentic: ${_lastScan!.isAuthentic} | accuracy: ${_lastScan!.accuracy}');
      _setState(ScanState.success);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('ScanViewModel error: $_errorMessage');
      _setState(ScanState.error);
    }
  }

  // ─── Embed Watermark ──────────────────────────────────────────────────────────

  Future<void> embedWatermark({
    required File image,
    required String userId,
  }) async {
    _setState(ScanState.processing);
    try {
      final downloadUrl = await _backendService.embedWatermark(
        image: image,
        fingerprint: userId,
      );
      debugPrint('Watermark embedded. URL: $downloadUrl');
      _setState(ScanState.success);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Embed error: $_errorMessage');
      _setState(ScanState.error);
    }
  }

  void reset() {
    _lastScan = null;
    _capturedImage = null;
    _errorMessage = null;
    _setState(ScanState.idle);
  }

  void _setState(ScanState newState) {
    _state = newState;
    notifyListeners();
  }
}