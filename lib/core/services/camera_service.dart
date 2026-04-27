import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw 'No cameras available';
      }

      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
    } catch (e) {
      throw 'Failed to initialize camera: ${e.toString()}';
    }
  }

  // Take picture
  Future<XFile> takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw 'Camera not initialized';
      }

      if (_controller!.value.isTakingPicture) {
        throw 'Camera is busy';
      }

      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      throw 'Failed to capture image: ${e.toString()}';
    }
  }

  Future<void> switchCamera() async {
    try {
      if (_cameras == null || _cameras!.length < 2) {
        throw 'Cannot switch camera';
      }

      final currentLens = _controller?.description.lensDirection;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentLens,
      );

      await disposeCamera();

      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
    } catch (e) {
      throw 'Failed to switch camera: ${e.toString()}';
    }
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      if (_controller == null) return;
      await _controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('Failed to set flash mode: $e');
    }
  }

  Future<void> disposeCamera() async {
    await _controller?.dispose();
    _controller = null;
  }
}
