import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/enrolled/data/models/enrolled_course.dart';
import 'package:cert_classroom_mobile/features/enrolled/presentation/controllers/enrolled_controller.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/features/lessons/data/lessons_repository.dart';
import 'package:cert_classroom_mobile/features/lessons/data/models/lesson.dart';
import 'package:cert_classroom_mobile/features/lessons/data/models/lesson_progress_update.dart';
import 'package:cert_classroom_mobile/features/lessons/presentation/controllers/lesson_controller.dart';
import 'package:cert_classroom_mobile/features/profile/data/models/progress_overview.dart';
import 'package:cert_classroom_mobile/features/profile/data/profile_repository.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';
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
              if (detail?.course?.id != null) ...[
                _CourseProgressCard(courseId: detail!.course!.id),
                const SizedBox(height: 20),
              ],
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
                Builder(
                  builder: (context) {
                    final lessonProgress = detail!.progress!;
                    final durationSeconds = (lessonProgress.videoDurationSeconds ?? 1).clamp(1, double.infinity).toDouble();
                    final rawValue = lessonProgress.status == 'COMPLETED'
                        ? 1.0
                        : (lessonProgress.videoProgressSeconds ?? 0) / durationSeconds;
                    final value = rawValue.clamp(0.0, 1.0);
                    final percentLabel = (value * 100).toStringAsFixed(0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiến độ bài học',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text('$percentLabel%'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(lessonProgress.status),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
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
  final LessonsRepository _lessonsRepository = LessonsRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  LessonProgress? _lessonProgress;
  CourseProgressSnapshot? _courseProgressSnapshot;

  int? _lessonsTotalCache;
  int? _lessonsDoneCache;
  double? _percentOverallCache;
  bool _initialLessonCompleted = false;
  bool _hasCompleted = false;
  bool _isSyncingProgress = false;
  bool _isFetchingSnapshot = false;
  double _watchedSeconds = 0;
  Duration? _lastPosition;
  Timer? _heartbeatTimer;

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

  CourseLessonSummary? _currentLessonSummary() {
    final lesson = detail?.lesson;
    if (lesson == null) return null;
    return CourseLessonSummary(
      id: lesson.id,
      title: lesson.title,
      order: lesson.order,
      type: lesson.type,
    );
  }

  @override
  void initState() {
    super.initState();
    _lessonProgress = detail?.progress;
    _initialLessonCompleted = _lessonProgress?.status == 'COMPLETED';
    _hydrateFromEnrollments();
    _loadCourseProgressSnapshot();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant _LessonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) {
      _lessonProgress = detail?.progress;
      _initialLessonCompleted = _lessonProgress?.status == 'COMPLETED';
      _hydrateFromEnrollments();
    }
  }

  Future<void> _initializePlayer() async {
    if (_isLocked) return;
    final url = _videoUrl;
    if (url == null) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    final resumeSeconds = detail?.progress?.videoProgressSeconds;
    if (resumeSeconds != null && resumeSeconds > 0) {
      final durationSeconds = controller.value.duration.inSeconds;
      if (durationSeconds > 0) {
        final clamped =
            resumeSeconds > durationSeconds ? durationSeconds : resumeSeconds;
        await controller.seekTo(Duration(seconds: clamped));
      }
    }
    _videoController = controller;
    controller.addListener(_handleVideoTick);
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

  void _handleVideoTick() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final value = controller.value;
    final position = value.position;
    final duration = value.duration;

    if (value.isPlaying) {
      final last = _lastPosition ?? Duration.zero;
      final delta = position - last;
      if (!delta.isNegative) {
        _watchedSeconds += delta.inMilliseconds / 1000;
      }
    } else {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }

    _lastPosition = position;
    final hasDuration = duration.inMilliseconds > 0;

    if (hasDuration &&
        !_hasCompleted &&
        position.inMilliseconds >= (duration.inMilliseconds * 0.9)) {
      _hasCompleted = true;
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _submitProgress(
        status: 'COMPLETED',
        position: position,
        duration: duration,
        markComplete: true,
      );
    } else if (value.isPlaying && hasDuration) {
      _scheduleHeartbeat(position, duration);
    }
  }

  void _scheduleHeartbeat(Duration position, Duration duration) {
    _heartbeatTimer ??= Timer(const Duration(seconds: 15), () {
      _heartbeatTimer = null;
      _submitProgress(
        status: 'IN_PROGRESS',
        position: position,
        duration: duration,
        silent: true,
      );
    });
  }

  void _hydrateFromEnrollments() {
    final courseId = detail?.course?.id;
    if (courseId == null) return;
    try {
      final enrolled = context.read<EnrolledController>();
      EnrolledCourse? match;
      for (final enrollment in enrolled.courses) {
        if (enrollment.course?.id == courseId) {
          match = enrollment;
          break;
        }
      }
      if (match == null) return;
      final total = detail?.course?.lessonsTotal;
      if (total != null && total > 0) {
        _lessonsTotalCache ??= total;
        final percent = (match.percentOverall ?? 0).clamp(0, 100).toDouble();
        _percentOverallCache = percent;
        _lessonsDoneCache = ((percent / 100) * _lessonsTotalCache!).round();
      }
    } catch (_) {
      // Ignore if controller not found.
    }
  }

  Future<void> _loadCourseProgressSnapshot() async {
    final courseId = detail?.course?.id;
    if (courseId == null || _isFetchingSnapshot) return;
    _isFetchingSnapshot = true;
    try {
      final overview = await _profileRepository.fetchProgressOverview();
      CourseProgressSnapshot? snapshotMatch;
      final snapshots = overview?.courses ?? const [];
      for (final snapshot in snapshots) {
        if (snapshot.courseId == courseId) {
          snapshotMatch = snapshot;
          break;
        }
      }
      final resolved = snapshotMatch;
      if (!mounted || resolved == null) return;
      setState(() {
        _courseProgressSnapshot = resolved;
        if (resolved.lessonsTotal > 0) {
          _lessonsTotalCache = resolved.lessonsTotal;
        }
        _lessonsDoneCache = resolved.lessonsDone;
        _percentOverallCache = resolved.overallPercent.toDouble();
      });
    } catch (_) {
      // silently fail
    } finally {
      _isFetchingSnapshot = false;
    }
  }

  Future<int?> _calculateNextPercent({required bool markComplete}) async {
    var total = _resolveLessonsTotal();
    if (total == null || total == 0) {
      await _loadCourseProgressSnapshot();
      total = _resolveLessonsTotal();
    }
    if (total == null || total == 0) return null;

    if (_lessonsDoneCache == null) {
      if (_percentOverallCache != null) {
        _lessonsDoneCache =
            ((_percentOverallCache!.clamp(0, 100) / 100) * total).round();
      } else {
        await _loadCourseProgressSnapshot();
        if (_lessonsDoneCache == null) {
          _lessonsDoneCache = 0;
        }
      }
    }

    var done = _lessonsDoneCache ?? 0;
    if (markComplete && !_initialLessonCompleted && done < total) {
      done += 1;
      _lessonsDoneCache = done;
    }

    final percent = ((done / total) * 100).round().clamp(0, 100);
    _percentOverallCache = percent.toDouble();
    return percent;
  }

  int? _resolveLessonsTotal() {
    if (_lessonsTotalCache != null && _lessonsTotalCache! > 0) {
      return _lessonsTotalCache;
    }
    final total = detail?.course?.lessonsTotal;
    if (total != null && total > 0) {
      _lessonsTotalCache = total;
      return total;
    }
    final snapshotTotal = _courseProgressSnapshot?.lessonsTotal;
    if (snapshotTotal != null && snapshotTotal > 0) {
      _lessonsTotalCache = snapshotTotal;
      return snapshotTotal;
    }
    return null;
  }

  Future<void> _submitProgress({
    required String status,
    required Duration position,
    required Duration duration,
    bool markComplete = false,
    bool silent = false,
  }) async {
    if (_isSyncingProgress || detail == null) return;

    final percentOverall = await _calculateNextPercent(
      markComplete: markComplete,
    );

    final input = LessonProgressUpdateInput(
      lessonId: detail!.lesson.id,
      status: status,
      totalViewSeconds: _watchedSeconds.floor(),
      videoProgressSeconds: position.inSeconds,
      videoDurationSeconds: duration.inSeconds,
      watchCount:
          markComplete
              ? (_lessonProgress?.watchCount ?? 0) + 1
              : _lessonProgress?.watchCount,
      lastViewedAt: DateTime.now().toIso8601String(),
      completedAt: markComplete ? DateTime.now().toIso8601String() : null,
      coursePercentOverall: percentOverall,
      markLastLesson: true,
    );

    try {
      setState(() => _isSyncingProgress = true);
      final result = await _lessonsRepository.updateLessonProgress(input);
      if (!mounted) return;
      _lessonProgress = result.lessonProgress ?? _lessonProgress;
      if (markComplete) {
        _initialLessonCompleted = true;
      }
      if (result.coursePercentOverall != null) {
        _percentOverallCache = result.coursePercentOverall!.toDouble();
      }
      final courseId = detail?.course?.id;
      if (courseId != null) {
        context.read<StudentSessionController>().updateCourseSnapshot(
          courseId: courseId,
          percentOverall:
              (result.coursePercentOverall ?? percentOverall)?.toDouble(),
          lastLesson: _currentLessonSummary(),
        );
      }
      if (!silent && markComplete) {
        _showProgressSnack('Đã cập nhật tiến độ bài học', success: true);
      }
      if (markComplete) {
        context.read<LessonController>().loadLesson(refresh: true);
        context.read<StudentSessionController>().refreshEnrollments(
          force: true,
        );
        context.read<EnrolledController>().loadEnrolled(refresh: true);
      }
    } on ApiException catch (error) {
      if (!silent) {
        _showProgressSnack(error.message, success: false);
      }
    } catch (_) {
      if (!silent) {
        _showProgressSnack('Không thể đồng bộ tiến độ', success: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingProgress = false);
      }
    }
  }

  Future<void> _flushProgressOnExit() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await _submitProgress(
      status: _hasCompleted ? 'COMPLETED' : 'IN_PROGRESS',
      position: controller.value.position,
      duration: controller.value.duration,
      silent: true,
    );
  }

  void _showProgressSnack(String message, {required bool success}) {
    if (!mounted) return;
    showCustomSnackbar(
      context: context,
      message: message,
      lottiePath:
          success ? 'assets/lottie/success.json' : 'assets/lottie/error.json',
      backgroundColor: success ? Colors.green.shade50 : Colors.red.shade50,
      textColor: success ? Colors.green.shade900 : Colors.red.shade900,
    );
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.removeListener(_handleVideoTick);
    _videoController?.dispose();
    unawaited(_flushProgressOnExit());
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
                  HomeTab.courses,
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

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentSessionController>(
      builder: (context, session, _) {
        final percent = session.progressPercentForCourse(courseId);
        final lastLesson = session.resumeLessonForCourse(courseId);
        if (percent == null && lastLesson == null) {
          return const SizedBox.shrink();
        }
        final percentValue = ((percent ?? 0).clamp(0, 100)).toDouble();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 12,
                offset: Offset(0, 6),
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
                      fontWeight: FontWeight.w700,
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
                  minHeight: 8,
                ),
              ),
              if (lastLesson?.title != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tiếp tục: ${lastLesson!.title}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}




