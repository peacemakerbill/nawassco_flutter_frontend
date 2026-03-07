import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nawassco/shared/theme/app_theme.dart';

// Import existing screens
import 'features/accounts/presentation/screens/accounts_dashboard_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/user_management/user_detail_screen.dart';
import 'features/admin/presentation/screens/user_management/user_update_screen.dart';
import 'features/field_technician/dashboard/presentation/field_technician_dashboard.dart';
import 'features/human_resource/dashboard/presentation/screens/hr_dashboard.dart';
import 'features/manager/presentation/screens/manager_dashboard.dart';
import 'features/procurement/presentation/screens/procurement_dashboard.dart';
import 'features/public/about/presentation/screens/about_us_screen.dart';
import 'features/public/auth/presentation/confirm_email_verification_screen.dart';
import 'features/public/auth/presentation/forgot_password_screen.dart';
import 'features/public/auth/presentation/login_screen.dart';
import 'features/public/auth/presentation/register_screen.dart';
import 'features/public/auth/presentation/reset_password_screen.dart';
import 'features/public/auth/presentation/verify_email_screen.dart';
import 'features/public/auth/providers/auth_provider.dart';
import 'features/public/contact/presentation/screens/contact_us_screen.dart';
import 'features/public/profile/presentation/profile_screen.dart';
import 'features/public/profile/presentation/screens/edit_profile_screen.dart';
import 'features/sales/presentation/sales_dashboard.dart';
import 'features/stores/presentation/screens/stores_dashboard_screen.dart';
import 'features/supplier/presentation/screens/supplier_dashboard_screen.dart';
import 'features/user/presentation/user_dashboard.dart';

// ---------------------------------------------------------------------
//  DASHBOARD → ROLE MAPPING
// ---------------------------------------------------------------------
const Map<String, String> _dashboardRoleMap = {
  '/admin': 'Admin',
  '/sales': 'SalesAgent',
  '/accounts': 'Accounts',
  '/manager': 'Manager',
  '/hr': 'HR',
  '/procurement': 'Procurement',
  '/supplier': 'Supplier',
  '/technician': 'Technician',
  '/stores': 'StoreManager',
  '/dashboard': 'User',
};

/// Returns the correct dashboard path based on user's roles
String _getDefaultDashboard(List<String> roles) {
  // Check for specific department roles first
  if (roles.contains('Admin')) return '/admin';
  if (roles.contains('SalesAgent')) return '/sales';
  if (roles.contains('Accounts')) return '/accounts';
  if (roles.contains('Manager')) return '/manager';
  if (roles.contains('HR')) return '/hr';
  if (roles.contains('Procurement')) return '/procurement';
  if (roles.contains('Supplier')) return '/supplier';
  if (roles.contains('Technician')) return '/technician';
  if (roles.contains('StoreManager')) return '/stores';

  // Default fallback
  return '/dashboard';
}

// ---------------------------------------------------------------------
//  ROUTE GROUPS
// ---------------------------------------------------------------------
class _RouteGroups {
  // ==================== PUBLIC ROUTES ====================
  static final publicRoutes = [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/verify-email',
      builder: (_, state) {
        final email = state.uri.queryParameters['email'];
        return VerifyEmailScreen(email: email);
      },
    ),
    GoRoute(
      path: '/confirm-email-verification',
      builder: (_, state) {
        final token = state.uri.queryParameters['token'];
        return ConfirmEmailVerificationScreen(token: token);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, state) => ResetPasswordScreen(
        token: state.uri.queryParameters['token'] ?? '',
      ),
    ),
    GoRoute(path: '/about', builder: (_, __) => const AboutUsScreen()),
    GoRoute(path: '/contact', builder: (_, __) => const ContactUsScreen()),
  ];

  // ==================== USER ROUTES ====================
  static final userRoutes = [
    // Profile routes
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(
      path: '/profile-edit',
      builder: (_, __) => const EditProfileScreen(),
    ),

    // User dashboard
    GoRoute(path: '/dashboard', builder: (_, __) => const UserDashboard()),

    // User feature routes (redirect to dashboard for internal navigation)
    GoRoute(
      path: '/payment',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/controller-payments',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/services',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/service-management',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/outage-map',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/resources',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/opportunities',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const UserDashboard(),
    ),
    GoRoute(
      path: '/consumption',
      builder: (_, __) => const UserDashboard(),
    ),
  ];

  // ==================== SALES ROUTES ====================
  static final salesRoutes = [
    GoRoute(path: '/sales', builder: (_, __) => const SalesDashboard()),
  ];

  // ==================== ADMIN ROUTES ====================
  static final adminRoutes = [
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'users',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'users/:id',
          builder: (context, state) =>
              UserDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'users/:id/edit',
          builder: (context, state) =>
              UserUpdateScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'controller',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'operations',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'services',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'analytics',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    ),
  ];

  // ==================== ACCOUNTS ROUTES ====================
  static final accountsRoutes = [
    GoRoute(
      path: '/accounts',
      builder: (_, __) => const AccountsDashboardScreen(),
    ),
  ];

  // ==================== MANAGER ROUTES ====================
  static final managerRoutes = [
    GoRoute(path: '/manager', builder: (_, __) => const ManagerDashboard()),
  ];

  // ==================== HR ROUTES ====================
  static final hrRoutes = [
    GoRoute(path: '/hr', builder: (_, __) => const HRDashboard()),
  ];

  // ==================== PROCUREMENT ROUTES ====================
  static final procurementRoutes = [
    GoRoute(
      path: '/procurement',
      builder: (_, __) => const ProcurementDashboard(),
    ),
  ];

  // ==================== SUPPLIER ROUTES ====================
  static final supplierRoutes = [
    GoRoute(
      path: '/supplier',
      builder: (context, state) => const SupplierDashboardScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
        GoRoute(
          path: 'tenders',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
        GoRoute(
          path: 'quotations',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
        GoRoute(
          path: 'purchase-orders',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
        GoRoute(
          path: 'deliveries',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
        GoRoute(
          path: 'invoices',
          builder: (context, state) => const SupplierDashboardScreen(),
        ),
      ],
    ),
  ];

  // ==================== TECHNICIAN ROUTES ====================
  static final technicianRoutes = [
    GoRoute(
      path: '/technician',
      builder: (context, state) => const FieldTechnicianDashboard(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'work-orders',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'map-view',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'inventory',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const FieldTechnicianDashboard(),
        ),
      ],
    ),
  ];

  // ==================== STORES ROUTES ====================
  static final storesRoutes = [
    GoRoute(
      path: '/stores',
      builder: (context, state) => const StoresDashboardScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'inventory',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'procurement',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'transactions',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'suppliers',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
        GoRoute(
          path: 'admin',
          builder: (context, state) => const StoresDashboardScreen(),
        ),
      ],
    ),
  ];
}

// ---------------------------------------------------------------------
//  GO ROUTER PROVIDER (WITH ROLE-BASED DASHBOARD PROTECTION)
// ---------------------------------------------------------------------
final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final loggedIn = auth.isAuthenticated;
  final roles = (auth.user?['roles'] as List<dynamic>?)
      ?.cast<String>()
      .toSet()
      .toList() ??
      <String>[];

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final path = state.uri.path;

      // =============================================================
      // 1. UNAUTHENTICATED USERS → Force login
      // =============================================================
      if (!loggedIn) {
        final isPublic = _RouteGroups.publicRoutes
            .any((route) => path.startsWith(route.path));
        if (!isPublic) {
          return '/login';
        }
        return null;
      }

      // =============================================================
      // 2. AUTHENTICATED USERS → Redirect from auth screens
      // =============================================================
      if (path == '/login' || path == '/register') {
        return _getDefaultDashboard(roles);
      }

      // =============================================================
      // 3. DASHBOARD ACCESS CONTROL
      //    - Block access to dashboards user doesn't have role for
      // =============================================================
      final requiredRole = _dashboardRoleMap[path];
      if (requiredRole != null && !roles.contains(requiredRole)) {
        return _getDefaultDashboard(roles);
      }

      // =============================================================
      // 4. DEPARTMENT ROUTES ACCESS CONTROL
      // =============================================================
      // Accounts billing_routes
      if (path.startsWith('/accounts') && !roles.contains('Accounts')) {
        return _getDefaultDashboard(roles);
      }

      // Manager billing_routes
      if (path.startsWith('/manager') && !roles.contains('Manager')) {
        return _getDefaultDashboard(roles);
      }

      // HR billing_routes
      if (path.startsWith('/hr') && !roles.contains('HR')) {
        return _getDefaultDashboard(roles);
      }

      // Procurement billing_routes
      if (path.startsWith('/procurement') && !roles.contains('Procurement')) {
        return _getDefaultDashboard(roles);
      }

      // Supplier billing_routes
      if (path.startsWith('/supplier') && !roles.contains('Supplier')) {
        return _getDefaultDashboard(roles);
      }

      // Technician billing_routes
      if (path.startsWith('/technician') && !roles.contains('Technician')) {
        return _getDefaultDashboard(roles);
      }

      // Stores billing_routes
      if (path.startsWith('/stores') && !roles.contains('StoreManager')) {
        return _getDefaultDashboard(roles);
      }

      // Admin billing_routes
      if (path.startsWith('/admin') && !roles.contains('Admin')) {
        return _getDefaultDashboard(roles);
      }

      // =============================================================
      // 5. No redirect needed
      // =============================================================
      return null;
    },
    routes: [
      // ==================== PUBLIC ROUTES ====================
      ..._RouteGroups.publicRoutes,

      // ==================== USER ROUTES ====================
      ..._RouteGroups.userRoutes,

      // ==================== DEPARTMENT ROUTES ====================
      ..._RouteGroups.salesRoutes,
      ..._RouteGroups.accountsRoutes,
      ..._RouteGroups.managerRoutes,
      ..._RouteGroups.hrRoutes,
      ..._RouteGroups.procurementRoutes,
      ..._RouteGroups.supplierRoutes,
      ..._RouteGroups.technicianRoutes,
      ..._RouteGroups.storesRoutes,
      ..._RouteGroups.adminRoutes,
    ],
  );
});

// ---------------------------------------------------------------------
//  MAIN APP WIDGET
// ---------------------------------------------------------------------
class NawasscoApp extends ConsumerWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const NawasscoApp({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'NAWASSCO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}