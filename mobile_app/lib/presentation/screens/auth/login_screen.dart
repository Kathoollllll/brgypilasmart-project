import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/common/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _svc   = AuthService();

  bool _loading = false;
  bool _showPass = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      AppUtils.showSnack(context, 'Login failed. Check your credentials.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.chipBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.account_balance, color: AppColors.primary, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(AppConstants.appName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('WELCOME!',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSub, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                const Text('Please log in to access your account.',
                  style: TextStyle(color: AppColors.textSub, fontSize: 13)),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Mobile number or email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppUtils.validateEmail,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  controller: _pass,
                  obscure: !_showPass,
                  validator: AppUtils.validatePassword,
                  suffix: IconButton(
                    icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 20, color: AppColors.textSub),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPassword(),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton(label: 'Login', onPressed: _login, loading: _loading),
                const SizedBox(height: 16),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: AppColors.textSub, fontSize: 12))), Expanded(child: Divider())]),
                const SizedBox(height: 16),
                AppButton(label: 'Create Account', onPressed: () => Navigator.pushNamed(context, AppRoutes.register), outlined: true),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: AppTextField(label: 'Email address', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _svc.resetPassword(emailCtrl.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
              AppUtils.showSnack(context, 'Reset email sent!');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
