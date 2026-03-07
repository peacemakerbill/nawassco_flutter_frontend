import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class TrainingFilter extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const TrainingFilter({super.key, required this.onClose});

  @override
  ConsumerState<TrainingFilter> createState() => _TrainingFilterState();
}

class _TrainingFilterState extends ConsumerState<TrainingFilter> {
  late String _searchQuery;
  late TrainingType? _selectedType;
  late TrainingCategory? _selectedCategory;
  late TrainingStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final state = ref.read(trainingProvider);
    _searchQuery = state.searchQuery;
    _selectedType = state.selectedType;
    _selectedCategory = state.selectedCategory;
    _selectedStatus = state.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Trainings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                tooltip: 'Close filters',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _searchQuery = '');
                  _applyFilters();
                },
              )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),

          // Training Type
          const Text(
            'Training Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _selectedType == null,
                onSelected: (_) {
                  setState(() => _selectedType = null);
                  _applyFilters();
                },
              ),
              ...TrainingType.values.map((type) {
                return FilterChip(
                  label: Text(_formatType(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? type : null);
                    _applyFilters();
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),

          // Category
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Categories'),
                selected: _selectedCategory == null,
                onSelected: (_) {
                  setState(() => _selectedCategory = null);
                  _applyFilters();
                },
              ),
              ...TrainingCategory.values.map((category) {
                return FilterChip(
                  label: Text(_formatCategory(category)),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = selected ? category : null);
                    _applyFilters();
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),

          // Status
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Statuses'),
                selected: _selectedStatus == null,
                onSelected: (_) {
                  setState(() => _selectedStatus = null);
                  _applyFilters();
                },
              ),
              ...TrainingStatus.values.map((status) {
                return FilterChip(
                  label: Text(_formatStatus(status)),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() => _selectedStatus = selected ? status : null);
                    _applyFilters();
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref.read(trainingProvider.notifier).filterTrainings(
      searchQuery: _searchQuery,
      type: _selectedType,
      category: _selectedCategory,
      status: _selectedStatus,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = null;
      _selectedCategory = null;
      _selectedStatus = null;
    });
    ref.read(trainingProvider.notifier).clearFilters();
  }

  String _formatType(TrainingType type) {
    return type.toString().split('.').last[0].toUpperCase() +
        type.toString().split('.').last.substring(1);
  }

  String _formatCategory(TrainingCategory category) {
    return category.toString().split('.').last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatStatus(TrainingStatus status) {
    return status.toString().split('.').last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}