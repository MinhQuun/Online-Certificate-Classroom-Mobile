import 'package:flutter/material.dart';

import 'package:cert_classroom_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/pages/lesson_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String courseDetail = '/course_detail';
  static const String lesson = '/lesson';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _build(settings, const SplashPage());
      case login:
        return _build(settings, const LoginPage());
      case home:
        return _build(settings, const HomePage());
      case courseDetail:
        final course = settings.arguments;
        return _build(
          settings,
          CourseDetailPage(course: course is Course ? course : null),
        );
      case lesson:
        final args = settings.arguments;
        return _build(
          settings,
          LessonPage(
            args: args is LessonPageArgs ? args : LessonPageArgs.placeholder(),
          ),
        );
      default:
        return _build(
          settings,
          Scaffold(
            body: Center(
              child: Text('Route ${settings.name} is not configured'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _build(
    RouteSettings settings,
    Widget child,
  ) => MaterialPageRoute<dynamic>(settings: settings, builder: (_) => child);
}
