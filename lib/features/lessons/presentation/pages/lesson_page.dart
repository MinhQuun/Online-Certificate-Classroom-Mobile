import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/lessons/data/models/lesson.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/controllers/lesson_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class LessonPageArgs {
  const LessonPageArgs({required this.lessonId, this.title, this.courseName});

  final int lessonId;
  final String? title;
  final String? courseName;
}

class LessonPage extends StatelessWidget {
  const LessonPage({super.key, required this.args});

  final LessonPageArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LessonController(lessonId: args.lessonId)..loadLesson(),
      child: _LessonContent(args: args),
    );
  }
}

class _LessonContent extends StatelessWidget {
  const _LessonContent({required this.args});

  final LessonPageArgs args;

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonController>(
      builder: (context, controller, _) {
        final detail = controller.lesson;
        final title = detail?.lesson.title ?? args.title ?? 'Bài học';
        final courseName =
            detail?.course?.title ?? args.courseName ?? 'Khóa học';

        if (controller.isLoading && detail == null) {
          return _LessonScaffold(
            title: courseName,
            child: const LoadingIndicator(message: 'Đang tải bài học...'),
          );
        }

        if (controller.errorMessage != null && detail == null) {
          return _LessonScaffold(
            title: courseName,
            child: ErrorView(
              title: 'Không thể tải bài học',
              message: controller.errorMessage,
              onRetry: controller.loadLesson,
            ),
          );
        }

        return _LessonScaffold(
          title: courseName,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              _VideoSection(
                coverImage: detail?.course?.coverImage,
                title: title,
                lesson: detail?.lesson,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (detail?.lesson.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  detail!.lesson.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 24),
              if (detail?.progress != null) ...[
                Text(
                  'Tiến độ bài học',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value:
                        detail!.progress?.status == 'COMPLETED'
                            ? 1
                            : (detail.progress?.videoProgressSeconds ?? 0) /
                                (detail.progress?.videoDurationSeconds ==
                                            null ||
                                        detail.progress!.videoDurationSeconds ==
                                            0
                                    ? 1
                                    : detail.progress!.videoDurationSeconds!
                                        .toDouble()),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(detail.progress?.status ?? 'NOT_STARTED'),
                const SizedBox(height: 24),
              ],
              Text(
                'Tài liệu bài học',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (detail?.materials.isEmpty ?? true)
                const Text('Chưa có tài liệu đính kèm')
              else
                ...detail!.materials.map(
                  (material) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(
                          material.type.toLowerCase().contains('pdf')
                              ? Icons.picture_as_pdf
                              : Icons.play_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(material.title),
                      subtitle: Text(material.type.toUpperCase()),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _openMaterial(material.url),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMaterial(String url) async {
    if (url.isEmpty) return;
    await launchUrlString(url);
  }
}

class _LessonScaffold extends StatelessWidget {
  const _LessonScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [_LessonHeader(title: title), Expanded(child: child)],
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            _BackCircleButton(onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bài học',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(onPressed: onTap, icon: const Icon(Icons.arrow_back)),
    );
  }
}

class _VideoSection extends StatelessWidget {
  const _VideoSection({
    required this.coverImage,
    required this.title,
    this.lesson,
  });

  final String? coverImage;
  final String title;
  final LessonInfo? lesson;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppGradients.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(coverImage!, fit: BoxFit.cover),
              ),
            Center(
              child: IconButton(
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 72,
                ),
                onPressed: () {
                  // open lesson video url if backend provides it later
                },
              ),
            ),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
            if (lesson?.type != null)
              Positioned(
                top: 16,
                right: 16,
                child: Chip(label: Text(lesson!.type!.toUpperCase())),
              ),
          ],
        ),
      ),
    );
  }
}
