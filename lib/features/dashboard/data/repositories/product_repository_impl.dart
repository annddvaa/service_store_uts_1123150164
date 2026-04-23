import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      final response = await DioClient.instance.get(
        ApiConstants.products,
        queryParameters: {
          'page': page, 
          'limit': limit, 
          if (category != null) 'category': category // Hanya kirim jika tidak null
        },
      );

      // Cek apakah response.data ada dan memiliki key 'data'
      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> rawList = response.data['data'];
        
        // Menggunakan mapping yang lebih aman
        return rawList.map((e) {
          try {
            return ProductModel.fromJson(e as Map<String, dynamic>);
          } catch (e) {
            // Jika satu produk error parsing, kita log tapi jangan hentikan yang lain
            debugPrint("🚨 Gagal parsing satu produk: $e");
            return null; 
          }
        }).whereType<ProductModel>().toList(); // Hapus yang null
      }
      
      return [];
    } catch (e) {
      debugPrint("🚨 Error Fatal di getProducts: $e");
      // Lempar error agar ditangkap oleh Provider/UI
      throw Exception("Gagal memuat produk: $e");
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await DioClient.instance.get(
        '${ApiConstants.products}/$id',
      );
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      debugPrint("🚨 Error di getProductById: $e");
      throw Exception("Produk tidak ditemukan");
    }
  }
}
