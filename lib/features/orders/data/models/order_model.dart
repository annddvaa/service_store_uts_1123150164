class OrderModel {
  final int id;
  final int userId;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['order_items'] as List? ?? [];
    List<OrderItemModel> items =
        itemsList.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderModel(
      id: json['ID'] ?? 0,
      userId: json['user_id'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'menunggu',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['CreatedAt'] ?? '',
      items: items,
    );
  }
}

class OrderItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final String productName;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.productName,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['ID'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      productName: json['product']?['name'] ?? 'Produk',
    );
  }
}
