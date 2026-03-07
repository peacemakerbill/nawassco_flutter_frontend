import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/vehicle.dart';
import '../../../../providers/vehicle_provider.dart';
import 'vehicle_card_widget.dart';

class VehicleListWidget extends ConsumerWidget {
  final Function(Vehicle) onVehicleSelected;
  final VoidCallback onCreateNew;

  const VehicleListWidget({
    super.key,
    required this.onVehicleSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleProvider);

    if (state.isLoading && state.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(vehicleProvider.notifier).loadVehicles(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsOverview(state),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return _buildWideGridView(state);
              } else {
                return _buildMobileListView(state);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(VehicleState state) {
    final metrics = state.metrics;
    final totalCount = state.vehicles.length;
    final availableCount =
        state.vehicles.where((v) => v.status == VehicleStatus.available).length;
    final maintenanceCount = state.vehicles
        .where((v) => v.status == VehicleStatus.underMaintenance)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Total', totalCount.toString(), Colors.blue),
          _buildStatItem('Available', availableCount.toString(), Colors.green),
          _buildStatItem(
              'Maintenance', maintenanceCount.toString(), Colors.orange),
          _buildStatItem(
              'In Use',
              (totalCount - availableCount - maintenanceCount).toString(),
              Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileListView(VehicleState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = state.vehicles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VehicleCardWidget(
            vehicle: vehicle,
            onTap: () => onVehicleSelected(vehicle),
          ),
        );
      },
    );
  }

  Widget _buildWideGridView(VehicleState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: state.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = state.vehicles[index];
        return VehicleCardWidget(
          vehicle: vehicle,
          onTap: () => onVehicleSelected(vehicle),
        );
      },
    );
  }
}
