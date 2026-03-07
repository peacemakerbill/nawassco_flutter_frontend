import 'package:flutter/material.dart';

import '../../../../models/vehicle.dart';

class VehicleCardWidget extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCardWidget({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIndicator(),
                  const Spacer(),
                  _buildPriorityBadge(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${vehicle.make} ${vehicle.model}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                vehicle.registrationNumber,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(Icons.person, vehicle.assignedToName ?? 'Unassigned'),
                  const Spacer(),
                  _buildInfoItem(Icons.speed, '${vehicle.currentOdometer} km'),
                ],
              ),
              const SizedBox(height: 8),
              _buildFuelGauge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final color = _getStatusColor(vehicle.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        vehicle.status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final color = _getOperationalStatusColor(vehicle.operationalStatus);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFuelGauge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_gas_station, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '${vehicle.fuelPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Text(
              '${vehicle.currentFuelLevel.toStringAsFixed(0)}/${vehicle.fuelCapacity}L',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: vehicle.fuelPercentage / 100,
          backgroundColor: Colors.grey[200],
          color: vehicle.fuelPercentage < 20 ? Colors.red : Colors.green,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
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