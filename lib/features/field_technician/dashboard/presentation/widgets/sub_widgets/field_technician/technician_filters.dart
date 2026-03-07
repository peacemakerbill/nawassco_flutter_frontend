import 'package:flutter/material.dart';

import '../../../../models/field_technician.dart';

class TechnicianFilters extends StatelessWidget {
  final String searchQuery;
  final TechnicianStatus? statusFilter;
  final FieldTechnicianRole? roleFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TechnicianStatus?> onStatusFilterChanged;
  final ValueChanged<FieldTechnicianRole?> onRoleFilterChanged;
  final VoidCallback onClearFilters;

  const TechnicianFilters({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    required this.roleFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onRoleFilterChanged,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || statusFilter != null || roleFilter != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      children: [
        // Search Bar
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search technicians...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => onSearchChanged(''),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filters Row
        Row(
          children: [
            // Status Filter
            Expanded(
              child: DropdownButtonFormField<TechnicianStatus?>(
                value: statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Statuses')),
                  ...TechnicianStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Icon(status.icon, color: status.color, size: 16),
                            const SizedBox(width: 8),
                            Text(status.displayName),
                          ],
                        ),
                      )),
                ],
                onChanged: onStatusFilterChanged,
              ),
            ),

            const SizedBox(width: 12),

            // Role Filter
            Expanded(
              child: DropdownButtonFormField<FieldTechnicianRole?>(
                value: roleFilter,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Roles')),
                  ...FieldTechnicianRole.values.map((role) => DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(role.icon, color: role.color, size: 16),
                            const SizedBox(width: 8),
                            Text(role.displayName),
                          ],
                        ),
                      )),
                ],
                onChanged: onRoleFilterChanged,
              ),
            ),

            // Clear Filters Button
            if (hasActiveFilters) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
