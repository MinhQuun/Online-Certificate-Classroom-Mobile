class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final bool isCompleted;

  static List<Lesson> sample(String courseId) => List.generate(
    6,
    (index) => Lesson(
      id: '$courseId-${index + 1}',
      title: 'Bai ${index + 1}: Noi dung thuong gap',
      duration: '08:0${index % 5} phut',
      videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      isCompleted: index < 2,
    ),
  );
}
