import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import '../content/inventory_content.dart';
import '../content/stock_movement_content.dart';
import '../content/stock_take_content.dart';
import '../content/store_manager_profile_content.dart';
import '../content/store_managers_management_content.dart';
import '../content/store_settings_content.dart';
import '../content/warehouse_content.dart';
import '../content/dashboard_content.dart';


class StoresDashboardScreen extends ConsumerStatefulWidget {
  const StoresDashboardScreen({super.key});

  @override
  ConsumerState<StoresDashboardScreen> createState() => _StoresDashboardScreenState();
}

class _StoresDashboardScreenState extends ConsumerState<StoresDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/stores/dashboard';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/stores/dashboard'},
    {'icon': Icons.inventory, 'label': 'Inventory', 'route': '/stores/inventory'},
    {'icon': Icons.warehouse, 'label': 'Warehouses', 'route': '/stores/warehouses'},
    {'icon': Icons.swap_horiz, 'label': 'Stock Movements', 'route': '/stores/stock-movements'},
    {'icon': Icons.inventory_2, 'label': 'Stock Takes', 'route': '/stores/stock-takes'},
    {'icon': Icons.person, 'label': 'Store Manager', 'route': '/stores/store-manager'},
    {'icon': Icons.people, 'label': 'Manage Managers', 'route': '/stores/manage-managers'},
    {'icon': Icons.settings, 'label': 'Store Settings', 'route': '/stores/settings'},
  ];

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
      final visibleTabs = _menuItems.take(4).toList();
      _selectedIndex = visibleTabs.indexWhere((item) => item['route'] == route);
      if (_selectedIndex == -1) {
        _selectedIndex = 0;
      }
      _isSidebarOpen = false;
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/stores/dashboard':
        return DashboardContent(onNavigate: _navigateToRoute);
      case '/stores/inventory':
        return const InventoryContent();
      case '/stores/warehouses':
        return const WarehouseScreen();
      case '/stores/stock-movements':
        return const StockMovementContent();
      case '/stores/stock-takes':
        return const StockTakeContent();
      case '/stores/store-manager':
        return const StoreManagerProfileContent();
      case '/stores/manage-managers':
        return const StoreManagerManagementContent();
      case '/stores/settings':
        return const StoreSettingsScreen();
      default:
        return DashboardContent(onNavigate: _navigateToRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        title: Text(
          _menuItems.firstWhere(
                (item) => item['route'] == _currentRoute,
            orElse: () => _menuItems.first,
          )['label'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: !isMobile
            ? IconButton(
          icon: Icon(
            _isSidebarOpen ? Icons.close : Icons.menu,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: UserAvatar(imageUrl: profilePic, radius: 18),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 22),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 260 : 0),
            child: _getCurrentContent(),
          ),

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

          if (!isMobile)
            _buildDesktopSidebar(),
          if (isMobile)
            _buildMobileSidebar(),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeSelectedIndex,
          onTap: (index) {
            if (index == 4 && moreTabs.isNotEmpty) {
              _showMoreOptions(context, moreTabs);
            } else if (index < visibleTabs.length) {
              final route = visibleTabs[index]['route'];
              _navigateToRoute(route);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs
                .map(
                  (item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              ),
            )
                .toList(),
            if (moreTabs.isNotEmpty)
              const BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: _buildSidebarContent(),
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: Container(
        width: 260,
        color: Colors.white,
        child: _buildSidebarContent(),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stores Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All inventory operations',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Menu Items
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _menuItems.map((item) {
                final isActive = _currentRoute == item['route'];
                return InkWell(
                  onTap: () => _navigateToRoute(item['route']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1E3A8A).withValues(alpha: 0.1) : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isActive ? const Color(0xFF1E3A8A) : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'],
                          size: 20,
                          color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[700],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (isActive)
                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1E3A8A)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info, size: 20, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Contact system admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0;
    final headerHeight = 120.0;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: items.map(
                        (item) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: const Color(0xFF1E3A8A)),
                      ),
                      title: Text(
                        item['label'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToRoute(item['route']);
                      },
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout(context);
    }
  }
}