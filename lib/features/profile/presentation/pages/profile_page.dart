import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:cert_classroom_mobile/core/config/app_config.dart';
import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/validators.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cert_classroom_mobile/features/courses/data/models/course.dart';
import 'package:cert_classroom_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:cert_classroom_mobile/features/profile/data/models/profile.dart';
import 'package:cert_classroom_mobile/features/profile/data/models/progress_overview.dart';
import 'package:cert_classroom_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_button.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedDob;
  bool _didPopulate = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showLogoutSnack(String message, {bool isSuccess = false}) {
    showCustomSnackbar(
      context: context,
      message: message,
      lottiePath:
          isSuccess
              ? 'assets/lottie/success.json' // success.json của bạn
              : 'assets/lottie/error.json', // error.json của bạn
      backgroundColor: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      textColor: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Gọi controller để xoá token / session, v.v.
      await context.read<AuthController>().logout();

      if (!mounted) return;

      _showLogoutSnack('Đăng xuất thành công', isSuccess: true);

      // Điều hướng về màn Login, xoá hết history (không back lại được)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showLogoutSnack(
        'Đăng xuất thất bại, vui lòng thử lại',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..loadProfile(),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.profile == null) {
            return const LoadingIndicator(message: 'Đang tải hồ sơ...');
          }

          if (controller.errorMessage != null && controller.profile == null) {
            return ErrorView(
              title: 'Không thể tải hồ sơ',
              message: controller.errorMessage,
              onRetry: controller.loadProfile,
            );
          }

          final profile = controller.profile;
          if (profile != null && !_didPopulate) {
            _populateFields(profile);
          }

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(
                    fullName: profile?.fullName ?? 'Sinh viên',
                    email: profile?.email ?? '',
                  ),
                  const SizedBox(height: 20),
                  _ProgressHighlights(
                    overview: controller.progress,
                    isLoading: controller.isProgressLoading,
                    errorMessage: controller.progressError,
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Trang cá nhân',
                    subtitle: 'Cập nhật thông tin liên hệ và mật khẩu',
                    child: _buildProfileForm(controller),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Tiến độ học tập',
                    subtitle: 'Theo dõi những khóa học đang học',
                    child: _ProgressSection(
                      overview: controller.progress,
                      isLoading: controller.isProgressLoading,
                      errorMessage: controller.progressError,
                      onCourseTap:
                          (snapshot) => _openCourseDetail(context, snapshot),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Mã kích hoạt',
                    subtitle: 'Kích hoạt khóa học bằng mã đã mua',
                    child: _PortalTile(
                      icon: Icons.qr_code_2,
                      title: 'Sử dụng mã kích hoạt',
                      description:
                          'Nhập mã để mở khóa học ngay trên cổng thông tin.',
                      actionLabel: 'Mở trang kích hoạt',
                      onTap: () => _openPortal('student/activation-codes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Lịch sử đơn hàng',
                    subtitle: 'Xem lại các giao dịch đã thanh toán',
                    child: _PortalTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Theo dõi đơn hàng',
                      description:
                          'Quản lý hóa đơn và tình trạng thanh toán nhanh chóng.',
                      actionLabel: 'Xem đơn hàng',
                      onTap: () => _openPortal('student/order-history'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _LogoutCard(
                    onLogout: _handleLogout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(ProfileController controller) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Họ và tên'),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              helperText: 'Email không thể thay đổi từ mobile',
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Số điện thoại'),
          ),
          const SizedBox(height: 12),
          _DobField(
            date: _selectedDob,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(1950),
                lastDate: DateTime(now.year + 1),
                initialDate: _selectedDob ?? DateTime(now.year - 18),
              );
              if (picked != null) {
                setState(() => _selectedDob = picked);
              }
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cập nhật mật khẩu',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            validator: (value) {
              if ((value ?? '').isEmpty) return null;
              if (_currentPasswordController.text.isEmpty) {
                return 'Nhập mật khẩu hiện tại trước';
              }
              return Validators.password(value);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nhập lại mật khẩu mới',
            ),
            validator: (value) {
              if (_newPasswordController.text.isEmpty) return null;
              if (value != _newPasswordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            label: controller.isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
            isLoading: controller.isSaving,
            onPressed:
                controller.isSaving
                    ? null
                    : () => _onSubmit(context, controller),
          ),
          if (controller.errorMessage != null &&
              controller.profile != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if (controller.successMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.successMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onSubmit(
    BuildContext context,
    ProfileController controller,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await controller.updateProfile(
      ProfileUpdateInput(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _selectedDob,
        currentPassword:
            _currentPasswordController.text.isEmpty
                ? null
                : _currentPasswordController.text,
        newPassword:
            _newPasswordController.text.isEmpty
                ? null
                : _newPasswordController.text,
        confirmPassword:
            _confirmPasswordController.text.isEmpty
                ? null
                : _confirmPasswordController.text,
      ),
    );
    if (!context.mounted) return;
    if (success) {
      setState(() {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _didPopulate = false;
      });
      controller.loadProfile(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
    }
  }

  void _populateFields(Profile profile) {
    _fullNameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _selectedDob = profile.dateOfBirth;
    _didPopulate = true;
  }

  Future<void> _openPortal(String path) async {
    final url = AppConfig.portalUri(path).toString();
    final launched = await launchUrlString(url);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở $url')));
    }
  }

  void _openCourseDetail(
    BuildContext context,
    CourseProgressSnapshot snapshot,
  ) {
    Navigator.of(context).pushNamed(
      AppRouter.courseDetail,
      arguments: CourseDetailArgs(
        courseId: snapshot.courseId,
        initialCourse: CourseSummary(
          id: snapshot.courseId,
          title: snapshot.title,
          slug: snapshot.slug,
          coverImage: snapshot.coverImage,
          shortDescription: null,
          price: null,
          lessonsCount:
              snapshot.lessonsTotal == 0 ? null : snapshot.lessonsTotal,
          teacherName: snapshot.teacherName,
          categoryName: snapshot.categoryName,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.fullName, required this.email});

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.verified_user, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Thành viên Student Portal',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ProgressHighlights extends StatelessWidget {
  const _ProgressHighlights({
    required this.overview,
    required this.isLoading,
    required this.errorMessage,
  });

  final ProgressOverview? overview;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      );
    }
    if (overview == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          errorMessage ??
              'Chưa có dữ liệu tiến độ. Bắt đầu với khóa học đầu tiên!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Row(
      children: [
        _HighlightTile(
          icon: Icons.menu_book_outlined,
          label: 'Khóa đang học',
          value: overview!.totalCourses.toString(),
        ),
        const SizedBox(width: 12),
        _HighlightTile(
          icon: Icons.auto_graph,
          label: 'Tiến độ TB',
          value:
              overview!.averageProgress == null
                  ? '--'
                  : '${overview!.averageProgress}%',
        ),
        const SizedBox(width: 12),
        _HighlightTile(
          icon: Icons.timer_outlined,
          label: 'Giờ học',
          value: overview!.totalLearningHours.toStringAsFixed(1),
        ),
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.overview,
    required this.isLoading,
    required this.errorMessage,
    required this.onCourseTap,
  });

  final ProgressOverview? overview;
  final bool isLoading;
  final String? errorMessage;
  final void Function(CourseProgressSnapshot snapshot) onCourseTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: LoadingIndicator(message: 'Đang tải tiến độ...'),
      );
    }

    if (overview == null) {
      return Text(
        errorMessage ?? 'Chưa có khóa học nào đang học.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    if (overview!.courses.isEmpty) {
      return Text(
        'Bắt đầu học để theo dõi tiến độ tại đây.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children:
          overview!.courses.take(3).map((snapshot) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ProgressCourseCard(
                snapshot: snapshot,
                onTap: () => onCourseTap(snapshot),
              ),
            );
          }).toList(),
    );
  }
}

class _ProgressCourseCard extends StatelessWidget {
  const _ProgressCourseCard({required this.snapshot, required this.onTap});

  final CourseProgressSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                snapshot.coverImage ??
                    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (snapshot.categoryName != null)
                    Text(
                      snapshot.categoryName!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.1,
                        color: AppColors.muted,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: snapshot.overallPercent / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.primarySoft.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${snapshot.overallPercent}% hoàn thành',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (snapshot.bestMiniTestScore != null)
                        Text(
                          'Minitest: ${snapshot.bestMiniTestScore!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (snapshot.lessonsTotal > 0)
                        Text(
                          '${snapshot.lessonsDone}/${snapshot.lessonsTotal} bài',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Mở khóa'),
                      ),
                    ],
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

class _PortalTile extends StatelessWidget {
  const _PortalTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySoft.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.primaryStrong),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryStrong, AppColors.primary],
        ),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đăng xuất',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bảo vệ tài khoản của bạn bằng cách đăng xuất khỏi thiết bị này.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryStrong,
            ),
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất khỏi tài khoản'),
          ),
        ],
      ),
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Ngày sinh'),
        child: Row(
          children: [
            Text(
              date == null
                  ? 'Chưa cập nhật'
                  : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
            ),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }
}
