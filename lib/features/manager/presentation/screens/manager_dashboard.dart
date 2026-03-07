import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';

import '../contents/dashboard_content.dart';
import '../contents/management_reports_content.dart';
import '../contents/decision_log_content.dart';
import '../contents/managers_content.dart';
import '../contents/manager_profile_content.dart';
import '../contents/strategic_plan_content.dart';

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({super.key});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/manager/dashboard';

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'route': '/manager/dashboard',
      'color': const Color(0xFF0066CC),
    },
    {
      'icon': Icons.description,
      'label': 'Management Reports',
      'route': '/manager/reports',
      'color': const Color(0xFFE17055),
    },
    {
      'icon': Icons.assignment,
      'label': 'Decision Logs',
      'route': '/manager/decision-logs',
      'color': const Color(0xFF00B894),
    },
    {
      'icon': Icons.people,
      'label': 'Managers',
      'route': '/manager/managers',
      'color': const Color(0xFF0096D6),
    },
    {
      'icon': Icons.person,
      'label': 'Manager Profile',
      'route': '/manager/profile',
      'color': Color(0xFF6C5CE7),
    },
    {
      'icon': Icons.track_changes,
      'label': 'Strategic Plans',
      'route': '/manager/strategic-plans',
      'color': Color(0xFF00CEA6),
    },
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
      case '/manager/dashboard':
        return DashboardContent(onNavigate: _navigateToRoute);
      case '/manager/reports':
        return const ManagementReportsContent();
      case '/manager/decision-logs':
        return const DecisionLogContent();
      case '/manager/managers':
        return const ManagersContent();
      case '/manager/profile':
        return const ManagerProfileContent();
      case '/manager/strategic-plans':
        return const StrategicPlanContent();
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

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
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
          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 260 : 0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
                ),
              ),
              child: _getCurrentContent(),
            ),
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
          if (!isMobile) _buildDesktopSidebar(),
          if (isMobile) _buildMobileSidebar(),
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
          selectedItemColor: const Color(0xFF0066CC),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs
                .map(
                  (item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'].split(' ').first,
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
      child: _buildSidebarContent(),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? 'manager@nawassco.com';

    final String displayName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      displayName = firstName;
    } else if (lastName.isNotEmpty) {
      displayName = lastName;
    } else {
      displayName = 'Manager';
    }

    return Material(
      elevation: 8,
      child: Container(
        width: 260,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0066CC),
              Color(0xFF0080FF),
              Color(0xFF66B2FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with user info and close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: profilePic,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Management Department',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => setState(() => _isSidebarOpen = false),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: _menuItems.map((item) {
                  final isSelected = _currentRoute == item['route'];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'],
                          color: isSelected ? item['color'] : Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.circle, color: item['color'], size: 8),
                      )
                          : Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6), size: 18),
                      onTap: () => _navigateToRoute(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer with system info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NAWASSCO Management System v2.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                          color: item['color'].withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: item['color']),
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