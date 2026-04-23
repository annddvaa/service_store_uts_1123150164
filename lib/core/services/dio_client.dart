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
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      validateStatus: (status) => status! < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        
        final token = await SecureStorageService.getToken();

        if (token != null && token.isNotEmpty) {
          
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint(' [AUTH] Token ditemukan, menyuntikkan ke Header.');
        } else {
          debugPrint(' [AUTH] Tidak ada token di storage. Request dikirim tanpa header Auth.');
        }

        
        debugPrint(' [REQUEST] ${options.method} | ${options.uri}');
        if (options.data != null) debugPrint(' [BODY] ${options.data}');
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        
        debugPrint(' [RESPONSE] ${response.statusCode} | ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        
        debugPrint(' [ERROR] ${e.type} | Message: ${e.message}');
        debugPrint(' [ERROR] URL: ${e.requestOptions.uri}');

        if (e.response?.statusCode == 401) {
          debugPrint(' [401] Sesi habis atau token tidak valid. Membersihkan storage...');
          await SecureStorageService.clearAll();
          
        }

        return handler.next(e);
      },
    ));

    return dio;
  }
}