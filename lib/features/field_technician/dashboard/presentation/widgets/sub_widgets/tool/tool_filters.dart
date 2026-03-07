import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/tool.dart';
import '../../../../providers/tool_provider.dart';

class ToolFiltersWidget extends ConsumerWidget {
  const ToolFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolState = ref.watch(toolProvider);
    final toolNotifier = ref.read(toolProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Filter Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => toolNotifier.clearFilters(),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tool Type Filter
          const Text(
            'Tool Type',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ToolType.values.map((type) {
              final isSelected = toolState.typeFilter == type;
              return FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  toolNotifier.setTypeFilter(selected ? type : null);
                },
                backgroundColor:
                    isSelected ? type.color.withOpacity(0.1) : null,
                selectedColor: type.color.withOpacity(0.2),
                checkmarkColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected ? type.color : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Status Filter
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ToolStatus.values.map((status) {
              final isSelected = toolState.statusFilter == status;
              return FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  toolNotifier.setStatusFilter(selected ? status : null);
                },
                backgroundColor:
                    isSelected ? status.color.withOpacity(0.1) : null,
                selectedColor: status.color.withOpacity(0.2),
                checkmarkColor: status.color,
                labelStyle: TextStyle(
                  color: isSelected ? status.color : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Location Filter
          const Text(
            'Location',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Filter by location...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => toolNotifier.setLocationFilter(value),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}