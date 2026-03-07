import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/tool.dart';
import '../../../providers/tool_provider.dart';
import '../sub_widgets/tool/tool_card.dart';
import '../sub_widgets/tool/tool_details.dart';
import '../sub_widgets/tool/tool_filters.dart';
import '../sub_widgets/tool/tool_form.dart';
import '../sub_widgets/tool/tool_metrics.dart';

class ToolsContent extends ConsumerStatefulWidget {
  const ToolsContent({super.key});

  @override
  ConsumerState<ToolsContent> createState() => _ToolsContentState();
}

class _ToolsContentState extends ConsumerState<ToolsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toolProvider.notifier).loadTools();
      ref.read(toolProvider.notifier).loadToolMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toolState = ref.watch(toolProvider);
    final toolNotifier = ref.read(toolProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(toolNotifier),

          // Metrics Overview
          if (_tabController.index == 0)
            ToolMetricsWidget(metrics: toolState.metrics),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              onTap: (index) {
                if (index == 1 &&
                    toolState.toolsNeedingMaintenance.isNotEmpty) {
                  // Show maintenance needed tools
                }
              },
              tabs: const [
                Tab(text: 'All Tools'),
                Tab(text: 'Maintenance'),
                Tab(text: 'Calibration'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllToolsTab(toolState, toolNotifier),
                _buildMaintenanceTab(toolState),
                _buildCalibrationTab(toolState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showToolForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Tool'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildHeader(ToolProvider toolNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.build, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Tool Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showFilters(context),
                icon: const Icon(Icons.filter_list, color: Colors.blue),
                tooltip: 'Filters',
              ),
              IconButton(
                onPressed: () => toolNotifier.loadTools(),
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => toolNotifier.searchTools(value),
              decoration: InputDecoration(
                hintText: 'Search tools by name, code, or serial number...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllToolsTab(ToolState toolState, ToolProvider toolNotifier) {
    if (toolState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (toolState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              toolState.error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => toolNotifier.loadTools(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final tools = toolState.filteredTools;

    if (tools.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tools found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first tool to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final crossAxisCount =
            isWide ? (constraints.maxWidth ~/ 400).clamp(2, 4) : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.6 : 1.4,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) => ToolCard(
            tool: tools[index],
            onTap: () => _showToolDetails(context, tools[index]),
            onEdit: () => _showToolForm(context, tools[index]),
            onDelete: () => _confirmDeleteTool(context, tools[index]),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceTab(ToolState toolState) {
    final maintenanceTools = toolState.toolsNeedingMaintenance;

    if (maintenanceTools.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All tools are up to date!',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: maintenanceTools.length,
      itemBuilder: (context, index) {
        final tool = maintenanceTools[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(tool.toolName),
            subtitle: Text(
                'Next maintenance: ${_formatDate(tool.maintenanceSchedule.nextMaintenanceDate)}'),
            trailing: const Icon(Icons.warning, color: Colors.orange),
            onTap: () => _showToolDetails(context, tool),
          ),
        );
      },
    );
  }

  Widget _buildCalibrationTab(ToolState toolState) {
    final calibrationTools = toolState.toolsNeedingCalibration;

    if (calibrationTools.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All tools are calibrated!',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: calibrationTools.length,
      itemBuilder: (context, index) {
        final tool = calibrationTools[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(tool.toolName),
            subtitle: Text('Needs calibration soon'),
            trailing: const Icon(Icons.science, color: Colors.red),
            onTap: () => _showToolDetails(context, tool),
          ),
        );
      },
    );
  }

  void _showToolForm(BuildContext context, Tool? tool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ToolFormWidget(
        tool: tool,
        onSaved: () {
          Navigator.pop(context);
          ref.read(toolProvider.notifier).loadTools();
        },
      ),
    );
  }

  void _showToolDetails(BuildContext context, Tool tool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ToolDetailsWidget(tool: tool),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ToolFiltersWidget(),
    );
  }

  void _confirmDeleteTool(BuildContext context, Tool tool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tool'),
        content: Text(
            'Are you sure you want to delete ${tool.toolName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(toolProvider.notifier).deleteTool(tool.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
