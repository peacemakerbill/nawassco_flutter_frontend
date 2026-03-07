import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/job_model.dart';
import '../../../../providers/job_providers.dart';
import '../sub_widgets/jobs/job_card.dart';
import '../sub_widgets/jobs/job_filter_sheet.dart';
import '../sub_widgets/jobs/job_form_dialog.dart';

class JobManagementContent extends ConsumerStatefulWidget {
  const JobManagementContent({super.key});

  @override
  ConsumerState<JobManagementContent> createState() =>
      _JobManagementContentState();
}

class _JobManagementContentState extends ConsumerState<JobManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_scrollListener);

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobProvider.notifier).fetchJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(jobProvider.notifier).loadMoreJobs();
    }
  }

  void _showCreateJobDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const JobFormDialog(),
    );
  }

  void _showEditJobDialog(String jobId) {
    final job = ref.read(jobProvider).jobs.firstWhere((j) => j.id == jobId);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JobFormDialog(initialJob: job),
    );
  }

  void _showFilters() {
    final currentFilters = ref.read(jobProvider).filters;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => JobFilterSheet(
        initialFilters: currentFilters,
        onApplyFilters: (filters) {
          ref.read(jobProvider.notifier).searchJobs(filters);
        },
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        ref.read(jobProvider.notifier).searchJobs({});
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(jobProvider.notifier).searchJobs({'title': query});
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = ref.watch(jobProvider);
    final authState = ref.watch(authProvider);

    if (!authState.hasAnyRole(['HR', 'Admin', 'Manager'])) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Job Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(jobProvider.notifier).getJobStats();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatItem(
                  icon: Icons.work,
                  value: stats.totalJobs.toString(),
                  label: 'Total Jobs',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.public,
                  value: (stats.jobs.where((j) => j.isPublished).length)
                      .toString(),
                  label: 'Published',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.drafts,
                  value: (stats.jobs
                          .where((j) => j.status == JobStatus.DRAFT)
                          .length)
                      .toString(),
                  label: 'Drafts',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.people,
                  value: stats.jobs
                      .fold(0, (sum, job) => sum + job.numberOfApplications)
                      .toString(),
                  label: 'Total Applications',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final authState = ref.watch(authProvider);
    final isHR = authState.hasAnyRole(['HR', 'Admin', 'Manager']);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No Jobs Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHR
                  ? 'Get started by creating your first job opening'
                  : 'Check back later for new job opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            if (isHR)
              ElevatedButton.icon(
                onPressed: _showCreateJobDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Job Opening'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList() {
    final state = ref.watch(jobProvider);
    final authState = ref.watch(authProvider);
    final isHR = authState.hasAnyRole(['HR', 'Admin', 'Manager']);

    if (state.isLoading && state.jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.jobs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(jobProvider.notifier).fetchJobs(resetFilters: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            state.jobs.length + (state.currentPage < state.totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final job = state.jobs[index];
          return JobCard(
            key: ValueKey(job.id),
            job: job,
            showActions: isHR,
            onEdit: () => _showEditJobDialog(job.id),
            onDelete: () => ref.read(jobProvider.notifier).deleteJob(job.id),
            onPublish: () => ref.read(jobProvider.notifier).publishJob(job.id),
            onClose: () => ref.read(jobProvider.notifier).closeJob(job.id),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isHR = authState.hasAnyRole(['HR', 'Admin', 'Manager']);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Job Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade800,
                        Colors.blue.shade600,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilters,
                ),
                if (isHR)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showCreateJobDialog,
                  ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            if (_showSearch) _buildSearchBar(),
            if (isHR) _buildStatsCard(),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: const [
                          Tab(text: 'All Jobs'),
                          Tab(text: 'Published'),
                          Tab(text: 'Drafts'),
                          Tab(text: 'Closed'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildJobList(),
                          _buildFilteredList(JobStatus.PUBLISHED),
                          _buildFilteredList(JobStatus.DRAFT),
                          _buildFilteredList(JobStatus.CLOSED),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isHR
          ? FloatingActionButton.extended(
              onPressed: _showCreateJobDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Job'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildFilteredList(JobStatus status) {
    final state = ref.watch(jobProvider);
    final filteredJobs =
        state.jobs.where((job) => job.status == status).toList();

    if (filteredJobs.isEmpty) {
      return Center(
        child: Text(
          'No ${status.displayName.toLowerCase()} jobs',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        final authState = ref.read(authProvider);
        final isHR = authState.hasAnyRole(['HR', 'Admin', 'Manager']);

        return JobCard(
          key: ValueKey(job.id),
          job: job,
          showActions: isHR,
          onEdit: () => _showEditJobDialog(job.id),
          onDelete: () => ref.read(jobProvider.notifier).deleteJob(job.id),
          onPublish: () => ref.read(jobProvider.notifier).publishJob(job.id),
          onClose: () => ref.read(jobProvider.notifier).closeJob(job.id),
        );
      },
    );
  }
}
