import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../public/auth/providers/auth_provider.dart';
import '../../../models/consultancy_model.dart';
import '../../../providers/consultancy_provider.dart';
import '../../dialogs/consultancy/milestone_dialog.dart';
import '../../dialogs/consultancy/team_member_dialog.dart';
import 'status_chip.dart';


class ConsultancyDetailView extends ConsumerStatefulWidget {
  final Consultancy consultancy;

  const ConsultancyDetailView({
    super.key,
    required this.consultancy,
  });

  @override
  ConsumerState<ConsultancyDetailView> createState() => _ConsultancyDetailViewState();
}

class _ConsultancyDetailViewState extends ConsumerState<ConsultancyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(ConsultancyStatus newStatus) async {
    await ref.read(consultancyProvider.notifier).updateConsultancyStatus(
      widget.consultancy.id,
      newStatus,
    );
  }

  Future<void> _addMilestone() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const MilestoneDialog(),
    );

    if (result != null) {
      await ref.read(consultancyProvider.notifier).addMilestone(
        widget.consultancy.id,
        result,
      );
    }
  }

  Future<void> _addTeamMember() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TeamMemberDialog(),
    );

    if (result != null) {
      await ref.read(consultancyProvider.notifier).addTeamMember(
        widget.consultancy.id,
        result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final canManage = authState.hasAnyRole(['Admin', 'Manager', 'HR']);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with background
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.consultancy.consultancyNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.consultancy.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusChip(status: widget.consultancy.status),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (canManage) ...[
                PopupMenuButton<ConsultancyStatus>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ConsultancyStatus.APPROVED,
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Approve'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: ConsultancyStatus.ACTIVE,
                      child: ListTile(
                        leading: Icon(Icons.play_circle, color: Colors.blue),
                        title: Text('Set Active'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: ConsultancyStatus.ON_HOLD,
                      child: ListTile(
                        leading: Icon(Icons.pause_circle, color: Colors.orange),
                        title: Text('Put On Hold'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: ConsultancyStatus.COMPLETED,
                      child: ListTile(
                        leading: Icon(Icons.done_all, color: Colors.green),
                        title: Text('Mark Completed'),
                      ),
                    ),
                  ],
                  onSelected: _updateStatus,
                ),
              ],
            ],
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats row
                _buildQuickStats(context),

                const SizedBox(height: 24),

                // Tabs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Scope'),
                        Tab(text: 'Team'),
                        Tab(text: 'Milestones'),
                        Tab(text: 'Budget'),
                      ],
                    ),

                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),
                          _buildScopeTab(),
                          _buildTeamTab(),
                          _buildMilestonesTab(),
                          _buildBudgetTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: canManage
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_milestone',
            onPressed: _addMilestone,
            child: const Icon(Icons.flag),
            mini: true,
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add_team',
            onPressed: _addTeamMember,
            child: const Icon(Icons.person_add),
            mini: true,
          ),
        ],
      )
          : null,
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.calendar_today,
              value: DateFormat('dd MMM').format(widget.consultancy.timeline.startDate),
              label: 'Start Date',
            ),
            _buildStatItem(
              context,
              icon: Icons.attach_money,
              value: 'KES ${NumberFormat('#,##0').format(widget.consultancy.budget.totalAmount)}',
              label: 'Budget',
            ),
            _buildStatItem(
              context,
              icon: Icons.people,
              value: widget.consultancy.team.length.toString(),
              label: 'Team',
            ),
            _buildStatItem(
              context,
              icon: Icons.flag,
              value: widget.consultancy.milestones.length.toString(),
              label: 'Milestones',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, {
        required IconData icon,
        required String value,
        required String label,
      }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: theme.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Description',
            child: Text(
              widget.consultancy.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoSection(
            title: 'Client Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(widget.consultancy.client.name),
                  subtitle: Text(widget.consultancy.client.type.displayName),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Address'),
                  subtitle: Text(widget.consultancy.client.address),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(widget.consultancy.client.contactPerson.name),
                  subtitle: Text(widget.consultancy.client.contactPerson.position),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(widget.consultancy.client.email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(widget.consultancy.client.phone),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoSection(
            title: 'Timeline',
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: widget.consultancy.progressPercentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(widget.consultancy.timeline.startDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Duration',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '${widget.consultancy.timeline.duration} months',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'End',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(widget.consultancy.timeline.endDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Methodology',
            child: Text(widget.consultancy.scope.methodology),
          ),

          const SizedBox(height: 16),

          _buildInfoSection(
            title: 'Objectives',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.consultancy.scope.objectives
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(entry.value),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoSection(
            title: 'Expected Deliverables',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.consultancy.scope.deliverables.map((deliverable) {
                return Chip(
                  label: Text(deliverable),
                  backgroundColor: Colors.green[50],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    final authState = ref.watch(authProvider);
    final canManage = authState.hasAnyRole(['Admin', 'Manager', 'HR']);

    return Column(
      children: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _addTeamMember,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Team Member'),
            ),
          ),

        Expanded(
          child: widget.consultancy.team.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No team members assigned',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: widget.consultancy.team.length,
            itemBuilder: (context, index) {
              final member = widget.consultancy.team[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(member.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.role.displayName),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${member.rate}/hr • ${member.hoursAllocated} hrs',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  trailing: Text(
                    'KES ${NumberFormat('#,##0').format(member.totalCost)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesTab() {
    final authState = ref.watch(authProvider);
    final canManage = authState.hasAnyRole(['Admin', 'Manager', 'HR']);

    return Column(
      children: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _addMilestone,
              icon: const Icon(Icons.flag),
              label: const Text('Add Milestone'),
            ),
          ),

        Expanded(
          child: widget.consultancy.milestones.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No milestones added',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: widget.consultancy.milestones.length,
            itemBuilder: (context, index) {
              final milestone = widget.consultancy.milestones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: milestone.status == MilestoneStatus.COMPLETED
                          ? Colors.green.withValues(alpha: 0.1)
                          : milestone.isOverdue
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      milestone.status == MilestoneStatus.COMPLETED
                          ? Icons.check_circle
                          : milestone.isOverdue
                          ? Icons.warning
                          : Icons.flag,
                      color: milestone.status == MilestoneStatus.COMPLETED
                          ? Colors.green
                          : milestone.isOverdue
                          ? Colors.red
                          : Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(milestone.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(milestone.description),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${milestone.formattedDueDate}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: milestone.isOverdue
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: milestone.isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(milestone.status.displayName),
                    backgroundColor: milestone.status == MilestoneStatus.COMPLETED
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: milestone.status == MilestoneStatus.COMPLETED
                          ? Colors.green
                          : Colors.grey[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTab() {
    final totalBudget = widget.consultancy.budget.totalAmount;
    final expenses = widget.consultancy.budget.expenses;
    final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final remainingBudget = totalBudget - totalExpenses;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Summary
          _buildInfoSection(
            title: 'Budget Summary',
            child: Column(
              children: [
                _buildBudgetItem(
                  label: 'Total Budget',
                  value: totalBudget,
                  color: Colors.blue,
                ),
                _buildBudgetItem(
                  label: 'Total Expenses',
                  value: totalExpenses,
                  color: Colors.orange,
                ),
                _buildBudgetItem(
                  label: 'Remaining Budget',
                  value: remainingBudget,
                  color: remainingBudget >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Budget Breakdown
          if (widget.consultancy.budget.breakdown.isNotEmpty) ...[
            _buildInfoSection(
              title: 'Budget Breakdown',
              child: Column(
                children: widget.consultancy.budget.breakdown
                    .map((item) => ListTile(
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.category.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(item.item),
                  subtitle: Text(item.description),
                  trailing: Text(
                    'KES ${NumberFormat('#,##0').format(item.total)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Payment Schedule
          if (widget.consultancy.budget.paymentSchedule.isNotEmpty) ...[
            _buildInfoSection(
              title: 'Payment Schedule',
              child: Column(
                children: widget.consultancy.budget.paymentSchedule
                    .map((payment) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: payment.status == PaymentStatus.PAID
                            ? Colors.green.withValues(alpha: 0.1)
                            : payment.status == PaymentStatus.OVERDUE
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        payment.status == PaymentStatus.PAID
                            ? Icons.check_circle
                            : payment.status == PaymentStatus.OVERDUE
                            ? Icons.warning
                            : Icons.schedule,
                        color: payment.status == PaymentStatus.PAID
                            ? Colors.green
                            : payment.status == PaymentStatus.OVERDUE
                            ? Colors.red
                            : Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(payment.milestone),
                    subtitle: Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(payment.dueDate)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'KES ${NumberFormat('#,##0').format(payment.amount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(${payment.percentage}%)',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetItem({
    required String label,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            'KES ${NumberFormat('#,##0').format(value)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}