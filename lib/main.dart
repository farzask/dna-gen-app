import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'views/splash/splash_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/scan_viewmodel.dart';
import 'routes/app_router.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ScanViewModel()),
      ],
      child: MaterialApp(
        title: 'DNA Gen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryCyan,
            secondary: AppColors.primaryPurple,
            surface: AppColors.backgroundLight,
            error: AppColors.error,
          ),
        ),
        home: const SplashView(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
