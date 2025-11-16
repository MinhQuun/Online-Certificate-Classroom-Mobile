import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/network/api_exceptions.dart';
import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';
import 'package:cert_classroom_mobile/core/utils/formatters.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/combo.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/controllers/courses_controller.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/features/home/presentation/controllers/home_navigation_controller.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  String? _selectedCategory;
  final Set<int> _pendingCourses = {};
  final Set<int> _pendingCombos = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(
    CoursesController controller,
    StudentSessionController session,
  ) async {
    await controller.loadCourses(refresh: true, search: _searchKeyword);
    await session.refreshAll(force: true);
  }

  void _onSearchSubmitted(CoursesController controller) {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchKeyword = _searchController.text.trim();
    });
    controller.loadCourses(search: _searchKeyword, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoursesController()..loadCourses(),
      child: Consumer2<CoursesController, StudentSessionController>(
        builder: (context, controller, session, _) {
          final homeNav = context.read<HomeNavigationController>();
          if (controller.isLoading && controller.courses.isEmpty) {
            return const LoadingIndicator(message: 'Đang tải khóa học...');
          }
          if (controller.errorMessage != null && controller.courses.isEmpty) {
            return ErrorView(
              title: 'Không thể tải danh sách',
              message: controller.errorMessage,
              onRetry: () => controller.loadCourses(refresh: true),
            );
          }
          if (controller.courses.isEmpty) {
            return _EmptyState(
              onRetry: () => controller.loadCourses(refresh: true),
            );
          }

          final categories =
              controller.courses
                  .map((course) => course.categoryName)
                  .whereType<String>()
                  .toSet()
                  .toList()
                ..sort();

          const orderedCategories = [
            'TOEIC Foundation (405-600)',
            'TOEIC Intermediate (605-780)',
            'TOEIC Advanced (785-990)',
          ];

          categories.sort((a, b) {
            final indexA = orderedCategories.indexOf(a);
            final indexB = orderedCategories.indexOf(b);
            if (indexA == -1 && indexB == -1) {
              return a.compareTo(b);
            } else if (indexA == -1) {
              return 1;
            } else if (indexB == -1) {
              return -1;
            }
            return indexA.compareTo(indexB);
          });

          final filteredCourses =
              controller.courses
                  .map(
                    (course) =>
                        course.copyWithState(session.stateForCourse(course.id)),
                  )
                  .where(
                    (course) =>
                        _selectedCategory == null ||
                        course.categoryName == _selectedCategory,
                  )
                  .where(
                    (course) =>
                        _searchKeyword.isEmpty ||
                        course.title.toLowerCase().contains(
                          _searchKeyword.toLowerCase(),
                        ) ||
                        (course.shortDescription ?? '').toLowerCase().contains(
                          _searchKeyword.toLowerCase(),
                        ),
                  )
                  .toList();

          filteredCourses.sort((a, b) {
            final catA = a.categoryName ?? '';
            final catB = b.categoryName ?? '';
            final indexA = orderedCategories.indexOf(catA);
            final indexB = orderedCategories.indexOf(catB);

            if (indexA != indexB) {
              if (indexA == -1 && indexB == -1) {
                return catA.compareTo(catB);
              } else if (indexA == -1) {
                return 1;
              } else if (indexB == -1) {
                return -1;
              }
              return indexA.compareTo(indexB);
            } else {
              return a.title.compareTo(b.title);
            }
          });

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _onRefresh(controller, session),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _CoursesHero(
                    totalCourses: controller.courses.length,
                    cartCount: session.cartCount,
                    searchController: _searchController,
                    onSearch: () => _onSearchSubmitted(controller),
                  ),
                ),
                if (controller.combos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _CombosSection(
                      combos: controller.combos,
                      pendingIds: _pendingCombos,
                      onAdd: (combo) => _handleAddCombo(combo, session),
                    ),
                  ),
                if (categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _CategoryFilter(
                      categories: categories,
                      selected: _selectedCategory,
                      onSelected: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ),
                if (controller.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                if (filteredCourses.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Không tìm thấy khóa học nào phù hợp. Hãy thử một từ khóa khác.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = filteredCourses[index];
                        final isBusy = _pendingCourses.contains(course.id);
                        return _CourseCard(
                          course: course,
                          isBusy: isBusy,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.courseDetail,
                              arguments: CourseDetailArgs(
                                courseId: course.id,
                                initialCourse: course,
                              ),
                            );
                          },
                          onAction:
                              () => _handleCourseCta(course, session, homeNav),
                        );
                      }, childCount: filteredCourses.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCourseCta(
    CourseSummary course,
    StudentSessionController session,
    HomeNavigationController nav,
  ) async {
    final state = course.userState;
    if (state == CourseUserState.addable) {
      setState(() => _pendingCourses.add(course.id));
      try {
        final result = await session.addCourseToCart(course.id);
        if (mounted) {
          _showSnack(
            result.message ?? 'Đã thêm khóa học vào giỏ hàng',
            success: result.isSuccess,
          );
        }
      } on ApiException catch (error) {
        if (!mounted) return;
        _showSnack(error.message, success: false);
      } catch (_) {
        if (!mounted) return;
        _showSnack('Thao tác thất bại', success: false);
      } finally {
        if (mounted) {
          setState(() => _pendingCourses.remove(course.id));
        }
      }
      return;
    }

    if (state == CourseUserState.inCart) {
      nav.select(HomeTab.cart);
      return;
    }

    nav.select(HomeTab.learning);
  }

  Future<void> _handleAddCombo(
    CourseCombo combo,
    StudentSessionController session,
  ) async {
    setState(() => _pendingCombos.add(combo.id));
    try {
      final result = await session.addComboToCart(combo.id);
      if (!mounted) return;
      _showSnack(
        result.message ?? 'Đã thêm combo vào giỏ hàng',
        success: result.isSuccess,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(error.message, success: false);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Không thể thêm combo', success: false);
    } finally {
      if (mounted) {
        setState(() => _pendingCombos.remove(combo.id));
      }
    }
  }

  void _showSnack(String message, {bool success = true}) {
    if (!mounted) return;
    showCustomSnackbar(
      context: context,
      message: message,
      lottiePath: success ? 'assets/lottie/success.json' : 'assets/lottie/error.json',
      backgroundColor: success ? Colors.green.shade50 : Colors.red.shade50,
      textColor: success ? Colors.green.shade900 : Colors.red.shade900,
    );
  }
}

class _CoursesHero extends StatelessWidget {
  const _CoursesHero({
    required this.totalCourses,
    required this.cartCount,
    required this.searchController,
    required this.onSearch,
  });

  final int totalCourses;
  final int cartCount;
  final TextEditingController searchController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online Certificate Classroom',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chương trình bám sát năng lực thực tế, mentor đồng hành và bài test chuẩn hoá.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm khóa học IELTS, TOEIC...',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _HeroStat(
                  label: 'Khóa học',
                  value: '$totalCourses+',
                  icon: Icons.menu_book_outlined,
                ),
                const SizedBox(width: 16),
                _HeroStat(
                  label: 'Trong giỏ hàng',
                  value: '$cartCount',
                  icon: Icons.shopping_bag_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              // Add this Expanded to constrain the Column horizontally
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70),
                    maxLines:
                        2, // Optional: Allow wrapping to 2 lines if needed
                    overflow:
                        TextOverflow
                            .ellipsis, // Optional: Ellipsis for very long text
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

class _CombosSection extends StatelessWidget {
  const _CombosSection({
    required this.combos,
    required this.onAdd,
    required this.pendingIds,
  });

  final List<CourseCombo> combos;
  final Function(CourseCombo combo) onAdd;
  final Set<int> pendingIds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Combo nổi bật',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Ưu đãi đến ${combos.length} combo',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final combo = combos[index];
                final isBusy = pendingIds.contains(combo.id);
                return _ComboCard(
                  combo: combo,
                  isBusy: isBusy,
                  onAdd: () => onAdd(combo),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: combos.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({
    required this.combo,
    required this.isBusy,
    required this.onAdd,
  });

  final CourseCombo combo;
  final bool isBusy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                combo.coverImage ??
                    'https://images.unsplash.com/photo-1551434678-e076c223a692?w=600',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            combo.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${combo.coursesCount ?? 0} khóa học • ${formatCurrency(combo.price?.sale)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: isBusy ? null : onAdd,
            icon:
                isBusy
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.shopping_cart),
            label: Text(isBusy ? 'Đang thêm...' : 'Thêm combo'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Tất cả'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return ChoiceChip(
            label: Text(category),
            selected: category == selected,
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.isBusy,
    required this.onTap,
    required this.onAction,
  });

  final CourseSummary course;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final style = _CourseCtaStyle.fromState(course.userState);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  course.coverImage ??
                      'https://images.unsplash.com/photo-1551434678-e076c223a692?w=600',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (course.categoryName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  course.categoryName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              course.shortDescription ??
                  'Lộ trình đầy đủ kỹ năng, mentor kèm cặp.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const Spacer(),
            Text(
              formatCurrency(course.price?.sale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _GradientButton(
                gradient: style.gradient,
                borderRadius: 20,
                child: TextButton(
                  onPressed: isBusy ? null : onAction,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        style.gradient == null
                            ? style.backgroundColor
                            : Colors.transparent,
                    foregroundColor: style.foregroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      isBusy
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(style.label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.child,
    this.gradient,
    this.borderRadius = 16,
  });

  final Widget child;
  final Gradient? gradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (gradient == null) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient!,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

class _CourseCtaStyle {
  const _CourseCtaStyle({
    required this.label,
    required this.foregroundColor,
    this.backgroundColor,
    this.gradient,
  });

  final String label;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Gradient? gradient;

  static _CourseCtaStyle fromState(CourseUserState state) {
    switch (state) {
      case CourseUserState.inCart:
        return _CourseCtaStyle(
          label: 'Đã trong giỏ hàng',
          backgroundColor: const Color(0xFFFDE9EF),
          foregroundColor: const Color(0xFFF43F5E),
        );
      case CourseUserState.activated:
        return _CourseCtaStyle(
          label: 'Đang học',
          backgroundColor: const Color(0xFFE7F8F1),
          foregroundColor: AppColors.success,
        );
      case CourseUserState.addable:
        return _CourseCtaStyle(
          label: 'Thêm vào giỏ hàng',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          gradient: AppGradients.primary,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có khóa học',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Danh mục hiện tại chưa có nội dung. Vui lòng quay lại sau.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử tải lại')),
          ],
        ),
      ),
    );
  }
}
