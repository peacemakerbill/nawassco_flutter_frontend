import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/warehouse_model.dart';

class WarehouseDetailsView extends ConsumerWidget {
  final Warehouse warehouse;
  final VoidCallback onEdit;
  final VoidCallback onViewUtilization;

  const WarehouseDetailsView({
    super.key,
    required this.warehouse,
    required this.onEdit,
    required this.onViewUtilization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(theme),
          const SizedBox(height: 20),

          // Details Tabs
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Capacity'),
                      Tab(text: 'Zones'),
                      Tab(text: 'Contact'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _buildOverviewTab(theme),
                      _buildCapacityTab(theme),
                      _buildZonesTab(theme),
                      _buildContactTab(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    final utilizationPercentage = warehouse.capacity.totalArea > 0
        ? (warehouse.capacity.currentUtilization / warehouse.capacity.totalArea) * 100
        : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(warehouse.status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(warehouse.status),
                    color: _getStatusColor(warehouse.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warehouse.warehouseName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        warehouse.warehouseCode,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.analytics_rounded),
                      onPressed: onViewUtilization,
                      tooltip: 'View Utilization',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: onEdit,
                      tooltip: 'Edit Warehouse',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              warehouse.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem('Status', _formatStatus(warehouse.status), theme),
                _buildDetailItem('Layout', _formatLayoutType(warehouse.layout.layoutType), theme),
                _buildDetailItem('Zones', warehouse.zones.length.toString(), theme),
                _buildDetailItem('Utilization', '${utilizationPercentage.toStringAsFixed(1)}%', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warehouse Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Warehouse Code', warehouse.warehouseCode, theme),
            _buildInfoRow('Description', warehouse.description, theme),
            _buildInfoRow('Address', '${warehouse.address.addressLine1}, ${warehouse.address.city}', theme),
            _buildInfoRow('Layout Type', _formatLayoutType(warehouse.layout.layoutType), theme),
            _buildInfoRow('Aisles', warehouse.layout.aisles.toString(), theme),
            _buildInfoRow('Racks', warehouse.layout.racks.toString(), theme),
            _buildInfoRow('Loading Bays', warehouse.layout.loadingBays.toString(), theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityTab(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacity Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Total Area', '${warehouse.capacity.totalArea.toStringAsFixed(0)} m²', theme),
            _buildInfoRow('Usable Area', '${warehouse.capacity.usableArea.toStringAsFixed(0)} m²', theme),
            _buildInfoRow('Storage Capacity', '${warehouse.capacity.storageCapacity.toStringAsFixed(0)} m³', theme),
            _buildInfoRow('Pallet Positions', warehouse.capacity.palletPositions.toString(), theme),
            _buildInfoRow('Current Utilization', '${warehouse.capacity.currentUtilization.toStringAsFixed(0)} m²', theme),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: warehouse.capacity.totalArea > 0 ? warehouse.capacity.currentUtilization / warehouse.capacity.totalArea : 0,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              color: _getUtilizationColor(warehouse.capacity.totalArea > 0 ? (warehouse.capacity.currentUtilization / warehouse.capacity.totalArea) * 100 : 0),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesTab(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warehouse Zones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (warehouse.zones.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.location_on_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No Zones Configured',
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              )
            else
              ...warehouse.zones.map((zone) => _buildZoneCard(zone, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(WarehouseZone zone, ThemeData theme) {
    final utilizationPercentage = zone.capacity > 0 ? (zone.currentUtilization / zone.capacity) * 100 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.square_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.zoneName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${zone.zoneCode} • ${_formatZoneType(zone.zoneType)}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: utilizationPercentage / 100,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  color: _getUtilizationColor(utilizationPercentage.toDouble()),
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${zone.currentUtilization.toStringAsFixed(0)} / ${zone.capacity.toStringAsFixed(0)} units',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    Text(
                      '${utilizationPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getUtilizationColor(utilizationPercentage.toDouble()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildContactItem('Phone', warehouse.contactInformation.phone, Icons.phone_rounded, theme),
            _buildContactItem('Email', warehouse.contactInformation.email, Icons.email_rounded, theme),
            if (warehouse.contactInformation.fax != null)
              _buildContactItem('Fax', warehouse.contactInformation.fax!, Icons.fax_rounded, theme),
            _buildContactItem('Emergency Contact', warehouse.contactInformation.emergencyContact, Icons.emergency_rounded, theme),
            const SizedBox(height: 16),
            const Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              warehouse.address.addressLine1,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
            if (warehouse.address.addressLine2 != null)
              Text(
                warehouse.address.addressLine2!,
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8)),
              ),
            Text(
              '${warehouse.address.city}, ${warehouse.address.state} ${warehouse.address.postalCode}',
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
            Text(
              warehouse.address.country,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods (same as before)
  Color _getStatusColor(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL: return Colors.green;
      case WarehouseStatus.UNDER_MAINTENANCE: return Colors.orange;
      case WarehouseStatus.CLOSED: return Colors.red;
      case WarehouseStatus.UNDER_CONSTRUCTION: return Colors.blue;
    }
  }

  IconData _getStatusIcon(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL: return Icons.check_circle_rounded;
      case WarehouseStatus.UNDER_MAINTENANCE: return Icons.build_rounded;
      case WarehouseStatus.CLOSED: return Icons.close_rounded;
      case WarehouseStatus.UNDER_CONSTRUCTION: return Icons.construction_rounded;
    }
  }

  Color _getUtilizationColor(double percentage) {
    if (percentage < 70) return Colors.green;
    if (percentage < 85) return Colors.orange;
    return Colors.red;
  }

  String _formatStatus(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL: return 'Operational';
      case WarehouseStatus.UNDER_MAINTENANCE: return 'Under Maintenance';
      case WarehouseStatus.CLOSED: return 'Closed';
      case WarehouseStatus.UNDER_CONSTRUCTION: return 'Under Construction';
    }
  }

  String _formatLayoutType(LayoutType type) {
    switch (type) {
      case LayoutType.SINGLE_STORY: return 'Single Story';
      case LayoutType.MULTI_STORY: return 'Multi Story';
      case LayoutType.RACKED: return 'Racked';
      case LayoutType.BULK_STORAGE: return 'Bulk Storage';
      case LayoutType.AUTOMATED: return 'Automated';
    }
  }

  String _formatZoneType(ZoneType type) {
    switch (type) {
      case ZoneType.BULK_STORAGE: return 'Bulk Storage';
      case ZoneType.RACK_STORAGE: return 'Rack Storage';
      case ZoneType.COLD_STORAGE: return 'Cold Storage';
      case ZoneType.HAZARDOUS: return 'Hazardous';
      case ZoneType.PICKING: return 'Picking';
      case ZoneType.RECEIVING: return 'Receiving';
      case ZoneType.DISPATCH: return 'Dispatch';
      case ZoneType.QUARANTINE: return 'Quarantine';
    }
  }
}