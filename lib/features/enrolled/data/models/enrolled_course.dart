class EnrolledCourse {
  const EnrolledCourse({
    required this.id,
    required this.title,
    required this.progress,
    required this.thumbnail,
    required this.nextLesson,
  });

  final String id;
  final String title;
  final double progress;
  final String thumbnail;
  final String nextLesson;

  static List<EnrolledCourse> sample() => [
    const EnrolledCourse(
      id: 'flutter-cert',
      title: 'Flutter Mobile Certification',
      progress: 0.72,
      thumbnail:
          'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?w=400',
      nextLesson: 'State management voi Provider',
    ),
    const EnrolledCourse(
      id: 'laravel-api',
      title: 'Laravel API Mastery',
      progress: 0.35,
      thumbnail:
          'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=400',
      nextLesson: 'Thiet ke module Lesson',
    ),
  ];
}
