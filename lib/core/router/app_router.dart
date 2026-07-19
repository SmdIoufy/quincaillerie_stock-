import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/audit/screens/audit_page.dart';
import '../../features/catalogue/screens/catalogue_page.dart';
import '../../features/dashboard/screens/dashboard_admin_screen.dart';
import '../../features/dashboard/screens/dashboard_gerant_screen.dart';
import '../../features/stats/screens/stats_page.dart';
import '../../features/stock/screens/stock_page.dart';
import '../../features/users/screens/users_page.dart';
import '../../features/vente/screens/ventes_page.dart';
import '../../providers/auth_provider.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/splash_screen.dart';
// Ajouter cet import en haut
import '../../features/inventaire/screens/inventaire_list_screen.dart';

class AppRouter {
  AppRouter(this.auth);

  final AuthProvider auth;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) {
          final role = auth.user?.role ?? '';
          return role == 'ADMIN' ? '/dashboard-admin' : '/dashboard-gerant';
        },
      ),
      GoRoute(
        path: '/dashboard-admin',
        builder: (context, state) => const DashboardAdminScreen(),
      ),
      GoRoute(
        path: '/dashboard-gerant',
        builder: (context, state) => const DashboardGerantScreen(),
      ),
      // Ajouter la route pour InventaireListScreen
      // Ajouter cette route avec les autres GoRoute
      GoRoute(
          path: '/inventaire',
          builder: (_, __) => const InventaireListScreen()),
      GoRoute(path: '/ventes', builder: (_, __) => const VentesPage()),
      GoRoute(path: '/stock', builder: (_, __) => const StockPage()),
      GoRoute(path: '/stats', builder: (_, __) => const StatsPage()),
      GoRoute(path: '/catalogue', builder: (_, __) => const CataloguePage()),
      GoRoute(path: '/users', builder: (_, __) => const UsersPage()),
      GoRoute(path: '/audit', builder: (_, __) => const AuditPage()),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final isSplash = location == '/';
      final isLogin = location == '/login';
      final isForgotPassword = location == '/forgot-password';

      if (!auth.isInitialized) {
        return isSplash ? null : '/';
      }

      if (!auth.isLoggedIn) {
        return (isLogin || isForgotPassword) ? null : '/login';
      }

      final role = auth.user?.role ?? '';
      final target = role == 'ADMIN' ? '/dashboard-admin' : '/dashboard-gerant';

      if (isSplash || isLogin || isForgotPassword) {
        return target;
      }

      if (location == '/dashboard-admin' && role != 'ADMIN') {
        return target;
      }

      if (location == '/dashboard-gerant' && role == 'ADMIN') {
        return target;
      }

      const adminOnly = ['/users', '/audit'];
      if (adminOnly.contains(location) && role != 'ADMIN') {
        return '/dashboard-gerant';
      }

      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Route introuvable: ${state.uri.path}'),
        ),
      );
    },
  );
}
