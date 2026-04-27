import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/widgets/logo_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.checkAuthState();

    if (!mounted) return;

    if (authViewModel.isAuthenticated) {
      AppRouter.navigateToHome(context);
    } else {
      AppRouter.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(size: 120),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primaryCyan),
          ],
        ),
      ),
    );
  }
}
