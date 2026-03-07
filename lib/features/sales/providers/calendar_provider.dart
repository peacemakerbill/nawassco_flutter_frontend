import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/features/sales/providers/proposal.provider.dart';
import 'package:nawassco/main.dart';
import 'package:nawassco/core/services/api_service.dart';
import 'package:nawassco/core/utils/toast_utils.dart';
import 'package:nawassco/features/public/auth/providers/auth_provider.dart';
import 'package:nawassco/features/sales/models/customer.model.dart';
import 'package:nawassco/features/sales/models/lead_models.dart';
import 'package:nawassco/features/sales/models/opportunity.model.dart';
import 'package:nawassco/features/sales/models/proposal.model.dart';
import 'package:nawassco/features/sales/models/quote.model.dart';
import 'package:nawassco/features/sales/providers/customer_provider.dart';
import 'package:nawassco/features/sales/providers/lead_provider.dart';
import 'package:nawassco/features/sales/providers/opportunity_provider.dart';
import 'package:nawassco/features/sales/providers/quote_provider.dart';
import '../models/calendar.model.dart';

// ============================================
// STATE
// ============================================

class CalendarState {
  final bool isLoading;
  final List<CalendarEvent> events;
  final CalendarEvent? selectedEvent;
  final CalendarFilters filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool showForm;
  final bool showDetails;
  final String? error;
  final List<Map<String, dynamic>>? conflicts;

  const CalendarState({
    this.isLoading = false,
    this.events = const [],
    this.selectedEvent,
    this.filters = const CalendarFilters(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.showForm = false,
    this.showDetails = false,
    this.error,
    this.conflicts,
  });

  CalendarState copyWith({
    bool? isLoading,
    List<CalendarEvent>? events,
    CalendarEvent? selectedEvent,
    CalendarFilters? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? showForm,
    bool? showDetails,
    String? error,
    List<Map<String, dynamic>>? conflicts,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      showForm: showForm ?? this.showForm,
      showDetails: showDetails ?? this.showDetails,
      error: error ?? this.error,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}

// ============================================
// PROVIDER
// ============================================

class CalendarProvider extends StateNotifier<CalendarState> {
  final Dio _dio;
  final Ref _ref;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  CalendarProvider(this._dio, this._ref, this._scaffoldKey)
      : super(const CalendarState());

  // Get current user from auth
  Map<String, dynamic>? get _currentUser {
    final authState = _ref.read(authProvider);
    return authState.user;
  }

  String? get _currentUserId => _currentUser?['_id'] as String?;
  String get _currentUserName => '${_currentUser?['firstName']} ${_currentUser?['lastName']}';

  // Get other providers data
  List<Customer> get _customers => _ref.read(customerProvider).customers;
  List<Lead> get _leads => _ref.read(leadProvider).leads;
  List<Opportunity> get _opportunities => _ref.read(opportunityProvider).opportunities;
  List<Proposal> get _proposals => _ref.read(proposalProvider).proposals;
  List<Quote> get _quotes => _ref.read(quoteProvider).quotes;

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  Future<void> loadEvents({bool refresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = {
        'page': state.currentPage.toString(),
        'limit': '20',
        ...state.filters.toQueryParams(),
      };

      // If showing only my events, filter by organizer
      if (state.filters.myEventsOnly == true && _currentUserId != null) {
        query['organizer'] = _currentUserId;
      }

      final response = await _dio.get('/v1/nawassco/sales/calendar', queryParameters: query);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final pagination = response.data['pagination'] as Map<String, dynamic>;

        final events = data
            .map<CalendarEvent>((json) => CalendarEvent.fromJson(json))
            .toList();

        state = state.copyWith(
          events: refresh ? events : [...state.events, ...events],
          totalPages: pagination['pages'] as int,
          totalItems: pagination['total'] as int,
          isLoading: false,
        );
      } else {
        _showError(response.data['message'] ?? 'Failed to load events');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<CalendarEvent?> loadEvent(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/sales/calendar/$id');

      if (response.data['success'] == true) {
        final event = CalendarEvent.fromJson(response.data['data']);
        state = state.copyWith(
          selectedEvent: event,
          isLoading: false,
        );
        return event;
      } else {
        _showError(response.data['message'] ?? 'Failed to load event');
        state = state.copyWith(isLoading: false);
        return null;
      }
    } catch (e) {
      _handleError(e);
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  Future<CalendarEvent?> createEvent(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      // Add current user as organizer if not specified
      if (_currentUserId != null && data['organizer'] == null) {
        data['organizer'] = _currentUserId;
      }

      // Add createdBy user reference
      if (_currentUserId != null) {
        data['createdBy'] = {
          'userId': _currentUserId,
          'firstName': _currentUser?['firstName'],
          'lastName': _currentUser?['lastName'],
          'email': _currentUser?['email'],
        };
      }

      final response = await _dio.post('/v1/nawassco/sales/calendar', data: data);

      if (response.data['success'] == true) {
        final event = CalendarEvent.fromJson(response.data['data']);

        state = state.copyWith(
          events: [event, ...state.events],
          selectedEvent: event,
          isCreating: false,
          showForm: false,
          showDetails: true,
        );

        _showSuccess('Event created successfully');
        return event;
      } else {
        _showError(response.data['message'] ?? 'Failed to create event');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }

  Future<CalendarEvent?> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      // Add lastModifiedBy user reference
      if (_currentUserId != null) {
        data['lastModifiedBy'] = {
          'userId': _currentUserId,
          'firstName': _currentUser?['firstName'],
          'lastName': _currentUser?['lastName'],
          'email': _currentUser?['email'],
        };
      }

      final response = await _dio.put('/v1/nawassco/sales/calendar/$id', data: data);

      if (response.data['success'] == true) {
        final updatedEvent = CalendarEvent.fromJson(response.data['data']);

        final updatedEvents = state.events.map((event) {
          return event.id == id ? updatedEvent : event;
        }).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: updatedEvent,
          isUpdating: false,
          showForm: false,
          showDetails: true,
        );

        _showSuccess('Event updated successfully');
        return updatedEvent;
      } else {
        _showError(response.data['message'] ?? 'Failed to update event');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final response = await _dio.delete('/v1/nawassco/sales/calendar/$id');

      if (response.data['success'] == true) {
        final updatedEvents = state.events.where((event) => event.id != id).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: null,
          isDeleting: false,
          showDetails: false,
        );

        _showSuccess('Event deleted successfully');
        return true;
      } else {
        _showError(response.data['message'] ?? 'Failed to delete event');
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  // ============================================
  // SPECIFIC OPERATIONS
  // ============================================

  Future<CalendarEvent?> cancelEvent(String id, String reason) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.put('/v1/nawassco/sales/calendar/$id/cancel', data: {
        'cancellationReason': reason,
      });

      if (response.data['success'] == true) {
        final updatedEvent = CalendarEvent.fromJson(response.data['data']);

        final updatedEvents = state.events.map((event) {
          return event.id == id ? updatedEvent : event;
        }).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: updatedEvent,
          isUpdating: false,
        );

        _showSuccess('Event cancelled successfully');
        return updatedEvent;
      } else {
        _showError(response.data['message'] ?? 'Failed to cancel event');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<CalendarEvent?> addAttendee(String id, String userId, {bool required = true}) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response = await _dio.post('/v1/nawassco/sales/calendar/$id/attendees', data: {
        'userId': userId,
        'required': required,
      });

      if (response.data['success'] == true) {
        final updatedEvent = CalendarEvent.fromJson(response.data['data']);

        final updatedEvents = state.events.map((event) {
          return event.id == id ? updatedEvent : event;
        }).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: updatedEvent,
          isUpdating: false,
        );

        _showSuccess('Attendee added successfully');
        return updatedEvent;
      } else {
        _showError(response.data['message'] ?? 'Failed to add attendee');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<CalendarEvent?> confirmAttendance(String id, {String? userId}) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final actualUserId = userId ?? _currentUserId;
      if (actualUserId == null) {
        _showError('User ID is required');
        return null;
      }

      final response = await _dio.post('/v1/nawassco/sales/calendar/$id/confirm-attendance', data: {
        'userId': actualUserId,
      });

      if (response.data['success'] == true) {
        final updatedEvent = CalendarEvent.fromJson(response.data['data']);

        final updatedEvents = state.events.map((event) {
          return event.id == id ? updatedEvent : event;
        }).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: updatedEvent,
          isUpdating: false,
        );

        _showSuccess('Attendance confirmed');
        return updatedEvent;
      } else {
        _showError(response.data['message'] ?? 'Failed to confirm attendance');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<CalendarEvent?> updateOutcome(
      String id,
      String outcome, {
        String? outcomeNotes,
        double? rating,
        String? feedback,
      }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final data = {
        'outcome': outcome,
        if (outcomeNotes != null) 'outcomeNotes': outcomeNotes,
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      };

      final response = await _dio.put('/v1/nawassco/sales/calendar/$id/outcome', data: data);

      if (response.data['success'] == true) {
        final updatedEvent = CalendarEvent.fromJson(response.data['data']);

        final updatedEvents = state.events.map((event) {
          return event.id == id ? updatedEvent : event;
        }).toList();

        state = state.copyWith(
          events: updatedEvents,
          selectedEvent: updatedEvent,
          isUpdating: false,
        );

        _showSuccess('Outcome updated successfully');
        return updatedEvent;
      } else {
        _showError(response.data['message'] ?? 'Failed to update outcome');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<List<Map<String, dynamic>>> checkSchedulingConflicts({
    required String organizerId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeEventId,
  }) async {
    try {
      final response = await _dio.post('/v1/nawassco/sales/calendar/check-conflicts', data: {
        'organizerId': organizerId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (excludeEventId != null) 'excludeEventId': excludeEventId,
      });

      if (response.data['success'] == true) {
        final conflicts = (response.data['data']['conflicts'] as List).cast<Map<String, dynamic>>();
        state = state.copyWith(conflicts: conflicts);
        return conflicts;
      }
      return [];
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<List<CalendarEvent>> loadUpcomingEvents({int days = 7}) async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/calendar/upcoming', queryParameters: {
        'days': days.toString(),
        if (_currentUserId != null) 'userId': _currentUserId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<CalendarEvent>((json) => CalendarEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<List<CalendarEvent>> loadTodaysEvents() async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/calendar/today', queryParameters: {
        if (_currentUserId != null) 'userId': _currentUserId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<CalendarEvent>((json) => CalendarEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> loadCalendarStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/calendar/stats', queryParameters: {
        if (_currentUserId != null) 'userId': _currentUserId,
      });

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  Future<Map<String, dynamic>> loadDashboardStats() async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/calendar/dashboard/stats', queryParameters: {
        if (_currentUserId != null) 'userId': _currentUserId,
      });

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  Future<List<CalendarEvent>> loadEventsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get('/v1/nawassco/sales/calendar/date-range', queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (_currentUserId != null) 'userId': _currentUserId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map<CalendarEvent>((json) => CalendarEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // ============================================
  // UI STATE MANAGEMENT
  // ============================================

  void showEventForm({CalendarEvent? event}) {
    state = state.copyWith(
      showForm: true,
      showDetails: false,
      selectedEvent: event,
    );
  }

  void showEventDetails(CalendarEvent event) {
    state = state.copyWith(
      showDetails: true,
      showForm: false,
      selectedEvent: event,
    );
  }

  void showEventList() {
    state = state.copyWith(
      showForm: false,
      showDetails: false,
      selectedEvent: null,
    );
  }

  void selectEvent(CalendarEvent? event) {
    state = state.copyWith(selectedEvent: event);
  }

  void updateFilters(CalendarFilters filters) {
    state = state.copyWith(
      filters: filters,
      currentPage: 1,
      events: [],
    );
    loadEvents(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const CalendarFilters(),
      currentPage: 1,
      events: [],
    );
    loadEvents(refresh: true);
  }

  void loadNextPage() {
    if (state.currentPage < state.totalPages && !state.isLoading) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadEvents();
    }
  }

  void refreshData() {
    state = state.copyWith(
      currentPage: 1,
      events: [],
    );
    loadEvents(refresh: true);
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldKey);
  }

  void _showError(String message) {
    state = state.copyWith(error: message);
    ToastUtils.showErrorToast(message, key: _scaffoldKey);
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'You don\'t have permission to perform this action.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Event not found.';
      } else if (error.response?.statusCode == 409) {
        errorMessage = 'Scheduling conflict detected. Please choose a different time.';
      } else if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out. Please check your connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
    }

    state = state.copyWith(error: errorMessage);
    ToastUtils.showErrorToast(errorMessage, key: _scaffoldKey);
  }
}

// ============================================
// PROVIDER DECLARATION
// ============================================

final calendarProvider = StateNotifierProvider<CalendarProvider, CalendarState>(
      (ref) {
    final dio = ref.read(dioProvider);
    return CalendarProvider(dio, ref, scaffoldMessengerKey);
  },
);