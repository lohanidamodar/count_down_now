import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'pages/create_edit_countdown_page.dart';
import 'pages/countdown_view_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

/// Notifier to refresh GoRouter when auth state changes
class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  GoRouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

/// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterNotifier(ref);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isGoingToDashboard = state.matchedLocation == '/dashboard';
      final isGoingToLogin = state.matchedLocation == '/login';

      // Don't redirect while loading
      if (isLoading) return null;

      // Redirect to login if going to dashboard without auth
      if (isGoingToDashboard && !isAuthenticated) {
        return '/login';
      }

      // Redirect to dashboard if going to login while authenticated
      if (isGoingToLogin && isAuthenticated) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/create',
        name: 'create',
        builder: (context, state) {
          final countdownId = state.uri.queryParameters['id'];
          return CreateEditCountdownPage(countdownId: countdownId);
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/c/:slug',
        name: 'countdown',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CountdownViewPage(slug: slug);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.path}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
