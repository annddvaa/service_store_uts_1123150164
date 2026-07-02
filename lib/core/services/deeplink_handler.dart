import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart' as dio;

/// Mendengarkan callback deeplink dari emoneyservice setelah pembayaran.
///
/// Format callback yang diterima:
///   servicestore://payment-result?status=success&reference=...&transaction_id=TXN...
///   servicestore://payment-result?status=failed&reference=...&error=...
///   servicestore://payment-result?status=cancelled&reference=...
///
/// Mendukung dua skenario:
/// - **In-app**: app masih berjalan → [onPaymentResult] langsung dipanggil.
/// - **Cold-start**: app di-restart via deeplink → hasil disimpan di [_pendingResult]
///   dan bisa diambil via [consumePending()] oleh SplashPage.
class DeeplinkHandler {
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  /// Callback yang dipanggil ketika hasil pembayaran diterima (in-app).
  final void Function(PaymentResult result) onPaymentResult;

  /// Pending result untuk cold-start — diambil oleh SplashPage.
  static PaymentResult? _pendingResult;
  static bool isHandlingPayment = false;

  /// Ambil dan hapus pending payment result (dipanggil dari SplashPage).
  static PaymentResult? consumePending() {
    final result = _pendingResult;
    _pendingResult = null;
    if (result != null) isHandlingPayment = true;
    debugPrint('[DeeplinkHandler] consumePending: $result');
    return result;
  }

  static bool get hasPending => _pendingResult != null;

  DeeplinkHandler({required this.onPaymentResult})
      : _appLinks = AppLinks();

  Future<void> _updateBackendStatus(PaymentResult result) async {
    if (result.isSuccess) {
      try {
        await dio.DioClient.instance.post('/orders/complete-latest');
        debugPrint('[DeeplinkHandler] Berhasil update status pesanan terbaru menjadi selesai.');
      } catch (e) {
        debugPrint('[DeeplinkHandler] Gagal request update status: $e');
      }
    }
  }

  Future<void> init() async {
    debugPrint('[DeeplinkHandler] init() dipanggil');

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && _isPaymentCallback(initialUri)) {
        final result = _parseResult(initialUri);
        final prefs = await SharedPreferences.getInstance();
        final lastTxn = prefs.getString('last_txn_id');
        final lastRef = prefs.getString('last_ref_id');
        
        final isDuplicateTxn = result.transactionId != null && result.transactionId == lastTxn;
        final isDuplicateRef = result.reference != null && result.reference == lastRef;

        if (isDuplicateTxn || isDuplicateRef) {
          debugPrint('[DeeplinkHandler] Mengabaikan initial URI karena transaksi sudah diproses.');
        } else {
          _pendingResult = result;
          if (result.transactionId != null) {
            await prefs.setString('last_txn_id', result.transactionId!);
          }
          if (result.reference != null) {
            await prefs.setString('last_ref_id', result.reference!);
          }
          // Otomatis update status pesanan terbaru menjadi 'selesai' di backend
          _updateBackendStatus(result);
        }
      }
    } catch (e) {
      debugPrint('[DeeplinkHandler] getInitialLink error: $e');
    }

    // In-app: dengarkan deeplink yang masuk saat app sudah berjalan
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        debugPrint('[DeeplinkHandler] URI diterima: $uri');
        if (_isPaymentCallback(uri)) {
          final result = _parseResult(uri);
          
          final prefs = await SharedPreferences.getInstance();
          final lastTxn = prefs.getString('last_txn_id');
          final lastRef = prefs.getString('last_ref_id');
          
          final isDuplicateTxn = result.transactionId != null && result.transactionId == lastTxn;
          final isDuplicateRef = result.reference != null && result.reference == lastRef;

          if (isDuplicateTxn || isDuplicateRef) {
            debugPrint('[DeeplinkHandler] Mengabaikan stream URI karena transaksi sudah diproses.');
            return;
          }
          
          if (result.transactionId != null) {
            await prefs.setString('last_txn_id', result.transactionId!);
          }
          if (result.reference != null) {
            await prefs.setString('last_ref_id', result.reference!);
          }

          // Otomatis update status pesanan terbaru menjadi 'selesai' di backend
          _updateBackendStatus(result);
          
          DeeplinkHandler.isHandlingPayment = true;
          onPaymentResult(result);
        }
      },
      onError: (e) => debugPrint('[DeeplinkHandler] stream error: $e'),
    );
  }

  bool _isPaymentCallback(Uri uri) {
    return uri.scheme == 'servicestore' && uri.host == 'payment-result';
  }

  PaymentResult _parseResult(Uri uri) {
    final params = uri.queryParameters;
    final status = params['status'] ?? 'unknown';
    final reference = params['reference'];
    final transactionId = params['transaction_id'];
    final error = params['error'];

    debugPrint('[DeeplinkHandler] Payment result: status=$status, ref=$reference, txn=$transactionId');

    return PaymentResult(
      status: status,
      reference: reference,
      transactionId: transactionId,
      error: error,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// Hasil pembayaran yang diterima dari emoneyservice via deeplink callback.
class PaymentResult {
  final String status; // 'success', 'failed', 'cancelled'
  final String? reference;
  final String? transactionId;
  final String? error;

  const PaymentResult({
    required this.status,
    this.reference,
    this.transactionId,
    this.error,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() => 'PaymentResult(status=$status, ref=$reference, txn=$transactionId)';
}
