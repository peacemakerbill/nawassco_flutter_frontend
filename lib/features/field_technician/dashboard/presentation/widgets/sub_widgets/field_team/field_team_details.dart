import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_team.dart';
import '../../../../models/field_technician.dart';
import '../../../../providers/field_team_provider.dart';

class FieldTeamDetailsWidget extends ConsumerStatefulWidget {
  final FieldTeam team;
  final VoidCallback onEdit;
  final VoidCallback onBack;

  const FieldTeamDetailsWidget({
    super.key,
    required this.team,
    required this.onEdit,
    required this.onBack,
  });

  @override
  ConsumerState<FieldTeamDetailsWidget> createState() =>
      _FieldTeamDetailsWidgetState();
}

class _FieldTeamDetailsWidgetState
    extends ConsumerState<FieldTeamDetailsWidget> {
  late FieldTeam _team;
  Map<String, dynamic>? _workloadData;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    _loadWorkloadData();
  }

  void _loadWorkloadData() async {
    final workload =
        await ref.read(fieldTeamProvider.notifier).getTeamWorkload(_team.id);
    if (mounted) {
      setState(() {
        _workloadData = workload;
      });
    }
  }

  void _refreshTeam() async {
    await ref.read(fieldTeamProvider.notifier).getFieldTeamById(_team.id);
    final updatedState = ref.read(fieldTeamProvider);
    if (updatedState.currentTeam != null && mounted) {
      setState(() {
        _team = updatedState.currentTeam!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.groups,
                          size: 32, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _team.teamName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _team.teamCode,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusBadge(_team.availability.status),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _team.isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _team.isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  _team.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _team.isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _refreshTeam,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Overview Cards
            _buildOverviewCards(),

            const SizedBox(height: 16),

            // Tabs for detailed information
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: 'Members'),
                        Tab(text: 'Performance'),
                        Tab(text: 'Schedule'),
                        Tab(text: 'Equipment'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildMembersTab(),
                        _buildPerformanceTab(),
                        _buildScheduleTab(),
                        _buildEquipmentTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      children: [
        _buildOverviewCard(
          'Team Members',
          '${_team.totalMembers}',
          Icons.people,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Workload',
          '${_team.currentWorkload.toStringAsFixed(1)}%',
          Icons.work,
          _team.workloadColor,
        ),
        _buildOverviewCard(
          'Performance',
          '${_team.performance.overallScore.toStringAsFixed(0)}%',
          Icons.assessment,
          _team.performance.performanceColor,
        ),
        _buildOverviewCard(
          'Availability',
          '${_team.availability.availableMembers}/${_team.availability.totalMembers}',
          Icons.event_available,
          _team.availability.status.color,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_team.teamLead != null) ...[
              _buildMemberTile(_team.teamLead!, true),
              const Divider(),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _team.members.length,
                itemBuilder: (context, index) =>
                    _buildMemberTile(_team.members[index], false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(FieldTechnician technician, bool isTeamLead) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: technician.currentStatus.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(technician.currentStatus.icon,
            color: technician.currentStatus.color),
      ),
      title: Text(
        technician.fullName,
        style: TextStyle(
          fontWeight: isTeamLead ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(technician.jobTitle.displayName),
          Text(
            technician.currentStatus.displayName,
            style: TextStyle(color: technician.currentStatus.color),
          ),
        ],
      ),
      trailing: isTeamLead
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Team Lead',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPerformanceTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric(
              'On-Time Completion',
              '${_team.performance.onTimeCompletionRate.toStringAsFixed(1)}%',
              _team.performance.onTimeCompletionRate,
            ),
            _buildPerformanceMetric(
              'Quality Score',
              '${_team.performance.qualityScore.toStringAsFixed(1)}%',
              _team.performance.qualityScore,
            ),
            _buildPerformanceMetric(
              'Customer Satisfaction',
              '${_team.performance.customerSatisfaction.toStringAsFixed(1)}%',
              _team.performance.customerSatisfaction,
            ),
            _buildPerformanceMetric(
              'Efficiency',
              '${_team.performance.efficiency.toStringAsFixed(1)}%',
              _team.performance.efficiency,
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Overall Performance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _team.performance.performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _team.performance.performanceColor),
                ),
                child: Text(
                  _team.performance.performanceLevel,
                  style: TextStyle(
                    color: _team.performance.performanceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[200],
            color: _getScoreColor(score),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Work Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildScheduleItem('Shift', _team.workSchedule.shift),
            _buildScheduleItem('Start Time', _team.workSchedule.startTime),
            _buildScheduleItem('End Time', _team.workSchedule.endTime),
            const SizedBox(height: 16),
            const Text(
              'Working Days',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _team.workSchedule.workingDays
                  .map((day) => Chip(
                        label: Text(day),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Equipment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vehicles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_team.assignedVehicleIds.isEmpty)
              const Text('No vehicles assigned'),
            ..._team.assignedVehicleIds.map((vehicle) => ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(vehicle),
                  subtitle: const Text('Assigned Vehicle'),
                )),
            const Divider(),
            const Text(
              'Tools',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_team.assignedToolIds.isEmpty) const Text('No tools assigned'),
            ..._team.assignedToolIds.map((tool) => ListTile(
                  leading: const Icon(Icons.build),
                  title: Text(tool),
                  subtitle: const Text('Assigned Tool'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TeamStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
