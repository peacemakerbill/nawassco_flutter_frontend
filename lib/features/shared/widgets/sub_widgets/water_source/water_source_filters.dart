import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/water_source_model.dart';
import '../../../providers/water_source_provider.dart';


class WaterSourceFilters extends ConsumerStatefulWidget {
  const WaterSourceFilters({Key? key}) : super(key: key);

  @override
  ConsumerState<WaterSourceFilters> createState() => _WaterSourceFiltersState();
}

class _WaterSourceFiltersState extends ConsumerState<WaterSourceFilters> {
  final _searchController = TextEditingController();
  String _selectedSort = '-createdAt';
  WaterSourceType? _selectedType;
  SourceStatus? _selectedStatus;
  QualityGrade? _selectedQuality;
  double _minCapacity = 0;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    final filters = ref.read(waterSourceProvider).filters;
    _selectedType = filters['type'];
    _selectedStatus = filters['status'];
    _selectedQuality = filters['quality'];
    _minCapacity = filters['minCapacity'] ?? 0;
    _selectedSort = filters['sort'] ?? '-createdAt';
    _searchController.text = filters['searchQuery'] ?? '';
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedType != null) filters['type'] = _selectedType;
    if (_selectedStatus != null) filters['status'] = _selectedStatus;
    if (_selectedQuality != null) filters['quality'] = _selectedQuality;
    if (_minCapacity > 0) filters['minCapacity'] = _minCapacity;
    if (_searchController.text.isNotEmpty) filters['searchQuery'] = _searchController.text;
    filters['sort'] = _selectedSort;

    ref.read(waterSourceProvider.notifier).applyFilters(filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedQuality = null;
      _minCapacity = 0;
      _searchController.clear();
      _selectedSort = '-createdAt';
    });
    ref.read(waterSourceProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search water sources...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    ),
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _applyFilters(),
          ),
        ),
        // Expandable filter section
        if (_showFilters)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Type filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Source Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: WaterSourceType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return FilterChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? type : null;
                                _applyFilters();
                              });
                            },
                            avatar: Text(type.icon),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SourceStatus.values.map((status) {
                          final isSelected = _selectedStatus == status;
                          return FilterChip(
                            label: Text(status.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                                _applyFilters();
                              });
                            },
                            selectedColor: status.color.withValues(alpha: 0.2),
                            checkmarkColor: status.color,
                            labelStyle: TextStyle(
                              color: isSelected ? status.color : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quality filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quality Grade',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: QualityGrade.values.map((quality) {
                          final isSelected = _selectedQuality == quality;
                          return FilterChip(
                            label: Text(quality.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedQuality = selected ? quality : null;
                                _applyFilters();
                              });
                            },
                            selectedColor: quality.color.withValues(alpha: 0.2),
                            checkmarkColor: quality.color,
                            labelStyle: TextStyle(
                              color: isSelected ? quality.color : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Capacity filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minimum Daily Capacity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _minCapacity,
                              min: 0,
                              max: 10000,
                              divisions: 20,
                              label: '${_minCapacity.toInt()} m³/day',
                              onChanged: (value) {
                                setState(() {
                                  _minCapacity = value;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${_minCapacity.toInt()} m³/day',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sort options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sort By',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSortChip('Name (A-Z)', 'name'),
                          _buildSortChip('Name (Z-A)', '-name'),
                          _buildSortChip('Capacity (Low-High)', 'capacity'),
                          _buildSortChip('Capacity (High-Low)', '-capacity'),
                          _buildSortChip('Newest First', '-createdAt'),
                          _buildSortChip('Oldest First', 'createdAt'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = selected ? value : '-createdAt';
          _applyFilters();
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}