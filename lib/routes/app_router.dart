import 'package:flutter/material.dart';
import '../views/auth/signup_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/home/home_view.dart';
import '../views/scan/scan_camera_view.dart';
import '../views/scan/scan_result_view.dart';
import '../core/constants/app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupView());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordView());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeView());

      case AppRoutes.scanCamera:
        return MaterialPageRoute(builder: (_) => const ScanCameraView());

      case AppRoutes.scanResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ScanResultView(scanId: args?['scanId'] as String?),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // Navigation helpers
  static void navigateToSignup(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  static void navigateToScanCamera(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.scanCamera);
  }

  static Future<void> navigateToScanResult(
    BuildContext context, {
    String? scanId,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanResultView(scanId: scanId)),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
