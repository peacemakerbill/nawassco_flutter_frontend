import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../../public/auth/providers/auth_provider.dart';
import '../../../../public/profile/presentation/widgets/user_avatar.dart';
import '../widgets/hr/department_content.dart';
import '../widgets/hr/employee_management_content.dart';
import '../widgets/employee/employee_performance_content.dart';
import '../widgets/hr_dashboard_content.dart';
import '../widgets/hr/job_application_management_content.dart';
import '../widgets/hr/job_management_content.dart';
import '../widgets/hr/leave_management_content.dart';
import '../widgets/hr/employee_performance_management_content.dart';
import '../widgets/hr/training_management_content.dart';


class HRDashboard extends ConsumerStatefulWidget {
  const HRDashboard({super.key});

  @override
  ConsumerState<HRDashboard> createState() => _HRDashboardState();
}

class _HRDashboardState extends ConsumerState<HRDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/hr/dashboard';

  // Menu items with routes that match the content widgets
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'HR Dashboard', 'route': '/hr/dashboard'},
    {'icon': Icons.people, 'label': 'Employee Management', 'route': '/hr/employees'},
    {'icon': Icons.business, 'label': 'Department Management', 'route': '/hr/departments'},
    {'icon': Icons.work, 'label': 'Job Management', 'route': '/hr/jobs'},
    {'icon': Icons.work_outline, 'label': 'Job Applications', 'route': '/hr/job-applications'},
    {'icon': Icons.beach_access, 'label': 'Leave Management', 'route': '/hr/leave'},
    {'icon': Icons.assessment, 'label': 'Manager Performance', 'route': '/hr/manager-performance'},
    {'icon': Icons.assessment, 'label': 'Employee Performance', 'route': '/hr/employee-performance'},
    {'icon': Icons.school, 'label': 'Training Management', 'route': '/hr/training'},
    {'icon': Icons.analytics, 'label': 'Reports', 'route': '/hr/reports'},
    {'icon': Icons.policy, 'label': 'Policies', 'route': '/hr/policies'},
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
    final user = ref.read(authProvider).user!;
    final authState = ref.read(authProvider);

    // Check if user has HR/Manager/Admin privileges
    final hasHRPermission = authState.isHR || authState.isAdmin || authState.isManager;

    switch (_currentRoute) {
      case '/hr/dashboard':
        return HRDashboardContent(
          user: user,
          onNavigate: _navigateToRoute,
        );
      case '/hr/employees':
        return hasHRPermission
            ? const EmployeeManagementContent()
            : _buildAccessDenied();
      case '/hr/departments':
        return hasHRPermission
            ? const DepartmentContent()
            : _buildAccessDenied();
      case '/hr/jobs':
        return hasHRPermission
            ? const JobManagementContent()
            : _buildAccessDenied();
      case '/hr/job-applications':
        return hasHRPermission
            ? const JobApplicationManagementContent()
            : _buildAccessDenied();
      case '/hr/leave':
        return hasHRPermission
            ? const LeaveManagementContent()
            : _buildAccessDenied();
      case '/hr/manager-performance':
          return const EmployeePerformanceManagementContent();
      case '/hr/employee-performance':
          return const EmployeePerformanceContent();
      case '/hr/training':
        return hasHRPermission
            ? const TrainingManagementContent()
            : _buildAccessDenied();
      case '/hr/reports':
        return _buildComingSoon('Reports');
      case '/hr/policies':
        return _buildComingSoon('Company Policies');
      default:
        return HRDashboardContent(
          user: user,
          onNavigate: _navigateToRoute,
        );
    }
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Access Denied',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need HR, Admin, or Manager privileges to access this section.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToRoute('/hr/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String featureName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.build, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            '$featureName - Coming Soon',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This feature is currently under development.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToRoute('/hr/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user!;
    final profilePic = user['profilePictureUrl'] as String?;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A47CA),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people_alt, color: Colors.white, size: 20),
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
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 22),
            onPressed: () => _showHRNotifications(context),
            tooltip: 'HR Notifications',
          ),
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
          selectedItemColor: const Color(0xFF3442C3),
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
    return Material(
      elevation: 8,
      child: Container(
        width: 280,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3744D5), Color(0xFF5462E3), Color(0xFF7184E3)],
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
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.people_alt, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'HR Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Human Resources Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                children: [
                  _buildQuickStat('Total Employees', '247', Icons.people),
                  const SizedBox(height: 8),
                  _buildQuickStat('On Leave Today', '12', Icons.beach_access),
                  const SizedBox(height: 8),
                  _buildQuickStat('Pending Approvals', '8', Icons.pending_actions),
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
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.2),
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
                        child: const Icon(Icons.circle, color: Color(0xFF3842BA), size: 8),
                      )
                          : const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                      onTap: () => _navigateToRoute(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),
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
                  const Row(
                    children: [
                      Icon(Icons.business, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'NAWASSCO HR Department',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Managing ${DateTime.now().year} Workforce',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
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

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0;
    final headerHeight = 140.0;
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
                child: Column(
                  children: [
                    const Icon(Icons.people_alt, color: Color(0xFF1A237E), size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'HR Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Additional HR Functions',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                          color: const Color(0xFF333EB5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: const Color(0xFF3942B8)),
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

  void _showHRNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF3A43BD)),
            SizedBox(width: 8),
            Text('HR Notifications'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildNotificationItem('Leave Request', 'John Doe submitted leave request', '2 min ago'),
              _buildNotificationItem('Payroll Processed', 'February payroll completed', '1 hour ago'),
              _buildNotificationItem('New Hire', 'Sarah Johnson joined Technical Dept', 'Yesterday'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
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