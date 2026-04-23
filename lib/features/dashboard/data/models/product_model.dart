import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // 1. GORM secara default menggunakan ID (Huruf Kapital)
      id: json['ID'] as int? ?? 0, 
      
      // 2. Gunakan nilai default jika data null dari backend
      name: json['name'] as String? ?? 'Tanpa Nama',
      
      // 3. Konversi price ke double dengan aman
      price: (json['price'] as num? ?? 0).toDouble(),
      
      // 4. Samakan key dengan log: image_url dan category
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
    );
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}