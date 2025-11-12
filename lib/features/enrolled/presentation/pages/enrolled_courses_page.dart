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

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  _EnrolledTab _activeTab = _EnrolledTab.all;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnrolledController()..loadEnrolled(),
      child: Consumer<EnrolledController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.courses.isEmpty) {
            return const LoadingIndicator(message: 'Đang tải khóa của bạn...');
          }
          if (controller.errorMessage != null && controller.courses.isEmpty) {
            return ErrorView(
              title: 'Không thể tải khóa học',
              message: controller.errorMessage,
              onRetry: controller.loadEnrolled,
            );
          }
          if (controller.courses.isEmpty) {
            return const _EnrolledEmptyState();
          }

          final counts = _countByTab(controller.courses);
          final filtered = _filterCourses(controller.courses);

          return RefreshIndicator(
            onRefresh: controller.loadEnrolled,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _EnrolledHero(
                    total: controller.courses.length,
                    active: counts[_EnrolledTab.active] ?? 0,
                    averageProgress: _averageProgress(controller.courses),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _EnrolledTabs(
                    counts: counts,
                    activeTab: _activeTab,
                    onChanged: (tab) => setState(() => _activeTab = tab),
                  ),
                ),
                if (controller.isLoading)
                  const SliverToBoxAdapter(child: _InlineLoader()),
                filtered.isEmpty
                    ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Không có khóa nào trong trạng thái này.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                    : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      sliver: SliverList.separated(
                        itemBuilder: (context, index) {
                          final course = filtered[index];
                          return _EnrolledCard(course: course);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: filtered.length,
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<_EnrolledTab, int> _countByTab(List<EnrolledCourse> courses) {
    final counts = {
      _EnrolledTab.all: courses.length,
      _EnrolledTab.active: 0,
      _EnrolledTab.pending: 0,
      _EnrolledTab.expired: 0,
    };
    for (final course in courses) {
      final normalized = course.status.toUpperCase();
      if (normalized == 'ACTIVE') {
        counts[_EnrolledTab.active] = counts[_EnrolledTab.active]! + 1;
      } else if (normalized == 'PENDING') {
        counts[_EnrolledTab.pending] = counts[_EnrolledTab.pending]! + 1;
      } else if (normalized == 'EXPIRED') {
        counts[_EnrolledTab.expired] = counts[_EnrolledTab.expired]! + 1;
      }
    }
    return counts;
  }

  double _averageProgress(List<EnrolledCourse> courses) {
    final values =
        courses
            .map((c) => c.percentOverall ?? 0)
            .where((value) => value > 0)
            .toList();
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  List<EnrolledCourse> _filterCourses(List<EnrolledCourse> courses) {
    if (_activeTab == _EnrolledTab.all) return courses;
    final target = _tabStatus(_activeTab);
    return courses
        .where((course) => course.status.toUpperCase() == target)
        .toList();
  }

  String _tabStatus(_EnrolledTab tab) {
    switch (tab) {
      case _EnrolledTab.active:
        return 'ACTIVE';
      case _EnrolledTab.pending:
        return 'PENDING';
      case _EnrolledTab.expired:
        return 'EXPIRED';
      case _EnrolledTab.all:
        return 'ALL';
    }
  }
}

enum _EnrolledTab { all, active, pending, expired }

class _EnrolledHero extends StatelessWidget {
  const _EnrolledHero({
    required this.total,
    required this.active,
    required this.averageProgress,
  });

  final int total;
  final int active;
  final double averageProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khóa của tôi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quản lý tiến độ học tập theo đúng phong cách Student Portal.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _HeroStat(label: 'Tổng khóa', value: '$total'),
                const SizedBox(width: 12),
                _HeroStat(label: 'Đang học', value: '$active'),
                const SizedBox(width: 12),
                _HeroStat(
                  label: 'Tiến độ TB',
                  value: '${averageProgress.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrolledTabs extends StatelessWidget {
  const _EnrolledTabs({
    required this.counts,
    required this.activeTab,
    required this.onChanged,
  });

  final Map<_EnrolledTab, int> counts;
  final _EnrolledTab activeTab;
  final ValueChanged<_EnrolledTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children:
            _EnrolledTab.values.map((tab) {
              final isActive = tab == activeTab;
              final label = switch (tab) {
                _EnrolledTab.all => 'Tất cả',
                _EnrolledTab.active => 'Đang học',
                _EnrolledTab.pending => 'Chờ kích hoạt',
                _EnrolledTab.expired => 'Hết hạn',
              };
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text('$label (${counts[tab] ?? 0})'),
                  selected: isActive,
                  onSelected: (_) => onChanged(tab),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _EnrolledCard extends StatelessWidget {
  const _EnrolledCard({required this.course});

  final EnrolledCourse course;

  @override
  Widget build(BuildContext context) {
    final summary = course.course;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 22,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    summary?.coverImage ??
                        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _StatusChip(status: course.status),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summary?.categoryName != null)
                  Text(
                    summary!.categoryName!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      letterSpacing: 1.1,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  summary?.title ?? 'Khóa học',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (course.lastLesson != null)
                  Text(
                    'Tiếp theo: ${course.lastLesson!.title}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (course.percentOverall ?? 0) / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.primarySoft.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${(course.percentOverall ?? 0).toStringAsFixed(0)}% hoàn thành',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (course.avgMiniTest != null)
                      Text(
                        'Bài tập: ${course.avgMiniTest!.toStringAsFixed(1)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            course.lastLesson == null
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
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Tiếp tục học'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed:
                          summary == null
                              ? null
                              : () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.courseDetail,
                                  arguments: CourseDetailArgs(
                                    courseId: summary.id,
                                    initialCourse: summary,
                                  ),
                                );
                              },
                      icon: const Icon(Icons.menu_book_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    Color bg;
    Color fg;
    String label;

    switch (normalized) {
      case 'ACTIVE':
        bg = const Color(0x332563EB);
        fg = AppColors.primary;
        label = 'Đang học';
        break;
      case 'PENDING':
        bg = const Color(0x33F97316);
        fg = const Color(0xFFF97316);
        label = 'Chờ kích hoạt';
        break;
      case 'EXPIRED':
        bg = const Color(0x33EF4444);
        fg = const Color(0xFFEF4444);
        label = 'Hết hạn';
        break;
      default:
        bg = const Color(0x330F172A);
        fg = AppColors.text;
        label = normalized;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: LinearProgressIndicator(minHeight: 4),
    );
  }
}

class _EnrolledEmptyState extends StatelessWidget {
  const _EnrolledEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn chưa đăng ký khóa học nào',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Khám phá thư viện khóa học để bắt đầu hành trình mới.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
