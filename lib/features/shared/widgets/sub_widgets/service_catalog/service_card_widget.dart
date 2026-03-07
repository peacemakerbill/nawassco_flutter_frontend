import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_catalog_model.dart';
import '../../../utils/service_catalog/service_constants.dart';

class ServiceCardWidget extends ConsumerWidget {
  final ServiceCatalog service;
  final VoidCallback? onTap;
  final bool showActions;
  final bool showStatus;
  final bool showPrice;

  const ServiceCardWidget({
    super.key,
    required this.service,
    this.onTap,
    this.showActions = true,
    this.showStatus = true,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey.shade900, Colors.grey.shade800]
                  : [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: service.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service.category.icon,
                      color: service.category.color,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Service code and name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  if (showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ServiceConstants.getStatusColor(service.status.displayName).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ServiceConstants.getStatusColor(service.status.displayName).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ServiceConstants.getStatusIcon(service.status.displayName),
                            size: 12,
                            color: ServiceConstants.getStatusColor(service.status.displayName),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.status.displayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ServiceConstants.getStatusColor(service.status.displayName),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                service.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Details row
              Row(
                children: [
                  // Price
                  if (showPrice)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ServiceConstants.formatCurrency(service.pricing.basePrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Customer types
                  Wrap(
                    spacing: 4,
                    children: service.eligibility.customerTypes.take(3).map((type) {
                      return Chip(
                        label: Text(type.displayName),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                        backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Popularity indicator
              if (service.popularityScore != null && service.popularityScore! > 80)
                const SizedBox(height: 12),
              if (service.popularityScore != null && service.popularityScore! > 80)
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Popular',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: service.popularityScore! / 100,
                        backgroundColor: Colors.green.shade100,
                        color: Colors.green,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),

              // Actions row
              if (showActions)
                const SizedBox(height: 12),
              if (showActions)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to details
                          if (onTap != null) onTap!();
                        },
                        icon: Icon(Icons.visibility, size: 16),
                        label: Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (service.status == ServiceStatus.active)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Apply for service
                          _showApplyDialog(context);
                        },
                        icon: Icon(Icons.send, size: 16),
                        label: Text('Apply'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for ${service.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Would you like to apply for this service?'),
            const SizedBox(height: 16),
            Text(
              'Requirements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...service.eligibility.documentationRequired.map((req) => Text('• $req')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to application form
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class ServiceCardGridWidget extends ConsumerWidget {
  final List<ServiceCatalog> services;
  final int crossAxisCount;
  final Function(ServiceCatalog)? onTap;

  const ServiceCardGridWidget({
    super.key,
    required this.services,
    this.crossAxisCount = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCardWidget(
          service: service,
          onTap: () => onTap?.call(service),
        );
      },
    );
  }
}

class ServiceCardListWidget extends ConsumerWidget {
  final List<ServiceCatalog> services;
  final Function(ServiceCatalog)? onTap;

  const ServiceCardListWidget({
    super.key,
    required this.services,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCardWidget(
          service: service,
          onTap: () => onTap?.call(service),
          showActions: false,
        );
      },
    );
  }
}