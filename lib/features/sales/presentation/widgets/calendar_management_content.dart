import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calendar.model.dart';
import '../../providers/calendar_provider.dart';
import 'sub_widgets/calender/calendar_event_card.widget.dart';
import 'sub_widgets/calender/calendar_event_details.widget.dart';
import 'sub_widgets/calender/calendar_event_form.widget.dart';
import 'sub_widgets/calender/calendar_filters.widget.dart';

class CalendarManagementContent extends ConsumerStatefulWidget {
  const CalendarManagementContent({super.key});

  @override
  ConsumerState<CalendarManagementContent> createState() =>
      _CalendarManagementContentState();
}

class _CalendarManagementContentState
    extends ConsumerState<CalendarManagementContent> {
  bool _showFilters = false;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  // Dialog state
  bool _showFormDialog = false;
  bool _showDetailsDialog = false;
  CalendarEvent? _selectedDialogEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarProvider.notifier).refreshData();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final notifier = ref.read(calendarProvider.notifier);
      final currentFilters = ref.read(calendarProvider).filters;

      notifier.updateFilters(
        currentFilters.copyWith(search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim()),
      );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    final notifier = ref.read(calendarProvider.notifier);
    final currentFilters = ref.read(calendarProvider).filters;
    notifier.updateFilters(currentFilters.copyWith(search: null));
  }

  void _createEvent() {
    setState(() {
      _showFormDialog = true;
      _selectedDialogEvent = null;
    });
  }

  void _editEvent(CalendarEvent event) {
    setState(() {
      _showFormDialog = true;
      _selectedDialogEvent = event;
    });
  }

  void _viewEventDetails(CalendarEvent event) {
    setState(() {
      _showDetailsDialog = true;
      _selectedDialogEvent = event;
    });
  }

  void _deleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(calendarProvider.notifier).deleteEvent(eventId);
      // Refresh data after deletion
      ref.read(calendarProvider.notifier).refreshData();
    }
  }

  void _handleFormSubmit(Map<String, dynamic> data) async {
    final notifier = ref.read(calendarProvider.notifier);
    if (_selectedDialogEvent != null) {
      await notifier.updateEvent(_selectedDialogEvent!.id, data);
    } else {
      await notifier.createEvent(data);
    }

    // Close dialog and refresh
    setState(() {
      _showFormDialog = false;
      _selectedDialogEvent = null;
    });
    notifier.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calendar Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
                          onPressed: notifier.refreshData,
                          tooltip: 'Refresh',
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _createEvent,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('NEW EVENT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 20, color: Color(0xFF6B7280)),
                            onPressed: _clearSearch,
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                        color: const Color(0xFF1E3A8A),
                        size: 24,
                      ),
                      onPressed: () => setState(() => _showFilters = !_showFilters),
                      tooltip: 'Show/Hide Filters',
                    ),
                  ],
                ),
              ),

              // Filters Section
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CalendarFiltersWidget(
                    initialFilters: state.filters,
                    onApply: (filters) {
                      notifier.updateFilters(filters);
                      setState(() => _showFilters = false);
                    },
                    onClear: () {
                      notifier.clearFilters();
                      setState(() => _showFilters = false);
                    },
                  ),
                ),

              // Main List
              Expanded(
                child: _buildEventsList(state, notifier),
              ),
            ],
          ),

          // Form Dialog
          if (_showFormDialog)
            _buildFormDialog(),

          // Details Dialog
          if (_showDetailsDialog && _selectedDialogEvent != null)
            _buildDetailsDialog(_selectedDialogEvent!),
        ],
      ),
    );
  }

  Widget _buildFormDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
        ),
        child: CalendarEventForm(
          initialEvent: _selectedDialogEvent,
          onSubmit: _handleFormSubmit,
          onCancel: () {
            setState(() {
              _showFormDialog = false;
              _selectedDialogEvent = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDetailsDialog(CalendarEvent event) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
        ),
        child: CalendarEventDetails(
          event: event,
          onEdit: () {
            setState(() {
              _showDetailsDialog = false;
              _showFormDialog = true;
              _selectedDialogEvent = event;
            });
          },
          onDelete: () {
            setState(() {
              _showDetailsDialog = false;
              _selectedDialogEvent = null;
            });
            _deleteEvent(event.id);
          },
          onClose: () {
            setState(() {
              _showDetailsDialog = false;
              _selectedDialogEvent = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEventsList(CalendarState state, CalendarProvider notifier) {
    if (state.isLoading && state.events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No events found',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
            ),
            if (state.filters.hasFilters)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: notifier.clearFilters,
                  child: const Text('Clear filters'),
                ),
              ),
          ],
        ),
      );
    }

    // Apply local search filtering
    List<CalendarEvent> filteredEvents = state.events;
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filteredEvents = filteredEvents.where((event) => event.matchesSearch(searchTerm)).toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        notifier.refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredEvents.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < filteredEvents.length) {
            final event = filteredEvents[index];
            return CalendarEventCard(
              event: event,
              onTap: () => _viewEventDetails(event),
              onEdit: () => _editEvent(event),
              onDelete: () => _deleteEvent(event.id),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}