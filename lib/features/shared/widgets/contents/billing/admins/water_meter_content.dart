import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/water_meter.model.dart';
import '../../../../providers/water_meter.provider.dart';
import '../../../sub_widgets/water_meter/meter_stats_card.dart';
import '../../../sub_widgets/water_meter/water_meter_card.dart';
import '../../../sub_widgets/water_meter/water_meter_detail.dart';
import '../../../sub_widgets/water_meter/water_meter_filter.dart';
import '../../../sub_widgets/water_meter/water_meter_form.dart';


class WaterMeterContent extends ConsumerStatefulWidget {
  const WaterMeterContent({super.key});

  @override
  ConsumerState<WaterMeterContent> createState() => _WaterMeterContentState();
}

class _WaterMeterContentState extends ConsumerState<WaterMeterContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  bool _showCreateForm = false;
  WaterMeter? _selectedMeter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterMeterProvider.notifier).refreshData();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(waterMeterProvider.notifier).loadNextPage();
    }
  }

  void _handleMeterSelect(WaterMeter meter) {
    setState(() {
      _selectedMeter = meter;
      _showCreateForm = false;
    });
  }

  void _handleCreateNew() {
    setState(() {
      _showCreateForm = true;
      _selectedMeter = null;
    });
  }

  void _handleBackToList() {
    setState(() {
      _showCreateForm = false;
      _selectedMeter = null;
    });
  }

  void _handleMeterUpdated() {
    setState(() {
      _showCreateForm = false;
      _selectedMeter = null;
    });
    ref.read(waterMeterProvider.notifier).refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final waterMeterState = ref.watch(waterMeterProvider);
    final waterMeterNotifier = ref.read(waterMeterProvider.notifier);

    // Check permissions
    final canCreate = authState.hasAnyRole(['Admin', 'Manager', 'Installer']);
    final canEdit = authState.hasAnyRole(['Admin', 'Manager', 'Technician']);
    final canDelete = authState.hasAnyRole(['Admin']);

    if (_showCreateForm) {
      return WaterMeterFormWidget(
        onCancel: _handleBackToList,
        onSuccess: _handleMeterUpdated,
        isEditMode: false,
      );
    }

    if (_selectedMeter != null) {
      return WaterMeterDetailWidget(
        waterMeter: _selectedMeter!,
        onBack: _handleBackToList,
        onEdit: canEdit ? () {
          setState(() {
            _showCreateForm = true;
          });
        } : null,
        onDelete: canDelete ? () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Water Meter'),
              content: const Text('Are you sure you want to delete this water meter? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await waterMeterNotifier.deleteWaterMeter(_selectedMeter!.id);
            _handleBackToList();
          }
        } : null,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Meters',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${waterMeterState.totalItems} meters installed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (canCreate)
                      ElevatedButton.icon(
                        onPressed: _handleCreateNew,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('New Meter'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                        color: _showFilters ? Colors.blue : Colors.grey[700],
                      ),
                      tooltip: 'Toggle Filters',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => waterMeterNotifier.refreshData(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Overview
          if (!waterMeterState.isLoading && waterMeterState.stats != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: Colors.white,
              child: MeterStatsCard(stats: waterMeterState.stats!),
            ),

          // Filters
          if (_showFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: WaterMeterFilterWidget(
                onFiltersChanged: (filters) {
                  waterMeterNotifier.updateFilters(filters);
                },
                onClear: () {
                  waterMeterNotifier.clearFilters();
                },
              ),
            ),

          // Main Content
          Expanded(
            child: waterMeterState.isLoading && waterMeterState.waterMeters.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : waterMeterState.waterMeters.isEmpty
                ? _buildEmptyState()
                : _buildMeterList(waterMeterState),
          ),

          // Loading more indicator
          if (waterMeterState.isLoading && waterMeterState.waterMeters.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_damage_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Water Meters Found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new water meter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleCreateNew,
            icon: const Icon(Icons.add),
            label: const Text('Add First Water Meter'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterList(WaterMeterState state) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(waterMeterProvider.notifier).refreshData();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: state.waterMeters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final meter = state.waterMeters[index];
          return WaterMeterCardWidget(
            waterMeter: meter,
            onTap: () => _handleMeterSelect(meter),
          );
        },
      ),
    );
  }
}