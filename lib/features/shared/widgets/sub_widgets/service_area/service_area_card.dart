import 'package:flutter/material.dart';

import '../../../models/service_area_model.dart';

class ServiceAreaCard extends StatelessWidget {
  final ServiceArea serviceArea;
  final VoidCallback onTap;
  final bool isSelected;

  const ServiceAreaCard({
    super.key,
    required this.serviceArea,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      serviceArea.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: serviceArea.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: serviceArea.status.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          serviceArea.status.icon,
                          size: 14,
                          color: serviceArea.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          serviceArea.status.displayName,
                          style: TextStyle(
                            color: serviceArea.status.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: serviceArea.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      serviceArea.type.icon,
                      size: 14,
                      color: serviceArea.type.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      serviceArea.type.displayName,
                      style: TextStyle(
                        color: serviceArea.type.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                serviceArea.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    Icons.people,
                    '${serviceArea.population}',
                    'Population',
                  ),
                  _buildStatItem(
                    context,
                    Icons.home,
                    '${serviceArea.households}',
                    'Households',
                  ),
                  _buildStatItem(
                    context,
                    Icons.water_drop,
                    '${serviceArea.coverage.waterCoverage.toStringAsFixed(0)}%',
                    'Water Coverage',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Services chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: serviceArea.services
                    .take(3)
                    .map((service) => Chip(
                  label: Text(service.displayName),
                  avatar: Icon(
                    service.icon,
                    size: 16,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}