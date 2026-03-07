import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import 'sub_widgets/leads/lead_list_widget.dart';

class LeadsManagementContent extends ConsumerStatefulWidget {
  const LeadsManagementContent({super.key});

  @override
  ConsumerState<LeadsManagementContent> createState() =>
      _LeadsManagementContentState();
}

class _LeadsManagementContentState
    extends ConsumerState<LeadsManagementContent> {
  @override
  void initState() {
    super.initState();
    // Initialize leads when content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).fetchLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final leadState = ref.watch(leadProvider);
    final notifier = ref.read(leadProvider.notifier);

    // Check if user has permission to view leads
    final hasPermission = authState.hasAnyRole([
      'Admin',
      'SalesAgent',
      'Manager',
      'SalesManager',
    ]);

    if (!hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have permission to access leads management.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to home or dashboard
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Column(
        children: [
          // Custom App Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leads Management',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and track all your leads in one place',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // View Toggle Button
                if (authState.isSalesAgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: leadState.isSalesRepView
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: leadState.isSalesRepView
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          leadState.isSalesRepView ? Icons.person : Icons.group,
                          size: 16,
                          color: leadState.isSalesRepView
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => notifier.toggleSalesRepView(),
                          child: Text(
                            leadState.isSalesRepView ? 'My Leads' : 'All Leads',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: leadState.isSalesRepView
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(width: 16),

                // Quick Stats
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${leadState.totalItems}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'Total Leads',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: leadState.isLoading && leadState.leads.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1E3A8A),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading leads...',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : const LeadListWidget(),
          ),
        ],
      ),
    );
  }
}