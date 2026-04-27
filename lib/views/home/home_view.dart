import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../core/widgets/scan_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/dna_pattern_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../routes/app_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel _viewModel;

  // @override
  // void initState() {
  //   super.initState();
  //   _viewModel = HomeViewModel();
  //   _loadData();
  // }
  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    // Load data when returning to home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await _viewModel.loadUserData();
  }

  Future<void> _handleRefresh() async {
    await _viewModel.refreshData();
  }

  Future<void> _handleLogout() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.signOut();
    if (!mounted) return;
    AppRouter.navigateToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: DnaPatternBackground(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primaryCyan,
              backgroundColor: AppColors.backgroundLight,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Consumer<HomeViewModel>(
                                  builder: (context, viewModel, child) {
                                    // Get user name from current user or auth provider
                                    final userName =
                                        viewModel.currentUser?.name ??
                                        context
                                            .read<AuthViewModel>()
                                            .authProvider
                                            .currentUser
                                            ?.name ??
                                        context
                                            .read<AuthViewModel>()
                                            .authProvider
                                            .firebaseUser
                                            ?.displayName ??
                                        'User';

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          viewModel.getGreeting(),
                                          style: AppTextStyles.bodySecondary,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userName,
                                          style: AppTextStyles.h2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: _handleLogout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Statistics Cards
                  SliverToBoxAdapter(
                    child: Consumer<HomeViewModel>(
                      builder: (context, viewModel, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle_outline,
                                  title: 'Total Scans',
                                  value: viewModel.totalScansCount.toString(),
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceM),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.verified_outlined,
                                  title: 'Success Rate',
                                  value:
                                      '${viewModel.successRate.toStringAsFixed(0)}%',
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXL),
                  ),

                  // Scan Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: GestureDetector(
                        onTap: () => AppRouter.navigateToScanCamera(context),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.spaceM),
                                    const Text(
                                      'Scan New Image',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXL),
                  ),

                  // Recent Scans Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.recentScans,
                            style: AppTextStyles.h3,
                          ),
                          Consumer<HomeViewModel>(
                            builder: (context, viewModel, child) {
                              if (viewModel.recentScans.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                '${viewModel.recentScans.length} scans',
                                style: AppTextStyles.bodySecondary,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceM),
                  ),

                  // Recent Scans List
                  Consumer<HomeViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryCyan,
                            ),
                          ),
                        );
                      }

                      if (viewModel.recentScans.isEmpty) {
                        return SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.image_search,
                            title: AppStrings.noScansYet,
                            subtitle: 'Tap the button above to start scanning',
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingL,
                          0,
                          AppDimensions.paddingL,
                          AppDimensions.paddingL, // Added bottom padding
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final scan = viewModel.recentScans[index];
                            return ScanCard(
                              scan: scan,
                              onTap: () => AppRouter.navigateToScanResult(
                                context,
                                scanId: scan.id,
                              ),
                            );
                          }, childCount: viewModel.recentScans.length),
                        ),
                      );
                    },
                  ),

                  // Extra padding at bottom
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.spaceS),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySecondarySmall),
        ],
      ),
    );
  }
}
