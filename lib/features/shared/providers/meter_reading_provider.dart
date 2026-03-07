import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nawassco/main.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../models/meter_reading_model.dart';

class MeterReadingState {
  final List<MeterReading> readings;
  final MeterReading? selectedReading;
  final bool isLoading;
  final String? error;
  final String filterMeterNumber;
  final ReadingStatus? filterStatus;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String searchQuery;
  final bool showCreateForm;
  final bool showDetailView;

  const MeterReadingState({
    required this.readings,
    this.selectedReading,
    this.isLoading = false,
    this.error,
    this.filterMeterNumber = '',
    this.filterStatus,
    this.filterStartDate,
    this.filterEndDate,
    this.searchQuery = '',
    this.showCreateForm = false,
    this.showDetailView = false,
  });

  List<MeterReading> get filteredReadings {
    var filtered = readings;

    // Apply meter number filter
    if (filterMeterNumber.isNotEmpty) {
      filtered = filtered
          .where((r) => r.meterNumber
              .toLowerCase()
              .contains(filterMeterNumber.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (filterStatus != null) {
      filtered =
          filtered.where((r) => r.readingStatus == filterStatus).toList();
    }

    // Apply date range filter
    if (filterStartDate != null && filterEndDate != null) {
      filtered = filtered.where((r) {
        return r.readingDate.isAfter(filterStartDate!) &&
            r.readingDate.isBefore(filterEndDate!);
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.meterNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            r.readerName?.toLowerCase().contains(searchQuery.toLowerCase()) ==
                true ||
            r.billNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ==
                true;
      }).toList();
    }

    return filtered;
  }

  MeterReadingState copyWith({
    List<MeterReading>? readings,
    MeterReading? selectedReading,
    bool? isLoading,
    String? error,
    String? filterMeterNumber,
    ReadingStatus? filterStatus,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? searchQuery,
    bool? showCreateForm,
    bool? showDetailView,
  }) {
    return MeterReadingState(
      readings: readings ?? this.readings,
      selectedReading: selectedReading ?? this.selectedReading,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filterMeterNumber: filterMeterNumber ?? this.filterMeterNumber,
      filterStatus: filterStatus ?? this.filterStatus,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      searchQuery: searchQuery ?? this.searchQuery,
      showCreateForm: showCreateForm ?? this.showCreateForm,
      showDetailView: showDetailView ?? this.showDetailView,
    );
  }
}

class MeterReadingProvider extends StateNotifier<MeterReadingState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  MeterReadingProvider(this.dio, this.scaffoldMessengerKey)
      : super(MeterReadingState(readings: []));

  // Get user ID from auth state
  String? get _currentUserId {
    // This would come from your auth provider
    // For now, we'll return null - you should integrate with your auth provider
    return null;
  }

  // Show toast safely
  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      ToastUtils.showErrorToast(message, key: scaffoldMessengerKey);
    } else {
      ToastUtils.showSuccessToast(message, key: scaffoldMessengerKey);
    }
  }

  // Load all meter readings
  Future<void> loadMeterReadings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await dio.get('/meter-readings');

      if (response.data['success'] == true) {
        final readings = (response.data['data'] as List)
            .map((json) => MeterReading.fromJson(json))
            .toList();

        state = state.copyWith(
          readings: readings,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load readings');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      _showToast('Failed to load readings: ${e.toString()}', isError: true);
    }
  }

  // Create new meter reading
  Future<void> createMeterReading(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      // Add reader info if user is authenticated
      if (_currentUserId != null) {
        data['readerId'] = _currentUserId;
      }

      final response = await dio.post(
        '/v1/nawassco/billing/meter_reading/readings',
        data: data,
      );

      if (response.data['success'] == true) {
        final reading = MeterReading.fromJson(response.data['data']);

        state = state.copyWith(
          readings: [reading, ...state.readings],
          isLoading: false,
          showCreateForm: false,
        );

        _showToast('Meter reading created successfully');
        loadMeterReadings(); // Refresh list
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create reading');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to create reading: ${e.toString()}', isError: true);
    }
  }

  // Update meter reading
  Future<void> updateMeterReading(
      String readingId, Map<String, dynamic> updates) async {
    try {
      state = state.copyWith(isLoading: true);

      // Add updatedBy info
      if (_currentUserId != null) {
        updates['updatedBy'] = _currentUserId;
      }

      final response = await dio.put(
        '/v1/nawassco/billing/meter_reading/readings/$readingId',
        data: updates,
      );

      if (response.data['success'] == true) {
        final updatedReading = MeterReading.fromJson(response.data['data']);

        final updatedReadings = state.readings.map((reading) {
          return reading.id == readingId ? updatedReading : reading;
        }).toList();

        state = state.copyWith(
          readings: updatedReadings,
          selectedReading: state.selectedReading?.id == readingId
              ? updatedReading
              : state.selectedReading,
          isLoading: false,
        );

        _showToast('Meter reading updated successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update reading');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to update reading: ${e.toString()}', isError: true);
    }
  }

  // Delete meter reading
  Future<void> deleteMeterReading(String readingId) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.delete(
        '/v1/nawassco/billing/meter_reading/readings/$readingId',
      );

      if (response.data['success'] == true) {
        final updatedReadings =
            state.readings.where((r) => r.id != readingId).toList();

        state = state.copyWith(
          readings: updatedReadings,
          selectedReading: state.selectedReading?.id == readingId
              ? null
              : state.selectedReading,
          showDetailView: state.selectedReading?.id == readingId
              ? false
              : state.showDetailView,
          isLoading: false,
        );

        _showToast('Meter reading deleted successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete reading');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to delete reading: ${e.toString()}', isError: true);
    }
  }

  // Verify reading
  Future<void> verifyReading(String readingId) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post(
        '/v1/nawassco/billing/meter_reading/readings/$readingId/verify',
      );

      if (response.data['success'] == true) {
        final updatedReading = MeterReading.fromJson(response.data['data']);

        final updatedReadings = state.readings.map((reading) {
          return reading.id == readingId ? updatedReading : reading;
        }).toList();

        state = state.copyWith(
          readings: updatedReadings,
          selectedReading: state.selectedReading?.id == readingId
              ? updatedReading
              : state.selectedReading,
          isLoading: false,
        );

        _showToast('Reading verified successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to verify reading');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to verify reading: ${e.toString()}', isError: true);
    }
  }

  // Reject reading
  Future<void> rejectReading(String readingId, String reason) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post(
        '/v1/nawassco/billing/meter_reading/readings/$readingId/reject',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        final updatedReading = MeterReading.fromJson(response.data['data']);

        final updatedReadings = state.readings.map((reading) {
          return reading.id == readingId ? updatedReading : reading;
        }).toList();

        state = state.copyWith(
          readings: updatedReadings,
          selectedReading: state.selectedReading?.id == readingId
              ? updatedReading
              : state.selectedReading,
          isLoading: false,
        );

        _showToast('Reading rejected successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to reject reading');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to reject reading: ${e.toString()}', isError: true);
    }
  }

  // Generate bill from reading
  Future<void> generateBill(String readingId) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.post(
        '/v1/nawassco/billing/meter_reading/readings/$readingId/generate-bill',
      );

      if (response.data['success'] == true) {
        final updatedReading = MeterReading.fromJson(response.data['data']);

        final updatedReadings = state.readings.map((reading) {
          return reading.id == readingId ? updatedReading : reading;
        }).toList();

        state = state.copyWith(
          readings: updatedReadings,
          selectedReading: state.selectedReading?.id == readingId
              ? updatedReading
              : state.selectedReading,
          isLoading: false,
        );

        _showToast('Bill generated successfully');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to generate bill');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to generate bill: ${e.toString()}', isError: true);
    }
  }

  // Get readings by meter number
  Future<void> getReadingsByMeter(String meterNumber) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.get(
        '/v1/nawassco/billing/meter_reading/readings/meter/$meterNumber',
      );

      if (response.data['success'] == true) {
        final readings = (response.data['data'] as List)
            .map((json) => MeterReading.fromJson(json))
            .toList();

        state = state.copyWith(
          readings: readings,
          filterMeterNumber: meterNumber,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load readings');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showToast('Failed to load readings: ${e.toString()}', isError: true);
    }
  }

  // UI State Management
  void selectReading(MeterReading reading) {
    state = state.copyWith(
      selectedReading: reading,
      showDetailView: true,
      showCreateForm: false,
    );
  }

  void showCreateForm() {
    state = state.copyWith(
      showCreateForm: true,
      showDetailView: false,
      selectedReading: null,
    );
  }

  void closeForms() {
    state = state.copyWith(
      showCreateForm: false,
      showDetailView: false,
      selectedReading: null,
    );
  }

  void setFilterMeterNumber(String meterNumber) {
    state = state.copyWith(filterMeterNumber: meterNumber);
  }

  void setFilterStatus(ReadingStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      filterStartDate: start,
      filterEndDate: end,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = state.copyWith(
      filterMeterNumber: '',
      filterStatus: null,
      filterStartDate: null,
      filterEndDate: null,
      searchQuery: '',
    );
  }
}

// Provider
final meterReadingProvider =
    StateNotifierProvider<MeterReadingProvider, MeterReadingState>((ref) {
  final dio = ref.read(dioProvider);
  return MeterReadingProvider(dio, scaffoldMessengerKey);
});
