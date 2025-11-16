import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/config/app_config.dart';
import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/controllers/enrolled_controller.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnlineCertificateApp());
}

class OnlineCertificateApp extends StatelessWidget {
  const OnlineCertificateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider<StudentSessionController>(
          create: (_) => StudentSessionController(),
        ),
        ChangeNotifierProvider<EnrolledController>(
          create: (_) => EnrolledController(),
        ),
        ChangeNotifierProvider<HomeNavigationController>(
          create: (_) => HomeNavigationController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.light,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
