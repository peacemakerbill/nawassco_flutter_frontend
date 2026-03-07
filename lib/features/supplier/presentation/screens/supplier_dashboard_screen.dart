import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import '../content/dashboard_content.dart';
import '../content/supplier_profile_content.dart';
import '../widgets/dashboard/supplier_sidebar.dart';

class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends ConsumerState<SupplierDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/supplier/dashboard';

  // Water-themed colors based on Nakuru Water website
  final Color _primaryBlue = const Color(0xFF0066A1);
  final Color _secondaryBlue = const Color(0xFF0080B3);
  final Color _lightBlue = const Color(0xFFE6F2F8);
  final Color _teal = const Color(0xFF009688);
  final Color _darkBlue = const Color(0xFF004D73);

  // Updated menu items to include profile
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/supplier/dashboard'},
    {'icon': Icons.person, 'label': 'My Profile', 'route': '/supplier/profile'},
    {'icon': Icons.business, 'label': 'My Bids', 'route': '/supplier/bids'},
    {'icon': Icons.assignment, 'label': 'Contracts', 'route': '/supplier/contracts'},
    {'icon': Icons.analytics, 'label': 'Performance', 'route': '/supplier/performance'},
    {'icon': Icons.notifications, 'label': 'Notifications', 'route': '/supplier/notifications'},
    {'icon': Icons.settings, 'label': 'Settings', 'route': '/supplier/settings'},
  ];

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
      // Find the index in the visible tabs (first 4 items)
      final visibleTabs = _menuItems.take(4).toList();
      _selectedIndex = visibleTabs.indexWhere((item) => item['route'] == route);
      if (_selectedIndex == -1) {
        _selectedIndex = 0; // Default to first tab if not found in visible tabs
      }
      _isSidebarOpen = false;
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/supplier/dashboard':
        return DashboardContent(onNavigate: _navigateToRoute);
      case '/supplier/profile':
        return const SupplierProfileContent();
      default:
        return DashboardContent(onNavigate: _navigateToRoute);
    }
  }

  String _getCurrentTitle() {
    final item = _menuItems.firstWhere(
          (item) => item['route'] == _currentRoute,
      orElse: () => _menuItems.first,
    );
    return item['label'];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: _lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryBlue, _secondaryBlue],
            ),
          ),
        ),
        title: Text(
          _getCurrentTitle(),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: UserAvatar(imageUrl: profilePic, radius: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 22),
                  onPressed: () => _navigateToRoute('/supplier/profile'),
                  tooltip: 'Profile',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                  onPressed: () => _showLogoutDialog(context, ref),
                  tooltip: 'Logout',
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background water-themed gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lightBlue.withValues(alpha: 0.3),
                  _lightBlue.withValues(alpha: 0.1),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 260 : 0),
            child: _getCurrentContent(),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, _lightBlue],
          ),
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
          backgroundColor: Colors.transparent,
          selectedItemColor: _primaryBlue,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs
                .map(
                  (item) => BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _currentRoute == item['route']
                        ? _primaryBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item['icon']),
                ),
                label: item['label'],
              ),
            )
                .toList(),
            if (moreTabs.isNotEmpty)
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_horiz),
                ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryBlue,
              _secondaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SupplierSidebar(
          currentRoute: _currentRoute,
          menuItems: _menuItems,
          onNavigate: _navigateToRoute,
          onClose: () => setState(() => _isSidebarOpen = false),
        ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryBlue,
              _secondaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SupplierSidebar(
          currentRoute: _currentRoute,
          menuItems: _menuItems,
          onNavigate: _navigateToRoute,
          onClose: () => setState(() => _isSidebarOpen = false),
        ),
      ),
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _lightBlue],
          ),
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
                  color: _primaryBlue.withValues(alpha: 0.6),
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
                    color: _primaryBlue,
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
                          gradient: LinearGradient(
                            colors: [_primaryBlue, _secondaryBlue],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: Colors.white),
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _darkBlue,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: _primaryBlue),
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