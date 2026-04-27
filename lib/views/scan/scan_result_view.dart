import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/scan_provider.dart';
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
  ScanModel? _historicalScan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.scanId != null) {
      _loadScan();
    }
  }

  Future<void> _loadScan() async {
    setState(() => _isLoading = true);
    try {
      _historicalScan =
          await context.read<ScanProvider>().getScanById(widget.scanId!);
    } catch (e) {
      debugPrint('Error loading scan: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(title: AppStrings.scanResult),
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            );
          }

          // Show historical scan loaded by scanId
          if (_historicalScan != null) {
            return _buildResult(_historicalScan!, useLocalFile: false);
          }

          // Show result from the most recently completed scan
          final currentScan = scanProvider.lastScan;
          if (currentScan != null) {
            return _buildResult(currentScan, useLocalFile: true);
          }

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

  Widget _buildResult(ScanModel scan, {required bool useLocalFile}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image preview
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: _buildImage(scan.imageUrl, useLocalFile: useLocalFile),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                StatusBadge(isAuthenticated: scan.isAuthentic),
                const SizedBox(height: AppDimensions.spaceXL),

                // Details card
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
                        value: scan.isAuthentic
                            ? 'Authenticated'
                            : 'Not Authenticated',
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                      _DetailRow(
                        icon: Icons.percent,
                        label: 'Accuracy',
                        value: '${scan.accuracy.toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                      _DetailRow(
                        icon: Icons.bar_chart,
                        label: 'Correlation Strength',
                        value: scan.correlationStrength.toStringAsFixed(4),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                      _DetailRow(
                        icon: Icons.compare_arrows,
                        label: 'Matches',
                        value: '${scan.matches} / ${scan.totalBits}',
                      ),
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

  Widget _buildImage(String imageUrl, {required bool useLocalFile}) {
    final isLocalPath = !imageUrl.startsWith('http');

    if (useLocalFile || isLocalPath) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: AppColors.iconPrimary,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.broken_image,
          size: 64,
          color: AppColors.iconPrimary,
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCyan),
        );
      },
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
