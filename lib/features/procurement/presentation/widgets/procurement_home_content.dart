import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import 'sub_widgets/procurement_charts_widget.dart';
import 'sub_widgets/procurement_kpi_widget.dart';
import 'sub_widgets/procurement_quick_actions.dart';
import 'sub_widgets/recent_activity_widget.dart';

class ProcurementHomeContent extends ConsumerWidget {
  final Function(String)? onNavigate;

  const ProcurementHomeContent({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Access user data
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? 'procurement@nawassco.co.ke';
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
      displayName = 'Procurement Team';
    }

    final greeting = _getTimeBasedGreeting();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with user info
          _buildWelcomeHeader(firstName, displayName, greeting, userEmail, profilePic, context),
          const SizedBox(height: 24),

          // KPI Metrics
          const ProcurementKPIWidget(),
          const SizedBox(height: 24),

          // Charts Section
          const ProcurementChartsWidget(),
          const SizedBox(height: 24),

          // Quick Actions - FIXED: Pass onNavigate callback
          ProcurementQuickActions(onNavigate: onNavigate),
          const SizedBox(height: 24),

          // Recent Activity - FIXED: Pass onNavigate callback
          RecentActivityWidget(onNavigate: onNavigate),
          const SizedBox(height: 24),
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
      BuildContext context
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47A1),  // Deep blue
            Color(0xFF1976D2),  // Medium blue
            Color(0xFF42A5F5),  // Light blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.4),
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
                  'Here\'s your procurement overview for today',
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
                    _buildStatChip('Active Tenders: 24', Icons.assignment,
                        onTap: () => _navigateTo('/procurement/tenders')),
                    _buildStatChip('Pending POs: 8', Icons.shopping_cart,
                        onTap: () => _navigateTo('/procurement/purchase-orders')),
                    _buildStatChip('Expiring Contracts: 5', Icons.warning,
                        onTap: () => _navigateTo('/procurement/contracts')),
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
                child: const Icon(Icons.shopping_bag, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 8),
              const Text(
                'Procurement',
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

  void _navigateTo(String route) {
    if (onNavigate != null) {
      onNavigate!(route);
    }
  }
}