import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/core/network/api_exception.dart';
import 'package:vc_stocks_mobile/features/auth/data/auth_repository.dart';
import 'package:vc_stocks_mobile/models/user.dart';

part 'auth_provider.g.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthStatus> build() async {
    final repository = ref.read(authRepositoryProvider);
    final isAuthenticated = await repository.isAuthenticated();
    return isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<User> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(username, password);
      state = const AsyncValue.data(AuthStatus.authenticated);
      return user;
    } on ApiException catch (e) {
      state = const AsyncValue.data(AuthStatus.unauthenticated);
      throw e;
    } catch (e, st) {
      state = const AsyncValue.data(AuthStatus.unauthenticated);
      throw ApiException.unknown(e.toString());
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }

  void forceLogout() {
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}
