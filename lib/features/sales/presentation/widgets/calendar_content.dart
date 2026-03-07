import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calendar.model.dart';
import '../../providers/calendar_provider.dart';
import 'sub_widgets/calender/calendar_event_card.widget.dart';
import 'sub_widgets/calender/calendar_event_details.widget.dart';
import 'sub_widgets/calender/calendar_event_form.widget.dart';
import 'sub_widgets/calender/calendar_filters.widget.dart';

class CalendarContent extends ConsumerStatefulWidget {
  const CalendarContent({super.key});

  @override
  ConsumerState<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<CalendarContent> {
  bool _showFilters = false;
  int _selectedTab = 0;
  final _tabs = ['Today', 'Upcoming', 'All Events'];
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
      _loadInitialData();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _loadInitialData() async {
    final notifier = ref.read(calendarProvider.notifier);
    notifier.updateFilters(const CalendarFilters(myEventsOnly: true));
    await notifier.loadEvents(refresh: true);
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

  void _viewEventDetails(CalendarEvent event) {
    setState(() {
      _showDetailsDialog = true;
      _selectedDialogEvent = event;
    });
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

  void _deleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content:
        const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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

  void _onTabChanged(int index) async {
    setState(() => _selectedTab = index);
    final notifier = ref.read(calendarProvider.notifier);

    switch (index) {
      case 0: // Today
        notifier.updateFilters(const CalendarFilters(
          myEventsOnly: true,
          upcomingOnly: false,
          pastOnly: false,
        ));
        break;
      case 1: // Upcoming
        notifier.updateFilters(const CalendarFilters(
          myEventsOnly: true,
          upcomingOnly: true,
          pastOnly: false,
        ));
        break;
      case 2: // All Events
        notifier.updateFilters(const CalendarFilters(
          myEventsOnly: true,
          upcomingOnly: false,
          pastOnly: false,
        ));
        break;
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
                      'My Calendar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                            color: const Color(0xFF1E3A8A),
                          ),
                          onPressed: () => setState(() => _showFilters = !_showFilters),
                          tooltip: 'Toggle Filters',
                        ),
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

              // Main List View
              Expanded(
                child: _buildListView(state, notifier),
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

  Widget _buildListView(CalendarState state, CalendarProvider notifier) {
    return Column(
      children: [
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

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final title = entry.value;
              return Expanded(
                child: InkWell(
                  onTap: () => _onTabChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == index
                              ? const Color(0xFF1E3A8A)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedTab == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _selectedTab == index
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Filters Section
        if (_showFilters)
          Padding(
            padding: const EdgeInsets.all(16),
            child: CalendarFiltersWidget(
              initialFilters: state.filters.copyWith(myEventsOnly: true),
              onApply: (filters) {
                notifier.updateFilters(filters.copyWith(myEventsOnly: true));
                setState(() => _showFilters = false);
              },
              onClear: () {
                notifier.updateFilters(
                    const CalendarFilters(myEventsOnly: true));
                setState(() => _showFilters = false);
              },
            ),
          ),

        // Statistics Banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A).withOpacity(0.9),
                const Color(0xFF3B82F6).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.event,
                'Total Events',
                state.totalItems.toString(),
              ),
              _buildStatItem(
                Icons.upcoming,
                'Upcoming',
                state.events.where((e) => e.isUpcoming).length.toString(),
              ),
              _buildStatItem(
                Icons.check_circle,
                'Completed',
                state.events.where((e) => e.status == EventStatus.completed).length.toString(),
              ),
            ],
          ),
        ),

        // Events List
        Expanded(
          child: _buildEventsList(state, notifier),
        ),
      ],
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
            Text(
              _getEmptyMessage(_selectedTab),
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
            ),
            if (_selectedTab == 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: _createEvent,
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule an Event'),
                ),
              ),
          ],
        ),
      );
    }

    List<CalendarEvent> filteredEvents = state.events;

    // Apply local filtering based on selected tab
    if (_selectedTab == 0) {
      // Today's events
      final today = DateTime.now();
      filteredEvents = state.events.where((event) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        return eventDate == todayDate;
      }).toList();
    } else if (_selectedTab == 1) {
      // Upcoming events
      filteredEvents =
          state.events.where((event) => event.isUpcoming).toList();
    }

    // Apply local search filtering
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
              isCompact: _selectedTab == 0,
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

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _getEmptyMessage(int tabIndex) {
    return switch (tabIndex) {
      0 => 'No events scheduled for today',
      1 => 'No upcoming events',
      2 => 'No events found',
      _ => 'No events found',
    };
  }
}