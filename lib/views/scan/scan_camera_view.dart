import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../../providers/scan_provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_appbar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/dialog_helper.dart';
import '../../core/utils/permission_handler.dart';
import '../../routes/app_router.dart';

class ScanCameraView extends StatefulWidget {
  const ScanCameraView({super.key});

  @override
  State<ScanCameraView> createState() => _ScanCameraViewState();
}

class _ScanCameraViewState extends State<ScanCameraView> {
  late final ScanProvider _scanProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scanProvider = context.read<ScanProvider>();
    _scanProvider.retakeImage(); // clear any previous capture before opening camera
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await PermissionHandler.requestCameraPermission();

    if (!hasPermission) {
      if (!mounted) return;
      DialogHelper.showPermissionDialog(
        context,
        message: 'Camera permission is required to scan images',
        onOpenSettings: () => PermissionHandler.openAppSettings(),
      );
      return;
    }

    final success = await _scanProvider.initializeCamera();

    if (success && mounted) {
      setState(() => _isInitialized = true);
    } else if (mounted) {
      DialogHelper.showErrorDialog(
        context,
        message: _scanProvider.errorMessage ?? 'Failed to initialize camera',
      );
    }
  }

  Future<void> _handleCapture() async {
    final success = await _scanProvider.captureImage();

    if (!success && mounted) {
      DialogHelper.showErrorDialog(
        context,
        message: _scanProvider.errorMessage ?? 'Failed to capture image',
      );
    }
  }

  void _handleRetake() {
    _scanProvider.retakeImage();
  }

  Future<void> _handleAnalyze() async {
    if (!mounted) return;
    DialogHelper.showLoadingDialog(context, message: AppStrings.analyzing);

    final userId =
        context.read<AuthViewModel>().authProvider.firebaseUser?.uid ?? '';

    final success = await _scanProvider.authenticateImage(userId);

    if (!mounted) return;
    DialogHelper.dismissDialog(context);

    if (success) {
      AppRouter.navigateToScanResult(context, scanId: null);
    } else {
      DialogHelper.showErrorDialog(
        context,
        message: _scanProvider.errorMessage ?? 'Failed to analyze image',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(title: AppStrings.scanImage),
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          if (!_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            );
          }

          if (scanProvider.hasImage) {
            return _buildImagePreview(scanProvider);
          }

          return _buildCameraPreview(scanProvider);
        },
      ),
    );
  }

  Widget _buildCameraPreview(ScanProvider scanProvider) {
    if (scanProvider.cameraController == null) {
      return const Center(child: Text('Camera not available'));
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(child: CameraPreview(scanProvider.cameraController!)),

        // Overlay border
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryCyan.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
        ),

        // Capture Button
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _handleCapture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ScanProvider scanProvider) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                File(scanProvider.capturedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          color: AppColors.backgroundLight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.retake,
                    onPressed: _handleRetake,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.analyze,
                    onPressed: _handleAnalyze,
                    isLoading: scanProvider.isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scanProvider.disposeCamera();
    super.dispose();
  }
}
