import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/job_application_model.dart';
import '../../../../providers/job_application_provider.dart';
import '../sub_widgets/job_application/applicant/apply_job_form.dart';
import '../sub_widgets/job_application/applicant/my_applications_list.dart';
import '../sub_widgets/job_application/common/application_details_card.dart';

class JobApplicationContent extends ConsumerStatefulWidget {
  final String? initialJobId;

  const JobApplicationContent({super.key, this.initialJobId});

  @override
  ConsumerState<JobApplicationContent> createState() =>
      _JobApplicationContentState();
}

class _JobApplicationContentState extends ConsumerState<JobApplicationContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // View management
  bool _showApplyForm = false;
  bool _showDetails = false;
  String? _selectedJobId;
  String? _selectedJobTitle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.initialJobId != null) {
      _selectedJobId = widget.initialJobId;
      _showApplyForm = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleApplyJob(String jobId, String jobTitle) {
    setState(() {
      _selectedJobId = jobId;
      _selectedJobTitle = jobTitle;
      _showApplyForm = true;
      _showDetails = false;
    });
  }

  void _handleViewDetails() {
    setState(() {
      _showDetails = true;
      _showApplyForm = false;
    });
  }

  void _closeForms() {
    setState(() {
      _showApplyForm = false;
      _showDetails = false;
      _selectedJobId = null;
      _selectedJobTitle = null;
    });
    ref.read(jobApplicationProvider.notifier).clearSelectedApplication();
  }

  void _handleApplicationSuccess() {
    _closeForms();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appState = ref.watch(jobApplicationProvider);
    final selectedApplication = appState.selectedApplication;

    // Check if user is applicant or HR
    final isApplicant =
        authState.hasRole('User') && !authState.isHR && !authState.isAdmin;

    if (!isApplicant) {
      return const Center(
        child: Text(
          'This section is only available for job applicants',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body:
          _showApplyForm && _selectedJobId != null && _selectedJobTitle != null
              ? _buildApplyForm()
              : _showDetails && selectedApplication != null
                  ? _buildDetailsView(selectedApplication)
                  : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
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
                Icons.work_outline,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Applications',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Track and manage your job applications',
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

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'My Applications',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Application History',
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // My Applications Tab
              MyApplicationsList(
                onApplicationSelected: _handleViewDetails,
                showFilters: true,
                showStats: true,
              ),

              // Application History Tab
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application Statistics',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  'Total Applications',
                                  '12',
                                  Icons.list_alt,
                                  Colors.blue,
                                ),
                                _buildStatItem(
                                  'Success Rate',
                                  '25%',
                                  Icons.trending_up,
                                  Colors.green,
                                ),
                                _buildStatItem(
                                  'Avg. Response Time',
                                  '3 days',
                                  Icons.timelapse,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_graph,
                              size: 80,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Detailed Analytics Coming Soon',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Track your application success rates and improve your job search strategy',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyForm() {
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
                onPressed: _closeForms,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply for $_selectedJobTitle',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Complete your application',
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

        // Apply Form
        Expanded(
          child: ApplyJobForm(
            jobId: _selectedJobId!,
            jobTitle: _selectedJobTitle!,
            onSuccess: _handleApplicationSuccess,
            onCancel: _closeForms,
          ),
        ),
      ],
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
                onPressed: _closeForms,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Details',
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
                onWithdraw: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Withdraw Application'),
                      content: const Text(
                        'Are you sure you want to withdraw this application? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            final success = await ref
                                .read(jobApplicationProvider.notifier)
                                .withdrawApplication(
                                  application.id,
                                  'User withdrew',
                                );
                            if (success) {
                              _closeForms();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Application withdrawn successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
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
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
