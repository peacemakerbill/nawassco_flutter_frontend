import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/vehicle.dart';
import '../../../../providers/vehicle_provider.dart';

class VehicleDetailsWidget extends ConsumerWidget {
  final VoidCallback onEdit;
  final VoidCallback onBack;

  const VehicleDetailsWidget({
    super.key,
    required this.onEdit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleProvider);
    final vehicle = state.selectedVehicle;

    if (vehicle == null) {
      return const Center(child: Text('No vehicle selected'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderSection(vehicle, context, ref),
          const SizedBox(height: 20),
          _buildOverviewSection(vehicle),
          const SizedBox(height: 20),
          _buildSpecificationsSection(vehicle),
          const SizedBox(height: 20),
          _buildMaintenanceSection(vehicle),
          const SizedBox(height: 20),
          _buildFinancialSection(vehicle),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
      Vehicle vehicle, BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getVehicleIcon(vehicle.vehicleType),
                    size: 32,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vehicle.registrationNumber,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handleMenuAction(value, vehicle, ref, context),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit Vehicle')),
                    const PopupMenuItem(
                        value: 'assign', child: Text('Assign Technician')),
                    if (vehicle.isAssigned)
                      const PopupMenuItem(
                          value: 'unassign', child: Text('Unassign')),
                    const PopupMenuItem(
                        value: 'service', child: Text('Record Service')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Vehicle',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusChip(vehicle.status, vehicle.operationalStatus),
                const Spacer(),
                ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit Vehicle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      VehicleStatus status, OperationalStatus operationalStatus) {
    final statusColor = _getStatusColor(status);
    final operationalColor = _getOperationalStatusColor(operationalStatus);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status.displayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: operationalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: operationalColor),
          ),
          child: Text(
            operationalStatus.displayName,
            style: TextStyle(
              color: operationalColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection(Vehicle vehicle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final children = [
                  _buildOverviewItem(
                      'Vehicle Type', vehicle.vehicleType.displayName),
                  _buildOverviewItem('Year', vehicle.year.toString()),
                  _buildOverviewItem('Color', vehicle.color),
                  _buildOverviewItem('Fuel Type', vehicle.fuelType.displayName),
                  _buildOverviewItem(
                      'Assigned To', vehicle.assignedToName ?? 'Unassigned'),
                  _buildOverviewItem(
                      'Odometer', '${vehicle.currentOdometer} km'),
                ];

                if (isWide) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3,
                    ),
                    itemCount: children.length,
                    itemBuilder: (context, index) => children[index],
                  );
                } else {
                  return Column(
                    children: children,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSpecificationsSection(Vehicle vehicle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFuelGauge(vehicle),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSpecItem(
                      'Fuel Capacity', '${vehicle.fuelCapacity}L'),
                ),
                Expanded(
                  child: _buildSpecItem(
                      'Current Fuel', '${vehicle.currentFuelLevel}L'),
                ),
                Expanded(
                  child: _buildSpecItem('Fuel %',
                      '${vehicle.fuelPercentage.toStringAsFixed(0)}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelGauge(Vehicle vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fuel Level',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${vehicle.fuelPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: vehicle.fuelPercentage < 20 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 12,
              width: (vehicle.fuelPercentage / 100) * 300,
              // Assuming max width of 300
              decoration: BoxDecoration(
                color: vehicle.fuelPercentage < 20
                    ? Colors.red
                    : vehicle.fuelPercentage < 50
                        ? Colors.orange
                        : Colors.green,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    vehicle.fuelPercentage < 20
                        ? Colors.red
                        : vehicle.fuelPercentage < 50
                            ? Colors.orange
                            : Colors.green,
                    vehicle.fuelPercentage < 20
                        ? Colors.red[300]!
                        : vehicle.fuelPercentage < 50
                            ? Colors.orange[300]!
                            : Colors.green[300]!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection(Vehicle vehicle) {
    final needsService = vehicle.needsService;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (needsService) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Service Due',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMaintenanceItem(
                    'Last Service',
                    vehicle.lastServiceDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'Never',
                    Icons.build,
                  ),
                ),
                Expanded(
                  child: _buildMaintenanceItem(
                    'Next Service',
                    vehicle.nextServiceDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'Not scheduled',
                    Icons.calendar_today,
                    isWarning: needsService,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMaintenanceItem(
              'Maintenance Cost',
              'KES ${vehicle.maintenanceCost.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceItem(String label, String value, IconData icon,
      {bool isWarning = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isWarning ? Colors.orange : Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isWarning ? Colors.orange : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSection(Vehicle vehicle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialItem(
                    'Purchase Price',
                    'KES ${vehicle.purchasePrice.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    'Current Value',
                    'KES ${vehicle.currentValue.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialItem(
                    'Maintenance Cost',
                    'KES ${vehicle.maintenanceCost.toStringAsFixed(2)}',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    'Fuel Cost',
                    'KES ${vehicle.fuelCost.toStringAsFixed(2)}',
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(
      String value, Vehicle vehicle, WidgetRef ref, BuildContext context) {
    switch (value) {
      case 'edit':
        onEdit();
        break;
      case 'assign':
        _showAssignDialog(context, vehicle, ref);
        break;
      case 'unassign':
        _unassignVehicle(vehicle, ref);
        break;
      case 'service':
        _showServiceDialog(context, vehicle, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, vehicle, ref);
        break;
    }
  }

  void _showAssignDialog(BuildContext context, Vehicle vehicle, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Vehicle'),
        content: const Text(
            'Assign vehicle to technician functionality would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement assign logic
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _unassignVehicle(Vehicle vehicle, WidgetRef ref) {
    ref.read(vehicleProvider.notifier).unassignVehicle(vehicle.id);
  }

  void _showServiceDialog(
      BuildContext context, Vehicle vehicle, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Service'),
        content: const Text('Service recording functionality would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement service recording logic
              Navigator.pop(context);
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Vehicle vehicle, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
            'Are you sure you want to delete ${vehicle.registrationNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(vehicleProvider.notifier).deleteVehicle(vehicle.id);
              Navigator.pop(context);
              onBack();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    return switch (type) {
      VehicleType.pickupTruck => Icons.local_shipping,
      VehicleType.van => Icons.airport_shuttle,
      VehicleType.suv => Icons.directions_car,
      VehicleType.motorcycle => Icons.motorcycle,
      VehicleType.truck => Icons.local_shipping,
      VehicleType.specialEquipment => Icons.build,
    };
  }

  Color _getStatusColor(VehicleStatus status) {
    return switch (status) {
      VehicleStatus.available => Colors.green,
      VehicleStatus.inUse => Colors.blue,
      VehicleStatus.underMaintenance => Colors.orange,
      VehicleStatus.outOfService => Colors.red,
    };
  }

  Color _getOperationalStatusColor(OperationalStatus status) {
    return switch (status) {
      OperationalStatus.operational => Colors.green,
      OperationalStatus.needsMaintenance => Colors.orange,
      OperationalStatus.repairNeeded => Colors.red,
      OperationalStatus.decommissioned => Colors.grey,
    };
  }
}
