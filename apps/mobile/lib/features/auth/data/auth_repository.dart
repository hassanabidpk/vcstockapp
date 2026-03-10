import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/api_endpoints.dart';
import 'package:vc_stocks_mobile/core/network/api_client.dart';
import 'package:vc_stocks_mobile/core/storage/secure_storage.dart';
import 'package:vc_stocks_mobile/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    client: ref.read(apiClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

class AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  AuthRepository({
    required ApiClient client,
    required SecureStorageService storage,
  })  : _client = client,
        _storage = storage;

  Future<User> login(String username, String password) async {
    final response = await _client.postRaw(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );

    final responseData = response.data['data'] as Map<String, dynamic>;

    // Try token from JSON body first (new backend), then fall back to Set-Cookie header
    String? token = responseData['token'] as String?;
    if (token == null || token.isEmpty) {
      token = _extractTokenFromCookies(response.headers['set-cookie']);
    }
    if (token == null || token.isEmpty) {
      throw Exception('No auth token received from server');
    }

    await _storage.saveToken(token);
    return User.fromJson(responseData['user'] as Map<String, dynamic>);
  }

  String? _extractTokenFromCookies(List<String>? cookies) {
    if (cookies == null) return null;
    for (final cookie in cookies) {
      if (cookie.startsWith('token=')) {
        final value = cookie.split(';').first.substring('token='.length);
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } finally {
      await _storage.deleteToken();
    }
  }

  Future<bool> isAuthenticated() async {
    return _storage.hasToken();
  }
}
