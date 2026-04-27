import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/services/camera_service.dart';
import '../core/services/cloudinary_service.dart'; // NEW
import '../core/services/backend_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/auth_service.dart';
import '../core/models/scan_model.dart';
import '../core/models/authentication_result.dart';
import '../core/models/app_state.dart';

class ScanProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final CloudinaryService _cloudinaryService = CloudinaryService(); // NEW
  final BackendService _backendService = BackendService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  AppState _state = AppState.idle;
  String? _errorMessage;
  XFile? _capturedImage;
  AuthenticationResult? _authenticationResult;
  List<ScanModel> _recentScans = [];

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  XFile? get capturedImage => _capturedImage;
  AuthenticationResult? get authenticationResult => _authenticationResult;
  List<ScanModel> get recentScans => _recentScans;
  CameraController? get cameraController => _cameraService.controller;
  bool get isCameraInitialized => _cameraService.isInitialized;

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

  // Initialize camera
  Future<bool> initializeCamera() async {
    try {
      _setState(AppState.loading);
      await _cameraService.initializeCamera();
      _setState(AppState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Capture image
  Future<bool> captureImage() async {
    try {
      _setState(AppState.loading);
      _capturedImage = await _cameraService.takePicture();
      _setState(AppState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Retake image
  void retakeImage() {
    _capturedImage = null;
    _authenticationResult = null;
    _setState(AppState.idle);
  }

  Future<bool> authenticateImage() async {
    try {
      if (_capturedImage == null) {
        _setError('No image captured');
        return false;
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        _setError('User not authenticated');
        return false;
      }

      _setState(AppState.loading);

      // Step 1: Upload image to Cloudinary
      debugPrint('📤 Uploading to Cloudinary...');
      String imageUrl;
      try {
        imageUrl = await _cloudinaryService.uploadImage(
          imagePath: _capturedImage!.path,
          userId: userId,
        );
        debugPrint('✅ Cloudinary URL: $imageUrl');
      } catch (e) {
        debugPrint('❌ Cloudinary upload failed: $e');
        _setError('Failed to upload image: $e');
        return false;
      }

      // Step 2: Send to backend for authentication
      debugPrint('🔍 Sending to Python backend for analysis...');
      AuthenticationResult authResult;
      try {
        final response = await _backendService.authenticateImageUrl(imageUrl);
        authResult = AuthenticationResult.fromJson(response);
        _authenticationResult = authResult;
        debugPrint('✅ Backend response: ${authResult.isAuthenticated}');
      } catch (e) {
        debugPrint('❌ Backend analysis failed: $e');
        _setError('Failed to analyze image: $e');
        return false;
      }

      // Step 3: Save to Firestore
      debugPrint('💾 Saving to Firestore...');
      String scanId = '';
      try {
        scanId = await _firestoreService.createScanRecord(
          userId: userId,
          imageUrl: imageUrl,
          isAuthenticated: authResult.isAuthenticated,
          metadata: {
            'confidenceScore': authResult.confidenceScore,
            'message': authResult.message,
            'storage': 'cloudinary',
          },
        );

        debugPrint('✅ Saved to Firestore');
      } catch (e) {
        debugPrint('❌ Firestore save failed: $e');
        debugPrint(
          '⚠️  Warning: Scan not saved to history, but analysis completed',
        );
      }

      // Create a new AuthenticationResult with the scanId
      _authenticationResult = AuthenticationResult(
        isAuthenticated: authResult.isAuthenticated,
        confidenceScore: authResult.confidenceScore,
        message: authResult.message,
        scanId: scanId.isNotEmpty ? scanId : null,
      );

      // Step 4: Reload recent scans
      try {
        await loadRecentScans();
      } catch (e) {
        debugPrint('Warning: Failed to reload scans: $e');
      }

      _setState(AppState.success);
      return true;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Load recent scans
  Future<void> loadRecentScans({int limit = 20}) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      _recentScans = await _firestoreService.getUserScans(userId, limit: limit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent scans: $e');
    }
  }

  // Get scan by ID
  Future<ScanModel?> getScanById(String scanId) async {
    try {
      return await _firestoreService.getScanById(scanId);
    } catch (e) {
      debugPrint('Error getting scan: $e');
      return null;
    }
  }

  // Delete scan (UPDATED - includes Cloudinary deletion)
  Future<bool> deleteScan(String scanId, String imageUrl) async {
    try {
      _setState(AppState.loading);

      // Delete from Firestore
      await _firestoreService.deleteScan(scanId);

      // Delete from Cloudinary
      final publicId = _cloudinaryService.getPublicIdFromUrl(imageUrl);
      if (publicId.isNotEmpty) {
        await _cloudinaryService.deleteImage(publicId);
      }

      // Reload recent scans
      await loadRecentScans();

      _setState(AppState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Switch camera
  Future<bool> switchCamera() async {
    try {
      await _cameraService.switchCamera();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await _cameraService.setFlashMode(mode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  // Dispose camera
  Future<void> disposeCamera() async {
    await _cameraService.disposeCamera();
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }
}
