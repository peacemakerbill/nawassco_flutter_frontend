import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/water_source_model.dart';
import '../../../providers/water_source_provider.dart';
import '../../../utils/water_sources/water_source_constants.dart';


class WaterSourceDetails extends ConsumerWidget {
  final WaterSource waterSource;
  final bool showActions;

  const WaterSourceDetails({
    Key? key,
    required this.waterSource,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                waterSource.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: waterSource.status.color.withValues(alpha: 0.8),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        waterSource.type.displayName,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Actions
                  _buildStatusSection(context, ref),
                  const SizedBox(height: 24),
                  // Location Information
                  _buildLocationSection(context),
                  const SizedBox(height: 24),
                  // Capacity Information
                  _buildCapacitySection(context),
                  const SizedBox(height: 24),
                  // Quality Information
                  _buildQualitySection(context),
                  const SizedBox(height: 24),
                  // Infrastructure Information
                  _buildInfrastructureSection(context),
                  const SizedBox(height: 24),
                  // Monitoring and Alerts
                  _buildMonitoringSection(context, ref),
                  const SizedBox(height: 24),
                  // Service Areas
                  if (waterSource.serviceAreas.isNotEmpty)
                    _buildServiceAreasSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: waterSource.status.color.withValues(alpha: 0.1),
                  radius: 30,
                  child: Text(
                    waterSource.type.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        waterSource.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        WaterSourceConstants
                                .sourceTypeDescriptions[waterSource.type] ??
                            '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (showActions) _buildActionButtons(context, ref),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    waterSource.status.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: waterSource.status.color,
                ),
                Chip(
                  label: Text(
                    'Catchment: ${waterSource.location.catchmentArea}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Elevation: ${waterSource.location.elevation.toStringAsFixed(0)}m',
                  ),
                ),
                if (waterSource.infrastructure.treatmentRequired)
                  const Chip(
                    label: Text(
                      'Treatment Required',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final provider = ref.read(waterSourceProvider.notifier);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            // Navigate to edit form
            break;
          case 'delete':
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Water Source'),
                content: const Text(
                    'Are you sure you want to delete this water source? This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await provider.deleteWaterSource(waterSource.id);
            }
            break;
          case 'add_alert':
            _showAddAlertDialog(context, ref);
            break;
          case 'schedule_inspection':
            _showScheduleInspectionDialog(context, ref);
            break;
        }
      },
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
          value: 'add_alert',
          child: Row(
            children: [
              Icon(Icons.warning, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Add Alert'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'schedule_inspection',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20),
              SizedBox(width: 8),
              Text('Schedule Inspection'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Location Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoItem(
                  context,
                  'Address',
                  waterSource.location.address,
                  Icons.home,
                ),
                _buildInfoItem(
                  context,
                  'Coordinates',
                  '${waterSource.location.coordinates.latitude.toStringAsFixed(4)}, '
                      '${waterSource.location.coordinates.longitude.toStringAsFixed(4)}',
                  Icons.gps_fixed,
                ),
                _buildInfoItem(
                  context,
                  'Catchment Area',
                  waterSource.location.catchmentArea,
                  Icons.landscape,
                ),
                _buildInfoItem(
                  context,
                  'Elevation',
                  '${waterSource.location.elevation.toStringAsFixed(0)} meters',
                  Icons.height,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection(BuildContext context) {
    final capacity = waterSource.capacity;
    final usagePercentage = capacity.dailyYield > 0
        ? capacity.currentUsage / capacity.dailyYield
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_damage, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Capacity & Usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  'Daily Yield',
                  '${capacity.dailyYield.toStringAsFixed(0)} m³',
                  Icons.waves,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Current Usage',
                  '${capacity.currentUsage.toStringAsFixed(0)} m³',
                  Icons.arrow_upward,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Available',
                  '${capacity.availableCapacity.toStringAsFixed(0)} m³',
                  Icons.water_drop,
                  Colors.blueAccent,
                ),
                _buildMetricCard(
                  'Utilization',
                  '${capacity.utilizationRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  usagePercentage > 0.8
                      ? Colors.red
                      : usagePercentage > 0.6
                          ? Colors.orange
                          : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: usagePercentage.toDouble(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercentage > 0.8
                    ? Colors.red
                    : usagePercentage > 0.6
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usage: ${capacity.currentUsage.toStringAsFixed(0)} m³',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Available: ${capacity.availableCapacity.toStringAsFixed(0)} m³',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySection(BuildContext context) {
    final quality = waterSource.quality;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Water Quality',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  'Quality Grade',
                  quality.qualityGrade.displayName,
                  Icons.grade,
                  quality.qualityGrade.color,
                ),
                _buildMetricCard(
                  'pH Level',
                  quality.phLevel.toStringAsFixed(1),
                  Icons.science,
                  quality.phColor,
                ),
                _buildMetricCard(
                  'Turbidity',
                  '${quality.turbidity.toStringAsFixed(1)} NTU',
                  Icons.opacity,
                  quality.turbidity > 5 ? Colors.orange : Colors.green,
                ),
                _buildMetricCard(
                  'Last Test',
                  '${DateTime.now().difference(quality.lastTestDate).inDays} days ago',
                  Icons.calendar_today,
                  DateTime.now().difference(quality.lastTestDate).inDays > 30
                      ? Colors.orange
                      : Colors.green,
                ),
              ],
            ),
            if (quality.contaminationRisks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Contamination Risks:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quality.contaminationRisks
                    .map((risk) => Chip(
                          label: Text(risk),
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureSection(BuildContext context) {
    final infra = waterSource.infrastructure;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Infrastructure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoItem(
                  context,
                  'Pumps',
                  '${infra.pumps} units',
                  Icons.inventory,
                ),
                _buildInfoItem(
                  context,
                  'Storage Capacity',
                  '${infra.storageCapacity.toStringAsFixed(0)} m³',
                  Icons.storage,
                ),
                _buildInfoItem(
                  context,
                  'Transmission Lines',
                  '${infra.transmissionLines.toStringAsFixed(1)} km',
                  Icons.plumbing_rounded,
                ),
                _buildInfoItem(
                  context,
                  'Power Supply',
                  WaterSourceConstants.powerSupplyTypes[infra.powerSupply] ??
                      infra.powerSupply,
                  Icons.power,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSection(BuildContext context, WidgetRef ref) {
    final monitoring = waterSource.monitoring;
    final activeAlerts = monitoring.activeAlerts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Monitoring & Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoItem(
                  context,
                  'Monitoring Frequency',
                  WaterSourceConstants.monitoringFrequencies[
                          monitoring.monitoringFrequency] ??
                      monitoring.monitoringFrequency,
                  Icons.access_time,
                ),
                _buildInfoItem(
                  context,
                  'Last Inspection',
                  '${DateTime.now().difference(monitoring.lastInspection).inDays} days ago',
                  Icons.calendar_today,
                ),
                _buildInfoItem(
                  context,
                  'Next Inspection',
                  'in ${monitoring.nextInspection.difference(DateTime.now()).inDays} days',
                  Icons.calendar_today,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Active Alerts
            if (activeAlerts.isNotEmpty) ...[
              Text(
                'Active Alerts:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...activeAlerts
                  .map((alert) => _buildAlertCard(context, alert, ref)),
            ],
            // Monitoring Parameters
            if (monitoring.parameters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Monitoring Parameters:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monitoring.parameters
                    .map((param) => Chip(
                          label: Text(param),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreasSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Service Areas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: waterSource.serviceAreas
                  .map((area) => Chip(
                        label: Text(area),
                        avatar: const Icon(Icons.location_city, size: 16),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
      BuildContext context, SourceAlert alert, WidgetRef ref) {
    return Card(
      color: alert.severityColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: alert.severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.type.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alert.severityColor,
                    ),
                  ),
                ),
                if (showActions)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: 20, color: alert.severityColor),
                    onSelected: (value) {
                      if (value == 'resolve') {
                        _showResolveAlertDialog(context, ref, alert);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'resolve',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 8),
                            Text('Mark as Resolved'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Triggered: ${_formatDate(alert.triggeredAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    alert.severity.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: alert.severityColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddAlertDialog(BuildContext context, WidgetRef ref) {
    final provider = ref.read(waterSourceProvider.notifier);
    final typeController = TextEditingController();
    final severityController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Alert Type'),
              items: const [
                DropdownMenuItem(
                    value: 'low_water_level', child: Text('Low Water Level')),
                DropdownMenuItem(
                    value: 'quality_issue', child: Text('Quality Issue')),
                DropdownMenuItem(
                    value: 'equipment_failure',
                    child: Text('Equipment Failure')),
                DropdownMenuItem(
                    value: 'power_outage', child: Text('Power Outage')),
                DropdownMenuItem(
                    value: 'contamination', child: Text('Contamination')),
              ],
              onChanged: (value) => typeController.text = value ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Severity'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
              ],
              onChanged: (value) => severityController.text = value ?? '',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (typeController.text.isNotEmpty &&
                  severityController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                await provider.addAlert(
                  waterSource.id,
                  {
                    'type': typeController.text,
                    'severity': severityController.text,
                    'message': messageController.text,
                  },
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Alert'),
          ),
        ],
      ),
    );
  }

  void _showResolveAlertDialog(
      BuildContext context, WidgetRef ref, SourceAlert alert) {
    final provider = ref.read(waterSourceProvider.notifier);
    final resolutionController = TextEditingController();
    final alertIndex = waterSource.monitoring.alerts.indexOf(alert);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              alert.message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution Details',
                hintText: 'Describe how this alert was resolved...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resolutionController.text.isNotEmpty) {
                await provider.resolveAlert(
                  waterSource.id,
                  alertIndex,
                  resolutionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Mark as Resolved'),
          ),
        ],
      ),
    );
  }

  void _showScheduleInspectionDialog(BuildContext context, WidgetRef ref) {
    final provider = ref.read(waterSourceProvider.notifier);
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Next Inspection'),
        content: SizedBox(
          height: 300,
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) => selectedDate = date,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Call API to schedule inspection
              // This would require additional API endpoint
              Navigator.pop(context);
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}
