import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../../viewmodels/scan_viewmodel.dart';
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
  late ScanViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ScanViewModel();
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

    final success = await _viewModel.initializeCamera();

    if (success && mounted) {
      setState(() => _isInitialized = true);
    } else if (mounted) {
      DialogHelper.showErrorDialog(
        context,
        message: _viewModel.errorMessage ?? 'Failed to initialize camera',
      );
    }
  }

  Future<void> _handleCapture() async {
    final success = await _viewModel.captureImage();

    if (!success && mounted) {
      DialogHelper.showErrorDialog(
        context,
        message: _viewModel.errorMessage ?? 'Failed to capture image',
      );
    }
  }

  void _handleRetake() {
    _viewModel.retakeImage();
  }

  Future<void> _handleAnalyze() async {
    DialogHelper.showLoadingDialog(context, message: AppStrings.analyzing);

    final success = await _viewModel.authenticateImage();

    if (!mounted) return;

    DialogHelper.dismissDialog(context);

    if (success) {
      // Get the scanId from the ViewModel after successful analysis
      final scanId = _viewModel.lastScanId;

      debugPrint('🔍 lastScanId: $scanId');
      debugPrint('🔍 authResult: ${_viewModel.authenticationResult}');
      debugPrint(
        '🔍 authResult.scanId: ${_viewModel.authenticationResult?.scanId}',
      );

      if (scanId != null) {
        // Navigate with scanId so the result page can fetch from Firebase
        AppRouter.navigateToScanResult(context, scanId: scanId);
      } else {
        DialogHelper.showErrorDialog(context, message: 'Failed to get scan ID');
      }
    } else {
      DialogHelper.showErrorDialog(
        context,
        message: _viewModel.errorMessage ?? 'Failed to analyze image',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: const CustomAppBar(title: AppStrings.scanImage),
        body: Consumer<ScanViewModel>(
          builder: (context, viewModel, child) {
            if (!_isInitialized) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryCyan),
              );
            }

            if (viewModel.hasImage) {
              return _buildImagePreview(viewModel);
            }

            return _buildCameraPreview(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(ScanViewModel viewModel) {
    if (viewModel.cameraController == null) {
      return const Center(child: Text('Camera not available'));
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(child: CameraPreview(viewModel.cameraController!)),

        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.5),
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

  Widget _buildImagePreview(ScanViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                File(viewModel.capturedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          color: AppColors.backgroundLight,
          child: Column(
            children: [
              Padding(
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
                        isLoading: viewModel.isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _viewModel.disposeCamera();
    _viewModel.dispose();
    super.dispose();
  }
}
