import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class CustomerSearch extends ConsumerWidget {
  const CustomerSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(customerProvider).filters;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText:
                        'Search by name, email, phone, or customer number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(customerProvider.notifier).updateFilters(
                          filters.copyWith(search: value),
                        );
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () => _showFilterDialog(context, ref),
                tooltip: 'Filters',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filters.status != null ||
              filters.customerType != null ||
              filters.customerSegment != null ||
              filters.priorityLevel != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filters.status != null)
                  FilterChip(
                    label: Text('Status: ${filters.status!.displayName}'),
                    onSelected: (selected) {
                      ref.read(customerProvider.notifier).updateFilters(
                            filters.copyWith(status: null),
                          );
                    },
                  ),
                if (filters.customerType != null)
                  FilterChip(
                    label: Text('Type: ${filters.customerType!.displayName}'),
                    onSelected: (selected) {
                      ref.read(customerProvider.notifier).updateFilters(
                            filters.copyWith(customerType: null),
                          );
                    },
                  ),
                if (filters.customerSegment != null)
                  FilterChip(
                    label: Text(
                        'Segment: ${filters.customerSegment!.displayName}'),
                    onSelected: (selected) {
                      ref.read(customerProvider.notifier).updateFilters(
                            filters.copyWith(customerSegment: null),
                          );
                    },
                  ),
                if (filters.priorityLevel != null)
                  FilterChip(
                    label:
                        Text('Priority: ${filters.priorityLevel!.displayName}'),
                    onSelected: (selected) {
                      ref.read(customerProvider.notifier).updateFilters(
                            filters.copyWith(priorityLevel: null),
                          );
                    },
                  ),
                TextButton(
                  onPressed: () {
                    ref.read(customerProvider.notifier).clearFilters();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(customerProvider).filters;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Customers'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CustomerStatus?>(
                  value: filters.status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<CustomerStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...CustomerStatus.values.map((status) {
                      return DropdownMenuItem<CustomerStatus>(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    ref.read(customerProvider.notifier).updateFilters(
                          filters.copyWith(status: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CustomerType?>(
                  value: filters.customerType,
                  decoration: const InputDecoration(
                    labelText: 'Customer Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<CustomerType?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...CustomerType.values.map((type) {
                      return DropdownMenuItem<CustomerType>(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    ref.read(customerProvider.notifier).updateFilters(
                          filters.copyWith(customerType: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CustomerSegment?>(
                  value: filters.customerSegment,
                  decoration: const InputDecoration(
                    labelText: 'Customer Segment',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<CustomerSegment?>(
                      value: null,
                      child: Text('All Segments'),
                    ),
                    ...CustomerSegment.values.map((segment) {
                      return DropdownMenuItem<CustomerSegment>(
                        value: segment,
                        child: Text(segment.displayName),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    ref.read(customerProvider.notifier).updateFilters(
                          filters.copyWith(customerSegment: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PriorityLevel?>(
                  value: filters.priorityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Priority Level',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<PriorityLevel?>(
                      value: null,
                      child: Text('All Priorities'),
                    ),
                    ...PriorityLevel.values.map((priority) {
                      return DropdownMenuItem<PriorityLevel>(
                        value: priority,
                        child: Text(priority.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    ref.read(customerProvider.notifier).updateFilters(
                          filters.copyWith(priorityLevel: value),
                        );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
