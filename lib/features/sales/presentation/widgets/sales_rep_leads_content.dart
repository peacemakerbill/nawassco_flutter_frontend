import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../providers/sales_rep_provider.dart';
import 'sub_widgets/leads/lead_list_widget.dart';

class SalesRepLeadsContent extends ConsumerStatefulWidget {
  const SalesRepLeadsContent({super.key});

  @override
  ConsumerState<SalesRepLeadsContent> createState() =>
      _SalesRepLeadsContentState();
}

class _SalesRepLeadsContentState extends ConsumerState<SalesRepLeadsContent> {
  @override
  void initState() {
    super.initState();
    // Initialize sales rep leads when content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeContent();
    });
  }

  Future<void> _initializeContent() async {
    final authState = ref.read(authProvider);
    final leadNotifier = ref.read(leadProvider.notifier);
    final salesRepNotifier = ref.read(salesRepProvider.notifier);

    // Fetch sales rep profile if needed
    if (authState.isSalesAgent) {
      await salesRepNotifier.fetchCurrentUserProfile();
    }

    // Fetch assigned leads
    await leadNotifier.fetchLeads();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final leadState = ref.watch(leadProvider);
    final salesRepState = ref.watch(salesRepProvider);

    if (!authState.isSalesAgent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sales Representative Access Only',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This section is only accessible to sales representatives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to appropriate dashboard
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
          // Custom App Bar - Responsive like Leads Management
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
            child: Column(
              children: [
                // Top row: Sales Rep Info and Stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sales Rep Profile
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF1E3A8A),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sales Rep Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salesRepState.currentSalesRep?.fullName ??
                                'Sales Representative',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            salesRepState.currentSalesRep?.employeeNumber ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Stats - Horizontal on desktop, vertical on mobile
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          // Desktop layout
                          return Row(
                            children: [
                              // Assigned Leads
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${leadState.totalItems}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text(
                                      'Assigned Leads',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Conversion Rate
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      salesRepState
                                          .currentSalesRep?.performance.conversionRate
                                          .toStringAsFixed(1) ??
                                          '0.0',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const Text(
                                      'Conversion %',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Mobile layout
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Assigned Leads
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${leadState.totalItems}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text(
                                      'Assigned Leads',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),

                // Welcome Section - Below the top row on mobile
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth <= 600) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              salesRepState.currentSalesRep?.salesTargets
                                  .monthlyTarget !=
                                  null
                                  ? 'You have ${leadState.totalItems} assigned leads. Target: KES ${salesRepState.currentSalesRep!.salesTargets.monthlyTarget.toStringAsFixed(2)}'
                                  : 'You have ${leadState.totalItems} assigned leads.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Welcome Section - Desktop only (shown as part of the main content)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  color: const Color(0xFF1E3A8A).withOpacity(0.05),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              salesRepState.currentSalesRep?.salesTargets
                                  .monthlyTarget !=
                                  null
                                  ? 'You have ${leadState.totalItems} assigned leads. Target: KES ${salesRepState.currentSalesRep!.salesTargets.monthlyTarget.toStringAsFixed(2)}'
                                  : 'You have ${leadState.totalItems} assigned leads.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
                    'Loading your leads...',
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

          // Performance Footer - Responsive
          if (salesRepState.currentSalesRep != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 400) {
                    // Desktop/Tablet layout
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Performance Summary',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: salesRepState.currentSalesRep!
                                    .performance.overallRating /
                                    100,
                                backgroundColor: Colors.grey.shade200,
                                color: const Color(0xFF1E3A8A),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Overall Rating: ${salesRepState.currentSalesRep!.performance.overallRating.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              'KES ${salesRepState.currentSalesRep!.performance.totalSales.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const Text(
                              'Total Sales',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performance Summary',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: salesRepState.currentSalesRep!.performance
                              .overallRating /
                              100,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF1E3A8A),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Rating: ${salesRepState.currentSalesRep!.performance.overallRating.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'KES ${salesRepState.currentSalesRep!.performance.totalSales.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const Text(
                                  'Total Sales',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}