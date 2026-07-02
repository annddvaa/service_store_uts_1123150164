import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_color.dart';
import 'core/providers/theme_provider.dart';
import 'core/routes/app_router.dart';
import 'core/services/deeplink_handler.dart';
import 'core/services/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/dashboard/presentation/providers/product_provider.dart';
import 'features/orders/presentation/providers/order_provider.dart';
import 'firebase_options.dart';

/// Global navigator key — digunakan oleh DeeplinkHandler untuk menampilkan
/// SnackBar dan navigasi saat callback pembayaran diterima.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeeplinkHandler _deeplinkHandler;
  bool _isPaymentSheetOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    // Tutup bottom sheet secara otomatis jika user melakukan hot reload
    if (_isPaymentSheetOpen) {
      navigatorKey.currentState?.pop();
      _isPaymentSheetOpen = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _deeplinkHandler = DeeplinkHandler(
      onPaymentResult: _handlePaymentResult,
    );
    _deeplinkHandler.init();
  }

  @override
  void dispose() {
    _deeplinkHandler.dispose();
    super.dispose();
  }

  void _handlePaymentResult(PaymentResult result) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    if (result.isSuccess) {
      _isPaymentSheetOpen = true;
      // Tampilkan bottom sheet sukses pembayaran
      showModalBottomSheet(
        context: ctx,
        isDismissible: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 16),
              const Text('Pembayaran Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Pembayaran via Service Pay berhasil.\n'
                'Ref: ${result.transactionId ?? '-'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.warning, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimasi pengerjaan: 30 menit - 2 jam\ntergantung jenis kerusakan.',
                        style: TextStyle(fontSize: 12, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    DeeplinkHandler.isHandlingPayment = false;
                    Navigator.pushNamedAndRemoveUntil(ctx, '/dashboard', (r) => false);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('KEMBALI KE BERANDA'),
                ),
              ),
            ],
          ),
        ),
      ).then((_) {
        _isPaymentSheetOpen = false;
        DeeplinkHandler.isHandlingPayment = false;
      });
    } else if (result.isFailed) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Pembayaran gagal: ${result.error ?? 'Terjadi kesalahan'}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (result.isCancelled) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran dibatalkan'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'DavPhone Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  bool _isPaymentSheetOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    // Tutup bottom sheet secara otomatis jika user melakukan hot reload
    if (_isPaymentSheetOpen) {
      navigatorKey.currentState?.pop();
      _isPaymentSheetOpen = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Cek apakah ada pending payment result dari deeplink callback (cold-start)
    final pendingPayment = DeeplinkHandler.consumePending();

    final token = await SecureStorageService.getToken();

    if (token != null && mounted) {
      context.read<AuthProvider>().restoreSession(token);
    }

    if (pendingPayment != null) {
      debugPrint('[Splash] Pending payment ditemukan: ${pendingPayment.status}');
      if (mounted) {
        if (token != null) {
          _showPaymentResult(pendingPayment, () {
            DeeplinkHandler.isHandlingPayment = false;
            if (mounted) Navigator.pushReplacementNamed(context, AppRouter.dashboard);
          });
        } else {
          _showPaymentResult(pendingPayment, () {
            DeeplinkHandler.isHandlingPayment = false;
            if (mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
          });
        }
      }
    } else {
      // Tunggu jika ada proses deeplink stream yang sedang menampilkan pop-up
      while (DeeplinkHandler.isHandlingPayment && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final route = token != null ? AppRouter.dashboard : AppRouter.login;
      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }

  void _showPaymentResult(PaymentResult result, VoidCallback onDone) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      onDone();
      return;
    }

    if (result.isSuccess) {
      _isPaymentSheetOpen = true;
      showModalBottomSheet(
        context: ctx,
        isDismissible: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 16),
              const Text('Pembayaran Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Pembayaran via Service Pay berhasil.\n'
                'Ref: ${result.transactionId ?? '-'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.check_outlined),
                  label: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ).then((_) {
        _isPaymentSheetOpen = false;
        onDone();
      });
    } else if (result.isFailed) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Pembayaran gagal: ${result.error ?? 'Terjadi kesalahan'}'),
          backgroundColor: Colors.red,
        ),
      );
      onDone();
    } else if (result.isCancelled) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran dibatalkan'),
          backgroundColor: Colors.orange,
        ),
      );
      onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo/logodavphone.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'DavPhone Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solusi Service HP Terpercaya',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                    ),
                    const SizedBox(height: 60),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
