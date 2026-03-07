import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/admin_colors.dart';

class ServiceRequestsScreen extends ConsumerStatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  ConsumerState<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends ConsumerState<ServiceRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  final Map<String, String> _filters = {
    'all': 'All Requests',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            border: Border(bottom: BorderSide(color: AdminColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Requests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('New Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8,
                  children: _filters.entries.map((filter) => FilterChip(
                    label: Text(filter.value),
                    selected: _selectedFilter == filter.key,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter.key : 'all';
                      });
                    },
                    selectedColor: AdminColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AdminColors.grey100,
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter.key ? Colors.white : AdminColors.textSecondary,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: AdminColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AdminColors.primary,
            unselectedLabelColor: AdminColors.textSecondary,
            indicatorColor: AdminColors.primary,
            tabs: const [
              Tab(text: 'Active Requests'),
              Tab(text: 'Request History'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ActiveRequestsTab(),
              RequestHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveRequestsTab extends StatelessWidget {
  const ActiveRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {
        'id': 'SR-001',
        'type': 'Leak Repair',
        'customer': 'John Doe',
        'location': 'Zone A, Nakuru',
        'priority': 'High',
        'status': 'Pending',
        'date': '2024-01-15',
      },
      {
        'id': 'SR-002',
        'type': 'Meter Installation',
        'customer': 'Jane Smith',
        'location': 'Zone B, Nakuru',
        'priority': 'Medium',
        'status': 'In Progress',
        'date': '2024-01-14',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _ServiceRequestCard(request: requests[index]);
      },
    );
  }
}

class RequestHistoryTab extends StatelessWidget {
  const RequestHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text('Service Request History Content'),
      ),
    );
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final Map<String, String> request;

  const _ServiceRequestCard({required this.request});

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AdminColors.error;
      case 'medium':
        return AdminColors.warning;
      case 'low':
        return AdminColors.success;
      default:
        return AdminColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'in progress':
        return AdminColors.info;
      case 'completed':
        return AdminColors.success;
      case 'cancelled':
        return AdminColors.error;
      default:
        return AdminColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request['id']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(request['priority']!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request['priority']!,
                        style: TextStyle(
                          color: _getPriorityColor(request['priority']!),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request['status']!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request['status']!,
                        style: TextStyle(
                          color: _getStatusColor(request['status']!),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request['type']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _RequestDetail(label: 'Customer', value: request['customer']!),
            _RequestDetail(label: 'Location', value: request['location']!),
            _RequestDetail(label: 'Date', value: request['date']!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('VIEW DETAILS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('ASSIGN TECHNICIAN'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestDetail extends StatelessWidget {
  final String label;
  final String value;

  const _RequestDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AdminColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}