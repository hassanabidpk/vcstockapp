import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/auth/presentation/login_screen.dart';
import 'package:vc_stocks_mobile/features/auth/providers/auth_provider.dart';
import 'package:vc_stocks_mobile/features/crypto_detail/presentation/crypto_detail_screen.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:vc_stocks_mobile/features/chat/presentation/chat_screen.dart';
import 'package:vc_stocks_mobile/features/explore/presentation/explore_screen.dart';
import 'package:vc_stocks_mobile/features/stock_detail/presentation/stock_detail_screen.dart';
import 'package:vc_stocks_mobile/shared/widgets/app_scaffold.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// A [ChangeNotifier] that bridges Riverpod auth state changes into
/// GoRouter's [refreshListenable], so the router re-evaluates its
/// redirect without being fully recreated (which would duplicate GlobalKeys).
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final authChangeNotifier = _AuthChangeNotifier();

  // Listen (not watch!) so the provider is NOT rebuilt on auth changes.
  // Instead we just poke the notifier so GoRouter re-runs redirect.
  ref.listen(authNotifierProvider, (_, __) {
    authChangeNotifier.notify();
  });

  ref.onDispose(() {
    authChangeNotifier.dispose();
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      // Read (not watch) the current auth status at redirect time.
      final status = ref.read(authNotifierProvider).valueOrNull;
      final isLoginRoute = state.matchedLocation == '/login';

      if (status == AuthStatus.unauthenticated && !isLoginRoute) {
        return '/login';
      }
      if (status == AuthStatus.authenticated && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final currentIndex = _calculateSelectedIndex(state);
          return AppScaffold(
            currentIndex: currentIndex,
            onTabChanged: (index) {
              switch (index) {
                case 0:
                  context.go('/dashboard');
                case 1:
                  context.go('/explore');
                case 2:
                  context.go('/chat');
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExploreScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/stock/:symbol',
        builder: (context, state) => StockDetailScreen(
          symbol: state.pathParameters['symbol']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/crypto/:coinId',
        builder: (context, state) => CryptoDetailScreen(
          coinId: state.pathParameters['coinId']!,
          name: state.uri.queryParameters['name'] ?? '',
        ),
      ),
    ],
  );
}

int _calculateSelectedIndex(GoRouterState state) {
  final location = state.matchedLocation;
  if (location.startsWith('/explore')) return 1;
  if (location.startsWith('/chat')) return 2;
  return 0;
}
