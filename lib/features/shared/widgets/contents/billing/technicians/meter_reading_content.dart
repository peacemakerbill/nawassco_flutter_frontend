import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/meter_reading_provider.dart';
import '../../../sub_widgets/meter_reading/meter_reading_detail.dart';
import '../../../sub_widgets/meter_reading/meter_reading_filter.dart';
import '../../../sub_widgets/meter_reading/meter_reading_form.dart';
import '../../../sub_widgets/meter_reading/meter_reading_list.dart';
import '../../../sub_widgets/meter_reading/reading_stats_card.dart';

class MeterReadingContent extends ConsumerStatefulWidget {
  const MeterReadingContent({super.key});

  @override
  ConsumerState<MeterReadingContent> createState() => _MeterReadingContentState();
}

class _MeterReadingContentState extends ConsumerState<MeterReadingContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meterReadingProvider.notifier).loadMeterReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meterReadingProvider);
    final provider = ref.read(meterReadingProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          _buildHeader(context, state, provider),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(state, provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MeterReadingState state, MeterReadingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Title and Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meter Readings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage all meter readings and billing',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  // Filter Button
                  if (!state.showCreateForm && !state.showDetailView)
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const MeterReadingFilter(),
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filter',
                    ),

                  // Refresh Button
                  IconButton(
                    onPressed: provider.loadMeterReadings,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),

                  // Create Button
                  if (!state.showCreateForm && !state.showDetailView)
                    ElevatedButton.icon(
                      onPressed: provider.showCreateForm,
                      icon: const Icon(Icons.add),
                      label: const Text('New Reading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  // Back Button (when in form or detail view)
                  if (state.showCreateForm || state.showDetailView)
                    OutlinedButton.icon(
                      onPressed: provider.closeForms,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to List'),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Stats
          if (!state.showCreateForm && !state.showDetailView)
            ReadingStatsCard(readings: state.readings),
        ],
      ),
    );
  }

  Widget _buildContent(MeterReadingState state, MeterReadingProvider provider) {
    // Loading State
    if (state.isLoading && state.readings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error State
    if (state.error != null && state.readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.loadMeterReadings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show appropriate view based on state
    if (state.showCreateForm) {
      return const MeterReadingForm();
    }

    if (state.showDetailView && state.selectedReading != null) {
      return MeterReadingDetail(reading: state.selectedReading!);
    }

    // Default: Show list
    return MeterReadingList(readings: state.filteredReadings);
  }
}