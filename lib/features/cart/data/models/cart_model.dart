class CartModel {
  final int id;
  final int productId;
  final int quantity;

  final String name;
  final double price;
  final String imageUrl;

  CartModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return CartModel(
      // handle ID / id
      id: json['ID'] ?? json['id'] ?? 0,

      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,

      // SAFE parsing
      name: product?['name'] ?? 'Tanpa Nama',
      price: (product?['price'] as num? ?? 0).toDouble(),
      imageUrl: product?['image_url'] ?? '',
    );
  }
}