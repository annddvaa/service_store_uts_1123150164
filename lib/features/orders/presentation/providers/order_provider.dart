import 'package:flutter/material.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../main.dart';
import '../../data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  bool isLoading = false;
  List<OrderModel> orders = [];
  String error = '';

  // Tab yang sedang aktif: 0 = Semua, 1 = Aktif, 2 = Selesai
  int currentTab = 0;

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final response = await DioClient.instance.get('/orders');
      
      final ctx = navigatorKey.currentContext;

      if (response.data != null && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        orders = data.map((json) => OrderModel.fromJson(json)).toList();
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Berhasil fetch! Total: ${orders.length} pesanan')),
          );
        }
      } else {
        error = 'Gagal mengambil data pesanan';
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Failed: ${response.data}')),
          );
        }
      }
    } catch (e) {
      error = 'Gagal mengambil data pesanan. Silakan coba lagi.';
      debugPrint("fetchOrders error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Mengembalikan data pesanan yang sudah difilter sesuai tab yang dipilih
  List<OrderModel> get filteredOrders {
    if (currentTab == 1) {
      // Aktif = menunggu atau dikerjakan
      return orders.where((o) => o.status == 'menunggu' || o.status == 'dikerjakan').toList();
    } else if (currentTab == 2) {
      // Selesai = selesai atau diambil
      return orders.where((o) => o.status == 'selesai' || o.status == 'diambil').toList();
    }
    // Semua
    return orders;
  }
}
