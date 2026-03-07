import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/outage.dart';
import '../../../../providers/outage_provider.dart';
import '../../../sub_widgets/outage/outage_card.dart';
import '../../../sub_widgets/outage/outage_detail.dart';
import '../../../sub_widgets/outage/outage_filter.dart';
import '../../../sub_widgets/outage/outage_map.dart';
import '../../../sub_widgets/outage/outage_stats.dart';

class OutageContent extends ConsumerStatefulWidget {
  const OutageContent({super.key});

  @override
  ConsumerState<OutageContent> createState() => _OutageContentState();
}

class _OutageContentState extends ConsumerState<OutageContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  String _selectedZone = 'All Zones';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(outageProvider.notifier).fetchOutages();
      ref.read(outageProvider.notifier).fetchOutageStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final outageState = ref.watch(outageProvider);
    final notifier = ref.read(outageProvider.notifier);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Water Outages',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time updates on water supply interruptions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
        ),

        // Stats Overview
        if (!_showFilters)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutageStatsWidget(),
          ),

        // Filter Section
        if (_showFilters)
          OutageFilterWidget(
            onFilterChanged: (filters) {
              notifier.fetchOutages(filters: filters);
            },
          ),

        // Map Section
        if (!_showFilters)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutageMapWidget(
              outages: outageState.outages,
              onZoneSelected: (zone) {
                setState(() {
                  _selectedZone = zone;
                });
                if (zone == 'All Zones') {
                  notifier.fetchOutages();
                } else {
                  notifier.fetchOutagesByZone(zone);
                }
              },
            ),
          ),

        // Zone Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('Zone:'),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedZone,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    'All Zones',
                    'Nakuru East',
                    'Bahati',
                    'Molo',
                    'Naivasha',
                    'Gilgil',
                    'Njoro',
                  ].map((zone) {
                    return DropdownMenuItem(
                      value: zone,
                      child: Text(zone),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedZone = value;
                      });
                      if (value == 'All Zones') {
                        notifier.fetchOutages();
                      } else {
                        notifier.fetchOutagesByZone(value);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Outage List Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Outages (${outageState.outages.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // Loading/Error/Content
        Expanded(
          child: _buildContent(outageState, notifier),
        ),
      ],
    );
  }

  Widget _buildContent(OutageState state, OutageProvider notifier) {
    if (state.isLoading && state.outages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.fetchOutages(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.outages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No active outages',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'All water supply systems are functioning normally',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await notifier.fetchOutages();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.outages.length,
        itemBuilder: (context, index) {
          final outage = state.outages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutageCard(
              outage: outage,
              onTap: () {
                _showOutageDetails(context, outage);
              },
            ),
          );
        },
      ),
    );
  }

  void _showOutageDetails(BuildContext context, Outage outage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OutageDetailWidget(outage: outage);
      },
    );
  }
}
