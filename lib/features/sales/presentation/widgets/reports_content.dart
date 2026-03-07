import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nawassco/features/sales/presentation/widgets/sub_widgets/reports/report_detail_widget.dart';
import 'package:nawassco/features/sales/presentation/widgets/sub_widgets/reports/report_form_widget.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../models/report.model.dart';
import '../../providers/report_provider.dart';
import 'sub_widgets/reports/report_list_widget.dart';
import 'sub_widgets/reports/report_stats_widget.dart';
import 'sub_widgets/reports/responsive.dart';

class ReportsContent extends ConsumerStatefulWidget {
  const ReportsContent({super.key});

  @override
  ConsumerState<ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends ConsumerState<ReportsContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final authState = ref.read(authProvider);
    final provider = ref.read(reportProvider.notifier);

    if (authState.user != null) {
      provider.updateFilters(ReportFilters(authorId: authState.user!['_id'].toString()));
    } else {
      provider.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);
    final provider = ref.read(reportProvider.notifier);
    final authState = ref.watch(authProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isMobile) _buildTabHeader(state),
            if (isMobile) _buildMobileHeader(state),
            const SizedBox(height: 16),
            Expanded(child: _buildTabContent(state, provider, authState)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader(ReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E3A8A),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF1E3A8A),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Reports List'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
        ),
        if (_currentTabIndex == 0) _buildListHeader(),
      ],
    );
  }

  Widget _buildMobileHeader(ReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Reports List'),
                selected: _currentTabIndex == 0,
                onSelected: (selected) {
                  setState(() {
                    _currentTabIndex = selected ? 0 : _currentTabIndex;
                    _tabController.animateTo(0);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Statistics'),
                selected: _currentTabIndex == 1,
                onSelected: (selected) {
                  setState(() {
                    _currentTabIndex = selected ? 1 : _currentTabIndex;
                    _tabController.animateTo(1);
                  });
                },
              ),
            ),
          ],
        ),
        if (_currentTabIndex == 0) _buildListHeader(),
      ],
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Reports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context, ref.read(reportProvider.notifier), ref.read(authProvider)),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ReportState state, ReportProvider provider, AuthState authState) {
    switch (_currentTabIndex) {
      case 0:
        return ReportListWidget(
          showFilters: false,
          showCreateButton: false,
          onCreateReport: () => _showCreateDialog(context, provider, authState),
          onViewReport: (report) => _showDetailDialog(context, report, provider, authState),
          onEditReport: (report) => _showEditDialog(context, report, provider, authState),
        );
      case 1:
        return state.stats != null
            ? SingleChildScrollView(child: ReportStatsWidget(stats: state.stats!))
            : const Center(child: CircularProgressIndicator());
      default:
        return ReportListWidget(
          showFilters: false,
          showCreateButton: false,
          onCreateReport: () => _showCreateDialog(context, provider, authState),
          onViewReport: (report) => _showDetailDialog(context, report, provider, authState),
          onEditReport: (report) => _showEditDialog(context, report, provider, authState),
        );
    }
  }

  void _showCreateDialog(BuildContext context, ReportProvider provider, AuthState authState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: ReportFormWidget(
            isEditing: false,
            onSubmitted: () {
              Navigator.pop(context);
              provider.refreshData();
            },
            onCancelled: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Report report, ReportProvider provider, AuthState authState) {
    final canEdit = report.authorId == authState.user?['_id'] && report.canEdit;
    if (!canEdit) {
      _showDetailDialog(context, report, provider, authState);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: ReportFormWidget(
            report: report,
            isEditing: true,
            onSubmitted: () {
              Navigator.pop(context);
              provider.refreshData();
            },
            onCancelled: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Report report, ReportProvider provider, AuthState authState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
          child: ReportDetailWidget(
            report: report,
            onClose: () => Navigator.pop(context),
            onEdit: () {
              Navigator.pop(context);
              _showEditDialog(context, report, provider, authState);
            },
            onDelete: () {
              Navigator.pop(context);
              provider.deleteReport(report.id);
            },
            onSubmitForReview: () {
              Navigator.pop(context);
              provider.submitReportForReview(report.id);
            },
            onApprove: () {
              Navigator.pop(context);
              provider.approveReport(report.id);
            },
            onReject: (String reason) {
              Navigator.pop(context);
              provider.rejectReport(report.id, reason);
            },
          ),
        ),
      ),
    );
  }
}