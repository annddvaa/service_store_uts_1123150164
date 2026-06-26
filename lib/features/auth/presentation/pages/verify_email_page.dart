import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/routes/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.checkEmailVerified();
      if (success && mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().resendVerificationEmail();

    setState(() { _resendCooldown = true; _countdown = 60; });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _countdown--; });
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Email verifikasi dikirim ulang!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          // ─── Header ──────────────────────────────────────
          Container(
            height: size.height * 0.38,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated email icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cek Email Kamu!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Link verifikasi sudah dikirim ke:',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.email ?? '-',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Steps info
                  ...[
                    ('1', 'Buka aplikasi email di HP Anda', Icons.email_outlined),
                    ('2', 'Cari email dari DavPhone Service', Icons.search),
                    ('3', 'Klik link "Verifikasi Email"', Icons.touch_app_outlined),
                  ].map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: Center(
                            child: Text(step.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(step.$3, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(step.$2, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 8),

                  // Polling indicator
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info),
                        ),
                        const SizedBox(width: 12),
                        const Text('Menunggu verifikasi secara otomatis...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Tombol kirim ulang
                  CustomButton(
                    label: _resendCooldown
                        ? 'Kirim Ulang ($_countdown detik)'
                        : 'Kirim Ulang Email',
                    variant: ButtonVariant.outlined,
                    onPressed: _resendCooldown ? null : _resendEmail,
                  ),
                  const SizedBox(height: 12),

                  // Logout
                  CustomButton(
                    label: 'Ganti Akun / Keluar',
                    variant: ButtonVariant.text,
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.pushReplacementNamed(context, AppRouter.login);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
