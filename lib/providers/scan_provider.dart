import 'package:camera/camera.dart';
import 'package:dnagen/core/models/scan_model.dart';
import 'package:flutter/foundation.dart';
import '../core/services/backend_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/camera_service.dart';
import '../viewmodels/scan_viewmodel.dart';

class ScanProvider extends ChangeNotifier {
  late final ScanViewModel _viewModel;

  ScanProvider({
    required BackendService backendService,
    required FirestoreService firestoreService,
    required CameraService cameraService,
  }) {
    _viewModel = ScanViewModel(
      backendService: backendService,
      firestoreService: firestoreService,
      cameraService: cameraService,
    );
    _viewModel.addListener(notifyListeners);
  }

  ScanViewModel get viewModel => _viewModel;

  // ─── State Getters ────────────────────────────────────────────────────────────

  ScanState get state => _viewModel.state;
  ScanModel? get lastScan => _viewModel.lastScan;
  String? get errorMessage => _viewModel.errorMessage;
  bool get isLoading => _viewModel.isLoading;
  XFile? get capturedImage => _viewModel.capturedImage;
  bool get hasImage => _viewModel.hasImage;
  CameraController? get cameraController => _viewModel.cameraController;

  // ─── Camera Methods ───────────────────────────────────────────────────────────

  Future<bool> initializeCamera() => _viewModel.initializeCamera();
  Future<bool> captureImage() => _viewModel.captureImage();
  void retakeImage() => _viewModel.retakeImage();
  void setPickedImage(XFile image) => _viewModel.setPickedImage(image);
  Future<bool> authenticateImage(String userId) => _viewModel.authenticateImage(userId);
  Future<void> disposeCamera() => _viewModel.disposeCamera();

  // ─── Data Methods ─────────────────────────────────────────────────────────────

  Future<ScanModel?> getScanById(String scanId) => _viewModel.getScanById(scanId);
  void reset() => _viewModel.reset();

  @override
  void dispose() {
    _viewModel.removeListener(notifyListeners);
    _viewModel.dispose();
    super.dispose();
  }
}