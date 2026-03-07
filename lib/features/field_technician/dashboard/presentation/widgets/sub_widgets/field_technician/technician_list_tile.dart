import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/field_technician.dart';
import '../../../../providers/field_technician_provider.dart';
import 'technician_details_dialog.dart';

class TechnicianListTile extends ConsumerWidget {
  final FieldTechnician technician;

  const TechnicianListTile({super.key, required this.technician});

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TechnicianDetailsDialog(technician: technician),
    );
  }

  void _updateStatus(
      BuildContext context, WidgetRef ref, TechnicianStatus newStatus) {
    ref
        .read(fieldTechnicianProvider.notifier)
        .updateTechnicianStatus(technician.id, newStatus);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailsDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: technician.profilePictureUrl != null
                        ? NetworkImage(technician.profilePictureUrl!)
                        : null,
                    child: technician.profilePictureUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Name and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          technician.jobTitle.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          technician.employeeNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: technician.currentStatus.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color:
                              technician.currentStatus.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          technician.currentStatus.icon,
                          size: 12,
                          color: technician.currentStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          technician.currentStatus.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: technician.currentStatus.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Performance and Details
              Row(
                children: [
                  // Performance Indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: technician.performanceScore / 100,
                                backgroundColor:
                                    theme.colorScheme.surfaceVariant,
                                color: technician.performanceColor,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${technician.performanceScore.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: technician.performanceColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Quick Actions
                  if (!isMobile) ...[
                    PopupMenuButton<TechnicianStatus>(
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (status) =>
                          _updateStatus(context, ref, status),
                      itemBuilder: (context) =>
                          TechnicianStatus.values.map((status) {
                        return PopupMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, color: status.color, size: 16),
                              const SizedBox(width: 8),
                              Text(status.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),

              // Mobile Quick Actions
              if (isMobile) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: TechnicianStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(context, ref, status),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: BorderSide(color: status.color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(status.icon, size: 12, color: status.color),
                              const SizedBox(width: 4),
                              Text(
                                status.displayName,
                                style: TextStyle(
                                    fontSize: 10, color: status.color),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
