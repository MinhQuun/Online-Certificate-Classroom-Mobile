class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.lessons,
    required this.durationInHours,
    required this.rating,
    required this.progress,
    required this.thumbnail,
    this.isEnrolled = false,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int lessons;
  final double durationInHours;
  final double rating;
  final double progress;
  final String thumbnail;
  final bool isEnrolled;

  static List<Course> sample() => [
    const Course(
      id: 'flutter-cert',
      title: 'Flutter Mobile Certification',
      description: 'Xay dung app Flutter gan voi giao dien web Student.',
      category: 'Mobile',
      lessons: 24,
      durationInHours: 18.0,
      rating: 4.9,
      progress: 35.0,
      thumbnail:
          'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400',
    ),
    const Course(
      id: 'laravel-api',
      title: 'Laravel API Mastery',
      description: 'Thiet ke backend RESTful bang Laravel 10.',
      category: 'Backend',
      lessons: 30,
      durationInHours: 22.0,
      rating: 4.8,
      progress: 70.0,
      thumbnail:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
      isEnrolled: true,
    ),
    const Course(
      id: 'ui-ux',
      title: 'UI/UX Foundations',
      description: 'Nguyen tac thiet ke trai nghiem nguoi dung hien dai.',
      category: 'Design',
      lessons: 18,
      durationInHours: 12.0,
      rating: 4.7,
      progress: 0.0,
      thumbnail:
          'https://images.unsplash.com/photo-1522199710521-72d69614c702?w=400',
    ),
  ];
}
