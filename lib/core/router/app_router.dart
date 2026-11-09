import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/inventory/presentation/food_detail_screen.dart';
import '../../features/inventory/presentation/add_edit_food_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/scan/presentation/scan_review_screen.dart';
import '../../features/planner/presentation/meal_plan_screen.dart';
import '../../features/shopping/presentation/shopping_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/notifications_screen.dart';
import '../../features/household/presentation/household_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../storage/secure_storage.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final token = await storage.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isAuthRoute = state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/register') ||
          state.uri.path.startsWith('/otp') ||
          state.uri.path.startsWith('/forgot-password');

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/inventory';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: '/planner',
            builder: (context, state) => const MealPlanScreen(),
          ),
          GoRoute(
            path: '/shopping',
            builder: (context, state) => const ShoppingListScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Sub-screens
      GoRoute(
        path: '/food-detail',
        builder: (context, state) {
          final foodId = state.extra as String? ?? '';
          return FoodDetailScreen(foodId: foodId);
        },
      ),
      GoRoute(
        path: '/add-edit-food',
        builder: (context, state) {
          final foodId = state.extra as String?;
          return AddEditFoodScreen(foodId: foodId);
        },
      ),
      GoRoute(
        path: '/scan-review',
        builder: (context, state) {
          final scanResult = state.extra;
          return ScanReviewScreen(scanResult: scanResult);
        },
      ),
      GoRoute(
        path: '/household',
        builder: (context, state) => const HouseholdScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
});

class MainShellScreen extends StatelessWidget {
  final Widget child;
  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/inventory')) return 0;
    if (location.startsWith('/scan')) return 1;
    if (location.startsWith('/planner')) return 2;
    if (location.startsWith('/shopping')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/inventory');
        break;
      case 1:
        context.go('/scan');
        break;
      case 2:
        context.go('/planner');
        break;
      case 3:
        context.go('/shopping');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen, color: primaryColor),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt, color: primaryColor),
            label: 'Quét',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: primaryColor),
            label: 'Kế hoạch',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: primaryColor),
            label: 'Mua sắm',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: primaryColor),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
