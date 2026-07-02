import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_color.dart';
import '../providers/order_provider.dart';
import '../../data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Fetch orders saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter tabs
              Container(
                color: AppColors.primary,
                child: Row(
                  children: [
                    _buildTab('Semua', 0, provider),
                    _buildTab('Aktif', 1, provider),
                    _buildTab('Selesai', 2, provider),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.error.isNotEmpty
                        ? Center(child: Text(provider.error))
                        : provider.filteredOrders.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchOrders(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: provider.filteredOrders.length,
                                  itemBuilder: (context, i) =>
                                      _buildOrderCard(context, provider.filteredOrders[i]),
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int tabIndex, OrderProvider provider) {
    final isActive = provider.currentTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTab(tabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.accent : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? AppColors.accent : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    // Generate label and color based on real status from API
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (order.status) {
      case 'dikerjakan':
        statusColor = AppColors.info;
        statusLabel = 'Dikerjakan';
        statusIcon = Icons.build_circle_outlined;
        break;
      case 'selesai':
        statusColor = AppColors.success;
        statusLabel = 'Selesai';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'diambil':
        statusColor = Colors.grey;
        statusLabel = 'Sudah Diambil';
        statusIcon = Icons.done_all;
        break;
      case 'menunggu':
      default:
        statusColor = AppColors.warning;
        statusLabel = 'Menunggu';
        statusIcon = Icons.hourglass_empty;
    }

    // Ambil nama layanan dari item pertama (bisa dikembangkan jika multiple items)
    String serviceName = order.items.isNotEmpty ? order.items.first.productName : 'Layanan Servis';
    if (order.items.length > 1) {
      serviceName += ' (+${order.items.length - 1} lainnya)';
    }

    // Format tanggal
    String dateStr = order.createdAt;
    try {
      final date = DateTime.parse(order.createdAt).toLocal();
      dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetail(context, order),
          child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ORD-${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama layanan
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.build_circle, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dateStr,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Timeline Progress
                _buildTimeline(order.status),
                const SizedBox(height: 12),

                Divider(height: 1, color: Theme.of(context).dividerColor),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Biaya', style: TextStyle(fontSize: 12)),
                        Text(
                          'Rp ${_formatPrice(order.totalPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    if (order.status == 'selesai')
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.star_border, size: 16),
                        label: const Text('Beri Ulasan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ), // end Column
      ), // end InkWell
      ), // end Material
    ); // end Container
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Pesanan (ORD-${order.id})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Rincian Layanan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.build_circle, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${item.quantity}x @ Rp ${_formatPrice(item.price)}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(item.price * item.quantity)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Biaya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        'Rp ${_formatPrice(order.totalPrice)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Pembayaran', style: TextStyle(fontSize: 14)),
                      Text(
                        order.paymentStatus == 'paid' ? 'Lunas' : 'Belum Dibayar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: order.paymentStatus == 'paid' ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeline(String status) {
    final steps = ['Diterima', 'Dikerjakan', 'Selesai', 'Diambil'];
    int currentStep;
    switch (status) {
      case 'dikerjakan':
        currentStep = 1;
        break;
      case 'selesai':
        currentStep = 2;
        break;
      case 'diambil':
        currentStep = 3;
        break;
      case 'menunggu':
      default:
        currentStep = 0;
    }

    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final label = entry.value;
        final isDone = i <= currentStep;
        final isCurrent = i == currentStep;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.accent : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 8)]
                          : [],
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? AppColors.accent : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: i < currentStep ? AppColors.accent : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          const Text('Belum Ada Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pesan layanan servis pertama Anda sekarang!', textAlign: TextAlign.center),
        ],
      ),
    );
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
}
