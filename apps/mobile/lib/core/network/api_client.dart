import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/network/api_exception.dart';
import 'package:vc_stocks_mobile/core/network/auth_interceptor.dart';
import 'package:vc_stocks_mobile/core/storage/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage: storage);
});

class ApiClient {
  late final Dio dio;

  ApiClient({required SecureStorageService storage}) {
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:4000');

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(storage: storage));
  }

  /// GET request, returns the `data` field from API response.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request, returns the `data` field from API response.
  Future<T> post<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request, returns the `data` field from API response.
  Future<T> put<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request, returns the `data` field from API response.
  Future<T> delete<T>(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Raw POST that returns the full Dio [Response] (used for login to extract token).
  Future<Response> postRaw(
    String path, {
    dynamic data,
  }) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return ApiException.fromJson(e.response!.data as Map<String, dynamic>);
    }
    return ApiException.unknown(e.message);
  }
}
