import 'package:flutter/material.dart';

class SalesDashboardContent extends StatefulWidget {
  const SalesDashboardContent({super.key});

  @override
  State<SalesDashboardContent> createState() => _SalesDashboardContentState();
}

class _SalesDashboardContentState extends State<SalesDashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Dummy data
  final Map<String, dynamic> _salesData = {
    'name': 'John Smith',
    'monthlyTarget': 78.5,
    'pendingVisits': 5,
    'pendingApplications': 3,
    'todaySales': 152000.0,
    'todayConnections': 18,
    'completedVisits': 7,
    'successRate': 72.3,
    'averageCommission': 12500.0,
    'recentActivities': [
      {
        'type': 'sale',
        'title': 'New Sale Completed',
        'description': 'Sold premium package to ABC Corp',
        'time': '2 hours ago'
      },
      {
        'type': 'visit',
        'title': 'Customer Visit',
        'description': 'Met with XYZ Ltd for quarterly review',
        'time': '4 hours ago'
      },
      {
        'type': 'commission',
        'title': 'Commission Received',
        'description': 'KES 8,500 for Q1 sales',
        'time': 'Yesterday'
      },
      {
        'type': 'application',
        'title': 'New Application',
        'description': 'Submitted business loan application',
        'time': '2 days ago'
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  _buildQuickStatsSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                  _buildPerformanceSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final name = _salesData['name'];
    final monthlyTarget = (_salesData['monthlyTarget'] as double);
    final pendingVisits = _salesData['pendingVisits'] as int;
    final pendingApplications = _salesData['pendingApplications'] as int;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${name.split(' ').first}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready to achieve today\'s sales targets?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black26,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatusChip('Target: ${monthlyTarget.ceil()}%',
                  Icons.flag, Colors.yellow),
              _buildStatusChip('$pendingVisits Visits Today',
                  Icons.calendar_today, Colors.green),
              if (pendingApplications > 0)
                _buildStatusChip('$pendingApplications Pending Apps',
                    Icons.pending_actions, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    final todaySales = (_salesData['todaySales'] as double);
    final todayConnections = _salesData['todayConnections'] as int;
    final pendingVisits = _salesData['pendingVisits'] as int;
    final completedVisits = _salesData['completedVisits'] as int;
    final successRate = (_salesData['successRate'] as double);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final crossAxisCount = isSmallScreen ? 2 : 4;
            final childAspectRatio = isSmallScreen ? 1.3 : 1.2;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                _buildStatCard(
                  'Total Sales',
                  'KES ${todaySales.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                  '+12% from yesterday',
                ),
                _buildStatCard(
                  'New Connections',
                  todayConnections.toString(),
                  Icons.group_add,
                  Colors.blue,
                  '$todayConnections processed',
                ),
                _buildStatCard(
                  'Customer Visits',
                  pendingVisits.toString(),
                  Icons.people,
                  Colors.purple,
                  '$completedVisits completed',
                ),
                _buildStatCard(
                  'Success Rate',
                  '${successRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                  'Above target',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: color.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final crossAxisCount = isSmallScreen ? 2 : 4;
            final childAspectRatio = isSmallScreen ? 1.1 : 1.0;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                _buildActionCard(
                  'New Customer',
                  Icons.person_add,
                  Colors.green,
                      () => _showSnackBar(context, 'Navigate to Customer Management'),
                ),
                _buildActionCard(
                  'Schedule Visit',
                  Icons.calendar_today,
                  Colors.blue,
                      () => _showSnackBar(context, 'Navigate to Visits'),
                ),
                _buildActionCard(
                  'Add Lead',
                  Icons.leaderboard,
                  Colors.purple,
                      () => _showSnackBar(context, 'Navigate to Leads'),
                ),
                _buildActionCard(
                  'Log Payment',
                  Icons.payment,
                  Colors.orange,
                      () => _showSnackBar(context, 'Navigate to Commissions'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String text, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: color.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final monthlyTarget = (_salesData['monthlyTarget'] as double);
    final successRate = (_salesData['successRate'] as double);
    final averageCommission = (_salesData['averageCommission'] as double);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricItem('Monthly Target', '${monthlyTarget.ceil()}%', Colors.blue),
                    _buildMetricItem('Conversion Rate', '${successRate.toStringAsFixed(1)}%', Colors.green),
                    _buildMetricItem('Avg. Commission', 'KES ${averageCommission.toStringAsFixed(0)}', Colors.orange),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: monthlyTarget / 100,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monthly Progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Target: 100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    final activities = (_salesData['recentActivities'] as List<dynamic>);
    final recentActivities = activities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: recentActivities.map((activity) => _buildActivityItem(activity)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getActivityColor(activity['type']).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getActivityIcon(activity['type']),
            color: _getActivityColor(activity['type']), size: 20),
      ),
      title: Text(
        activity['title'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(activity['description']),
      trailing: Text(
        activity['time'],
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Color _getActivityColor(String type) {
    return switch (type) {
      'sale' => Colors.green,
      'visit' => Colors.blue,
      'application' => Colors.orange,
      'commission' => Colors.purple,
      _ => Colors.grey,
    };
  }

  IconData _getActivityIcon(String type) {
    return switch (type) {
      'sale' => Icons.attach_money,
      'visit' => Icons.people,
      'application' => Icons.description,
      'commission' => Icons.payment,
      _ => Icons.notifications,
    };
  }

  // Helper method to show snackbar for quick actions
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}