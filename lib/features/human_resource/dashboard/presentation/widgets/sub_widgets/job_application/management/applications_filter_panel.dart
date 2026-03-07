import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';

class ApplicationsFilterPanel extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic> initialFilters;

  const ApplicationsFilterPanel({
    super.key,
    required this.onFilterChanged,
    required this.initialFilters,
  });

  @override
  State<ApplicationsFilterPanel> createState() =>
      _ApplicationsFilterPanelState();
}

class _ApplicationsFilterPanelState extends State<ApplicationsFilterPanel> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _applyFilters() {
    widget.onFilterChanged(_filters);
  }

  void _resetFilters() {
    setState(() {
      _filters = {};
    });
    widget.onFilterChanged({});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Applications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Filter
            Text(
              'Application Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values.map((status) {
                final isSelected =
                    _filters['status'] == status.name.toLowerCase();
                return FilterChip(
                  label: Text(
                    status.name
                        .split('_')
                        .map(
                            (word) => word[0].toUpperCase() + word.substring(1))
                        .join(' '),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters['status'] = status.name.toLowerCase();
                      } else if (_filters['status'] ==
                          status.name.toLowerCase()) {
                        _filters.remove('status');
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Date Range
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _filters['startDate'] = date.toIso8601String();
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _filters['startDate'] != null
                          ? _formatDate(DateTime.parse(_filters['startDate']))
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _filters['endDate'] = date.toIso8601String();
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _filters['endDate'] != null
                          ? _formatDate(DateTime.parse(_filters['endDate']))
                          : '',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rating Filter
            Text(
              'Minimum Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: (_filters['minRating'] ?? 0.0).toDouble(),
              min: 0,
              max: 5,
              divisions: 10,
              label: '${(_filters['minRating'] ?? 0.0).toStringAsFixed(1)}',
              onChanged: (value) {
                setState(() {
                  _filters['minRating'] = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reset Filters'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
