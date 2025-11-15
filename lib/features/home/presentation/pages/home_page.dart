import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/courses_page.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/pages/enrolled_courses_page.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = const [
      CoursesPage(),
      CartPage(),
      EnrolledCoursesPage(),
      ProfilePage(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentSessionController>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeNavigationController, StudentSessionController>(
      builder: (context, nav, session, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: nav.currentIndex, children: _tabs),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: nav.currentIndex,
            onTap: nav.selectByIndex,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Khóa học',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    if (session.cartCount > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            '${session.cartCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Giỏ hàng',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                label: 'Học tập',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Tài khoản',
              ),
            ],
          ),
        );
      },
    );
  }
}
