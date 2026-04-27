import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/scan_viewmodel.dart';
import '../../core/widgets/custom_appbar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/models/scan_model.dart';
import '../../routes/app_router.dart';

class ScanResultView extends StatefulWidget {
  final String? scanId;

  const ScanResultView({super.key, this.scanId});

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView> {
  late ScanViewModel _viewModel;
  ScanModel? _scan;
  bool _isLoading = false;
  Map<String, dynamic>? _firebaseData;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ScanViewModel>();

    if (widget.scanId != null) {
      _loadScan();
    }
  }

  Future<void> _loadScan() async {
    setState(() => _isLoading = true);
    try {
      _scan = await _viewModel.getScanById(widget.scanId!);

      // Fetch Firebase data
      if (_scan != null) {
        await _fetchFirebaseData(_scan!.id);
      }
    } catch (e) {
      print('Error loading scan: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchFirebaseData(String scanId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('scans')
          .doc(scanId)
          .get();

      if (doc.exists) {
        print('Firebase data: ${doc.data()}');
        setState(() {
          _firebaseData = doc.data();
        });
      } else {
        print('Document does not exist for scanId: $scanId');
      }
    } catch (e) {
      print('Error fetching Firebase data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(title: AppStrings.scanResult),
      body: Consumer<ScanViewModel>(
        builder: (context, viewModel, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            );
          }

          // Show from scan history (when scanId is provided)
          if (_scan != null && _firebaseData != null) {
            return _buildResultFromScan(_scan!);
          }

          // Show from current authentication result - check all conditions
          final hasImage = viewModel.capturedImage != null;
          final hasAuthResult = viewModel.authenticationResult != null;
          final hasResult = viewModel.hasResult;

          print('=== Current Result Check ===');
          print('hasImage: $hasImage');
          print('hasAuthResult: $hasAuthResult');
          print('hasResult: $hasResult');
          print('capturedImage path: ${viewModel.capturedImage?.path}');
          print('authenticationResult: ${viewModel.authenticationResult}');

          // Show result if we have image and auth result (even if hasResult is false)
          if (hasImage && hasAuthResult) {
            print('Building current result from image + auth result');
            return _buildResultFromCurrent(viewModel);
          }

          // No result available
          print('No result available - returning empty state');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.primaryCyan,
                ),
                const SizedBox(height: 16),
                const Text('No result available', style: AppTextStyles.h3),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Back to Home',
                  onPressed: () => AppRouter.navigateToHome(context),
                  width: 200,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultFromScan(ScanModel scan) {
    final isAuthenticated = _firebaseData?['isAuthenticated'] ?? false;
    final metadata = _firebaseData?['metadata'] as Map<String, dynamic>?;
    final confidenceScore = metadata?['confidenceScore'];
    final message = metadata?['message'];

    print('isAuthenticated: $isAuthenticated');
    print('confidenceScore: $confidenceScore');
    print('message: $message');

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image from URL
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: Image.network(
              scan.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.iconPrimary,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryCyan,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                StatusBadge(isAuthenticated: isAuthenticated),
                const SizedBox(height: AppDimensions.spaceXL),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: isAuthenticated ? 'Authenticated' : 'Failed',
                      ),
                      if (confidenceScore != null) ...[
                        const SizedBox(height: AppDimensions.spaceM),
                        _DetailRow(
                          icon: Icons.percent,
                          label: 'Confidence',
                          value:
                              '${(confidenceScore * 100).toStringAsFixed(1)}%',
                        ),
                      ],
                      if (message != null) ...[
                        const SizedBox(height: AppDimensions.spaceM),
                        _DetailRow(
                          icon: Icons.message_outlined,
                          label: 'Message',
                          value: message.toString(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: CustomButton(
                    text: 'Done',
                    onPressed: () => AppRouter.navigateToHome(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultFromCurrent(ScanViewModel viewModel) {
    final confidenceScore = viewModel.authenticationResult?.confidenceScore;
    final isAuthenticated =
        viewModel.authenticationResult?.isAuthenticated ?? false;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image from local file
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: Image.file(
              File(viewModel.capturedImage!.path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.iconPrimary,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                StatusBadge(isAuthenticated: isAuthenticated),
                const SizedBox(height: AppDimensions.spaceXL),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: isAuthenticated ? 'Authenticated' : 'Failed',
                      ),
                      if (confidenceScore != null) ...[
                        const SizedBox(height: AppDimensions.spaceM),
                        _DetailRow(
                          icon: Icons.percent,
                          label: 'Confidence',
                          value:
                              '${(confidenceScore * 100).toStringAsFixed(1)}%',
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spaceM),
                      _DetailRow(
                        icon: Icons.message_outlined,
                        label: 'Message',
                        value: viewModel.getResultMessage(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                CustomButton(
                  text: 'Back to Home',
                  onPressed: () => AppRouter.navigateToHome(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryCyan),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySecondarySmall),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
