import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/controllers/enrolled_controller.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/pages/lesson_page.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class EnrolledCoursesPage extends StatelessWidget {
  const EnrolledCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => EnrolledController()
            ..loadEnrolled(),
      child: const _EnrolledContent(),
    );
  }
}

class _EnrolledContent extends StatelessWidget {
  const _EnrolledContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<EnrolledController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.courses.isEmpty) {
          return const LoadingIndicator(message: 'Đang tải khóa của bạn...');
        }
        if (controller.errorMessage != null && controller.courses.isEmpty) {
          return ErrorView(
            title: 'Không thể tải khóa của bạn',
            message: controller.errorMessage,
            onRetry: controller.loadEnrolled,
          );
        }
        if (controller.courses.isEmpty) {
          return Center(
            child: Text(
              'Bạn chưa đăng ký khóa học nào.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.loadEnrolled(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              final course = controller.courses[index];
              return _EnrolledCard(course: course);
            },
          ),
        );
      },
    );
  }
}

class _EnrolledCard extends StatelessWidget {
  const _EnrolledCard({required this.course});

  final EnrolledCourse course;

  @override
  Widget build(BuildContext context) {
    final summary = course.course;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (summary == null) return;
        Navigator.of(context).pushNamed(
          AppRouter.courseDetail,
          arguments: CourseDetailArgs(courseId: summary.id, initialCourse: summary),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      summary?.coverImage ??
                          'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?w=400',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      summary?.title ?? 'Khoa hoc',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (course.lastLesson != null) ...[
                Text(
                  'Bai hoc ke tiep',
                  style:
                      Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  course.lastLesson!.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: LinearProgressIndicator(
                  value: (course.percentOverall ?? 0) / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.primarySoft.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(course.percentOverall ?? 0).toStringAsFixed(0)}% hoan thanh',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: course.lastLesson == null
                    ? null
                    : () {
                      Navigator.of(context).pushNamed(
                        AppRouter.lesson,
                        arguments: LessonPageArgs(
                          lessonId: course.lastLesson!.id,
                          title: course.lastLesson!.title,
                          courseName: summary?.title,
                        ),
                      );
                    },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Tiep tuc hoc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
