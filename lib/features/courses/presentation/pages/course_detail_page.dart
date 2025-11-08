import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/controllers/course_detail_controller.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/pages/lesson_page.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_button.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.args});

  final CourseDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => CourseDetailController(courseId: args.courseId)
            ..loadDetail(),
      child: _CourseDetailContent(args: args),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  const _CourseDetailContent({required this.args});

  final CourseDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseDetailController>(
      builder: (context, controller, _) {
        final detail = controller.detail;
        final placeholder = CourseDetail(
          id: args.courseId,
          title: args.initialCourse?.title ?? 'Khoa hoc',
          description: args.initialCourse?.shortDescription,
          coverImage: args.initialCourse?.coverImage,
          chapters: const [],
        );
        final data = detail ?? placeholder;

        if (controller.isLoading && detail == null) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Dang tai khoa hoc...'),
          );
        }

        if (controller.errorMessage != null && detail == null) {
          return Scaffold(
            body: ErrorView(
              title: 'Khong the tai khoa hoc',
              message: controller.errorMessage,
              onRetry: () => controller.loadDetail(refresh: true),
            ),
          );
        }

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
                      Image.network(
                        data.coverImage ??
                            'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400',
                        fit: BoxFit.cover,
                      ),
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
                          if (data.categoryName != null)
                            _InfoPill(
                              icon: Icons.category_outlined,
                              label: data.categoryName!,
                            ),
                          if (data.teacherName != null)
                            _InfoPill(
                              icon: Icons.person_outline,
                              label: data.teacherName!,
                            ),
                          if (data.price?.sale != null)
                            _InfoPill(
                              icon: Icons.sell_outlined,
                              label:
                                  '${data.price!.sale!.toStringAsFixed(0)} ${data.price!.currency ?? 'VND'}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (data.description != null)
                        Text(
                          data.description!,
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.muted,
                                  ),
                        ),
                      const SizedBox(height: 28),
                      Text(
                        'Noi dung khoa hoc',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (data.chapters.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Chua co du lieu bai hoc'),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: data.chapters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final chapter = data.chapters[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          ...chapter.lessons.map(
                            (lesson) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primarySoft.withValues(
                                        alpha: 0.2,
                                      ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(lesson.title),
                                subtitle: lesson.type == null
                                    ? null
                                    : Text(lesson.type!.toUpperCase()),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRouter.lesson,
                                    arguments: LessonPageArgs(
                                      lessonId: lesson.id,
                                      title: lesson.title,
                                      courseName: data.title,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              label: 'Vao hoc bai dau tien',
              onPressed:
                  data.chapters.isEmpty
                      ? null
                      : () {
                        final firstLesson = data.chapters
                            .expand((c) => c.lessons)
                            .firstOrNull;
                        if (firstLesson == null) return;
                        Navigator.of(context).pushNamed(
                          AppRouter.lesson,
                          arguments: LessonPageArgs(
                            lessonId: firstLesson.id,
                            title: firstLesson.title,
                            courseName: data.title,
                          ),
                        );
                      },
            ),
          ),
        );
      },
    );
  }
}

class CourseDetailArgs {
  CourseDetailArgs({required this.courseId, this.initialCourse});

  final int courseId;
  final CourseSummary? initialCourse;

  static CourseDetailArgs fromRoute(dynamic args) {
    if (args is CourseDetailArgs) return args;
    if (args is CourseSummary) {
      return CourseDetailArgs(courseId: args.id, initialCourse: args);
    }
    if (args is int) return CourseDetailArgs(courseId: args);
    return CourseDetailArgs(courseId: 0);
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
