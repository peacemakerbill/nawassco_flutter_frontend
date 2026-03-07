import 'package:flutter/material.dart';
import '../../../models/service_area_model.dart';
import 'common/coverage_indicator.dart';

class ServiceAreaDetails extends StatelessWidget {
  final ServiceArea serviceArea;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ServiceAreaDetails({
    super.key,
    required this.serviceArea,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceArea.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            serviceArea.type.icon,
                            size: 16,
                            color: serviceArea.type.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            serviceArea.type.displayName,
                            style: TextStyle(
                              color: serviceArea.type.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            serviceArea.status.icon,
                            size: 16,
                            color: serviceArea.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            serviceArea.status.displayName,
                            style: TextStyle(
                              color: serviceArea.status.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(serviceArea.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  Icons.people,
                  'Population',
                  '${serviceArea.population}',
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  Icons.home,
                  'Households',
                  '${serviceArea.households}',
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  Icons.apartment,
                  'Water Sources',
                  '${serviceArea.waterSources.length}',
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  Icons.factory,
                  'Treatment Plants',
                  '${serviceArea.treatmentPlants.length}',
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Coverage Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coverage Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CoverageIndicator(
                      percentage: serviceArea.coverage.waterCoverage,
                      label: 'Water Coverage',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    CoverageIndicator(
                      percentage: serviceArea.coverage.sewerageCoverage,
                      label: 'Sewerage Coverage',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    CoverageIndicator(
                      percentage: serviceArea.coverage.connectionRate,
                      label: 'Connection Rate',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.square_foot, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Total Area: ${serviceArea.coverage.totalArea} km²',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Infrastructure
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Infrastructure',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfrastructureItem(
                      context,
                      Icons.plumbing,
                      'Water Mains',
                      '${serviceArea.infrastructure.waterMains} km',
                    ),
                    _buildInfrastructureItem(
                      context,
                      Icons.plumbing_sharp,
                      'Sewer Mains',
                      '${serviceArea.infrastructure.sewerMains} km',
                    ),
                    _buildInfrastructureItem(
                      context,
                      Icons.water_damage,
                      'Reservoirs',
                      '${serviceArea.infrastructure.reservoirs} units',
                    ),
                    _buildInfrastructureItem(
                      context,
                      Icons.ev_station,
                      'Pumping Stations',
                      '${serviceArea.infrastructure.pumpingStations} units',
                    ),
                    _buildInfrastructureItem(
                      context,
                      Icons.factory,
                      'Treatment Plants',
                      '${serviceArea.infrastructure.treatmentPlants} units',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Services
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: serviceArea.services
                          .map((service) => Chip(
                        label: Text(service.displayName),
                        avatar: Icon(service.icon, size: 16),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      Icons.location_on,
                      'Office Address',
                      serviceArea.contact.officeAddress,
                    ),
                    _buildContactItem(
                      context,
                      Icons.phone,
                      'Phone',
                      serviceArea.contact.phone,
                    ),
                    _buildContactItem(
                      context,
                      Icons.email,
                      'Email',
                      serviceArea.contact.email,
                    ),
                    _buildContactItem(
                      context,
                      Icons.person,
                      'Manager',
                      serviceArea.contact.manager,
                    ),
                    _buildContactItem(
                      context,
                      Icons.emergency,
                      'Emergency Contact',
                      serviceArea.contact.emergencyContact,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Card(
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureItem(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}