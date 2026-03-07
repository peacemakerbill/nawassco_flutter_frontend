import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import '../widgets/dashboard/supplier_kpi_widget.dart';
import '../widgets/dashboard/tender_opportunities_widget.dart';
import '../widgets/dashboard/purchase_orders_widget.dart';
import '../widgets/dashboard/delivery_tracking_widget.dart';

class DashboardContent extends ConsumerWidget {
  final Function(String) onNavigate;

  const DashboardContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? '';
    final profilePic = user?['profilePictureUrl'] as String?;

    final String displayName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else {
      displayName = 'Supplier Team';
    }

    final greeting = _getTimeBasedGreeting();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(firstName, displayName, greeting, userEmail, profilePic),
                const SizedBox(height: 24),

                // KPI Metrics
                const SupplierKPIWidget(),
                const SizedBox(height: 24),

                // Tender Opportunities
                TenderOpportunitiesWidget(onNavigate: onNavigate),
                const SizedBox(height: 24),

                // Purchase Orders
                const PurchaseOrdersWidget(),
                const SizedBox(height: 24),

                // Delivery Tracking
                const DeliveryTrackingWidget(),
                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
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

  Widget _buildWelcomeHeader(String firstName, String displayName, String greeting, String userEmail, String? profilePic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0066A1), // Dark blue from website
            Color(0xFF0083CC), // Medium blue
            Color(0xFF00A8FF), // Light blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066A1).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Supplier',
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
          const SizedBox(height: 16),
          Text(
            'Here\'s your supplier overview for today',
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
              _buildStatChip('Active Tenders: 8', Icons.assignment,
                  onTap: () => onNavigate('/supplier/tenders')),
              _buildStatChip('Pending POs: 3', Icons.shopping_cart,
                  onTap: () => onNavigate('/supplier/purchase-orders')),
              _buildStatChip('Deliveries Today: 2', Icons.local_shipping,
                  onTap: () => onNavigate('/supplier/deliveries')),
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
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'type': 'tender',
        'title': 'New Tender Available',
        'description': 'Water Pipe Supply - Deadline: 3 days',
        'time': '2 hours ago',
        'icon': Icons.assignment,
        'color': Color(0xFF0066A1), // Dark blue
        'route': '/supplier/tenders',
      },
      {
        'type': 'po',
        'title': 'Purchase Order Received',
        'description': 'PO-2024-00123 - KES 450,000',
        'time': 'Yesterday',
        'icon': Icons.shopping_cart,
        'color': Color(0xFF00A8FF), // Light blue
        'route': '/supplier/purchase-orders',
      },
      {
        'type': 'delivery',
        'title': 'Delivery Scheduled',
        'description': 'Order #789 to Nakuru East Depot',
        'time': 'Today',
        'icon': Icons.local_shipping,
        'color': Color(0xFF0083CC), // Medium blue
        'route': '/supplier/deliveries',
      },
      {
        'type': 'invoice',
        'title': 'Payment Received',
        'description': 'KES 280,000 for Invoice INV-2024-0456',
        'time': '2 days ago',
        'icon': Icons.payment,
        'color': Color(0xFF0066A1), // Dark blue
        'route': '/supplier/invoices',
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
                    Icon(Icons.history, color: Color(0xFF0066A1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066A1),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigate('/supplier/activity'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0066A1),
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
                  color: activity['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity['icon'], color: activity['color'], size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                      color: activity['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity['time'],
                      style: TextStyle(
                        color: activity['color'],
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