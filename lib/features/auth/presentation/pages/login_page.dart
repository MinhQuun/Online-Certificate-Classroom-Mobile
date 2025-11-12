import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lottie/lottie.dart';

import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';

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

  // Controllers KHÔNG còn giá trị mặc định
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmController = TextEditingController();

  // Trạng thái tab & ẩn/hiện mật khẩu
  _AuthPanel _panel = _AuthPanel.login;
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isRegisterConfirmPasswordVisible = false;

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
      _showSnack('Đăng nhập thành công', isSuccess: true);
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      _showSnack(
        controller.errorMessage ?? 'Đăng nhập thất bại, vui lòng thử lại.',
        isSuccess: false,
      );
    }
  }

  Future<void> _onRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final portalUrl =
        '${AppConfig.portalBaseUri.toString()}/?open=register&source=app';
    final launched = await launchUrlString(portalUrl);

    if (!launched && mounted) {
      _showSnack('Không thể mở trang đăng ký $portalUrl', isSuccess: false);
    } else if (mounted) {
      _showSnack('Vui lòng hoàn tất đăng ký trên cổng web.', isSuccess: true);
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    showCustomSnackbar(
      context: context,
      message: message,
      lottiePath:
          isSuccess ? 'assets/lottie/success.json' : 'assets/lottie/error.json',
      backgroundColor: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      textColor: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
    );
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

  /// Card xếp chồng (mobile)
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
                        isPasswordVisible: _isLoginPasswordVisible,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _isLoginPasswordVisible = !_isLoginPasswordVisible;
                          });
                        },
                        onSubmit: _onLogin,
                      )
                      : _RegisterPanel(
                        formKey: _registerFormKey,
                        nameController: _regNameController,
                        emailController: _regEmailController,
                        phoneController: _regPhoneController,
                        passwordController: _regPasswordController,
                        confirmController: _regConfirmController,
                        isPasswordVisible: _isRegisterPasswordVisible,
                        isConfirmPasswordVisible:
                            _isRegisterConfirmPasswordVisible,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _isRegisterPasswordVisible =
                                !_isRegisterPasswordVisible;
                          });
                        },
                        onToggleConfirmPasswordVisibility: () {
                          setState(() {
                            _isRegisterConfirmPasswordVisible =
                                !_isRegisterConfirmPasswordVisible;
                          });
                        },
                        onSubmit: _onRegister,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// Layout 2 cột (tablet/desktop)
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Cột login
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
                isPasswordVisible: _isLoginPasswordVisible,
                onTogglePasswordVisibility: () {
                  setState(() {
                    _isLoginPasswordVisible = !_isLoginPasswordVisible;
                  });
                },
                onSubmit: _onLogin,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Cột register
        Expanded(
          child: Card(
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.24),
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
                isPasswordVisible: _isRegisterPasswordVisible,
                isConfirmPasswordVisible: _isRegisterConfirmPasswordVisible,
                onTogglePasswordVisibility: () {
                  setState(() {
                    _isRegisterPasswordVisible = !_isRegisterPasswordVisible;
                  });
                },
                onToggleConfirmPasswordVisibility: () {
                  setState(() {
                    _isRegisterConfirmPasswordVisible =
                        !_isRegisterConfirmPasswordVisible;
                  });
                },
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
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function(AuthController controller) onSubmit;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;

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
                  color: AppColors.text,
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

              // Email
              _AuthInput(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                lottiePath: 'assets/lottie/email.json',
              ),
              const SizedBox(height: 16),

              // Mật khẩu + show/hide
              _AuthInput(
                controller: passwordController,
                label: 'Mật khẩu',
                obscureText: !isPasswordVisible,
                validator: Validators.password,
                lottiePath: 'assets/lottie/password.json',
                enableToggleObscure: true,
                onToggleObscure: onTogglePasswordVisibility,
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Đăng nhập',
                isLoading: controller.isLoading,
                onPressed:
                    controller.isLoading ? null : () => onSubmit(controller),
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
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onSubmit;
  final bool inverted;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: inverted ? Colors.white : AppColors.text,
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: inverted ? Colors.white70 : AppColors.muted,
    );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chưa có tài khoản?', style: titleStyle),
          const SizedBox(height: 8),
          Text(
            'Điền thông tin bên dưới, hệ thống sẽ mở cổng web để bạn hoàn tất đăng ký và kích hoạt tài khoản.',
            style: bodyStyle,
          ),
          const SizedBox(height: 24),

          // Họ tên
          _AuthInput(
            controller: nameController,
            label: 'Họ và tên',
            keyboardType: TextInputType.name,
            validator:
                (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
            inverted: inverted,
            lottiePath: 'assets/lottie/user.json',
          ),
          const SizedBox(height: 12),

          // Email
          _AuthInput(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            inverted: inverted,
            lottiePath: 'assets/lottie/email.json',
          ),
          const SizedBox(height: 12),

          // Số điện thoại
          _AuthInput(
            controller: phoneController,
            label: 'Số điện thoại',
            keyboardType: TextInputType.phone,
            validator:
                (value) =>
                    value == null || value.length < 10
                        ? 'Nhập số điện thoại hợp lệ'
                        : null,
            inverted: inverted,
            lottiePath: 'assets/lottie/phone.json',
          ),
          const SizedBox(height: 12),

          // Mật khẩu
          _AuthInput(
            controller: passwordController,
            label: 'Mật khẩu',
            obscureText: !isPasswordVisible,
            validator: Validators.password,
            inverted: inverted,
            lottiePath: 'assets/lottie/password.json',
            enableToggleObscure: true,
            onToggleObscure: onTogglePasswordVisibility,
          ),
          const SizedBox(height: 12),

          // Nhập lại mật khẩu
          _AuthInput(
            controller: confirmController,
            label: 'Nhập lại mật khẩu',
            obscureText: !isConfirmPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
            inverted: inverted,
            lottiePath: 'assets/lottie/confirm_password.json',
            enableToggleObscure: true,
            onToggleObscure: onToggleConfirmPasswordVisibility,
          ),
          const SizedBox(height: 24),

          Text(
            'Sau khi bấm đăng ký, hệ thống sẽ mở trang web Study Space để bạn hoàn tất thông tin.',
            style: bodyStyle,
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: inverted ? Colors.white : AppColors.primary,
                foregroundColor: inverted ? AppColors.primary : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
    this.lottiePath,
    this.enableToggleObscure = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool inverted;
  final String? lottiePath;
  final bool enableToggleObscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final textColor = inverted ? Colors.white : AppColors.text;
    final fillColor =
        inverted ? Colors.white.withOpacity(0.12) : Colors.grey.shade100;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: fillColor,
        prefixIcon:
            lottiePath == null
                ? null
                : SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset(
                    lottiePath!,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon:
            enableToggleObscure
                ? IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: inverted ? Colors.white70 : Colors.grey,
                  ),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
