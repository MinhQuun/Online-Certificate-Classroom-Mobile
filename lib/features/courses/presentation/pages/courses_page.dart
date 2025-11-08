import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/controllers/courses_controller.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => CoursesController()
            ..loadCourses(),
      child: const _CoursesContent(),
    );
  }
}

class _CoursesContent extends StatelessWidget {
  const _CoursesContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<CoursesController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.courses.isEmpty) {
          return const LoadingIndicator(message: 'Dang tai khoa hoc...');
        }
        if (controller.errorMessage != null && controller.courses.isEmpty) {
          return ErrorView(
            title: 'Khong the tai danh sach',
            message: controller.errorMessage,
            onRetry: controller.loadCourses,
          );
        }
        if (controller.courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chua co khoa hoc de hien thi.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      controller.isLoading ? null : controller.loadCourses,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thu tai lai'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.loadCourses(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              final course = controller.courses[index];
              return _CourseCard(
                course: course,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.courseDetail,
                    arguments: CourseDetailArgs(
                      courseId: course.id,
                      initialCourse: course,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseSummary course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                course.coverImage ??
                    'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.categoryName != null) ...[
                    Text(
                      course.categoryName!.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.1,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  if (course.shortDescription != null)
                    Text(
                      course.shortDescription!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text('${course.lessonsCount ?? 0} bai'),
                      const Spacer(),
                      if (course.teacherName != null)
                        Text(
                          course.teacherName!,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
