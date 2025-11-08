import 'package:flutter/material.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';

class LessonPageArgs {
  const LessonPageArgs({
    required this.title,
    required this.courseName,
    required this.videoUrl,
  });

  final String title;
  final String courseName;
  final String videoUrl;

  factory LessonPageArgs.placeholder() => const LessonPageArgs(
    title: 'Bai hoc demo',
    courseName: 'Khoa hoc demo',
    videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
  );
}

class LessonPage extends StatelessWidget {
  const LessonPage({super.key, required this.args});

  final LessonPageArgs args;

  @override
  Widget build(BuildContext context) {
    final resources = List.generate(
      4,
      (index) => 'Tai lieu tham khao ${index + 1}',
    );

    return Scaffold(
      appBar: AppBar(title: Text(args.courseName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: AppGradients.primary,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            args.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Video huong dan chi tiet, bam sat giao dien Student tren nen web.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Text(
            'Tai nguyen di kem',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...resources.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.insert_drive_file, color: Colors.white),
                ),
                title: Text(item),
                subtitle: const Text('PDF ~ 1.2 MB'),
                trailing: const Icon(Icons.download_outlined),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Danh dau hoan thanh'),
          ),
        ],
      ),
    );
  }
}
