import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/utils/toast_utils.dart';
import '../../../../models/service_request_model.dart';
import '../../../../providers/service_request_provider.dart';
import '../../../sub_widgets/service_request/request_stats_widget.dart';
import '../../../sub_widgets/service_request/service_request_card.dart';
import '../../../sub_widgets/service_request/service_request_details.dart';
import '../../../sub_widgets/service_request/service_request_filter.dart';
import '../../../sub_widgets/service_request/service_request_form.dart';
import '../../../sub_widgets/service_request/technician_performance_widget.dart';

class ServiceRequestManagement extends ConsumerStatefulWidget {
  const ServiceRequestManagement({super.key});

  @override
  ConsumerState<ServiceRequestManagement> createState() => _ServiceRequestManagementState();
}

class _ServiceRequestManagementState extends ConsumerState<ServiceRequestManagement> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  ViewMode _viewMode = ViewMode.list;
  String? _selectedRequestId;
  bool _showBulkActions = false;
  final Set<String> _selectedRequests = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestProvider.notifier).fetchServiceRequests();
      ref.read(serviceRequestProvider.notifier).fetchRequestStats('month');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !ref.read(serviceRequestProvider).hasMore) return;

    setState(() => _isLoadingMore = true);
    await ref.read(serviceRequestProvider.notifier).fetchServiceRequests(loadMore: true);
    setState(() => _isLoadingMore = false);
  }

  void _toggleRequestSelection(String requestId) {
    setState(() {
      if (_selectedRequests.contains(requestId)) {
        _selectedRequests.remove(requestId);
      } else {
        _selectedRequests.add(requestId);
      }
      _showBulkActions = _selectedRequests.isNotEmpty;
    });
  }

  void _selectAllRequests() {
    setState(() {
      final allRequests = ref.read(serviceRequestProvider).requests;
      if (_selectedRequests.length == allRequests.length) {
        _selectedRequests.clear();
      } else {
        _selectedRequests.addAll(allRequests.map((r) => r.id));
      }
      _showBulkActions = _selectedRequests.isNotEmpty;
    });
  }

  // Helper method for title case conversion
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _showBulkAssignDialog() {
    // In production, fetch technicians from API
    final technicians = [
      {'id': '1', 'name': 'John Doe'},
      {'id': '2', 'name': 'Jane Smith'},
      {'id': '3', 'name': 'Mike Johnson'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bulk Assign (${_selectedRequests.length} requests)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                return ListTile(
                  leading: const Icon(Icons.engineering),
                  title: Text(tech['name']!),
                  onTap: () {
                    ref.read(serviceRequestProvider.notifier).bulkAssignTechnicians(
                      _selectedRequests.toList(),
                      tech['id']!,
                    );
                    setState(() {
                      _selectedRequests.clear();
                      _showBulkActions = false;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bulk Update Status (${_selectedRequests.length} requests)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: RequestStatus.values.length,
              itemBuilder: (context, index) {
                final status = RequestStatus.values[index];
                return ListTile(
                  leading: Icon(Icons.circle, color: _getStatusColor(status)),
                  title: Text(_toTitleCase(status.name.replaceAll('_', ' '))),
                  onTap: () {
                    // In production, you would implement bulk status update
                    // For now, update one by one
                    for (final requestId in _selectedRequests) {
                      ref.read(serviceRequestProvider.notifier).updateRequestStatus(
                        requestId,
                        status,
                      );
                    }
                    setState(() {
                      _selectedRequests.clear();
                      _showBulkActions = false;
                    });
                    ToastUtils.showSuccessToast(
                        'Status updated for ${_selectedRequests.length} requests');
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRequestDetails(String requestId) {
    setState(() => _selectedRequestId = requestId);
    ref.read(serviceRequestProvider.notifier).fetchServiceRequestById(requestId);
  }

  void _closeDetails() {
    setState(() => _selectedRequestId = null);
    ref.read(serviceRequestProvider.notifier).clearSelectedRequest();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceRequestProvider);
    final selectedRequest = state.selectedRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Request Management'),
        actions: [
          if (_showBulkActions) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showBulkAssignDialog,
              tooltip: 'Bulk Assign',
            ),
            IconButton(
              icon: const Icon(Icons.update),
              onPressed: _showBulkStatusDialog,
              tooltip: 'Bulk Update Status',
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedRequests.clear();
                  _showBulkActions = false;
                });
              },
              tooltip: 'Clear Selection',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const RequestStatsWidget(),
                );
              },
              tooltip: 'View Stats',
            ),
            IconButton(
              icon: const Icon(Icons.engineering),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const TechnicianPerformanceWidget(),
                );
              },
              tooltip: 'Technician Performance',
            ),
            IconButton(
              icon: Icon(_viewMode == ViewMode.list ? Icons.grid_view : Icons.list),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
                });
              },
              tooltip: 'Toggle View',
            ),
          ],
        ],
      ),
      body: _selectedRequestId != null && selectedRequest != null
          ? _buildDetailsView(selectedRequest)
          : _buildMainView(state),
      bottomNavigationBar: _showBulkActions
          ? _buildBulkActionsBar()
          : null,
    );
  }

  Widget _buildMainView(ServiceRequestState state) {
    return Column(
      children: [
        const ServiceRequestFilter(),
        if (state.stats.isNotEmpty) _buildStatsBar(state.stats),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(serviceRequestProvider.notifier).fetchServiceRequests(),
            child: state.isLoading && state.requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.requests.isEmpty
                ? _buildEmptyState()
                : _buildRequestList(state),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(Map<String, dynamic> stats) {
    final byStatus = stats['byStatus'] as List? ?? [];
    final totalRequests = byStatus.fold(0, (sum, item) => sum + (item['count'] as int));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalRequests.toString(), Icons.list),
          _buildStatItem(
            'Completed',
            (byStatus.firstWhere((item) => item['_id'] == 'completed', orElse: () => {})['count'] ?? 0).toString(),
            Icons.check_circle,
          ),
          _buildStatItem(
            'In Progress',
            (byStatus.firstWhere((item) => item['_id'] == 'in_progress', orElse: () => {})['count'] ?? 0).toString(),
            Icons.timer,
          ),
          _buildStatItem(
            'Pending',
            (byStatus.firstWhere((item) => item['_id'] == 'submitted', orElse: () => {})['count'] ?? 0).toString(),
            Icons.pending,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestList(ServiceRequestState state) {
    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: state.requests.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.requests.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final request = state.requests[index];
          final isSelected = _selectedRequests.contains(request.id);

          return GestureDetector(
            onLongPress: () => _toggleRequestSelection(request.id),
            child: Stack(
              children: [
                ServiceRequestCard(
                  request: request,
                  onTap: () => _showRequestDetails(request.id),
                  showActions: true,
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.requests.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final request = state.requests[index];
          final isSelected = _selectedRequests.contains(request.id);

          return GestureDetector(
            onLongPress: () => _toggleRequestSelection(request.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ServiceRequestCard(
                request: request,
                onTap: () => _showRequestDetails(request.id),
                showActions: true,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailsView(ServiceRequest request) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeDetails,
          ),
          title: Text(request.requestNumber),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'assign',
                  child: Row(
                    children: [
                      Icon(Icons.person_add, size: 20),
                      SizedBox(width: 8),
                      Text('Assign Technician'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(Icons.update, size: 20),
                      SizedBox(width: 8),
                      Text('Update Status'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'note',
                  child: Row(
                    children: [
                      Icon(Icons.note_add, size: 20),
                      SizedBox(width: 8),
                      Text('Add Note'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditForm(request);
                } else if (value == 'assign') {
                  _showAssignDialog(request);
                } else if (value == 'status') {
                  _showStatusDialog(request);
                } else if (value == 'note') {
                  _showAddNoteDialog(request);
                } else if (value == 'delete') {
                  _confirmDelete(request);
                }
              },
            ),
          ],
        ),
        Expanded(
          child: ServiceRequestDetails(
            request: request,
            showActions: true,
            onEdit: () => _showEditForm(request),
            onAssign: () => _showAssignDialog(request),
            onUpdateStatus: () => _showStatusDialog(request),
            onAddNote: () => _showAddNoteDialog(request),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Service Requests',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No service requests found matching your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(top: BorderSide(color: Colors.blue[100]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedRequests.length} selected',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _selectAllRequests,
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text('Select All'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showBulkAssignDialog,
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Bulk Assign'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showBulkStatusDialog,
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Bulk Status'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  void _showEditForm(ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ServiceRequestForm(
            initialData: request,
            onSuccess: () {
              Navigator.pop(context);
              ToastUtils.showSuccessToast('Service request updated successfully!');
            },
          ),
        );
      },
    );
  }

  void _showAssignDialog(ServiceRequest request) {
    // Similar to previous implementation
    final technicians = [
      {'id': '1', 'name': 'John Doe'},
      {'id': '2', 'name': 'Jane Smith'},
      {'id': '3', 'name': 'Mike Johnson'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Technician'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                return ListTile(
                  leading: const Icon(Icons.engineering),
                  title: Text(tech['name']!),
                  onTap: () {
                    ref.read(serviceRequestProvider.notifier).assignTechnician(
                      request.id,
                      tech['id']!,
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusDialog(ServiceRequest request) {
    // Similar to previous implementation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: RequestStatus.values.length,
              itemBuilder: (context, index) {
                final status = RequestStatus.values[index];
                return ListTile(
                  leading: Icon(Icons.circle, color: _getStatusColor(status)),
                  title: Text(_toTitleCase(status.name.replaceAll('_', ' '))),
                  onTap: () {
                    ref.read(serviceRequestProvider.notifier).updateRequestStatus(
                      request.id,
                      status,
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog(ServiceRequest request) {
    // Similar to previous implementation
    showDialog(
      context: context,
      builder: (context) {
        String note = '';
        String type = 'general';
        bool isInternal = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => note = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Note Type',
                      border: OutlineInputBorder(),
                    ),
                    items: NoteType.values.map((t) {
                      return DropdownMenuItem(
                        value: t.name,
                        child: Text(_toTitleCase(t.name.replaceAll('_', ' '))),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => type = value!),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Internal Note'),
                    value: isInternal,
                    onChanged: (value) => setState(() => isInternal = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (note.isNotEmpty) {
                      ref.read(serviceRequestProvider.notifier).addRequestNote(
                        request.id,
                        {
                          'note': note,
                          'type': type,
                          'isInternal': isInternal,
                        },
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(ServiceRequest request) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete service request ${request.requestNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(serviceRequestProvider.notifier).deleteServiceRequest(request.id);
                Navigator.pop(context);
                _closeDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.completed:
      case RequestStatus.closed:
        return Colors.green;
      case RequestStatus.inProgress:
      case RequestStatus.scheduled:
        return Colors.blue;
      case RequestStatus.submitted:
      case RequestStatus.underReview:
        return Colors.orange;
      case RequestStatus.rejected:
      case RequestStatus.cancelled:
        return Colors.red;
      case RequestStatus.onHold:
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}

enum ViewMode { list, grid }