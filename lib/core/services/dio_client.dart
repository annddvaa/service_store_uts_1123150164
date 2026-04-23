import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'secure_storage.dart';

class DioClient {
  static Dio? _instance;
  
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }
  
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
      // Mengizinkan redirect dan status code error agar tidak langsung crash
      followRedirects: true,
      validateStatus: (status) => status! < 500, 
    ));
 
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Log URL lengkap untuk verifikasi IP
        debugPrint('🚀 [REQUEST] ${options.method} ${options.uri}');
        
        final token = await SecureStorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [RESPONSE] ${response.statusCode} | Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Detail error untuk melacak No route to host
        debugPrint('❌ [ERROR] Type: ${e.type}');
        debugPrint('❌ [ERROR] Message: ${e.message}');
        debugPrint('❌ [ERROR] URI: ${e.requestOptions.uri}');
        
        if (e.response?.statusCode == 401) {
          SecureStorageService.clearAll();
        }
        return handler.next(e);
      },
    ));
 
    return dio;
  }
}