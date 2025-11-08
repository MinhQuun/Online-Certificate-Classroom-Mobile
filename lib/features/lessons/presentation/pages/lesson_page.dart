import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/lessons/data/models/lesson.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/controllers/lesson_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class LessonPageArgs {
  const LessonPageArgs({
    required this.lessonId,
    this.title,
    this.courseName,
  });

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
      create:
          (_) => LessonController(lessonId: args.lessonId)
            ..loadLesson(),
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
        final title = detail?.lesson.title ?? args.title ?? 'Bai hoc';
        final courseName =
            detail?.course?.title ?? args.courseName ?? 'Khoa hoc';

        if (controller.isLoading && detail == null) {
          return Scaffold(
            appBar: AppBar(title: Text(courseName)),
            body: const LoadingIndicator(message: 'Dang tai bai hoc...'),
          );
        }

        if (controller.errorMessage != null && detail == null) {
          return Scaffold(
            appBar: AppBar(title: Text(courseName)),
            body: ErrorView(
              title: 'Khong the tai bai hoc',
              message: controller.errorMessage,
              onRetry: controller.loadLesson,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(courseName)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _VideoSection(
                coverImage: detail?.course?.coverImage,
                title: title,
                lesson: detail?.lesson,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              if (detail?.lesson.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  detail!.lesson.description!,
                  style:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                ),
              ],
              const SizedBox(height: 24),
              if (detail?.progress != null) ...[
                Text(
                  'Tien do bai hoc',
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: detail!.progress?.status == 'COMPLETED'
                        ? 1
                        : (detail.progress?.videoProgressSeconds ?? 0) /
                            (detail.progress?.videoDurationSeconds == null ||
                                    detail.progress!.videoDurationSeconds == 0
                                ? 1
                                : detail.progress!.videoDurationSeconds!.toDouble()),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(detail.progress?.status ?? 'NOT_STARTED'),
                const SizedBox(height: 24),
              ],
              Text(
                'Tai lieu bai hoc',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
              ),
              const SizedBox(height: 12),
              if (detail?.materials.isEmpty ?? true)
                const Text('Chua co tai lieu dinh kem')
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
