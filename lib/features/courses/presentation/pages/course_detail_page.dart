import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';
import 'package:cert_classroom_mobile/core/utils/formatters.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/controllers/course_detail_controller.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/pages/lesson_page.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.args});

  final CourseDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => CourseDetailController(courseId: args.courseId)..loadDetail(),
      child: _CourseDetailContent(args: args),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  const _CourseDetailContent({required this.args});

  final CourseDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseDetailController, StudentSessionController>(
      builder: (context, controller, session, _) {
        final detail = controller.detail;
        final placeholder = CourseDetail(
          id: args.courseId,
          title: args.initialCourse?.title ?? 'Khóa học',
          description: args.initialCourse?.shortDescription,
          coverImage: args.initialCourse?.coverImage,
          chapters: const [],
        );
        final data = detail ?? placeholder;
        final ctaState = session.stateForCourse(data.id);

        if (controller.isLoading && detail == null) {
          return _buildRefreshablePlaceholder(
            controller: controller,
            session: session,
            child: const LoadingIndicator(message: 'Đang tải khóa học...'),
          );
        }

        if (controller.errorMessage != null && detail == null) {
          return _buildRefreshablePlaceholder(
            controller: controller,
            session: session,
            child: ErrorView(
              title: 'Không thể tải khóa học',
              message: controller.errorMessage,
              onRetry: () => controller.loadDetail(refresh: true),
            ),
          );
        }

        final resumeLessonId = session.resumeLessonForCourse(data.id)?.id;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _refreshPage(controller, session),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DetailHero(
                      detail: data,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _CourseInfo(detail: data),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _CourseProgressBanner(
                        detail: data,
                        onContinue: () => _openPreferredLesson(context, data),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    sliver: _ChaptersSection(
                      detail: data,
                      hasFullAccess: ctaState == CourseUserState.activated,
                      resumeLessonId: resumeLessonId,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _DetailActionBar(
            detail: data,
            state: ctaState,
            onOpenLesson: () => _openPreferredLesson(context, data),
          ),
        );
      },
    );
  }

  CourseLessonSummary? _firstAvailableLesson(CourseDetail detail) {
    for (final chapter in detail.chapters) {
      if (chapter.lessons.isNotEmpty) {
        return chapter.lessons.first;
      }
    }
    return null;
  }

  void _openPreferredLesson(BuildContext context, CourseDetail detail) {
    final session = context.read<StudentSessionController>();
    final resume = session.resumeLessonForCourse(detail.id);
    final target = resume ?? _firstAvailableLesson(detail);
    if (target == null) return;
    Navigator.of(context).pushNamed(
      AppRouter.lesson,
      arguments: LessonPageArgs(
        lessonId: target.id,
        title: target.title,
        courseName: detail.title,
      ),
    );
  }

  Future<void> _refreshPage(
    CourseDetailController controller,
    StudentSessionController session,
  ) async {
    await Future.wait([
      controller.loadDetail(refresh: true),
      session.refreshAll(force: true),
    ]);
  }

  Widget _buildRefreshablePlaceholder({
    required CourseDetailController controller,
    required StudentSessionController session,
    required Widget child,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refreshPage(controller, session),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                  child: Center(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.detail, required this.onBack});

  final CourseDetail detail;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                detail.coverImage ??
                    'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _HeroButton(icon: Icons.arrow_back, onTap: onBack),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                detail.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  const _CourseInfo({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (detail.categoryName != null)
              _InfoPill(
                icon: Icons.category_outlined,
                label: detail.categoryName!,
              ),
            if (detail.teacherName != null)
              _InfoPill(icon: Icons.person_outline, label: detail.teacherName!),
            if (detail.chapters.isNotEmpty)
              _InfoPill(
                icon: Icons.menu_book_outlined,
                label: '${detail.chapters.length} chương',
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (detail.price?.sale != null)
          Text(
            formatCurrency(detail.price?.sale),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (detail.description != null) ...[
          const SizedBox(height: 12),
          Text(
            detail.description!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
        if (detail.promotion != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ưu đãi: ${detail.promotion!.name ?? 'Giảm giá'} - hết hạn ${detail.promotion!.expiresAt ?? 'sắp tới'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CourseProgressBanner extends StatelessWidget {
  const _CourseProgressBanner({required this.detail, required this.onContinue});

  final CourseDetail detail;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentSessionController>(
      builder: (context, session, _) {
        final percent = session.progressPercentForCourse(detail.id);
        final lastLesson = session.resumeLessonForCourse(detail.id);
        if (percent == null && lastLesson == null) {
          return const SizedBox.shrink();
        }
        final percentValue = ((percent ?? 0).clamp(0, 100)).toDouble();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ khóa học',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${percentValue.toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: percentValue / 100,
                  minHeight: 10,
                ),
              ),
              if (lastLesson?.title != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Tiếp tục: ${lastLesson!.title}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Tiếp tục học'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChaptersSection extends StatelessWidget {
  const _ChaptersSection({
    required this.detail,
    required this.hasFullAccess,
    required this.resumeLessonId,
  });

  final CourseDetail detail;
  final bool hasFullAccess;
  final int? resumeLessonId;

  @override
  Widget build(BuildContext context) {
    if (detail.chapters.isEmpty) {
      return SliverToBoxAdapter(
        child: Text(
          'Chưa có nội dung bài học.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    final previewLessonId =
        detail.chapters.isEmpty
            ? null
            : detail.chapters.first.lessons.isEmpty
            ? null
            : detail.chapters.first.lessons.first.id;
    return SliverList.separated(
      itemBuilder: (context, index) {
        final chapter = detail.chapters[index];
        return ExpansionTile(
          title: Text(
            chapter.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          children:
              chapter.lessons.map((lesson) {
                final isPreview = lesson.id == previewLessonId;
                final canOpen = hasFullAccess || isPreview;
                final isResumeTarget =
                    resumeLessonId != null &&
                    resumeLessonId == lesson.id &&
                    hasFullAccess;
                final icon =
                    isPreview
                        ? Icons.visibility_outlined
                        : canOpen
                        ? Icons.play_circle_fill
                        : Icons.lock_outline;
                final subtitle =
                    isPreview
                        ? 'Xem thử miễn phí'
                        : canOpen
                        ? (isResumeTarget ? 'Tiếp tục học' : 'Bắt đầu học')
                        : 'Cần mua khóa học';
                return ListTile(
                  leading: Icon(
                    icon,
                    color: canOpen ? AppColors.success : AppColors.muted,
                  ),
                  title: Text(lesson.title),
                  subtitle: Text(subtitle),
                  trailing:
                      isResumeTarget
                          ? const Icon(
                            Icons.flag_circle,
                            color: AppColors.primary,
                          )
                          : null,
                  onTap:
                      canOpen
                          ? () {
                            Navigator.of(context).pushNamed(
                              AppRouter.lesson,
                              arguments: LessonPageArgs(
                                lessonId: lesson.id,
                                title: lesson.title,
                                courseName: detail.title,
                              ),
                            );
                          }
                          : null,
                );
              }).toList(),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: detail.chapters.length,
    );
  }
}

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({
    required this.detail,
    required this.state,
    required this.onOpenLesson,
  });

  final CourseDetail detail;
  final CourseUserState state;
  final VoidCallback onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final session = context.read<StudentSessionController>();
    final nav = context.read<HomeNavigationController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _handleAction(context, session, nav),
          child: Text(_labelForState(state)),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    StudentSessionController session,
    HomeNavigationController nav,
  ) async {
    try {
      switch (state) {
        case CourseUserState.addable:
          await session.addCourseToCart(detail.id);
          if (!context.mounted) return;
          showCustomSnackbar(
            context: context,
            message: 'Đã thêm vào giỏ hàng',
            lottiePath: 'assets/lottie/success.json',
            backgroundColor: Colors.green.shade50,
            textColor: Colors.green.shade900,
          );
          break;
        case CourseUserState.inCart:
          nav.select(HomeTab.cart);
          break;
        case CourseUserState.activated:
          onOpenLesson();
          break;
      }
    } on ApiException catch (error) {
      showCustomSnackbar(
        context: context,
        message: error.message,
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    }
  }

  String _labelForState(CourseUserState state) {
    switch (state) {
      case CourseUserState.addable:
        return 'Thêm vào giỏ hàng';
      case CourseUserState.inCart:
        return 'Đến giỏ hàng';
      case CourseUserState.activated:
        return 'Vào học ngay';
    }
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.text),
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
