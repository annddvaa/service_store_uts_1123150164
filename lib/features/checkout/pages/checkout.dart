import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_color.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../orders/data/models/order_model.dart';

class CheckoutPage extends StatefulWidget {
  final OrderModel? pendingOrder;
  const CheckoutPage({super.key, this.pendingOrder});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late int _selectedPayment;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default 0, tapi kalau bayar ulang, set otomatis ke 3 (e-Money)
    _selectedPayment = widget.pendingOrder != null ? 3 : 0;
  }

  final List<_PaymentMethod> _payments = [
    _PaymentMethod('Tunai di Kasir', Icons.payments_outlined, 'Bayar langsung saat HP selesai'),
    _PaymentMethod('QRIS / Scan', Icons.qr_code_scanner, 'Bayar via QRIS semua e-wallet'),
    _PaymentMethod('Transfer Bank', Icons.account_balance_outlined, 'BCA, Mandiri, BNI, BRI'),
    _PaymentMethod('Service Pay (E-Money)', Icons.account_balance_wallet_outlined, 'Bayar via aplikasi Service Pay'),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final isRepayment = widget.pendingOrder != null;

    final totalItemsCount = isRepayment
        ? widget.pendingOrder!.items.fold<int>(0, (sum, i) => sum + i.quantity)
        : cart.totalItems;
    final totalPriceValue = isRepayment
        ? widget.pendingOrder!.totalPrice
        : cart.totalPrice;
    final displayItems = isRepayment
        ? widget.pendingOrder!.items
        : cart.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRepayment ? 'Bayar Ulang Pesanan' : 'Konfirmasi Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          children: [
            if (!isRepayment)
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildStep(1, 'Keranjang', true),
                    Expanded(child: Container(height: 2, color: AppColors.accent.withOpacity(0.5))),
                    _buildStep(2, 'Konfirmasi', true),
                    Expanded(child: Container(height: 2, color: Colors.white.withOpacity(0.2))),
                    _buildStep(3, 'Selesai', false),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Informasi Pemesan ──────────────────────────────
                    _buildSectionTitle('Informasi Pemesan', Icons.person_outline),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.firebaseUser?.displayName ?? 'Pelanggan',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(auth.firebaseUser?.email ?? '-', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Daftar Layanan ──────────────────────────────
                    _buildSectionTitle('Daftar Layanan', Icons.build_outlined),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayItems.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
                        itemBuilder: (context, i) {
                          final item = displayItems[i];
                          final name = isRepayment ? (item as OrderItemModel).productName : (item as dynamic).name;
                          final qty = isRepayment ? (item as OrderItemModel).quantity : (item as dynamic).quantity;
                          final price = isRepayment ? (item as OrderItemModel).price : (item as dynamic).price;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.build_circle, color: AppColors.accent, size: 20),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Qty: $qty  •  Garansi 7 Hari', style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              'Rp ${_formatPrice(price * qty)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 13),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Ringkasan ──────────────────────────────────
                    _buildSectionTitle('Ringkasan', Icons.receipt_long_outlined),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Harga ($totalItemsCount item)', style: const TextStyle(color: Colors.grey)),
                              Text('Rp ${_formatPrice(totalPriceValue)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Biaya Layanan', style: TextStyle(color: Colors.grey)),
                              Text('Rp 0', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                'Rp ${_formatPrice(totalPriceValue)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Metode Pembayaran ───────────────────────────
                    if (!isRepayment) ...[
                      _buildSectionTitle('Metode Pembayaran', Icons.payment_outlined),
                      ...List.generate(_payments.length, (i) {
                        final pm = _payments[i];
                        final isSelected = i == _selectedPayment;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPayment = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withOpacity(0.08)
                                  : Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : Theme.of(context).dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(pm.icon, color: isSelected ? AppColors.accent : Theme.of(context).iconTheme.color),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(pm.desc, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Radio<int>(
                                  value: i,
                                  groupValue: _selectedPayment,
                                  activeColor: AppColors.accent,
                                  onChanged: (v) => setState(() => _selectedPayment = v!),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // ─── Bottom Summary Panel ─────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          'Rp ${_formatPrice(totalPriceValue)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (displayItems.isEmpty) return;

                          if (isRepayment) {
                            if (_selectedPayment == 3) {
                              _launchEmoneyDeeplink(totalPriceValue, reference: 'ORDER_${widget.pendingOrder!.id}');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan ini hanya bisa dilanjutkan menggunakan e-Money.')));
                            }
                            return;
                          }

                          if (_selectedPayment == 3) {
                            double finalPrice = cart.totalPrice;
                            if (finalPrice <= 0) {
                              finalPrice = 50000;
                            }

                            _showLoadingDialog(context);
                            final orderId = await cart.checkout();
                            if (!mounted) return;
                            Navigator.pop(context); 
                            
                            if (orderId != null) {
                              // Gunakan real order ID dari database
                              await _launchEmoneyDeeplink(finalPrice, reference: 'ORDER_$orderId');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal membuat pesanan, coba lagi'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } else {
                            _showLoadingDialog(context);
                            final orderId = await cart.checkout();
                            if (!mounted) return;
                            Navigator.pop(context); 
                            
                            if (orderId != null) {
                              _showSuccessBottomSheet(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal membuat pesanan, coba lagi'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(isRepayment ? 'BAYAR SEKARANG' : 'KONFIRMASI PESANAN', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Membangun URL deeplink dan membuka aplikasi emoneyservice.
  Future<void> _launchEmoneyDeeplink(double totalPrice, {String? reference}) async {
    final ref = reference ?? 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    final amount = totalPrice.toStringAsFixed(0);

    // Bangun URI sebagai string manual agar format query parameter terjamin benar.
    final uriString = 'dompetkampus://pay'
        '?merchant_id=davphone_service'
        '&merchant_name=${Uri.encodeComponent('DavPhone Service')}'
        '&amount=$amount'
        '&description=${Uri.encodeComponent('Pembayaran Service HP')}'
        '&reference=$ref'
        '&callback=${Uri.encodeComponent('servicestore://payment-result')}';

    final uri = Uri.parse(uriString);

    debugPrint('[Checkout] totalPrice=$totalPrice, amount=$amount');
    debugPrint('[Checkout] Launching deeplink: $uri');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi Service Pay tidak ditemukan. Pastikan sudah diinstal.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Checkout] launchUrl error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka aplikasi Service Pay'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.accent),
                SizedBox(height: 16),
                Text('Memproses pesanan...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
            const Text('Pesanan Berhasil! 🎉', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Silakan serahkan HP Anda ke teknisi DavPhone.\nKami akan menghubungi Anda ketika HP sudah selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
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
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false),
                icon: const Icon(Icons.home_outlined),
                label: const Text('KEMBALI KE BERANDA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final IconData icon;
  final String desc;
  _PaymentMethod(this.name, this.icon, this.desc);
}
