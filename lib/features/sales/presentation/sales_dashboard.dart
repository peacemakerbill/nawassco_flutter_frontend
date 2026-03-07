import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/logout_confirm_dialog.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../../public/profile/presentation/widgets/user_avatar.dart';

import 'widgets/quote_management_content.dart';
import 'widgets/proposal_content.dart';
import 'widgets/reports_management_content.dart';
import 'widgets/reports_content.dart';
import 'widgets/sales_opportunities_management_content.dart';
import 'widgets/sales_opportunities_content.dart';
import 'widgets/calendar_content.dart';
import 'widgets/calendar_management_content.dart';
import 'widgets/customer_management_content.dart';
import 'widgets/sales_dashboard_content.dart';
import 'widgets/sales_rep_profile_content.dart';
import 'widgets/leads_management_content.dart';
import 'widgets/sales_rep_leads_content.dart';
import 'widgets/sales_rep_management_content.dart';


class SalesDashboard extends ConsumerStatefulWidget {
  const SalesDashboard({super.key});

  @override
  ConsumerState<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends ConsumerState<SalesDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/sales-dashboard';

  // Dummy sales data (could be moved to provider if needed)
  final Map<String, dynamic> _dummySalesData = {
    'monthlyTarget': 78.5,
    'pendingTasks': 3,
  };

  // Complete menu items - all users see the same menu
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/sales-dashboard'},
    {'icon': Icons.description, 'label': 'Quotes', 'route': '/quote-management'},
    {'icon': Icons.description, 'label': 'Proposals', 'route': '/proposal-management'},
    {'icon': Icons.assessment, 'label': 'Reports', 'route': '/reports'},
    {'icon': Icons.assessment, 'label': 'Reports Mgmt', 'route': '/reports-management'},
    {'icon': Icons.business_center, 'label': 'Opportunities', 'route': '/opportunities'},
    {'icon': Icons.business_center, 'label': 'Opp. Mgmt', 'route': '/opportunities-management'},
    {'icon': Icons.calendar_today, 'label': 'Calendar', 'route': '/calendar'},
    {'icon': Icons.calendar_today, 'label': 'Calendar Mgmt', 'route': '/calendar-management'},
    {'icon': Icons.people, 'label': 'Customers', 'route': '/customer-management'},
    {'icon': Icons.person, 'label': 'My Profile', 'route': '/sales-rep-profile'},
    {'icon': Icons.leaderboard, 'label': 'Leads', 'route': '/leads-management'},
    {'icon': Icons.leaderboard, 'label': 'My Leads', 'route': '/sales-rep-leads'},
    {'icon': Icons.group, 'label': 'Sales Rep Mgmt', 'route': '/sales-rep-management'},
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
    // All users can access all content now (no role checking)
    switch (_currentRoute) {
      case '/sales-dashboard':
        return const SalesDashboardContent();
      case '/quote-management':
        return const QuoteManagementContent();
      case '/proposal-management':
        return const ProposalContent();
      case '/reports':
        return const ReportsContent();
      case '/reports-management':
        return const ReportsManagementContent();
      case '/opportunities':
        return const SalesOpportunitiesContent();
      case '/opportunities-management':
        return const SalesOpportunitiesManagementContent();
      case '/calendar':
        return const CalendarContent();
      case '/calendar-management':
        return const CalendarManagementContent();
      case '/customer-management':
        return const CustomerManagementContent();
      case '/sales-rep-profile':
        return const SalesRepProfileContent();
      case '/leads-management':
        return const LeadsManagementContent();
      case '/sales-rep-leads':
        return const SalesRepLeadsContent();
      case '/sales-rep-management':
        return const SalesRepManagementContent();
      default:
        return const SalesDashboardContent();
    }
  }

  // Get user data from auth provider
  Map<String, dynamic>? _getUserData() {
    final authState = ref.read(authProvider);
    return authState.user;
  }

  // Helper to get user full name
  String _getUserName() {
    final user = _getUserData();
    if (user?['firstName'] != null && user?['lastName'] != null) {
      return '${user!['firstName']} ${user['lastName']}';
    } else if (user?['name'] != null) {
      return user!['name'].toString();
    }
    return 'User Name';
  }

  // Helper to get user email
  String _getUserEmail() {
    final user = _getUserData();
    return user?['email']?.toString() ?? 'user@example.com';
  }

  // Helper to get profile picture URL
  String? _getProfilePictureUrl() {
    final user = _getUserData();
    return user?['profilePictureUrl']?.toString();
  }

  // Get roles from auth state
  String _getUserRole() {
    final authState = ref.read(authProvider);
    final roles = authState.activeRoles;
    if (roles.isNotEmpty) {
      // Display the first role, or format them nicely
      return roles.join(', ');
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final authState = ref.watch(authProvider);

    // Check if user is authenticated
    if (!authState.isAuthenticated) {
      Future.delayed(Duration.zero, () {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
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
          ],
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
          _buildNotificationBadge(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: UserAvatar(
              imageUrl: _getProfilePictureUrl(),
              radius: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 22),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 280 : 0),
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
              color: Colors.black.withOpacity(0.1),
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
          unselectedItemColor: Colors.grey[600],
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
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    final userName = _getUserName();
    final userEmail = _getUserEmail();
    final profilePictureUrl = _getProfilePictureUrl();
    final userRole = _getUserRole();
    final monthlyTarget = _dummySalesData['monthlyTarget'] as double;

    return Material(
      elevation: 8,
      child: Container(
        width: 280,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sales Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 22),
                        onPressed: () {
                          setState(() {
                            _isSidebarOpen = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      UserAvatar(imageUrl: profilePictureUrl, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userEmail,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userRole,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: _menuItems.map((item) {
                  final isSelected = _currentRoute == item['route'];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isSelected ? 0.3 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: Colors.white, size: 20),
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.circle, color: Color(0xFF1E3A8A), size: 8),
                      )
                          : Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.6), size: 18),
                      onTap: () => _navigateToRoute(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.yellow[300], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Monthly Target: ${monthlyTarget.ceil()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: monthlyTarget / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.yellow[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge() {
    final pendingTasks = _dummySalesData['pendingTasks'] as int;
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white, size: 22),
          onPressed: () => _navigateToRoute('/sales-notifications'),
        ),
        if (pendingTasks > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                pendingTasks > 9 ? '9+' : pendingTasks.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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
              color: Colors.black.withOpacity(0.2),
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
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
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

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );

    if (confirmed == true) {
      // Use the auth provider to logout
      try {
        final auth = ref.read(authProvider.notifier);
        await auth.logout(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}