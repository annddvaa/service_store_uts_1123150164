import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data pesanan dummy untuk tampilan — sesuaikan dengan API Anda
    final List<_OrderItem> dummyOrders = [
      _OrderItem(
        id: 'ORD-001',
        serviceName: 'Ganti Layar iPhone 14',
        date: '22 Jun 2026, 14:30',
        price: 850000,
        status: OrderStatus.selesai,
        note: 'Selesai — silakan ambil HP Anda',
      ),
      _OrderItem(
        id: 'ORD-002',
        serviceName: 'Ganti Baterai Samsung A53',
        date: '23 Jun 2026, 09:00',
        price: 350000,
        status: OrderStatus.dikerjakan,
        note: 'Sedang dalam proses perbaikan',
      ),
      _OrderItem(
        id: 'ORD-003',
        serviceName: 'Servis Charging Port Xiaomi',
        date: '24 Jun 2026, 11:00',
        price: 180000,
        status: OrderStatus.menunggu,
        note: 'Menunggu giliran dikerjakan',
      ),
    ];

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
      body: dummyOrders.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                // Filter tabs
                Container(
                  color: AppColors.primary,
                  child: Row(
                    children: [
                      _buildTab('Semua', true, context),
                      _buildTab('Aktif', false, context),
                      _buildTab('Selesai', false, context),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dummyOrders.length,
                    itemBuilder: (context, i) => _buildOrderCard(context, dummyOrders[i]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String label, bool isActive, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
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
    );
  }

  Widget _buildOrderCard(BuildContext context, _OrderItem order) {
    final statusColor = switch (order.status) {
      OrderStatus.menunggu => AppColors.warning,
      OrderStatus.dikerjakan => AppColors.info,
      OrderStatus.selesai => AppColors.success,
      OrderStatus.diambil => Colors.grey,
    };

    final statusLabel = switch (order.status) {
      OrderStatus.menunggu => 'Menunggu',
      OrderStatus.dikerjakan => 'Dikerjakan',
      OrderStatus.selesai => 'Selesai',
      OrderStatus.diambil => 'Sudah Diambil',
    };

    final statusIcon = switch (order.status) {
      OrderStatus.menunggu => Icons.hourglass_empty,
      OrderStatus.dikerjakan => Icons.build_circle_outlined,
      OrderStatus.selesai => Icons.check_circle_outline,
      OrderStatus.diambil => Icons.done_all,
    };

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
                  order.id,
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
                            order.serviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            order.date,
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
                          'Rp ${_formatPrice(order.price)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    if (order.status == OrderStatus.selesai)
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
      ),
    );
  }

  Widget _buildTimeline(OrderStatus status) {
    final steps = ['Diterima', 'Dikerjakan', 'Selesai', 'Diambil'];
    final currentStep = switch (status) {
      OrderStatus.menunggu => 0,
      OrderStatus.dikerjakan => 1,
      OrderStatus.selesai => 2,
      OrderStatus.diambil => 3,
    };

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

enum OrderStatus { menunggu, dikerjakan, selesai, diambil }

class _OrderItem {
  final String id;
  final String serviceName;
  final String date;
  final double price;
  final OrderStatus status;
  final String note;

  _OrderItem({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.price,
    required this.status,
    required this.note,
  });
}
