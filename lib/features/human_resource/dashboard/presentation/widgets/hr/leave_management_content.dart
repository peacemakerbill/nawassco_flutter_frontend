import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/leave/leave_application.dart';
import '../../../../providers/leave_provider.dart';
import '../sub_widgets/leave/leave_application_card.dart';
import '../sub_widgets/leave/leave_application_details.dart';
import '../sub_widgets/leave/leave_calendar_widget.dart';
import '../sub_widgets/leave/leave_filter_widget.dart';
import '../sub_widgets/leave/leave_statistics_widget.dart';

class LeaveManagementContent extends ConsumerStatefulWidget {
  const LeaveManagementContent({super.key});

  @override
  ConsumerState<LeaveManagementContent> createState() =>
      _LeaveManagementContentState();
}

class _LeaveManagementContentState extends ConsumerState<LeaveManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaveApplication? _selectedApplication;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildApplicationsList() {
    final state = ref.watch(leaveProvider);
    final applications = state.filteredApplications;

    if (state.isLoading && applications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No leave applications found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (state.searchQuery.isNotEmpty ||
                state.selectedLeaveType != null ||
                state.selectedStatus != null)
              TextButton(
                onPressed: () {
                  ref.read(leaveProvider.notifier).clearFilters();
                },
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(leaveProvider.notifier).loadApplications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == applications.length) {
            if (state.hasMore && !state.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(leaveProvider.notifier)
                    .loadApplications(loadMore: true);
              });
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final application = applications[index];
          return LeaveApplicationCard(
            application: application,
            showEmployeeInfo: true,
            canManage: true,
            onTap: () {
              setState(() {
                _selectedApplication = application;
              });
            },
            onApprove: () => _approveApplication(application),
            onReject: () => _rejectApplication(application),
            onCancel: () => _cancelApplication(application),
          );
        },
      ),
    );
  }

  Future<void> _approveApplication(LeaveApplication application) async {
    final success = await ref.read(leaveProvider.notifier).updateLeaveStatus(
          applicationId: application.id,
          status: LeaveStatus.approved,
        );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave application approved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectApplication(LeaveApplication application) async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success =
                    await ref.read(leaveProvider.notifier).updateLeaveStatus(
                          applicationId: application.id,
                          status: LeaveStatus.rejected,
                          rejectionReason: reasonController.text.trim(),
                        );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leave application rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelApplication(LeaveApplication application) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content:
            const Text('Are you sure you want to cancel this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(leaveProvider.notifier)
                  .cancelLeave(application.id);
              if (success) {
                if (_selectedApplication?.id == application.id) {
                  setState(() {
                    _selectedApplication = null;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave application cancelled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedApplication != null) {
      return LeaveApplicationDetails(
        application: _selectedApplication!,
      );
    }

    return Column(
      children: [
        if (_showFilters) const LeaveFilterWidget(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildApplicationsList(),
              const LeaveStatisticsWidget(),
              const LeaveCalendarWidget(),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Leave approvals and manager actions can be performed from the applications list.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);
    final canManage =
        ref.read(authProvider).hasAnyRole(['Admin', 'HR', 'Manager']);

    if (!canManage) {
      return const Center(
        child: Text(
          'Access denied. You need HR/Manager/Admin privileges.',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header with Tabs
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 24,
                        color: Color(0xFF1A237E),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Leave Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(
                          _showFilters
                              ? Icons.filter_alt_off
                              : Icons.filter_alt,
                          color: const Color(0xFF1A237E),
                        ),
                        tooltip: 'Toggle filters',
                      ),
                      if (_selectedApplication != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedApplication = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          tooltip: 'Back to list',
                        ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF1A237E),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1A237E),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.list),
                      text: 'Applications (${state.applications.length})',
                    ),
                    const Tab(
                      icon: Icon(Icons.analytics),
                      text: 'Statistics',
                    ),
                    const Tab(
                      icon: Icon(Icons.calendar_today),
                      text: 'Calendar',
                    ),
                    const Tab(
                      icon: Icon(Icons.settings),
                      text: 'Management',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.error!)),
                  IconButton(
                    onPressed: () {
                      ref.read(leaveProvider.notifier).clearMessages();
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          if (state.success != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green[50],
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.success!)),
                  IconButton(
                    onPressed: () {
                      ref.read(leaveProvider.notifier).clearMessages();
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
