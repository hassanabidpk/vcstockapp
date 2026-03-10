import 'package:dio/dio.dart';
import 'package:vc_stocks_mobile/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;

  AuthInterceptor({required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      storage.deleteToken();
    }
    handler.next(err);
  }
}
