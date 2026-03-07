import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/tender_application_model.dart';
import '../../../providers/tender_application_provider.dart';
import '../sub_screens/tender/create_application_screen.dart';
import '../sub_screens/tender/tender_application_detail_screen.dart';


class TenderApplicationListContent extends ConsumerStatefulWidget {
  final String? tenderId;
  final bool isMyApplications;

  const TenderApplicationListContent({
    super.key,
    this.tenderId,
    this.isMyApplications = false,
  });

  @override
  ConsumerState<TenderApplicationListContent> createState() => _TenderApplicationListContentState();
}

class _TenderApplicationListContentState extends ConsumerState<TenderApplicationListContent> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  void _loadApplications() {
    final applicationNotifier = ref.read(tenderApplicationProvider.notifier);

    if (widget.isMyApplications) {
      applicationNotifier.getMyApplications();
    } else if (widget.tenderId != null) {
      applicationNotifier.getTenderApplications(widget.tenderId!);
    } else {
      applicationNotifier.getAllApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(tenderApplicationProvider);
    final applications = widget.isMyApplications
        ? applicationState.myApplications
        : applicationState.applications;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMyApplications
            ? 'My Applications'
            : widget.tenderId != null
            ? 'Tender Applications'
            : 'All Applications'
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
          if (widget.tenderId != null && widget.isMyApplications == false)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                ref.read(tenderApplicationProvider.notifier).getApplicationStats();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Statistics (for procurement staff)
          if (!widget.isMyApplications) _buildStatisticsSection(applicationState),

          // Applications List
          Expanded(
            child: _buildApplicationsList(applications, applicationState),
          ),
        ],
      ),
      floatingActionButton: widget.isMyApplications
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateApplicationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'All'),
            ...ApplicationStatus.values.map((status) {
              final statusName = status.name.replaceAll('_', ' ');
              return _buildFilterChip(statusName, statusName);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'All';
          });
        },
      ),
    );
  }

  Widget _buildStatisticsSection(TenderApplicationState state) {
    if (state.stats == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', state.stats!['totalApplications']?.toString() ?? '0'),
          _buildStatItem('Submitted', _getStatusCount(state, ApplicationStatus.SUBMITTED)),
          _buildStatItem('Under Review', _getStatusCount(state, ApplicationStatus.UNDER_REVIEW)),
          _buildStatItem('Awarded', _getStatusCount(state, ApplicationStatus.AWARDED)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _getStatusCount(TenderApplicationState state, ApplicationStatus status) {
    final byStatus = state.stats!['byStatus'] as List?;
    if (byStatus == null) return '0';

    final statusData = byStatus.cast<Map<String, dynamic>>().firstWhere(
          (item) => item['status'] == status.name,
      orElse: () => {'count': 0},
    );

    return statusData['count'].toString();
  }

  Widget _buildApplicationsList(List<TenderApplication> applications, TenderApplicationState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading applications',
              style: TextStyle(color: Colors.red[300], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadApplications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredApplications = _selectedFilter == 'All'
        ? applications
        : applications.where((app) =>
    app.applicationStatus.name.replaceAll('_', ' ') == _selectedFilter
    ).toList();

    if (filteredApplications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No applications found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadApplications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredApplications.length,
        itemBuilder: (context, index) {
          final application = filteredApplications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(TenderApplication application) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TenderApplicationDetailScreen(
                applicationId: application.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application.applicationNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.applicationStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(application.applicationStatus).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      application.applicationStatus.name.replaceAll('_', ' '),
                      style: TextStyle(
                        color: _getStatusColor(application.applicationStatus),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Company Info
              Text(
                application.companyProfile.companyName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Financial Info
              if (application.totalBidAmount != null)
                Text(
                  'Bid Amount: KES ${application.totalBidAmount!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              // Evaluation Scores
              if (application.technicalScore != null || application.financialScore != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (application.technicalScore != null)
                        _buildScoreChip('Technical', application.technicalScore!),
                      if (application.financialScore != null) ...[
                        const SizedBox(width: 8),
                        _buildScoreChip('Financial', application.financialScore!),
                      ],
                      if (application.totalScore != null) ...[
                        const SizedBox(width: 8),
                        _buildScoreChip('Total', application.totalScore!, isTotal: true),
                      ],
                    ],
                  ),
                ),

              // Dates
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${application.submissionDate != null ? _formatDate(application.submissionDate!) : 'Not submitted'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              // Actions
              if (widget.isMyApplications && application.applicationStatus == ApplicationStatus.DRAFT)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Edit application
                          },
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _submitApplication(application.id);
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, double score, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTotal ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTotal ? Colors.blue : Colors.grey,
        ),
      ),
      child: Text(
        '$label: ${score.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isTotal ? Colors.blue : Colors.grey[700],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.DRAFT:
        return Colors.grey;
      case ApplicationStatus.SUBMITTED:
        return Colors.blue;
      case ApplicationStatus.UNDER_REVIEW:
        return Colors.orange;
      case ApplicationStatus.TECHNICAL_EVALUATION:
        return Colors.deepOrange;
      case ApplicationStatus.FINANCIAL_EVALUATION:
        return Colors.purple;
      case ApplicationStatus.QUALIFIED:
        return Colors.green;
      case ApplicationStatus.DISQUALIFIED:
        return Colors.red;
      case ApplicationStatus.AWARDED:
        return Colors.teal;
      case ApplicationStatus.REJECTED:
        return Colors.red;
      case ApplicationStatus.WITHDRAWN:
        return Colors.brown;
      case ApplicationStatus.PENDING_CLARIFICATION:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submitApplication(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Application'),
        content: const Text('Are you sure you want to submit this application? Once submitted, you cannot make changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(tenderApplicationProvider.notifier).submitApplication(
        applicationId,
        DateTime.now(),
      );

      if (success) {
        _loadApplications();
      }
    }
  }
}