import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/controllers/courses_controller.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoursesController()..loadCourses(),
      child: const _CoursesContent(),
    );
  }
}

class _CoursesContent extends StatefulWidget {
  const _CoursesContent();

  @override
  State<_CoursesContent> createState() => _CoursesContentState();
}

class _CoursesContentState extends State<_CoursesContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoursesController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.courses.isEmpty) {
          return const LoadingIndicator(message: 'Đang tải khóa học...');
        }
        if (controller.errorMessage != null && controller.courses.isEmpty) {
          return ErrorView(
            title: 'Không thể tải danh sách',
            message: controller.errorMessage,
            onRetry: controller.loadCourses,
          );
        }
        if (controller.courses.isEmpty) {
          return _EmptyState(
            title: 'Chưa có khóa học',
            message: 'Danh mục hiện tại chưa có nội dung. Thử quay lại sau.',
            onRetry: controller.loadCourses,
          );
        }

        final categories = _buildCategories(controller.courses);
        final filtered = _filterCourses(controller.courses);

        return RefreshIndicator(
          onRefresh: () => controller.loadCourses(refresh: true),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _CoursesHero(
                  totalCourses: controller.courses.length,
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                ),
              ),
              if (categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: _CategoryChips(
                    categories: categories,
                    selected: _selectedCategory,
                    onSelected: (value) {
                      setState(() {
                        if (value == null) {
                          _selectedCategory = null;
                        } else {
                          _selectedCategory =
                              _selectedCategory == value ? null : value;
                        }
                      });
                    },
                  ),
                ),
              if (controller.isLoading)
                const SliverToBoxAdapter(child: _InlineLoader()),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    title: 'Không tìm thấy khóa học',
                    message: 'Thử đổi từ khóa hoặc danh mục khác.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final course = filtered[index];
                      return _CourseCard(
                        course: course,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.courseDetail,
                            arguments: CourseDetailArgs(
                              courseId: course.id,
                              initialCourse: course,
                            ),
                          );
                        },
                      );
                    }, childCount: filtered.length),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.80,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<String> _buildCategories(List<CourseSummary> courses) {
    final set = <String>{};

    for (final course in courses) {
      final category = course.categoryName?.trim();
      if (category != null && category.isNotEmpty) {
        set.add(category);
      }
    }

    final list = set.toList();

    // Hàm phụ: lấy số đầu tiên trong chuỗi, ví dụ "TOEIC Advanced (785-990)" -> 785
    int _extractStartScore(String s) {
      final match = RegExp(r'(\d{3,})').firstMatch(s);
      if (match == null) return 0;
      return int.tryParse(match.group(1)!) ?? 0;
    }

    list.sort((a, b) {
      final aScore = _extractStartScore(a);
      final bScore = _extractStartScore(b);

      // Nếu bắt được số thì sort theo số
      if (aScore != 0 || bScore != 0) {
        return aScore.compareTo(bScore);
      }

      // Fallback: sort theo chữ cái
      return a.compareTo(b);
    });

    return list;
  }

  List<CourseSummary> _filterCourses(List<CourseSummary> courses) {
    return courses.where((course) {
      final matchesCategory =
          _selectedCategory == null ||
          (course.categoryName?.toLowerCase() ==
              _selectedCategory!.toLowerCase());
      final matchesQuery =
          _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery) ||
          (course.shortDescription?.toLowerCase().contains(_searchQuery) ??
              false);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}

class _CoursesHero extends StatelessWidget {
  const _CoursesHero({
    required this.totalCourses,
    required this.searchController,
    required this.onSearchChanged,
  });

  final int totalCourses;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220F172A),
              blurRadius: 30,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$totalCourses Khóa học đang mở',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kho khóa học chuẩn Student Portal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Theo lộ trình rõ ràng với mentor đồng hành và bài tập.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khóa học...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _HeroMetaChip(label: 'Tài liệu phong phú'),
                _HeroMetaChip(label: 'Mentor theo sát'),
                _HeroMetaChip(label: 'Review exercises'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <String>['Tất cả', ...categories];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = items[index];
          final bool isAll = index == 0;

          final bool isActive = isAll ? selected == null : selected == category;

          return FilterChip(
            label: Text(category),
            selected: isActive,
            onSelected: (_) {
              if (isAll) {
                // Chip "Tất cả" -> clear filter
                onSelected(null);
              } else {
                onSelected(category);
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isActive ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: LinearProgressIndicator(minHeight: 4),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseSummary course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      course.coverImage ??
                          'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=600',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child:
                          course.categoryName == null
                              ? const SizedBox.shrink()
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  course.categoryName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (course.shortDescription != null)
                      Text(
                        course.shortDescription!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${course.lessonsCount ?? 0} bài',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        if (course.teacherName != null)
                          Text(
                            course.teacherName!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _PriceTag(price: course.price),
                        const Spacer(),
                        FilledButton(
                          onPressed: onTap,
                          child: const Text('Xem chi tiết'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({this.price});

  final CoursePrice? price;

  @override
  Widget build(BuildContext context) {
    if (price == null || price!.sale == null) {
      return const Text(
        'Liên hệ',
        style: TextStyle(fontWeight: FontWeight.w600),
      );
    }
    final currency = price!.currency ?? 'VND';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${price!.sale!.toStringAsFixed(0)} $currency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (price!.original != null && price!.original! > (price!.sale ?? 0))
          Text(
            '${price!.original!.toStringAsFixed(0)} $currency',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message, this.onRetry});

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Thử tải lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
