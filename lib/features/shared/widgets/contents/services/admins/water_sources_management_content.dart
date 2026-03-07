import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/water_source_model.dart';
import '../../../../providers/water_source_provider.dart';
import '../../../sub_widgets/water_source/water_source_card.dart';
import '../../../sub_widgets/water_source/water_source_details.dart';
import '../../../sub_widgets/water_source/water_source_filters.dart';
import '../../../sub_widgets/water_source/water_source_form.dart';
import '../../../sub_widgets/water_source/water_source_map.dart';
import '../../../sub_widgets/water_source/water_source_stats.dart';

class WaterSourcesManagementContent extends ConsumerStatefulWidget {
  const WaterSourcesManagementContent({Key? key}) : super(key: key);

  @override
  ConsumerState<WaterSourcesManagementContent> createState() =>
      _WaterSourcesManagementContentState();
}

class _WaterSourcesManagementContentState
    extends ConsumerState<WaterSourcesManagementContent> {
  WaterSource? _selectedSource;
  bool _showForm = false;
  bool _isEditing = false;
  int _selectedIndex = 0;
  final List<Widget> _managementTabs = [
    const Tab(text: 'Overview'),
    const Tab(text: 'Alerts'),
    const Tab(text: 'Utilization'),
    const Tab(text: 'Reports'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterSourceProvider.notifier).fetchWaterSources();
      ref.read(waterSourceProvider.notifier).fetchStats();
      ref.read(waterSourceProvider.notifier).fetchUtilization();
      ref.read(waterSourceProvider.notifier).fetchActiveAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final state = ref.watch(waterSourceProvider);
    final waterSources = state.filteredSources.isNotEmpty ? state
        .filteredSources : state.waterSources;
    final activeAlerts = state.activeAlerts;
    final utilizationData = state.utilizationData;

    // Check if user has permission to manage water sources
    final canManage = authState.isAdmin || authState.isManager;

    if (!canManage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to manage water sources.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Management Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                            Icons.manage_accounts, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'Water Source Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Quick actions
                        Row(
                          children: [
                            if (authState.isAdmin)
                              Tooltip(
                                message: 'Create New Water Source',
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _showForm = true;
                                      _isEditing = false;
                                      _selectedSource = null;
                                    });
                                  },
                                ),
                              ),
                            Tooltip(
                              message: 'Refresh Data',
                              child: IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.blue),
                                onPressed: () {
                                  ref
                                      .read(waterSourceProvider.notifier)
                                      .fetchWaterSources();
                                  ref
                                      .read(waterSourceProvider.notifier)
                                      .fetchActiveAlerts();
                                },
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                  Icons.more_vert, color: Colors.blue),
                              onSelected: (value) {
                                switch (value) {
                                  case 'export':
                                    _exportData(context, waterSources);
                                    break;
                                  case 'import':
                                    _importData(context);
                                    break;
                                  case 'settings':
                                  // Show settings dialog
                                    break;
                                }
                              },
                              itemBuilder: (context) =>
                              [
                                const PopupMenuItem(
                                  value: 'export',
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, size: 20),
                                      SizedBox(width: 8),
                                      Text('Export Data'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'import',
                                  child: Row(
                                    children: [
                                      Icon(Icons.upload, size: 20),
                                      SizedBox(width: 8),
                                      Text('Import Data'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'settings',
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings, size: 20),
                                      SizedBox(width: 8),
                                      Text('Settings'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Management Tabs
                    TabBar(
                      onTap: (index) => setState(() => _selectedIndex = index),
                      isScrollable: true,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: _managementTabs,
                    ),
                  ],
                ),
              ),
              // Content based on selected tab
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // Tab 0: Overview
                    _buildOverviewTab(context, state, waterSources),
                    // Tab 1: Alerts
                    _buildAlertsTab(context, activeAlerts),
                    // Tab 2: Utilization
                    _buildUtilizationTab(context, utilizationData),
                    // Tab 3: Reports
                    _buildReportsTab(context, waterSources),
                  ],
                ),
              ),
            ],
          ),
          // Form overlay (conditionally shown)
          if (_showForm) _buildFormOverlay(context),
        ],
      ),
      // Floating Action Button for creating new water source
      floatingActionButton: authState.isAdmin && !_showForm
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showForm = true;
            _isEditing = false;
            _selectedSource = null;
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New Water Source'),
        backgroundColor: Colors.green,
      )
          : null,
    );
  }

  Widget _buildOverviewTab(BuildContext context, WaterSourceState state,
      List<WaterSource> waterSources) {
    return Column(
      children: [
        // Stats and Quick Actions
        const WaterSourceStats(),
        const SizedBox(height: 8),
        // Quick action chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(
                    Icons.warning, size: 16, color: Colors.orange),
                label: const Text('View Active Alerts'),
                onPressed: () => setState(() => _selectedIndex = 1),
              ),
              ActionChip(
                avatar: const Icon(
                    Icons.trending_up, size: 16, color: Colors.green),
                label: const Text('View Utilization'),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
              ActionChip(
                avatar: const Icon(Icons.map, size: 16, color: Colors.blue),
                label: const Text('View on Map'),
                onPressed: () => _showMapView(context, waterSources),
              ),
              ActionChip(
                avatar: const Icon(
                    Icons.download, size: 16, color: Colors.purple),
                label: const Text('Generate Report'),
                onPressed: () => _generateReport(context, waterSources),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Filters
        const WaterSourceFilters(),
        // Water Source List
        Expanded(
          child: _buildWaterSourceList(context, waterSources, state.isLoading),
        ),
      ],
    );
  }

  Widget _buildWaterSourceList(BuildContext context,
      List<WaterSource> waterSources, bool isLoading) {
    if (isLoading && waterSources.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (waterSources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_damage, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No water sources found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _isEditing = false;
                });
              },
              child: const Text('Create First Water Source'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(waterSourceProvider.notifier).fetchWaterSources();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: waterSources.length,
        itemBuilder: (context, index) {
          final source = waterSources[index];
          return WaterSourceCard(
            waterSource: source,
            onTap: () => _showSourceDetails(context, source, true),
            showActions: true,
            onEdit: () => _editWaterSource(source),
            onDelete: () => _deleteWaterSource(context, source),
            onToggleFavorite: () {
              // Implement favorite functionality
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab(BuildContext context, List<WaterSource> activeAlerts) {
    final criticalAlerts = activeAlerts
        .expand((source) => source.monitoring.activeAlerts)
        .where((alert) => alert.severity == 'critical')
        .toList();
    final highAlerts = activeAlerts
        .expand((source) => source.monitoring.activeAlerts)
        .where((alert) => alert.severity == 'high')
        .toList();

    return Column(
      children: [
        // Alert summary cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildAlertSummaryCard(
                  'Total Alerts',
                  '${activeAlerts.length}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlertSummaryCard(
                  'Critical',
                  '${criticalAlerts.length}',
                  Icons.error,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlertSummaryCard(
                  'High Priority',
                  '${highAlerts.length}',
                  Icons.priority_high,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
        // Alert list
        Expanded(
          child: activeAlerts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'No Active Alerts',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'All water sources are operating normally',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeAlerts.length,
            itemBuilder: (context, index) {
              final source = activeAlerts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: source.monitoring.activeAlerts
                        .any((alert) => alert.severity == 'critical')
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text(source.name),
                  subtitle: Text(
                    '${source.monitoring.activeAlerts.length} active alert(s)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSourceDetails(context, source, true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizationTab(BuildContext context,
      List<Map<String, dynamic>> utilizationData) {
    return Column(
      children: [
        // Utilization summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Utilization Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (utilizationData.isNotEmpty)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3,
                      children: [
                        _buildUtilizationMetric(
                          'Average Utilization',
                          '${_calculateAverageUtilization(utilizationData)
                              .toStringAsFixed(1)}%',
                          Icons.trending_up,
                        ),
                        _buildUtilizationMetric(
                          'Highest Utilization',
                          '${_getHighestUtilization(utilizationData)
                              .toStringAsFixed(1)}%',
                          Icons.arrow_upward,
                        ),
                        _buildUtilizationMetric(
                          'Lowest Utilization',
                          '${_getLowestUtilization(utilizationData)
                              .toStringAsFixed(1)}%',
                          Icons.arrow_downward,
                        ),
                        _buildUtilizationMetric(
                          'Total Daily Yield',
                          '${_calculateTotalYield(utilizationData)
                              .toStringAsFixed(0)} m³',
                          Icons.water_damage,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        // Utilization list
        Expanded(
          child: utilizationData.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Utilization Data',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: utilizationData.length,
            itemBuilder: (context, index) {
              final data = utilizationData[index];
              final utilization = (data['utilizationRate'] ?? 0).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getUtilizationColor(utilization)
                        .withValues(alpha: 0.1),
                    child: Icon(
                      utilization > 80 ? Icons.warning :
                      utilization > 60 ? Icons.trending_up : Icons
                          .trending_flat,
                      color: _getUtilizationColor(utilization),
                    ),
                  ),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${data['type'] ?? 'Unknown'}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: utilization / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getUtilizationColor(utilization),
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${utilization.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getUtilizationColor(utilization),
                        ),
                      ),
                      Text(
                        '${(data['currentUsage'] ?? 0).toStringAsFixed(
                            0)}/${(data['dailyYield'] ?? 0).toStringAsFixed(
                            0)} m³',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(BuildContext context,
      List<WaterSource> waterSources) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Report type selection
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery
                .of(context)
                .size
                .width < 600 ? 2 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildReportCard(
                'Status Report',
                Icons.assignment,
                Colors.blue,
                    () => _generateStatusReport(context, waterSources),
              ),
              _buildReportCard(
                'Quality Report',
                Icons.health_and_safety,
                Colors.green,
                    () => _generateQualityReport(context, waterSources),
              ),
              _buildReportCard(
                'Capacity Report',
                Icons.pie_chart,
                Colors.orange,
                    () => _generateCapacityReport(context, waterSources),
              ),
              _buildReportCard(
                'Financial Report',
                Icons.attach_money,
                Colors.purple,
                    () => _generateFinancialReport(context, waterSources),
              ),
              _buildReportCard(
                'Maintenance Report',
                Icons.build,
                Colors.brown,
                    () => _generateMaintenanceReport(context, waterSources),
              ),
              _buildReportCard(
                'Comprehensive',
                Icons.description,
                Colors.teal,
                    () => _generateComprehensiveReport(context, waterSources),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Report parameters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report Parameters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Report Format',
                          ),
                          value: 'pdf',
                          items: const [
                            DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                            DropdownMenuItem(value: 'excel',
                                child: Text('Excel')),
                            DropdownMenuItem(value: 'csv', child: Text('CSV')),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Time Period',
                          ),
                          value: 'monthly',
                          items: const [
                            DropdownMenuItem(value: 'daily',
                                child: Text('Daily')),
                            DropdownMenuItem(value: 'weekly',
                                child: Text('Weekly')),
                            DropdownMenuItem(value: 'monthly',
                                child: Text('Monthly')),
                            DropdownMenuItem(value: 'quarterly',
                                child: Text('Quarterly')),
                            DropdownMenuItem(value: 'yearly',
                                child: Text('Yearly')),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.9,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: WaterSourceForm(
              initialData: _isEditing ? _selectedSource : null,
              isEditing: _isEditing,
              onSuccess: () {
                setState(() {
                  _showForm = false;
                  _isEditing = false;
                  _selectedSource = null;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertSummaryCard(String title, String value, IconData icon,
      Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationMetric(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color,
      VoidCallback onTap) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceDetails(BuildContext context, WaterSource source,
      bool showActions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.9,
            child: WaterSourceDetails(
              waterSource: source,
              showActions: showActions,
            ),
          ),
    );
  }

  void _editWaterSource(WaterSource source) {
    setState(() {
      _showForm = true;
      _isEditing = true;
      _selectedSource = source;
    });
  }

  Future<void> _deleteWaterSource(BuildContext context,
      WaterSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Water Source'),
            content: Text(
              'Are you sure you want to delete "${source
                  .name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(waterSourceProvider.notifier).deleteWaterSource(source.id);
    }
  }

  void _showMapView(BuildContext context, List<WaterSource> waterSources) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.9,
            child: WaterSourceMap(
              waterSources: waterSources,
              onSourceSelected: (source) {
                Navigator.pop(context);
                _showSourceDetails(context, source, true);
              },
            ),
          ),
    );
  }

  void _generateReport(BuildContext context, List<WaterSource> waterSources) {
    setState(() => _selectedIndex = 3);
  }

  void _exportData(BuildContext context, List<WaterSource> waterSources) {
    // Implement export functionality
  }

  void _importData(BuildContext context) {
    // Implement import functionality
  }

  void _selectDate(BuildContext context) {
    // Implement date picker
  }

  double _calculateAverageUtilization(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final total = data.fold<double>(
        0, (sum, item) => sum + (item['utilizationRate'] ?? 0));
    return total / data.length;
  }

  double _getHighestUtilization(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    return data.fold<double>(0, (max, item) =>
    (item['utilizationRate'] ?? 0) > max ? (item['utilizationRate'] ?? 0) : max
    );
  }

  double _getLowestUtilization(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    return data.fold<double>(100, (min, item) =>
    (item['utilizationRate'] ?? 100) < min
        ? (item['utilizationRate'] ?? 100)
        : min
    );
  }

  double _calculateTotalYield(List<Map<String, dynamic>> data) {
    return data.fold<double>(0, (sum, item) => sum + (item['dailyYield'] ?? 0));
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization > 80) return Colors.red;
    if (utilization > 60) return Colors.orange;
    return Colors.green;
  }

  void _generateStatusReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement status report generation
  }

  void _generateQualityReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement quality report generation
  }

  void _generateCapacityReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement capacity report generation
  }

  void _generateFinancialReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement financial report generation
  }

  void _generateMaintenanceReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement maintenance report generation
  }

  void _generateComprehensiveReport(BuildContext context,
      List<WaterSource> waterSources) {
    // Implement comprehensive report generation
  }
}