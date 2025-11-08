import 'package:flutter/material.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/pages/lesson_page.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_button.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, this.course});

  final Course? course;

  @override
  Widget build(BuildContext context) {
    final data = course ?? Course.sample().first;
    final modules = List.generate(
      data.lessons,
      (index) => 'Bai ${index + 1}: Noi dung hap dan',
    ).take(6).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(data.title),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(data.thumbnail, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoPill(
                        icon: Icons.schedule,
                        label: '${data.durationInHours} gio',
                      ),
                      _InfoPill(
                        icon: Icons.list_alt_outlined,
                        label: '${data.lessons} bai hoc',
                      ),
                      _InfoPill(
                        icon: Icons.star,
                        label: data.rating.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Noi dung khoa hoc',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...modules.map(
                    (module) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySoft.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(module),
                      subtitle: const Text('08:00 phut'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.lesson,
                          arguments: LessonPageArgs(
                            title: module,
                            courseName: data.title,
                            videoUrl:
                                'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: AppButton(
          label: data.isEnrolled ? 'Tiep tuc hoc' : 'Dang ky ngay',
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRouter.lesson,
              arguments: LessonPageArgs(
                title: modules.first,
                courseName: data.title,
                videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: AppColors.primarySoft.withValues(alpha: 0.15),
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
