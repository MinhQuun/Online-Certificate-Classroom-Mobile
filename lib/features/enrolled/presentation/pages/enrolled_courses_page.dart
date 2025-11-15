import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/formatters.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_response.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/controllers/enrolled_controller.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class EnrolledCoursesPage extends StatelessWidget {
  const EnrolledCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnrolledController()..loadEnrolled(),
      child: const _EnrolledView(),
    );
  }
}

class _EnrolledView extends StatelessWidget {
  const _EnrolledView();

  @override
  Widget build(BuildContext context) {
    return Consumer<EnrolledController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.courses.isEmpty) {
          return const LoadingIndicator(
            message: 'Đang tải khóa học của bạn...',
          );
        }
        if (controller.errorMessage != null && controller.courses.isEmpty) {
          return ErrorView(
            title: 'Không thể tải danh sách',
            message: controller.errorMessage,
            onRetry:
                () => controller.loadEnrolled(
                  status: controller.activeFilter,
                  refresh: true,
                ),
          );
        }
        if (controller.courses.isEmpty) {
          return const _EnrolledEmptyState();
        }
        return RefreshIndicator(
          onRefresh:
              () => controller.loadEnrolled(
                status: controller.activeFilter,
                refresh: true,
              ),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _EnrolledHeader(summary: controller.summary),
              ),
              SliverToBoxAdapter(
                child: _StatusTabs(
                  summary: controller.summary,
                  active: controller.activeFilter,
                  onChanged:
                      (status) => controller.loadEnrolled(status: status),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final enrollment = controller.courses[index];
                    return _EnrollmentCard(course: enrollment);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: controller.courses.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EnrolledHeader extends StatelessWidget {
  const _EnrolledHeader({required this.summary});

  final EnrolledSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khóa học của tôi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.all} khóa học đã đăng ký',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.summary,
    required this.active,
    required this.onChanged,
  });

  final EnrolledSummary summary;
  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'Tất cả', summary.all),
      ('active', 'Đang học', summary.active),
      ('pending', 'Chờ kích hoạt', summary.pending),
      ('expired', 'Đã hết hạn', summary.expired),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children:
            tabs.map((tab) {
              final selected = tab.$1 == active;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${tab.$2} (${tab.$3})'),
                  selected: selected,
                  onSelected: (_) => onChanged(tab.$1),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.course});

  final EnrolledCourse course;

  @override
  Widget build(BuildContext context) {
    final summary = course.course;
    if (summary == null) return const SizedBox.shrink();
    final timeline = course.timeline;
    final statusChip = _StatusChip(status: course.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    summary.coverImage ??
                        'https://images.unsplash.com/photo-1551434678-e076c223a692?w=300',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      statusChip,
                      if (timeline?.expiresAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Hết hạn: ${formatDateLabel(timeline!.expiresAt) ?? '--'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressSection(course: course),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _handleAction(context, course, summary),
                    child: Text(_actionLabel(course.status)),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.courseDetail,
                      arguments: CourseDetailArgs(
                        courseId: summary.id,
                        initialCourse: summary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _actionLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Tiếp tục học';
      case 'PENDING':
        return 'Kích hoạt ngay';
      case 'EXPIRED':
        return 'Xem chi tiết';
      default:
        return 'Xem';
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    EnrolledCourse enrollment,
    CourseSummary summary,
  ) async {
    final status = enrollment.status.toUpperCase();
    if (status == 'ACTIVE') {
      Navigator.of(context).pushNamed(
        AppRouter.courseDetail,
        arguments: CourseDetailArgs(
          courseId: summary.id,
          initialCourse: summary,
        ),
      );
      return;
    }
    if (status == 'PENDING') {
      context.read<HomeNavigationController>().select(HomeTab.account);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRouter.courseDetail,
      arguments: CourseDetailArgs(courseId: summary.id, initialCourse: summary),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.course});

  final EnrolledCourse course;

  @override
  Widget build(BuildContext context) {
    final isActive = course.status.toUpperCase() == 'ACTIVE';
    if (!isActive) {
      return Text(
        course.status.toUpperCase() == 'PENDING'
            ? 'Khóa học đang chờ kích hoạt. Vui lòng nhập mã kích hoạt đã được gửi tới email của bạn.'
            : 'Khóa học đã hết hạn. Hãy gia hạn hoặc đăng ký lại để tiếp tục.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tiến độ học tập'),
            Text('${course.percentOverall?.toStringAsFixed(0) ?? '0'}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: (course.percentOverall ?? 0) / 100,
            minHeight: 8,
          ),
        ),
        if (course.lastLesson != null) ...[
          const SizedBox(height: 8),
          Text(
            'Bài học gần nhất: ${course.lastLesson!.title}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        bg = AppColors.successTint;
        fg = AppColors.success;
        label = 'Đang học';
        break;
      case 'PENDING':
        bg = AppColors.warningTint;
        fg = AppColors.warning;
        label = 'Chờ kích hoạt';
        break;
      case 'EXPIRED':
        bg = AppColors.dangerTint;
        fg = AppColors.danger;
        label = 'Đã hết hạn';
        break;
      default:
        bg = AppColors.infoTint;
        fg = AppColors.info;
        label = status;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

class _EnrolledEmptyState extends StatelessWidget {
  const _EnrolledEmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn chưa đăng ký khóa học nào',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Khám phá thư viện khóa học để bắt đầu hành trình học tập.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
