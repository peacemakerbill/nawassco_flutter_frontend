import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/tool.dart';
import 'assignment_dialog.dart';
import 'service_dialog.dart';
import 'calibration_dialog.dart';

class ToolDetailsWidget extends ConsumerStatefulWidget {
  final Tool tool;

  const ToolDetailsWidget({super.key, required this.tool});

  @override
  ConsumerState<ToolDetailsWidget> createState() => _ToolDetailsWidgetState();
}

class _ToolDetailsWidgetState extends ConsumerState<ToolDetailsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(tool.toolType.icon, color: tool.toolType.color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.toolName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tool.toolCode,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(tool.currentStatus),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              children: [
                if (tool.currentStatus == ToolStatus.available)
                  _buildActionButton(
                    'Assign',
                    Icons.person_add,
                    Colors.blue,
                        () => _showAssignmentDialog(),
                  ),
                if (tool.currentStatus == ToolStatus.inUse)
                  _buildActionButton(
                    'Return',
                    Icons.keyboard_return,
                    Colors.green,
                        () => _showReturnDialog(),
                  ),
                _buildActionButton(
                  'Service',
                  Icons.build_circle,
                  Colors.orange,
                      () => _showServiceDialog(),
                ),
                _buildActionButton(
                  'Calibrate',
                  Icons.science,
                  Colors.purple,
                      () => _showCalibrationDialog(),
                ),
                _buildActionButton(
                  'Usage',
                  Icons.timer,
                  Colors.blue,
                      () => _showUsageDialog(),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Specifications'),
                Tab(text: 'Maintenance'),
                Tab(text: 'History'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(tool),
                _buildSpecificationsTab(tool),
                _buildMaintenanceTab(tool),
                _buildHistoryTab(tool),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ToolStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: color),
          label: Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
          style: TextButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Tool tool) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Description', tool.description),
                  _buildInfoRow('Category', tool.category),
                  _buildInfoRow('Brand', tool.brand),
                  _buildInfoRow('Model', tool.toolModel),
                  _buildInfoRow('Serial Number', tool.serialNumber),
                  _buildInfoRow('Location', tool.currentLocation),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Usage & Financial Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usage & Financial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Total Usage',
                          '${tool.totalUsageHours}h',
                          Icons.timer,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'Usage Count',
                          tool.usageCount.toString(),
                          Icons.repeat,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Purchase Price',
                          'KES ${tool.purchasePrice.toStringAsFixed(0)}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'Current Value',
                          'KES ${tool.currentValue.toStringAsFixed(0)}',
                          Icons.money,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMetricItem(
                    'Depreciation',
                    '${tool.depreciationRate.toStringAsFixed(1)}%',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Safety Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Safety Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Risk Level', tool.riskLevel.displayName),
                  _buildInfoRow('Training Required', tool.requiresTraining ? 'Yes' : 'No'),
                  if (tool.safetyInstructions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Safety Instructions:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ...tool.safetyInstructions.map((instruction) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $instruction'),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab(Tool tool) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tool.specifications.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.info, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No specifications added'),
                ],
              ),
            )
          else
            ...tool.specifications.map((spec) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  spec.parameter,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('${spec.value} ${spec.unit}'),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab(Tool tool) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maintenance Schedule
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Last Maintenance', _formatDate(tool.maintenanceSchedule.lastMaintenanceDate)),
                  _buildInfoRow('Next Maintenance', _formatDate(tool.maintenanceSchedule.nextMaintenanceDate)),
                  _buildInfoRow('Interval', '${tool.maintenanceSchedule.maintenanceInterval} days'),
                  if (tool.maintenanceSchedule.maintenanceTasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Maintenance Tasks:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ...tool.maintenanceSchedule.maintenanceTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $task'),
                    )),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Service History
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Service History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        'Total Cost: KES ${tool.maintenanceCost.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (tool.serviceHistory.isEmpty)
                    const Center(child: Text('No service records'))
                  else
                    ...tool.serviceHistory.reversed.take(5).map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                record.serviceType,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                'KES ${record.cost.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Text(
                            _formatDate(record.serviceDate),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          Text(record.description),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(Tool tool) {
    final allHistory = [
      ...tool.serviceHistory.map((record) => _HistoryItem(
        date: record.serviceDate,
        type: 'Service',
        description: '${record.serviceType} - ${record.description}',
        cost: record.cost,
      )),
      ...tool.calibrationHistory.map((record) => _HistoryItem(
        date: record.calibrationDate,
        type: 'Calibration',
        description: 'Calibrated by ${record.calibratedBy}',
        cost: 0,
      )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (allHistory.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No history records'),
                ],
              ),
            )
          else
            ...allHistory.take(10).map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.type == 'Service' ? Colors.orange : Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(item.type),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: item.cost > 0 ? Text('KES ${item.cost.toStringAsFixed(0)}') : null,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AssignmentDialog(tool: widget.tool),
    );
  }

  void _showReturnDialog() {
    // Implementation for return dialog
  }

  void _showServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => ServiceDialog(tool: widget.tool),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => CalibrationDialog(tool: widget.tool),
    );
  }

  void _showUsageDialog() {
    // Implementation for usage dialog
  }
}

class _HistoryItem {
  final DateTime date;
  final String type;
  final String description;
  final double cost;

  _HistoryItem({
    required this.date,
    required this.type,
    required this.description,
    required this.cost,
  });
}