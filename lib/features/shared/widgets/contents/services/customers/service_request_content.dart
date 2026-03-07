import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/utils/toast_utils.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/service_request_model.dart';
import '../../../../providers/service_request_provider.dart';
import '../../../sub_widgets/service_request/request_stats_widget.dart';
import '../../../sub_widgets/service_request/service_request_card.dart';
import '../../../sub_widgets/service_request/service_request_details.dart';
import '../../../sub_widgets/service_request/service_request_filter.dart';
import '../../../sub_widgets/service_request/service_request_form.dart';

class ServiceRequestContent extends ConsumerStatefulWidget {
  const ServiceRequestContent({super.key});

  @override
  ConsumerState<ServiceRequestContent> createState() => _ServiceRequestContentState();
}

class _ServiceRequestContentState extends ConsumerState<ServiceRequestContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  ViewMode _viewMode = ViewMode.list;
  String? _selectedRequestId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestProvider.notifier).fetchServiceRequests();
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

  void _showCreateForm() {
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
            onSuccess: () {
              Navigator.pop(context);
              ToastUtils.showSuccessToast('Service request created successfully!');
            },
          ),
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

  // Helper method for title case conversion
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceRequestProvider);
    final authState = ref.watch(authProvider);
    final selectedRequest = state.selectedRequest;
    final isAdminOrManager = authState.isAdmin || authState.isManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateForm,
            tooltip: 'New Request',
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
          if (isAdminOrManager)
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
        ],
      ),
      body: _selectedRequestId != null && selectedRequest != null
          ? _buildDetailsView(selectedRequest)
          : _buildMainView(state),
      floatingActionButton: _selectedRequestId == null
          ? FloatingActionButton(
        onPressed: _showCreateForm,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildMainView(ServiceRequestState state) {
    return Column(
      children: [
        if (ref.read(authProvider).isAdmin || ref.read(authProvider).isManager)
          const ServiceRequestFilter(),
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
          return ServiceRequestCard(
            request: request,
            onTap: () => _showRequestDetails(request.id),
            showActions: ref.read(authProvider).isAdmin || ref.read(authProvider).isManager,
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
          return ServiceRequestCard(
            request: request,
            onTap: () => _showRequestDetails(request.id),
            showActions: ref.read(authProvider).isAdmin || ref.read(authProvider).isManager,
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
            if (ref.read(authProvider).isAdmin || ref.read(authProvider).isManager)
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
            showActions: ref.read(authProvider).isAdmin || ref.read(authProvider).isManager,
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
            'Create your first service request',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCreateForm,
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
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
    // In production, you would fetch technicians from your API
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