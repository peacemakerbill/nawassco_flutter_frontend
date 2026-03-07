import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/leave/leave_application.dart';
import '../../../../providers/leave_provider.dart';
import '../sub_widgets/leave/leave_application_card.dart';
import '../sub_widgets/leave/leave_application_details.dart';
import '../sub_widgets/leave/leave_application_form.dart';
import '../sub_widgets/leave/leave_balance_widget.dart';

class LeaveApplicationContent extends ConsumerStatefulWidget {
  const LeaveApplicationContent({super.key});

  @override
  ConsumerState<LeaveApplicationContent> createState() =>
      _LeaveApplicationContentState();
}

class _LeaveApplicationContentState
    extends ConsumerState<LeaveApplicationContent> {
  int _selectedTab = 0;
  LeaveApplication? _selectedApplication;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveProvider.notifier).initialize();
    });
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
            onTap: () {
              setState(() {
                _selectedApplication = application;
              });
            },
            onCancel: () => _showCancelDialog(context, application),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, LeaveApplication application) {
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 0) {
      // My Applications
      return Column(
        children: [
          const LeaveBalanceWidget(),
          const SizedBox(height: 16),
          Expanded(child: _buildApplicationsList()),
        ],
      );
    } else if (_selectedTab == 1) {
      // Apply for Leave
      return LeaveApplicationForm(
        onSuccess: () {
          setState(() {
            _selectedTab = 0;
          });
        },
      );
    } else {
      // Application Details
      if (_selectedApplication == null) {
        return const Center(
          child: Text('No application selected'),
        );
      }
      return LeaveApplicationDetails(
        application: _selectedApplication!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);

    return Scaffold(
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event,
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
                  onTap: (index) {
                    setState(() {
                      _selectedTab = index;
                      if (index != 2) {
                        _selectedApplication = null;
                      }
                    });
                  },
                  isScrollable: true,
                  labelColor: const Color(0xFF1A237E),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1A237E),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.list),
                      text: 'My Applications (${state.applications.length})',
                    ),
                    const Tab(
                      icon: Icon(Icons.add),
                      text: 'Apply for Leave',
                    ),
                    if (_selectedApplication != null)
                      const Tab(
                        icon: Icon(Icons.description),
                        text: 'Application Details',
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
