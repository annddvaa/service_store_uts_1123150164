import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/routes/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/divider_with_text.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: ctrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final size = MediaQuery.of(context).size;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Masuk ke akun...',
      child: Scaffold(
        body: Column(
          children: [
            // ─── Hero Header ───────────────────────────────
            Container(
              height: size.height * 0.32,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo/logodavphone.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DavPhone Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solusi Service HP Terpercaya',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Form Section ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang 👋',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masuk untuk melanjutkan',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      const SizedBox(height: 28),

                      CustomTextField(
                        label: 'Email',
                        hint: 'Masukkan email Anda',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Email wajib diisi';
                          if (!EmailValidator.validate(v!)) return 'Format email salah';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Password',
                        hint: 'Masukkan password',
                        controller: _passCtrl,
                        obscureText: !_showPass,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPass = !_showPass),
                        ),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: const Text('Lupa Password?'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomButton(label: 'Masuk', onPressed: _loginEmail, isLoading: isLoading),
                      const SizedBox(height: 20),

                      const DividerWithText(text: 'atau masuk dengan'),
                      const SizedBox(height: 20),

                      GoogleSignInButton(onPressed: _loginGoogle, isLoading: isLoading),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRouter.register),
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
