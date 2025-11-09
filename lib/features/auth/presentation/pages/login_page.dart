import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:cert_classroom_mobile/core/config/app_config.dart';
import 'package:cert_classroom_mobile/core/routing/app_router.dart';
import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/validators.dart';
import 'package:cert_classroom_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_button.dart';
import 'package:cert_classroom_mobile/shared/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'student@demo.com');
  final _passwordController = TextEditingController(text: '123456');
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmController = TextEditingController();
  _AuthPanel _panel = _AuthPanel.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmController.dispose();
    super.dispose();
  }

  Future<void> _onLogin(AuthController controller) async {
    if (!_loginFormKey.currentState!.validate()) return;
    final success = await controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      _showSnack(
        controller.errorMessage ?? 'Đăng nhập thất bại, vui lòng thử lại.',
      );
    }
  }

  Future<void> _onRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final portalUrl =
        '${AppConfig.portalBaseUri.toString()}/?open=register&source=app';
    final launched = await launchUrlString(portalUrl);
    if (!launched && mounted) {
      _showSnack('Không thể mở trang đăng ký $portalUrl');
    } else if (mounted) {
      _showSnack('Vui lòng hoàn tất đăng ký trên cổng web.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 1000 : 520,
                      minHeight: isWide ? 520 : 0,
                    ),
                    child: isWide ? _buildWideLayout() : _buildStackedLayout(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedLayout() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: _AuthPanel.values.map((p) => p == _panel).toList(),
              borderRadius: BorderRadius.circular(20),
              onPressed: (index) {
                setState(() => _panel = _AuthPanel.values[index]);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Đăng nhập'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Đăng ký'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child:
                  _panel == _AuthPanel.login
                      ? _LoginPanel(
                        formKey: _loginFormKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onSubmit: _onLogin,
                      )
                      : _RegisterPanel(
                        formKey: _registerFormKey,
                        nameController: _regNameController,
                        emailController: _regEmailController,
                        phoneController: _regPhoneController,
                        passwordController: _regPasswordController,
                        confirmController: _regConfirmController,
                        onSubmit: _onRegister,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _LoginPanel(
                formKey: _loginFormKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onSubmit: _onLogin,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Card(
            color: Colors.white.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.24),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: _RegisterPanel(
                formKey: _registerFormKey,
                nameController: _regNameController,
                emailController: _regEmailController,
                phoneController: _regPhoneController,
                passwordController: _regPasswordController,
                confirmController: _regConfirmController,
                onSubmit: _onRegister,
                inverted: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _AuthPanel { login, register }

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function(AuthController controller) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào học viên!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để tiếp tục hành trình học trực tuyến.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordController,
                label: 'Mật khẩu',
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Đăng nhập',
                isLoading: controller.isLoading,
                onPressed:
                    controller.isLoading ? null : () => onSubmit(controller),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed:
                      controller.isLoading ? null : () => onSubmit(controller),
                  child: const Text('Đăng nhập nhanh'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
    this.inverted = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final Future<void> Function() onSubmit;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final textColor = inverted ? Colors.white : AppColors.text;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đăng ký',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo tài khoản mới và kích hoạt khóa học bằng activation code.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: inverted ? Colors.white70 : AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          _AuthInput(
            controller: nameController,
            label: 'Họ và tên',
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
            inverted: inverted,
          ),
          const SizedBox(height: 12),
          _AuthInput(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            inverted: inverted,
          ),
          const SizedBox(height: 12),
          _AuthInput(
            controller: phoneController,
            label: 'Số điện thoại',
            keyboardType: TextInputType.phone,
            validator:
                (value) =>
                    value == null || value.length < 10
                        ? 'Nhập số hợp lệ'
                        : null,
            inverted: inverted,
          ),
          const SizedBox(height: 12),
          _AuthInput(
            controller: passwordController,
            label: 'Mật khẩu',
            obscureText: true,
            validator: Validators.password,
            inverted: inverted,
          ),
          const SizedBox(height: 12),
          _AuthInput(
            controller: confirmController,
            label: 'Nhập lại mật khẩu',
            obscureText: true,
            validator:
                (value) =>
                    value != passwordController.text
                        ? 'Mật khẩu không khớp'
                        : null,
            inverted: inverted,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: inverted ? Colors.white : AppColors.primary,
                foregroundColor: inverted ? AppColors.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: onSubmit,
              child: const Text('Mở trang đăng ký'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.inverted = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: inverted ? Colors.white : AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: inverted ? Colors.white70 : AppColors.muted,
        ),
        filled: true,
        fillColor:
            inverted ? Colors.white.withValues(alpha: 0.1) : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: inverted ? Colors.white24 : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: inverted ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
