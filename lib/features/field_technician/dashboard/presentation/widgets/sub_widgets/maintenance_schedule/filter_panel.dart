import 'package:flutter/material.dart';

import '../../../../models/maintenance_schedule.dart';

class FilterPanel extends StatefulWidget {
  final MaintenanceTargetType? targetTypeFilter;
  final MaintenanceStatus? statusFilter;
  final PriorityLevel? priorityFilter;
  final bool showCompleted;
  final bool showOverdue;
  final Function(MaintenanceTargetType?) onTargetTypeChanged;
  final Function(MaintenanceStatus?) onStatusChanged;
  final Function(PriorityLevel?) onPriorityChanged;
  final Function(bool) onShowCompletedChanged;
  final Function(bool) onShowOverdueChanged;
  final VoidCallback onClearFilters;

  const FilterPanel({
    super.key,
    this.targetTypeFilter,
    this.statusFilter,
    this.priorityFilter,
    required this.showCompleted,
    required this.showOverdue,
    required this.onTargetTypeChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onShowCompletedChanged,
    required this.onShowOverdueChanged,
    required this.onClearFilters,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_hasActiveFilters) ...[
                  TextButton(
                    onPressed: widget.onClearFilters,
                    child: const Text('Clear All'),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  iconSize: 20,
                ),
              ],
            ),
            // Expanded Content
            if (_expanded) ...[
              const SizedBox(height: 16),
              _buildFilterContent(),
            ],
            // Active Filters Summary (when collapsed)
            if (!_expanded && _hasActiveFilters) ...[
              const SizedBox(height: 8),
              _buildActiveFiltersSummary(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    return Column(
      children: [
        // Target Type Filter
        _buildFilterSection(
          'Target Type',
          MaintenanceTargetType.values
              .map((type) => _buildFilterChip(
                    type.displayName,
                    widget.targetTypeFilter == type,
                    () => widget.onTargetTypeChanged(
                      widget.targetTypeFilter == type ? null : type,
                    ),
                    icon: type.icon,
                    color: type.color,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Status Filter
        _buildFilterSection(
          'Status',
          MaintenanceStatus.values
              .map((status) => _buildFilterChip(
                    status.displayName,
                    widget.statusFilter == status,
                    () => widget.onStatusChanged(
                      widget.statusFilter == status ? null : status,
                    ),
                    icon: status.icon,
                    color: status.color,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Priority Filter
        _buildFilterSection(
          'Priority',
          PriorityLevel.values
              .map((priority) => _buildFilterChip(
                    priority.displayName,
                    widget.priorityFilter == priority,
                    () => widget.onPriorityChanged(
                      widget.priorityFilter == priority ? null : priority,
                    ),
                    icon: priority.icon,
                    color: priority.color,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Toggle Filters
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Show Completed'),
                value: widget.showCompleted,
                onChanged: (value) => widget.onShowCompletedChanged(value!),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Show Overdue'),
                value: widget.showOverdue,
                onChanged: (value) => widget.onShowOverdueChanged(value!),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap,
      {IconData? icon, Color? color}) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: color ?? Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildActiveFiltersSummary() {
    final activeFilters = <String>[];

    if (widget.targetTypeFilter != null) {
      activeFilters.add(widget.targetTypeFilter!.displayName);
    }
    if (widget.statusFilter != null) {
      activeFilters.add(widget.statusFilter!.displayName);
    }
    if (widget.priorityFilter != null) {
      activeFilters.add(widget.priorityFilter!.displayName);
    }
    if (!widget.showCompleted) {
      activeFilters.add('Hide Completed');
    }
    if (!widget.showOverdue) {
      activeFilters.add('Hide Overdue');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        const Text('Active filters:', style: TextStyle(fontSize: 12)),
        ...activeFilters
            .map((filter) => Chip(
                  label: Text(filter, style: const TextStyle(fontSize: 12)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ))
            .toList(),
      ],
    );
  }

  bool get _hasActiveFilters {
    return widget.targetTypeFilter != null ||
        widget.statusFilter != null ||
        widget.priorityFilter != null ||
        !widget.showCompleted ||
        !widget.showOverdue;
  }
}
