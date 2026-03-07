import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/training.model.dart';
import 'employee_provider.dart';

// State
class TrainingState {
  final List<Training> trainings;
  final Training? selectedTraining;
  final List<Training> myTrainings;
  final TrainingStatistics? statistics;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isRegistering;
  final String? error;
  final String? success;
  final String searchQuery;
  final TrainingType? selectedType;
  final TrainingCategory? selectedCategory;
  final TrainingStatus? selectedStatus;
  final int currentPage;
  final bool hasMore;
  final ViewMode viewMode;

  TrainingState({
    this.trainings = const [],
    this.selectedTraining,
    this.myTrainings = const [],
    this.statistics,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isRegistering = false,
    this.error,
    this.success,
    this.searchQuery = '',
    this.selectedType,
    this.selectedCategory,
    this.selectedStatus,
    this.currentPage = 1,
    this.hasMore = true,
    this.viewMode = ViewMode.list,
  });

  TrainingState copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    List<Training>? myTrainings,
    TrainingStatistics? statistics,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isRegistering,
    String? error,
    String? success,
    String? searchQuery,
    TrainingType? selectedType,
    TrainingCategory? selectedCategory,
    TrainingStatus? selectedStatus,
    int? currentPage,
    bool? hasMore,
    ViewMode? viewMode,
  }) {
    return TrainingState(
      trainings: trainings ?? this.trainings,
      selectedTraining: selectedTraining ?? this.selectedTraining,
      myTrainings: myTrainings ?? this.myTrainings,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isRegistering: isRegistering ?? this.isRegistering,
      error: error,
      success: success,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

enum ViewMode { list, calendar, stats }

// Provider
class TrainingProvider extends StateNotifier<TrainingState> {
  final Ref ref;
  final Dio dio;
  final ImagePicker _imagePicker = ImagePicker();

  TrainingProvider(this.ref, this.dio) : super(TrainingState());

  bool get canManageTrainings {
    final authState = ref.read(authProvider);
    return authState.isAdmin || authState.isHR || authState.isManager;
  }

  String? get currentEmployeeId {
    final employee = ref.read(employeeProvider).currentEmployee;
    return employee?.id;
  }

  // Load trainings
  Future<void> loadTrainings({bool loadMore = false}) async {
    if (!loadMore) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
      );
    }

    try {
      final page = loadMore ? state.currentPage + 1 : 1;

      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': 20,
      };

      // Filters — UPDATED
      if (state.searchQuery.isNotEmpty) {
        queryParams['search'] = state.searchQuery;
      }
      if (state.selectedType != null) {
        queryParams['trainingType'] = state.selectedType!.name;
      }
      if (state.selectedCategory != null) {
        queryParams['category'] = state.selectedCategory!.name;
      }
      if (state.selectedStatus != null) {
        queryParams['status'] = state.selectedStatus!.name;
      }

      final response =
          await dio.get('/v1/nawassco/human_resource/trainings', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<dynamic> trainingData =
            response.data['data']['result']['trainings'] ?? [];
        final trainings =
            trainingData.map((t) => Training.fromJson(t)).toList();

        final employeeId = currentEmployeeId;
        final trainingsWithRegistration = trainings.map((training) {
          final isRegistered =
              training.participants.any((p) => p.employeeId == employeeId);
          return training.copyWith(isRegistered: isRegistered);
        }).toList();

        final total =
            response.data['data']['result']['pagination']['total'] ?? 0;
        final hasMore = trainings.length < total;

        state = state.copyWith(
          trainings: loadMore
              ? [...state.trainings, ...trainingsWithRegistration]
              : trainingsWithRegistration,
          isLoading: false,
          currentPage: page,
          hasMore: hasMore,
          error: null,
        );

        if (employeeId != null) {
          await _loadMyTrainings(employeeId);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to load trainings',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading trainings: ${e.toString()}',
      );
    }
  }

  Future<void> _loadMyTrainings(String employeeId) async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/trainings/employee/$employeeId/history');

      if (response.data['success'] == true) {
        final List<dynamic> trainingData =
            response.data['data']['history']['trainings'] ?? [];
        final myTrainings =
            trainingData.map((t) => Training.fromJson(t)).toList();

        state = state.copyWith(myTrainings: myTrainings);
      }
    } catch (e) {
      print('Error loading my trainings: $e');
    }
  }

  // Get training by ID
  Future<Training?> getTrainingById(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await dio.get('/v1/nawassco/human_resource/trainings/$id');

      if (response.data['success'] == true) {
        final training = Training.fromJson(response.data['data']['training']);
        final employeeId = currentEmployeeId;
        final isRegistered =
            training.participants.any((p) => p.employeeId == employeeId);
        final trainingWithRegistration =
            training.copyWith(isRegistered: isRegistered);

        state = state.copyWith(
          selectedTraining: trainingWithRegistration,
          isLoading: false,
        );
        return trainingWithRegistration;
      }
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading training: ${e.toString()}',
      );
      return null;
    }
  }

  // Create
  Future<bool> createTraining(Map<String, dynamic> data) async {
    state = state.copyWith(isCreating: true, error: null, success: null);

    try {
      final response = await dio.post('/v1/nawassco/human_resource/trainings', data: data);

      if (response.data['success'] == true) {
        final newTraining =
            Training.fromJson(response.data['data']['training']);

        state = state.copyWith(
          isCreating: false,
          success: 'Training created successfully',
          trainings: [newTraining, ...state.trainings],
          selectedTraining: newTraining,
        );
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.data['message'] ?? 'Failed to create training',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Error creating training: ${e.toString()}',
      );
      return false;
    }
  }

  // Update
  Future<bool> updateTraining(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, error: null, success: null);

    try {
      final response = await dio.put('/v1/nawassco/human_resource/trainings/$id', data: data);

      if (response.data['success'] == true) {
        final updatedTraining =
            Training.fromJson(response.data['data']['training']);

        final updatedTrainings = state.trainings
            .map((t) => t.id == id ? updatedTraining : t)
            .toList();

        final updatedMyTrainings = state.myTrainings
            .map((t) => t.id == id ? updatedTraining : t)
            .toList();

        state = state.copyWith(
          isUpdating: false,
          success: 'Training updated successfully',
          trainings: updatedTrainings,
          myTrainings: updatedMyTrainings,
          selectedTraining: state.selectedTraining?.id == id
              ? updatedTraining
              : state.selectedTraining,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'Failed to update training',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error updating training: ${e.toString()}',
      );
      return false;
    }
  }

  // Delete
  Future<bool> deleteTraining(String id) async {
    try {
      final response = await dio.delete('/v1/nawassco/human_resource/trainings/$id');

      if (response.data['success'] == true) {
        final updatedTrainings =
            state.trainings.where((t) => t.id != id).toList();
        final updatedMyTrainings =
            state.myTrainings.where((t) => t.id != id).toList();

        state = state.copyWith(
          trainings: updatedTrainings,
          myTrainings: updatedMyTrainings,
          selectedTraining:
              state.selectedTraining?.id == id ? null : state.selectedTraining,
          success: 'Training deleted successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete training',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error deleting training: ${e.toString()}',
      );
      return false;
    }
  }

  // Register
  Future<bool> registerForTraining(String trainingId) async {
    final employeeId = currentEmployeeId;
    if (employeeId == null) {
      state = state.copyWith(error: 'No employee profile found');
      return false;
    }

    state = state.copyWith(isRegistering: true, error: null, success: null);

    try {
      final response =
          await dio.post('/v1/nawassco/human_resource/trainings/$trainingId/participants', data: {
        'employeeId': employeeId,
      });

      if (response.data['success'] == true) {
        await getTrainingById(trainingId);
        await loadTrainings();

        state = state.copyWith(
          isRegistering: false,
          success: 'Successfully registered for training',
        );
        return true;
      } else {
        state = state.copyWith(
          isRegistering: false,
          error: response.data['message'] ?? 'Failed to register for training',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        error: 'Error registering for training: ${e.toString()}',
      );
      return false;
    }
  }

  // Update participant
  Future<bool> updateParticipantStatus(
      String trainingId, String employeeId, String status,
      {String? feedback, double? preScore, double? postScore}) async {
    try {
      final data = {
        'employeeId': employeeId,
        'status': status,
        if (feedback != null) 'feedback': feedback,
        if (preScore != null || postScore != null)
          'scores': {
            if (preScore != null) 'preTrainingScore': preScore,
            if (postScore != null) 'postTrainingScore': postScore,
          },
      };

      final response =
          await dio.patch('/v1/nawassco/human_resource/trainings/$trainingId/participants', data: data);

      if (response.data['success'] == true) {
        await getTrainingById(trainingId);
        state = state.copyWith(success: 'Participant status updated');
        return true;
      }
      return false;
    } catch (e) {
      state =
          state.copyWith(error: 'Error updating participant: ${e.toString()}');
      return false;
    }
  }

  // Upload material
  Future<bool> uploadMaterial(String trainingId, XFile file) async {
    try {
      final formData = FormData.fromMap({
        'material':
            await MultipartFile.fromFile(file.path, filename: file.name),
      });

      final response =
          await dio.post('/v1/nawassco/human_resource/trainings/$trainingId/materials', data: formData);

      if (response.data['success'] == true) {
        await getTrainingById(trainingId);
        state = state.copyWith(success: 'Material uploaded successfully');
        return true;
      }
      return false;
    } catch (e) {
      state =
          state.copyWith(error: 'Error uploading material: ${e.toString()}');
      return false;
    }
  }

  // Upload certificate
  Future<bool> uploadCertificate(
      String trainingId, String employeeId, XFile file) async {
    try {
      final formData = FormData.fromMap({
        'employeeId': employeeId,
        'certificate':
            await MultipartFile.fromFile(file.path, filename: file.name),
      });

      final response =
          await dio.post('/v1/nawassco/human_resource/trainings/$trainingId/certificates', data: formData);

      if (response.data['success'] == true) {
        await getTrainingById(trainingId);
        state = state.copyWith(success: 'Certificate uploaded successfully');
        return true;
      }
      return false;
    } catch (e) {
      state =
          state.copyWith(error: 'Error uploading certificate: ${e.toString()}');
      return false;
    }
  }

  // Evaluate
  Future<bool> evaluateTraining(
      String trainingId, List<Map<String, dynamic>> criteria) async {
    try {
      final response = await dio.post('/v1/nawassco/human_resource/trainings/$trainingId/evaluate', data: {
        'evaluationData': {'criteria': criteria},
      });

      if (response.data['success'] == true) {
        await getTrainingById(trainingId);
        state = state.copyWith(success: 'Training evaluated successfully');
        return true;
      }
      return false;
    } catch (e) {
      state =
          state.copyWith(error: 'Error evaluating training: ${e.toString()}');
      return false;
    }
  }

  // Stats
  Future<void> loadStatistics() async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/trainings/stats');

      if (response.data['success'] == true) {
        final stats =
            TrainingStatistics.fromJson(response.data['data']['stats']);
        state = state.copyWith(statistics: stats);
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Filtering
  void filterTrainings({
    String? searchQuery,
    TrainingType? type,
    TrainingCategory? category,
    TrainingStatus? status,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      selectedType: type ?? state.selectedType,
      selectedCategory: category ?? state.selectedCategory,
      selectedStatus: status ?? state.selectedStatus,
    );

    loadTrainings();
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedType: null,
      selectedCategory: null,
      selectedStatus: null,
    );

    loadTrainings();
  }

  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);

    if (mode == ViewMode.stats && state.statistics == null) {
      loadStatistics();
    }
  }

  void selectTraining(Training? training) {
    state = state.copyWith(selectedTraining: training);
  }

  void clearMessages() {
    state = state.copyWith(error: null, success: null);
  }

  List<Training> get filteredTrainings {
    return state.trainings;
  }
}

// Provider
final trainingProvider =
    StateNotifierProvider<TrainingProvider, TrainingState>((ref) {
  final dio = ref.read(dioProvider);
  return TrainingProvider(ref, dio);
});
