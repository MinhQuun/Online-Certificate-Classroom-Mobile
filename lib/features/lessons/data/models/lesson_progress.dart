class LessonProgress {
  const LessonProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  double get percent => total == 0 ? 0 : completed / total;

  static LessonProgress sample() => const LessonProgress(completed: 2, total: 6);
}
