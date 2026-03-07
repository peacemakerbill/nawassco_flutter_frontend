import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_technician.dart';
import '../../../../providers/field_technician_provider.dart';

class TechnicianProfileHeader extends ConsumerWidget {
  final FieldTechnician technician;

  const TechnicianProfileHeader({super.key, required this.technician});

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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.primaryContainer.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar and Basic Info
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: isMobile ? 40 : 50,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: technician.profilePictureUrl != null
                            ? NetworkImage(technician.profilePictureUrl!)
                            : null,
                        child: technician.profilePictureUrl == null
                            ? Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                                size: isMobile ? 32 : 40,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: technician.currentStatus.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            technician.currentStatus.icon,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Name and Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technician.jobTitle.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technician.employeeNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email_rounded,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                technician.email,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              technician.phone,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status and Actions
              Row(
                children: [
                  // Status Badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: technician.currentStatus.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: technician.currentStatus.color),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            technician.currentStatus.icon,
                            color: technician.currentStatus.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Status',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: technician.currentStatus.color
                                        .withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  technician.currentStatus.displayName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: technician.currentStatus.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status Dropdown
                  PopupMenuButton<TechnicianStatus>(
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onSelected: (status) => _updateStatus(context, ref, status),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
