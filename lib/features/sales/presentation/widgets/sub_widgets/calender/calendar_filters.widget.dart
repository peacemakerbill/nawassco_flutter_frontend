import 'package:flutter/material.dart';

import '../../../../models/calendar.model.dart';

class CalendarFiltersWidget extends StatefulWidget {
  final CalendarFilters initialFilters;
  final Function(CalendarFilters) onApply;
  final VoidCallback onClear;
  final bool showSearchField;

  const CalendarFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
    this.showSearchField = false,
  });

  @override
  State<CalendarFiltersWidget> createState() => _CalendarFiltersWidgetState();
}

class _CalendarFiltersWidgetState extends State<CalendarFiltersWidget> {
  late CalendarEventType? _selectedType;
  late EventStatus? _selectedStatus;
  late PriorityLevel? _selectedPriority;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String _searchQuery;
  late bool _myEventsOnly;
  late bool _upcomingOnly;
  late bool _pastOnly;
  late bool _showCancelled;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilters.type;
    _selectedStatus = widget.initialFilters.status;
    _selectedPriority = widget.initialFilters.priority;
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _searchQuery = widget.initialFilters.search ?? '';
    _myEventsOnly = widget.initialFilters.myEventsOnly ?? false;
    _upcomingOnly = widget.initialFilters.upcomingOnly ?? false;
    _pastOnly = widget.initialFilters.pastOnly ?? false;
    _showCancelled = widget.initialFilters.showCancelled ?? false;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _applyFilters() {
    widget.onApply(CalendarFilters(
      type: _selectedType,
      status: _selectedStatus,
      priority: _selectedPriority,
      startDate: _startDate,
      endDate: _endDate,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      myEventsOnly: _myEventsOnly,
      upcomingOnly: _upcomingOnly,
      pastOnly: _pastOnly,
      showCancelled: _showCancelled,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedPriority = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _myEventsOnly = false;
      _upcomingOnly = false;
      _pastOnly = false;
      _showCancelled = false;
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filter Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),

          // Search Field (if enabled)
          if (widget.showSearchField)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Quick Filters (Checkboxes)
          const Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              // My Events
              CheckboxListTile(
                title: const Text('My Events Only'),
                value: _myEventsOnly,
                onChanged: (value) => setState(() {
                  _myEventsOnly = value ?? false;
                  if (_myEventsOnly) {
                    _upcomingOnly = false;
                    _pastOnly = false;
                  }
                }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),

              // Upcoming Events
              CheckboxListTile(
                title: const Text('Upcoming Events'),
                value: _upcomingOnly,
                onChanged: (value) => setState(() {
                  _upcomingOnly = value ?? false;
                  if (_upcomingOnly) {
                    _myEventsOnly = false;
                    _pastOnly = false;
                  }
                }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),

              // Past Events
              CheckboxListTile(
                title: const Text('Past Events'),
                value: _pastOnly,
                onChanged: (value) => setState(() {
                  _pastOnly = value ?? false;
                  if (_pastOnly) {
                    _myEventsOnly = false;
                    _upcomingOnly = false;
                  }
                }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),

              // Show Cancelled
              CheckboxListTile(
                title: const Text('Show Cancelled Events'),
                value: _showCancelled,
                onChanged: (value) => setState(() => _showCancelled = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate == null
                              ? 'Start Date'
                              : _formatDate(_startDate!),
                          style: TextStyle(
                            color: _startDate == null
                                ? Colors.grey.shade500
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('to', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate == null
                              ? 'End Date'
                              : _formatDate(_endDate!),
                          style: TextStyle(
                            color: _endDate == null
                                ? Colors.grey.shade500
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type Filter
          DropdownButtonFormField<CalendarEventType?>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Event Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...CalendarEventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 16),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: 16),

          // Status Filter
          DropdownButtonFormField<EventStatus?>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              ...EventStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) => setState(() => _selectedStatus = value),
          ),
          const SizedBox(height: 16),

          // Priority Filter
          DropdownButtonFormField<PriorityLevel?>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.priority_high),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Priorities'),
              ),
              ...PriorityLevel.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: priority.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) => setState(() => _selectedPriority = value),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6B7280)),
                  ),
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}