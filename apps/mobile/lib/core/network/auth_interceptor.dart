import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vc_stocks_mobile/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;

  /// Called after the token is cleared on a 401 response, so the app
  /// can transition to the unauthenticated state and redirect to login.
  final VoidCallback? onUnauthorized;

  AuthInterceptor({required this.storage, this.onUnauthorized});

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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await storage.deleteToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
