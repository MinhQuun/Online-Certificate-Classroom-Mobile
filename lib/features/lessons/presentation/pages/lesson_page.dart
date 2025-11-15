import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
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
              _LessonVideoPlayer(detail: detail, title: title),
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

class _LessonVideoPlayer extends StatefulWidget {
  const _LessonVideoPlayer({required this.detail, required this.title});

  final LessonDetail? detail;
  final String title;

  @override
  State<_LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<_LessonVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  LessonDetail? get detail => widget.detail;

  bool get _isLocked {
    final permissions = detail?.permissions;
    if (permissions == null) return false;
    return permissions.canAccess != true && permissions.isPreview != true;
  }

  bool get _isPreview {
    final permissions = detail?.permissions;
    return permissions?.isPreview == true;
  }

  String? get _videoUrl {
    final materials = detail?.materials ?? [];
    for (final material in materials) {
      final mime = material.mimeType?.toLowerCase();
      final type = material.type.toLowerCase();
      if ((mime?.startsWith('video/') ?? false) || type == 'video') {
        return material.url;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_isLocked) return;
    final url = _videoUrl;
    if (url == null) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    _videoController = controller;
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: false,
      looping: false,
      allowMuting: true,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverImage = detail?.course?.coverImage;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.primarySoft.withValues(alpha: 0.3),
            ),
            child:
                _chewieController != null && !_isLocked
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Chewie(controller: _chewieController!),
                    )
                    : coverImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(coverImage, fit: BoxFit.cover),
                    )
                    : const Center(
                      child: Icon(Icons.play_circle_outline, size: 64),
                    ),
          ),
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_isPreview)
            Positioned(
              top: 16,
              right: 16,
              child: Chip(
                label: const Text('Xem thử'),
                backgroundColor: AppColors.successTint,
                labelStyle: const TextStyle(color: AppColors.success),
              ),
            ),
          if (_isLocked) const _LockedOverlay(),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withValues(alpha: 0.7),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Kích hoạt khóa học để xem toàn bộ bài học',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).maybePop();
                context.read<HomeNavigationController>().select(
                  HomeTab.account,
                );
              },
              child: const Text('Nhập mã kích hoạt'),
            ),
          ],
        ),
      ),
    );
  }
}
