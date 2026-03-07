import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/job_application_model.dart';
import '../../../../providers/job_application_provider.dart';
import '../sub_widgets/job_application/common/application_card.dart';
import '../sub_widgets/job_application/common/application_details_card.dart';
import '../sub_widgets/job_application/management/application_review_form.dart';
import '../sub_widgets/job_application/management/interview_schedule_form.dart';

class JobApplicationManagementContent extends ConsumerStatefulWidget {
  const JobApplicationManagementContent({super.key});

  @override
  ConsumerState<JobApplicationManagementContent> createState() =>
      _JobApplicationManagementContentState();
}

class _JobApplicationManagementContentState
    extends ConsumerState<JobApplicationManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // View management
  bool _showDetails = false;
  bool _showReviewForm = false;
  bool _showInterviewForm = false;

  // Filters
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedJobId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
      _loadStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadApplications() {
    ref.read(jobApplicationProvider.notifier).getAllApplications();
  }

  void _loadStats() {
    ref.read(jobApplicationProvider.notifier).getApplicationStats();
  }

  void _handleViewDetails() {
    setState(() {
      _showDetails = true;
      _showReviewForm = false;
      _showInterviewForm = false;
    });
  }

  void _handleCloseDetails() {
    setState(() {
      _showDetails = false;
      _showReviewForm = false;
      _showInterviewForm = false;
    });
    ref.read(jobApplicationProvider.notifier).clearSelectedApplication();
  }

  void _handleShowReviewForm() {
    setState(() {
      _showReviewForm = true;
      _showInterviewForm = false;
    });
  }

  void _handleShowInterviewForm() {
    setState(() {
      _showInterviewForm = true;
      _showReviewForm = false;
    });
  }

  void _handleReviewSubmitted(ReviewHistory review) async {
    final selectedApplication =
        ref.read(jobApplicationProvider).selectedApplication;
    if (selectedApplication != null) {
      final success = await ref.read(jobApplicationProvider.notifier).addReview(
            applicationId: selectedApplication.id,
            review: review,
          );
      if (success && mounted) {
        _handleCloseDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleInterviewScheduled(InterviewDetails interviewDetails) async {
    final selectedApplication =
        ref.read(jobApplicationProvider).selectedApplication;
    if (selectedApplication != null) {
      final success =
          await ref.read(jobApplicationProvider.notifier).addInterviewDetails(
                applicationId: selectedApplication.id,
                interviewDetails: interviewDetails,
              );
      if (success && mounted) {
        _handleCloseDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview scheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _filterApplications() {
    ref.read(jobApplicationProvider.notifier).filterApplications(
          status: _selectedStatus != null
              ? ApplicationStatus.values.firstWhere(
                  (status) => status.name.toLowerCase() == _selectedStatus,
                  orElse: () => ApplicationStatus.APPLIED,
                )
              : null,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appState = ref.watch(jobApplicationProvider);
    final selectedApplication = appState.selectedApplication;
    final applications = appState.filteredApplications;
    final stats = appState.stats;

    // Check if user is HR/Admin/Manager
    final isHR = authState.isHR || authState.isAdmin || authState.isManager;

    if (!isHR) {
      return const Center(
        child: Text(
          'Access denied. HR/Admin/Manager permissions required.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return _showReviewForm && selectedApplication != null
        ? _buildReviewForm(selectedApplication)
        : _showInterviewForm && selectedApplication != null
            ? _buildInterviewForm(selectedApplication)
            : _showDetails && selectedApplication != null
                ? _buildDetailsView(selectedApplication)
                : _buildMainContent(context, applications, stats);
  }

  Widget _buildMainContent(
    BuildContext context,
    List<JobApplication> applications,
    Map<String, dynamic> stats,
  ) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.supervisor_account,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Management',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Review and manage all job applications',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadApplications,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Stats Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context)
              .colorScheme
              .surfaceVariant
              .withValues(alpha: 0.1),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard(
                  context,
                  'Total Applications',
                  '${stats['totalApplications'] ?? 0}',
                  Icons.list_alt,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Active Applications',
                  '${stats['activeApplications'] ?? 0}',
                  Icons.trending_up,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Pending Review',
                  '${stats['statusBreakdown']?[0]?['count'] ?? 0}',
                  Icons.access_time,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Interviews',
                  '${stats['statusBreakdown']?[1]?['count'] ?? 0}',
                  Icons.calendar_today,
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Selected',
                  '${stats['statusBreakdown']?[2]?['count'] ?? 0}',
                  Icons.star,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(
                icon: Icon(Icons.inbox),
                text: 'All Applications',
              ),
              Tab(
                icon: Icon(Icons.access_time),
                text: 'Pending Review',
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'Interviews',
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: 'Selected',
              ),
            ],
          ),
        ),

        // Search and Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search applications...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _filterApplications();
                  });
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = null);
                        _filterApplications();
                      },
                    ),
                    const SizedBox(width: 8),
                    ...ApplicationStatus.values
                        .where((status) =>
                            status != ApplicationStatus.DRAFT &&
                            status != ApplicationStatus.ARCHIVED)
                        .map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            status.name
                                .split('_')
                                .map((word) =>
                                    word[0].toUpperCase() + word.substring(1))
                                .join(' '),
                          ),
                          selected:
                              _selectedStatus == status.name.toLowerCase(),
                          onSelected: (selected) {
                            setState(() => _selectedStatus =
                                selected ? status.name.toLowerCase() : null);
                            _filterApplications();
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Applications List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Applications
              _buildApplicationsList(applications),

              // Pending Review (filtered by status)
              _buildApplicationsList(applications
                  .where((app) =>
                      app.status == ApplicationStatus.UNDER_REVIEW ||
                      app.status == ApplicationStatus.SCREENING)
                  .toList()),

              // Interviews (filtered by status)
              _buildApplicationsList(applications
                  .where((app) =>
                      app.status == ApplicationStatus.INTERVIEW_SCHEDULED ||
                      app.status == ApplicationStatus.INTERVIEW_IN_PROGRESS ||
                      app.status == ApplicationStatus.INTERVIEW_COMPLETED)
                  .toList()),

              // Selected (filtered by status)
              _buildApplicationsList(applications
                  .where((app) =>
                      app.status == ApplicationStatus.SELECTED ||
                      app.status == ApplicationStatus.OFFER_PENDING ||
                      app.status == ApplicationStatus.OFFER_EXTENDED ||
                      app.status == ApplicationStatus.OFFER_ACCEPTED)
                  .toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsList(List<JobApplication> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No applications found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
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
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return ApplicationCard(
            application: application,
            showJobDetails: true,
            showApplicantDetails: true,
            showActions: true,
            onTap: () {
              ref
                  .read(jobApplicationProvider.notifier)
                  .selectApplication(application);
              _handleViewDetails();
            },
            onViewDetails: () {
              ref
                  .read(jobApplicationProvider.notifier)
                  .selectApplication(application);
              _handleViewDetails();
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailsView(JobApplication application) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleCloseDetails,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Management',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      application.applicationNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Details Card
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ApplicationDetailsCard(
                application: application,
                showFullDetails: true,
                isHRView: true,
                onScheduleInterview: _handleShowInterviewForm,
                onAddReview: _handleShowReviewForm,
                onWithdraw: () {
                  // Withdraw functionality for HR
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewForm(JobApplication application) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _showReviewForm = false);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Review',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      application.applicationNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Review Form
        Expanded(
          child: ApplicationReviewForm(
            application: application,
            onSubmit: _handleReviewSubmitted,
            onCancel: () {
              setState(() => _showReviewForm = false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewForm(JobApplication application) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _showInterviewForm = false);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Interview',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      application.applicant.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Interview Form
        Expanded(
          child: InterviewScheduleForm(
            application: application,
            onSubmit: _handleInterviewScheduled,
            onCancel: () {
              setState(() => _showInterviewForm = false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
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
