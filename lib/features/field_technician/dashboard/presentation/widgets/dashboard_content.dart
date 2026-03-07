import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../public/auth/providers/auth_provider.dart';
import '../../../../public/profile/presentation/widgets/user_avatar.dart';
import 'task_card.dart';

class DashboardContent extends ConsumerWidget {
  final Function(String) onNavigate;

  const DashboardContent({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Access user data
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? '';
    final profilePic = user?['profilePictureUrl'] as String?;

    // Create display name
    final String displayName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      displayName = firstName;
    } else if (lastName.isNotEmpty) {
      displayName = lastName;
    } else {
      displayName = 'Field Technician';
    }

    final greeting = _getTimeBasedGreeting();

    // Generate dummy data for work orders
    final List<Map<String, dynamic>> dummyWorkOrders = [
      {'id': '1', 'status': 'assigned', 'title': 'Leak Repair', 'description': 'Moi Road - Kitchen area'},
      {'id': '2', 'status': 'assigned', 'title': 'Meter Installation', 'description': 'Bahati Road'},
      {'id': '3', 'status': 'in_progress', 'title': 'Pressure Check', 'description': 'Lake Road'},
      {'id': '4', 'status': 'in_progress', 'title': 'Valve Replacement', 'description': 'Industrial Zone'},
      {'id': '5', 'status': 'completed', 'title': 'Pipe Inspection', 'description': 'CBD Area'},
      {'id': '6', 'status': 'completed', 'title': 'Maintenance', 'description': 'Suburb Area'},
    ];

    // Generate dummy data for today's tasks
    final List<Map<String, dynamic>> dummyTodayTasks = [
      {
        'id': '1',
        'title': 'Leak Repair - Moi Road',
        'description': 'Kitchen area leak detection and repair',
        'time': '9:00 AM - 11:00 AM',
        'address': '123 Moi Road, Nairobi',
        'priority': 'High',
        'status': 'in_progress'
      },
      {
        'id': '2',
        'title': 'Meter Installation - Bahati',
        'description': 'New water meter installation',
        'time': '1:00 PM - 3:00 PM',
        'address': '456 Bahati Road, Nairobi',
        'priority': 'Medium',
        'status': 'assigned'
      },
      {
        'id': '3',
        'title': 'Pressure Check - Lake Road',
        'description': 'Water pressure inspection and report',
        'time': '3:30 PM - 4:30 PM',
        'address': '789 Lake Road, Nairobi',
        'priority': 'Low',
        'status': 'scheduled'
      },
      {
        'id': '4',
        'title': 'Valve Maintenance - Industrial',
        'description': 'Preventive maintenance for industrial valves',
        'time': '10:00 AM - 12:00 PM',
        'address': '101 Industrial Zone, Nairobi',
        'priority': 'Medium',
        'status': 'overdue'
      },
    ];

    // Calculate stats from dummy data
    final assignedTasksCount = dummyWorkOrders.where((wo) => wo['status'] == 'assigned').length;
    final inProgressTasksCount = dummyWorkOrders.where((wo) => wo['status'] == 'in_progress').length;
    final completedTasksCount = dummyWorkOrders.where((wo) => wo['status'] == 'completed').length;
    final overdueTasksCount = dummyTodayTasks.where((task) => task['status'] == 'overdue').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with user info
          _buildWelcomeHeader(
            firstName,
            displayName,
            greeting,
            userEmail,
            profilePic,
            assignedTasksCount,
            inProgressTasksCount,
            completedTasksCount,
          ),
          const SizedBox(height: 24),

          // Quick Stats Grid
          _buildQuickStatsGrid(
            assignedTasksCount,
            inProgressTasksCount,
            completedTasksCount,
            overdueTasksCount,
          ),
          const SizedBox(height: 24),

          // Today's Schedule
          _buildTodaySchedule(dummyTodayTasks),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildWelcomeHeader(
      String firstName,
      String displayName,
      String greeting,
      String userEmail,
      String? profilePic,
      int assignedTasks,
      int inProgressTasks,
      int completedTasks,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0066CC), // Deep ocean blue
            Color(0xFF0088FF), // Bright water blue
            Color(0xFF00BFFF), // Sky blue water
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile picture with white background
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: UserAvatar(
                          imageUrl: profilePic,
                          radius: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            firstName.isNotEmpty ? '$firstName!' : displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready to tackle today\'s field tasks?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildStatChip('$assignedTasks Tasks Assigned', Icons.assignment,
                        onTap: () => onNavigate('/technician/work-orders')),
                    _buildStatChip('$inProgressTasks In Progress', Icons.timelapse,
                        onTap: () => onNavigate('/technician/work-orders')),
                    _buildStatChip('$completedTasks Completed Today', Icons.check_circle,
                        onTap: () => onNavigate('/technician/work-orders')),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.engineering, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 8),
              const Text(
                'Field Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid(int assigned, int inProgress, int completed, int overdue) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Assigned Tasks',
        'value': assigned.toString(),
        'color': Colors.blue,
        'icon': Icons.assignment,
        'route': '/technician/work-orders'
      },
      {
        'label': 'In Progress',
        'value': inProgress.toString(),
        'color': Colors.orange,
        'icon': Icons.timelapse,
        'route': '/technician/work-orders'
      },
      {
        'label': 'Completed',
        'value': completed.toString(),
        'color': Colors.green,
        'icon': Icons.check_circle,
        'route': '/technician/work-orders'
      },
      {
        'label': 'Overdue',
        'value': overdue.toString(),
        'color': Colors.red,
        'icon': Icons.warning,
        'route': '/technician/work-orders'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Responsive layout based on screen width
        if (screenWidth > 1200) {
          // Large screens - 4 in a row
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: stats.map((stat) {
              return _buildStatCard(
                stat['value'] as String,
                stat['label'] as String,
                stat['icon'] as IconData,
                stat['color'] as Color,
                stat['route'] as String,
              );
            }).toList(),
          );
        } else if (screenWidth > 800) {
          // Medium screens - 2 in a row
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: stats.map((stat) {
              return _buildStatCard(
                stat['value'] as String,
                stat['label'] as String,
                stat['icon'] as IconData,
                stat['color'] as Color,
                stat['route'] as String,
              );
            }).toList(),
          );
        } else {
          // Small screens - 2 in a row (compact)
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: stats.map((stat) {
              return _buildStatCard(
                stat['value'] as String,
                stat['label'] as String,
                stat['icon'] as IconData,
                stat['color'] as Color,
                stat['route'] as String,
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => onNavigate(route),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(List<Map<String, dynamic>> todayTasks) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule, color: Color(0xFF1E3A8A), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigate('/technician/work-orders'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (todayTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.assignment, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'No tasks scheduled for today',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              ...todayTasks.map((task) => TaskCard(task: task)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'type': 'repair',
        'title': 'Leak Repair Completed',
        'description': 'Moi Road - Kitchen area leak fixed',
        'time': '2 hours ago',
        'icon': Icons.build,
        'color': Colors.green,
        'route': '/technician/work-orders',
      },
      {
        'type': 'installation',
        'title': 'Meter Installation Started',
        'description': 'Bahati Road - New service installation',
        'time': '4 hours ago',
        'icon': Icons.bolt,
        'color': Colors.blue,
        'route': '/technician/work-orders',
      },
      {
        'type': 'inspection',
        'title': 'Site Inspection Report',
        'description': 'Lake Road - Water pressure check completed',
        'time': '1 day ago',
        'icon': Icons.assignment,
        'color': Colors.orange,
        'route': '/technician/reports',
      },
      {
        'type': 'maintenance',
        'title': 'Preventive Maintenance',
        'description': 'Industrial Zone - Valve maintenance scheduled',
        'time': 'Yesterday',
        'icon': Icons.engineering,
        'color': Colors.purple,
        'route': '/technician/work-orders',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF1E3A8A), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigate('/technician/reports'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return GestureDetector(
      onTap: () => onNavigate(activity['route']),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity['time'] as String,
                      style: TextStyle(
                        color: activity['color'] as Color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}