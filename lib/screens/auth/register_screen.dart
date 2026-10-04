import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_routes.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/validators.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/widgets/app_text_field.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create account', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to start organizing your boxes',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmController,
                  label: 'Confirm password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.confirmPassword(_passwordController),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  label: 'Register',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: AppTextStyles.bodySecondary,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}