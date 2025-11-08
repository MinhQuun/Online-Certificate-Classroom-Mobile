import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/validators.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cert_classroom_mobile/features/profile/data/models/profile.dart';
import 'package:cert_classroom_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_button.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ProfileController()
            ..loadProfile(),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.profile == null) {
            return const LoadingIndicator(message: 'Dang tai ho so...');
          }
          if (controller.errorMessage != null && controller.profile == null) {
            return ErrorView(
              title: 'Khong the tai ho so',
              message: controller.errorMessage,
              onRetry: controller.loadProfile,
            );
          }

          final profile = controller.profile;
          if (profile != null && !_didPopulate) {
            _populateFields(profile);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  fullName: profile?.fullName ?? 'Sinh vien',
                  email: profile?.email ?? '',
                ),
                const SizedBox(height: 24),
                Text(
                  'Thong tin ca nhan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Ho va ten'),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Vui long nhap ho ten'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          helperText: 'Email khong the thay doi tu mobile',
                        ),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'So dien thoai'),
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
                      const SizedBox(height: 32),
                      Text(
                        'Doi mat khau',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mat khau hien tai',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Mat khau moi'),
                        validator: (value) {
                          if ((value ?? '').isEmpty) return null;
                          if (_currentPasswordController.text.isEmpty) {
                            return 'Nhap mat khau hien tai truoc';
                          }
                          return Validators.password(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Nhap lai mat khau moi'),
                        validator: (value) {
                          if ((_newPasswordController.text).isEmpty) return null;
                          if (value != _newPasswordController.text) {
                            return 'Mat khau khong khop';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: controller.isSaving ? 'Dang luu...' : 'Luu thay doi',
                        isLoading: controller.isSaving,
                        onPressed:
                            controller.isSaving
                                ? null
                                : () => _onSubmit(context, controller),
                      ),
                      if (controller.errorMessage != null) ...[
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
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Dang xuat'),
                        onPressed: () => context.read<AuthController>().logout(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        currentPassword: _currentPasswordController.text.isEmpty
            ? null
            : _currentPasswordController.text,
        newPassword: _newPasswordController.text.isEmpty
            ? null
            : _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text.isEmpty
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
        const SnackBar(content: Text('Cap nhat ho so thanh cong')),
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.fullName, required this.email});

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                ),
              ],
            ),
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
        decoration: const InputDecoration(labelText: 'Ngay sinh'),
        child: Row(
          children: [
            Text(
              date == null
                  ? 'Chua cap nhat'
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
