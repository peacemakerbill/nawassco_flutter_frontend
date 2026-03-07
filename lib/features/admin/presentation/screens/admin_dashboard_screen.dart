import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../constants/admin_colors.dart';
import '../widgets/shared/admin_sidebar.dart';
import 'user_management/user_list_screen.dart';
import 'billing_management/billing_dashboard_screen.dart';
import 'water_operations/operations_dashboard_screen.dart';
import 'service_management/service_requests_screen.dart';
import 'analytics_reports/analytics_dashboard_screen.dart';
import 'system_admin/system_settings_screen.dart';
import '../widgets/dashboard/dashboard_content.dart';
import '../widgets/shared/admin_app_bar.dart';
import '../widgets/shared/mobile_bottom_nav_bar.dart';
import '../widgets/shared/more_options_bottom_sheet.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isSidebarOpen = false;
  String _currentRoute = '/admin/dashboard';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/admin/dashboard'},
    {'icon': Icons.people, 'label': 'User Management', 'route': '/admin/users'},
    {'icon': Icons.receipt_long, 'label': 'Billing & Revenue', 'route': '/admin/controller'},
    {'icon': Icons.water_drop, 'label': 'Water Operations', 'route': '/admin/operations'},
    {'icon': Icons.support_agent, 'label': 'Service Requests', 'route': '/admin/services'},
    {'icon': Icons.analytics, 'label': 'Analytics & Reports', 'route': '/admin/analytics'},
    {'icon': Icons.settings, 'label': 'System Settings', 'route': '/admin/settings'},
  ];

  final Map<String, Widget> _screens = {
    '/admin/users': const UserListScreen(),
    '/admin/controller': const BillingDashboardScreen(),
    '/admin/operations': const OperationsDashboardScreen(),
    '/admin/services': const ServiceRequestsScreen(),
    '/admin/analytics': const AnalyticsDashboardScreen(),
    '/admin/settings': const SystemSettingsScreen(),
  };

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
    if (MediaQuery.of(context).size.width < 1024) {
      setState(() => _isSidebarOpen = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout(context);
    }
  }

  Widget _getCurrentContent() {
    final user = ref.read(authProvider).user!;

    // Handle dashboard content separately
    if (_currentRoute == '/admin/dashboard') {
      return DashboardContent(
        user: user,
        onNavigate: _navigateTo,
      );
    }

    // Return other screens
    return _screens[_currentRoute] ?? DashboardContent(user: user, onNavigate: _navigateTo);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth < 1024;

    // For mobile, show bottom nav with first 4 items + more
    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();
    final currentIndex = visibleTabs.indexWhere((item) => item['route'] == _currentRoute);

    return Scaffold(
      backgroundColor: AdminColors.background,
      // Mobile Bottom Navigation
      bottomNavigationBar: isMobile
          ? MobileBottomNavBar(
        visibleTabs: visibleTabs,
        moreTabs: moreTabs,
        currentIndex: currentIndex,
        onTabSelected: _navigateTo,
        onMoreSelected: () => _showMoreOptions(context, moreTabs),
      )
          : null,
      body: Stack(
        children: [
          // Main content area
          Column(
            children: [
              // App Bar - Always visible
              AdminAppBar(
                user: user,
                isMobile: isMobile,
                currentRoute: _currentRoute,
                menuItems: _menuItems,
                onToggleSidebar: _toggleSidebar,
                onNavigateToProfile: () => context.go('/profile'),
                onLogout: _showLogoutDialog,
              ),

              // Content area
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(
                    left: (_isSidebarOpen && !isMobile) ? 280 : 0,
                  ),
                  child: _getCurrentContent(),
                ),
              ),
            ],
          ),

          // Sidebar overlay for mobile
          if (isMobile && _isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Sidebar
          if (!isMobile)
            _buildDesktopSidebar(),
          if (isMobile)
            _buildMobileSidebar(),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: AdminSidebar(
        isOpen: _isSidebarOpen,
        currentRoute: _currentRoute,
        onNavigate: _navigateTo,
        onToggle: _toggleSidebar,
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: AdminSidebar(
        isOpen: _isSidebarOpen,
        currentRoute: _currentRoute,
        onNavigate: _navigateTo,
        onToggle: _toggleSidebar,
      ),
    );
  }

  void _showMoreOptions(BuildContext context, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MoreOptionsBottomSheet(
        items: items,
        onItemSelected: (route) {
          Navigator.pop(context);
          _navigateTo(route);
        },
      ),
    );
  }
}