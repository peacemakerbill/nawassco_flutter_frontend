import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';

import 'widgets/dashboard_content.dart';
import 'widgets/technicians/work_orders_content.dart';
import 'widgets/management/field_inventory_content.dart';
import 'widgets/management/vehicle_content.dart';
import 'widgets/technicians/maintenance_schedule_content.dart';
import 'widgets/management/field_customer_content.dart';
import 'widgets/management/field_team_content.dart';
import 'widgets/management/tools_content.dart';
import 'widgets/management/field_technician_content.dart';
import 'widgets/technicians/field_service_report_content.dart';
import 'widgets/technicians/technician_profile_content.dart';
import 'widgets/quick_actions_panel.dart';


class FieldTechnicianDashboard extends ConsumerStatefulWidget {
  const FieldTechnicianDashboard({super.key});

  @override
  ConsumerState<FieldTechnicianDashboard> createState() =>
      _FieldTechnicianDashboardState();
}

class _FieldTechnicianDashboardState
    extends ConsumerState<FieldTechnicianDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/technician/dashboard';

  // Mock data using Maps instead of entity classes
  final List<Map<String, dynamic>> _workOrders = [
    {
      'id': 'WO-001',
      'type': 'leakRepair',
      'priority': 'high',
      'status': 'assigned',
      'customerName': 'John Kamau',
      'address': '123 Moi Road, Nakuru',
      'contactNumber': '+254712345678',
      'scheduledDate': DateTime.now().add(const Duration(hours: 2)),
      'description': 'Major water leak reported in kitchen area',
      'meterNumber': 'MTR-789012',
    },
    {
      'id': 'WO-002',
      'type': 'meterReplacement',
      'priority': 'medium',
      'status': 'assigned',
      'customerName': 'Jane Wanjiku',
      'address': '456 Kenyatta Ave, Nakuru',
      'contactNumber': '+254723456789',
      'scheduledDate': DateTime.now().add(const Duration(days: 1)),
      'description': 'Faulty service needs replacement',
      'meterNumber': 'MTR-789013',
    },
    {
      'id': 'WO-003',
      'type': 'newConnection',
      'priority': 'low',
      'status': 'inProgress',
      'customerName': 'Robert Omondi',
      'address': '789 Lake Road, Nakuru',
      'contactNumber': '+254734567890',
      'scheduledDate': DateTime.now().add(const Duration(hours: 4)),
      'description': 'New water connection installation',
      'meterNumber': 'MTR-789014',
    },
  ];

  final List<Map<String, dynamic>> _todayTasks = [
    {
      'id': 'T-001',
      'title': 'Leak Repair - Moi Road',
      'type': 'repair',
      'priority': 'high',
      'status': 'inProgress',
      'location': '123 Moi Road, Nakuru',
      'scheduledTime': '09:00 AM',
      'estimatedDuration': '2 hours',
      'customerName': 'John Kamau',
    },
    {
      'id': 'T-002',
      'title': 'Meter Installation - Bahati',
      'type': 'installation',
      'priority': 'medium',
      'status': 'assigned',
      'location': '78 Bahati Road',
      'scheduledTime': '02:00 PM',
      'estimatedDuration': '1 hour',
      'customerName': 'Sarah Mwangi',
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'route': '/technician/dashboard'
    },
    {
      'icon': Icons.assignment,
      'label': 'Work Orders',
      'route': '/technician/work-orders'
    },
    {
      'icon': Icons.inventory_2,
      'label': 'Inventory',
      'route': '/technician/inventory'
    },
    {
      'icon': Icons.directions_car,
      'label': 'Vehicles',
      'route': '/technician/vehicles'
    },
    {
      'icon': Icons.build_circle,
      'label': 'Maintenance',
      'route': '/technician/maintenance'
    },
    {
      'icon': Icons.people,
      'label': 'Customers',
      'route': '/technician/customers'
    },
    {
      'icon': Icons.groups,
      'label': 'Teams',
      'route': '/technician/teams'
    },
    {
      'icon': Icons.engineering,
      'label': 'Tools',
      'route': '/technician/tools'
    },
    {
      'icon': Icons.assignment,
      'label': 'Service Reports',
      'route': '/technician/service-reports'
    },
    {
      'icon': Icons.manage_accounts,
      'label': 'Technicians',
      'route': '/technician/technicians'
    },
    {
      'icon': Icons.person,
      'label': 'My Profile',
      'route': '/technician/my-profile'
    },
    {
      'icon': Icons.settings,
      'label': 'Settings',
      'route': '/technician/settings'
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

  void _updateWorkOrder(Map<String, dynamic> workOrder) {
    setState(() {
      final index = _workOrders.indexWhere((wo) => wo['id'] == workOrder['id']);
      if (index != -1) {
        _workOrders[index] = workOrder;
      }
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/technician/dashboard':
        return DashboardContent(
          onNavigate: _navigateToRoute,
        );
      case '/technician/work-orders':
        return const WorkOrdersContent();
      case '/technician/inventory':
        return const FieldInventoryContent();
      case '/technician/vehicles':
        return const VehicleContent();
      case '/technician/maintenance':
        return const MaintenanceScheduleContent();
      case '/technician/customers':
        return const FieldCustomerContent();
      case '/technician/teams':
        return const FieldTeamContent();
      case '/technician/tools':
        return const ToolsContent();
      case '/technician/service-reports':
        return const FieldServiceReportContent();
      case '/technician/technicians':
        return const FieldTechnicianContent();
      case '/technician/my-profile':
        return const TechnicianProfileContent();
      case '/technician/settings':
        return _buildSettingsPlaceholder();
      default:
        return DashboardContent(
          onNavigate: _navigateToRoute,
        );
    }
  }

  Widget _buildSettingsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Settings page under development',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;
    final firstName = user?['firstName'] as String? ?? 'Technician';
    final lastName = user?['lastName'] as String? ?? 'User';
    final email = user?['email'] as String? ?? 'technician@nawasso.co.ke';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
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
          _buildNotificationButton(),
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
            child: _getCurrentContent(),
          ),

          // Sidebar overlay for mobile
          if (isMobile && _isSidebarOpen)
            GestureDetector(
              onTap: () => setState(() => _isSidebarOpen = false),
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Sidebar
          if (!isMobile)
            _buildDesktopSidebar(firstName, lastName, email, profilePic),
          if (isMobile)
            _buildMobileSidebar(firstName, lastName, email, profilePic),
        ],
      ),
      floatingActionButton: _buildQuickActionsFAB(),
      bottomNavigationBar: isMobile
          ? _buildBottomNavigationBar(visibleTabs, moreTabs, safeSelectedIndex)
          : null,
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none,
              color: Colors.white, size: 22),
          onPressed: () => _navigateToRoute('/technician/notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              style: TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar(
      String firstName, String lastName, String email, String? profilePic) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(firstName, lastName, email, profilePic),
    );
  }

  Widget _buildMobileSidebar(
      String firstName, String lastName, String email, String? profilePic) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(firstName, lastName, email, profilePic),
    );
  }

  Widget _buildSidebarContent(
      String firstName, String lastName, String email, String? profilePic) {
    return Material(
      elevation: 8,
      child: Container(
        width: 260,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
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
            // Header with user info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    radius: 25,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Field Technician',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
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
            ),

            // Quick Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSidebarStat(_workOrders.length.toString(), 'Tasks'),
                  _buildSidebarStat(
                    _workOrders
                        .where((wo) => wo['status'] == 'completed')
                        .length
                        .toString(),
                    'Completed',
                  ),
                  _buildSidebarStat(
                    _workOrders
                        .where((wo) => wo['status'] == 'assigned')
                        .length
                        .toString(),
                    'Pending',
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
                    margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    child: ListTile(
                      leading:
                      Icon(item['icon'], color: Colors.white, size: 22),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.circle,
                          color: Colors.white, size: 8)
                          : const Icon(Icons.chevron_right,
                          color: Colors.white70, size: 18),
                      onTap: () => _navigateToRoute(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Column(
                children: [
                  const LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly Target: 70%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last sync: ${TimeOfDay.now().format(context)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
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

  Widget _buildSidebarStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(List<Map<String, dynamic>> visibleTabs,
      List<Map<String, dynamic>> moreTabs, int safeSelectedIndex) {
    return Container(
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
        selectedItemColor: const Color(0xFF0D47A1),
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
    );
  }

  Widget _buildQuickActionsFAB() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const QuickActionsPanel(),
        );
      },
      backgroundColor: const Color(0xFF0D47A1),
      foregroundColor: Colors.white,
      child: const Icon(Icons.bolt),
    );
  }

  void _showMoreOptions(
      BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0;
    final headerHeight = 120.0;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight =
    calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

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
                  children: [
                    ...items
                        .map(
                          (item) => ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'],
                              color: const Color(0xFF0D47A1)),
                        ),
                        title: Text(
                          item['label'],
                          style:
                          const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.grey),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToRoute(item['route']);
                        },
                      ),
                    )
                        .toList(),
                    // Add Logout option in More menu
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context, ref);
                      },
                    ),
                  ],
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
      // Implement logout logic
      await ref.read(authProvider.notifier).logout(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }
}