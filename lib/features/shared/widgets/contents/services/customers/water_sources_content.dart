import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/water_source_model.dart';
import '../../../../providers/water_source_provider.dart';
import '../../../sub_widgets/water_source/water_source_card.dart';
import '../../../sub_widgets/water_source/water_source_details.dart';
import '../../../sub_widgets/water_source/water_source_filters.dart';
import '../../../sub_widgets/water_source/water_source_map.dart';
import '../../../sub_widgets/water_source/water_source_stats.dart';

class WaterSourcesContent extends ConsumerStatefulWidget {
  const WaterSourcesContent({Key? key}) : super(key: key);

  @override
  ConsumerState<WaterSourcesContent> createState() =>
      _WaterSourcesContentState();
}

class _WaterSourcesContentState extends ConsumerState<WaterSourcesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WaterSource? _selectedSource;
  bool _showMap = false;
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch water sources when initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterSourceProvider.notifier).fetchWaterSources();
      ref.read(waterSourceProvider.notifier).fetchStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waterSourceProvider);
    final waterSources = state.filteredSources.isNotEmpty
        ? state.filteredSources
        : state.waterSources;

    return Scaffold(
      body: Column(
        children: [
          // Header with tabs and actions
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.water, color: Colors.blue, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Water Sources',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Toggle buttons for view options
                      Row(
                        children: [
                          Tooltip(
                            message: _showMap ? 'Show List' : 'Show Map',
                            child: IconButton(
                              icon: Icon(
                                _showMap ? Icons.list : Icons.map,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() => _showMap = !_showMap);
                              },
                            ),
                          ),
                          Tooltip(
                            message: _showStats ? 'Hide Stats' : 'Show Stats',
                            child: IconButton(
                              icon: Icon(
                                _showStats
                                    ? Icons.insights
                                    : Icons.insights_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() => _showStats = !_showStats);
                              },
                            ),
                          ),
                          // Filter button
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_alt,
                                color: Colors.blue),
                            onSelected: (value) {
                              if (value == 'nearby') {
                                _showNearbySources(context);
                              } else if (value == 'operational') {
                                ref
                                    .read(waterSourceProvider.notifier)
                                    .applyFilters({
                                  'status': SourceStatus.OPERATIONAL,
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'nearby',
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on, size: 20),
                                    SizedBox(width: 8),
                                    Text('Find Nearby Sources'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'operational',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 20, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Show Operational Only'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'All Sources'),
                    Tab(text: 'Quality & Safety'),
                  ],
                ),
              ],
            ),
          ),
          // Content based on selected tab and view mode
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Sources
                _buildAllSourcesTab(context, state, waterSources),
                // Tab 2: Quality & Safety
                _buildQualityTab(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSourcesTab(BuildContext context, WaterSourceState state,
      List<WaterSource> waterSources) {
    if (state.isLoading && waterSources.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && waterSources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(waterSourceProvider.notifier).fetchWaterSources(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filters
        const WaterSourceFilters(),
        // Stats (optional)
        if (_showStats) const WaterSourceStats(),
        // Map or List view
        Expanded(
          child: _showMap
              ? WaterSourceMap(
                  waterSources: waterSources,
                  onSourceSelected: (source) {
                    setState(() => _selectedSource = source);
                    _showSourceDetails(context, source);
                  },
                )
              : _buildWaterSourceList(context, waterSources),
        ),
      ],
    );
  }

  Widget _buildWaterSourceList(
      BuildContext context, List<WaterSource> waterSources) {
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
            const Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(waterSourceProvider.notifier).clearFilters();
              },
              child: const Text('Clear Filters'),
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
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: waterSources.length,
        itemBuilder: (context, index) {
          final source = waterSources[index];
          return WaterSourceCard(
            waterSource: source,
            onTap: () => _showSourceDetails(context, source),
            onToggleFavorite: () {
              // Implement favorite functionality
              // This would require additional backend endpoint
            },
          );
        },
      ),
    );
  }

  Widget _buildQualityTab(BuildContext context, WaterSourceState state) {
    final waterSources = state.waterSources;
    final excellentSources = waterSources
        .where(
          (s) => s.quality.qualityGrade == QualityGrade.EXCELLENT,
        )
        .toList();
    final goodSources = waterSources
        .where(
          (s) => s.quality.qualityGrade == QualityGrade.GOOD,
        )
        .toList();
    final fairSources = waterSources
        .where(
          (s) => s.quality.qualityGrade == QualityGrade.FAIR,
        )
        .toList();
    final poorSources = waterSources
        .where(
          (s) =>
              s.quality.qualityGrade == QualityGrade.POOR ||
              s.quality.qualityGrade == QualityGrade.UNUSABLE,
        )
        .toList();

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.grade, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Excellent'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.grade, color: Colors.lightGreen),
                      SizedBox(width: 4),
                      Text('Good'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.grade, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Fair'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.grade, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Poor/Unusable'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildQualityCategoryList(
                    context, excellentSources, 'Excellent'),
                _buildQualityCategoryList(context, goodSources, 'Good'),
                _buildQualityCategoryList(context, fairSources, 'Fair'),
                _buildQualityCategoryList(context, poorSources, 'Poor Quality'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCategoryList(
      BuildContext context, List<WaterSource> sources, String category) {
    if (sources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category == 'Excellent'
                  ? Icons.grade
                  : category == 'Good'
                      ? Icons.grade
                      : category == 'Fair'
                          ? Icons.grade
                          : Icons.warning,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No $category quality sources',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sources.length,
      itemBuilder: (context, index) {
        final source = sources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  source.quality.qualityGrade.color.withValues(alpha: 0.1),
              child: Text(source.type.icon),
            ),
            title: Text(source.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.location.address),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        source.quality.phStatus,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: source.quality.phColor,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    const SizedBox(width: 4),
                    if (source.quality.turbidity > 5)
                      const Chip(
                        label: Text(
                          'High Turbidity',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                    if (source.infrastructure.treatmentRequired)
                      const Chip(
                        label: Text(
                          'Treatment Required',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSourceDetails(context, source),
          ),
        );
      },
    );
  }

  void _showSourceDetails(BuildContext context, WaterSource source) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: WaterSourceDetails(
          waterSource: source,
        ),
      ),
    );
  }

  void _showNearbySources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Nearby Sources'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your location coordinates:'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., -0.3031',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 36.0800',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              decoration: const InputDecoration(
                labelText: 'Search Radius',
              ),
              value: 10000.0,
              items: const [
                DropdownMenuItem(value: 5000.0, child: Text('5 km')),
                DropdownMenuItem(value: 10000.0, child: Text('10 km')),
                DropdownMenuItem(value: 25000.0, child: Text('25 km')),
                DropdownMenuItem(value: 50000.0, child: Text('50 km')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement nearby search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
