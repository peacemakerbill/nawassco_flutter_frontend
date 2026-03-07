import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class OutageDetailWidget extends StatelessWidget {
  final Outage outage;
  final bool showActions;

  const OutageDetailWidget({
    super.key,
    required this.outage,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(outage.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(outage.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outage.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '#${outage.outageNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _buildQuickStats(),

                  const SizedBox(height: 24),

                  // Description
                  _buildSection('Description', outage.description, context),

                  const SizedBox(height: 24),

                  // Affected Areas
                  _buildAffectedAreas(context),

                  const SizedBox(height: 24),

                  // Timing
                  _buildTimingInfo(context),

                  const SizedBox(height: 24),

                  // Impact Assessment
                  _buildImpactAssessment(context),

                  const SizedBox(height: 24),

                  // Resources
                  _buildResources(context),

                  const SizedBox(height: 24),

                  // Metadata
                  _buildMetadata(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'Priority',
          outage.priority.toString().split('.').last,
          _getPriorityColor(outage.priority),
        ),
        _buildStatCard(
          'Status',
          outage.status.toString().split('.').last.replaceAll('_', ' '),
          _getStatusColor(outage.status),
        ),
        _buildStatCard(
          'Affected',
          outage.estimatedAffectedCustomers.toString(),
          Colors.blue,
        ),
        _buildStatCard(
          'Duration',
          '${outage.estimatedDuration ~/ 60}h',
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAffectedAreas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Affected Areas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...outage.affectedAreas.map((area) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${area.zone} - ${area.subzone}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14),
                      const SizedBox(width: 4),
                      Text('${area.estimatedCustomers} customers'),
                      const SizedBox(width: 16),
                      if (area.alternativeSupply)
                        const Row(
                          children: [
                            Icon(Icons.water_drop, size: 14),
                            SizedBox(width: 4),
                            Text('Alternative supply available'),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimingInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timing',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                'Reported',
                outage.createdAt,
                Icons.report,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeCard(
                'Updated',
                outage.updatedAt,
                Icons.update,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (outage.scheduledStart != null)
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  'Scheduled Start',
                  outage.scheduledStart!,
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              if (outage.scheduledEnd != null)
                Expanded(
                  child: _buildTimeCard(
                    'Scheduled End',
                    outage.scheduledEnd!,
                    Icons.schedule,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildTimeCard(String label, DateTime time, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${time.day}/${time.month}/${time.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactAssessment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Assessment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildImpactItem('Residential',
                          outage.impact.residentialCustomers),
                    ),
                    Expanded(
                      child: _buildImpactItem('Commercial',
                          outage.impact.commercialCustomers),
                    ),
                    Expanded(
                      child: _buildImpactItem('Industrial',
                          outage.impact.industrialCustomers),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.speed, size: 16),
                    const SizedBox(width: 4),
                    const Text('Pressure Impact:'),
                    const SizedBox(width: 8),
                    Text(
                      outage.impact.waterPressureImpact
                          .toString()
                          .split('.')
                          .last,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (outage.impact.waterQualityIssues)
                  const SizedBox(height: 8),
                if (outage.impact.waterQualityIssues)
                  const Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('Water Quality Issues'),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildResources( BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (outage.assignedCrew.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assigned Crew:'),
              Wrap(
                spacing: 4,
                children: outage.assignedCrew
                    .map((member) => Chip(label: Text(member)))
                    .toList(),
              ),
            ],
          ),
        if (outage.requiredResources.isNotEmpty) const SizedBox(height: 12),
        if (outage.requiredResources.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Required Resources:'),
              ...outage.requiredResources.map((resource) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.inventory, size: 20),
                  title: Text(
                    '${resource.quantity} ${resource.unit} ${resource.type.toString().split('.').last.toLowerCase()}',
                  ),
                  subtitle: Text(
                    resource.status.toString().split('.').last.toLowerCase(),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metadata',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMetadataItem('Reported By', outage.reportedBy),
            if (outage.approvedBy != null)
              _buildMetadataItem('Approved By', outage.approvedBy!),
            _buildMetadataItem('Created', outage.createdAt.toString()),
            _buildMetadataItem('Last Updated', outage.updatedAt.toString()),
            if (outage.closedAt != null)
              _buildMetadataItem('Closed', outage.closedAt!.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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

  Color _getStatusColor(OutageStatus status) {
    switch (status) {
      case OutageStatus.REPORTED:
        return Colors.orange;
      case OutageStatus.CONFIRMED:
        return Colors.deepOrange;
      case OutageStatus.IN_PROGRESS:
        return Colors.blue;
      case OutageStatus.ON_HOLD:
        return Colors.amber;
      case OutageStatus.RESOLVED:
        return Colors.green;
      case OutageStatus.VERIFIED:
        return Colors.teal;
      case OutageStatus.CLOSED:
        return Colors.grey;
      case OutageStatus.CANCELLED:
        return Colors.red;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.LOW:
        return Colors.green;
      case PriorityLevel.MEDIUM:
        return Colors.blue;
      case PriorityLevel.HIGH:
        return Colors.orange;
      case PriorityLevel.CRITICAL:
        return Colors.red;
    }
  }
}