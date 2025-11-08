import 'package:flutter/material.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/courses_page.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/pages/enrolled_courses_page.dart';
import 'package:cert_classroom_mobile/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const CoursesPage(),
    const EnrolledCoursesPage(),
    const ProfilePage(),
  ];

  static const List<String> _titles = ['Khoa hoc', 'Khoa cua toi', 'Ho so'];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Khoa hoc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Khoa cua toi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Ho so',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton.extended(
                backgroundColor: AppColors.primaryStrong,
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Tim khoa hoc'),
              )
              : null,
    );
  }
}
