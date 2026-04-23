import 'package:flutter/material.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> _items = [];
  bool _loading = false;

  List<CartModel> get items => _items;
  bool get isLoading => _loading;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  /// GET CART 
  Future<void> fetchCart() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await DioClient.instance.get('/cart');

      if (res.data['success'] == true) {
        final List data = res.data['data'];
        _items = data.map((e) => CartModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint(" fetchCart error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  /// ADD TO CART 
  Future<void> addToCart(int productId) async {
    try {
      await DioClient.instance.post('/cart', data: {
        'product_id': productId,
        'quantity': 1,
      });

      await fetchCart();
    } catch (e) {
      debugPrint(" addToCart error: $e");
    }
  }

  /// UPDATE QTY 
  Future<void> updateQty(int cartId, int qty) async {
    try {
      await DioClient.instance.put('/cart/$cartId', data: {
        'quantity': qty,
      });

      await fetchCart();
    } catch (e) {
      debugPrint(" updateQty error: $e");
    }
  }

  /// REMOVE ITEM 
  Future<void> removeItem(int cartId) async {
    try {
      await DioClient.instance.delete('/cart/$cartId');
      await fetchCart();
    } catch (e) {
      debugPrint(" removeItem error: $e");
    }
  }

  /// CLEAR CART 
  Future<void> clearCart() async {
    try {
      await DioClient.instance.delete('/cart');
      await fetchCart();
    } catch (e) {
      debugPrint(" clearCart error: $e");
    }
  }

  /// CHECKOUT 
  Future<bool> checkout() async {
    try {
      final res = await DioClient.instance.post('/cart/checkout');

      if (res.data['success'] == true) {
        _items = [];
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(" checkout error: $e");
      return false;
    }
  }
}