import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../main.dart';
import '../models/department.dart';

import '../models/employee_model.dart';

class DepartmentState {
  final List<Department> departments;
  final Department? selectedDepartment;
  final bool isLoading;
  final bool isFormLoading;
  final String? error;
  final DepartmentStats? stats;
  final List<DepartmentHierarchy> hierarchy;
  final Map<String, dynamic>? filter;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final List<Employee> departmentEmployees;
  final bool isLoadingEmployees;

  DepartmentState({
    this.departments = const [],
    this.selectedDepartment,
    this.isLoading = false,
    this.isFormLoading = false,
    this.error,
    this.stats,
    this.hierarchy = const [],
    this.filter,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.departmentEmployees = const [],
    this.isLoadingEmployees = false,
  });

  DepartmentState copyWith({
    List<Department>? departments,
    Department? selectedDepartment,
    bool? isLoading,
    bool? isFormLoading,
    String? error,
    DepartmentStats? stats,
    List<DepartmentHierarchy>? hierarchy,
    Map<String, dynamic>? filter,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    List<Employee>? departmentEmployees,
    bool? isLoadingEmployees,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      isLoading: isLoading ?? this.isLoading,
      isFormLoading: isFormLoading ?? this.isFormLoading,
      error: error,
      stats: stats ?? this.stats,
      hierarchy: hierarchy ?? this.hierarchy,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      departmentEmployees: departmentEmployees ?? this.departmentEmployees,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
    );
  }
}

class DepartmentProvider extends StateNotifier<DepartmentState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  DepartmentProvider(this.dio, this.scaffoldMessengerKey)
      : super(DepartmentState());

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selection
  void clearSelection() {
    state = state.copyWith(selectedDepartment: null);
  }

  // Set filter
  void setFilter(Map<String, dynamic> filter) {
    state = state.copyWith(filter: filter, currentPage: 1);
    _loadDepartments();
  }

  // Clear filter
  void clearFilter() {
    state = state.copyWith(filter: null, currentPage: 1);
    _loadDepartments();
  }

  // Set page
  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    _loadDepartments();
  }

  // Load departments with pagination
  Future<void> _loadDepartments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, dynamic> queryParams = {
        'page': state.currentPage,
        'limit': 20,
      };

      // Add filter if exists
      if (state.filter != null) {
        queryParams.addAll(state.filter!);
      }

      final response = await dio.get('/v1/nawassco/human_resource/departments', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final result = response.data['data']['result'];
        final departments = (result['departments'] as List)
            .map((dept) => Department.fromJson(dept))
            .toList();

        final pagination = result['pagination'];

        state = state.copyWith(
          departments: departments,
          isLoading: false,
          totalPages: pagination['screens'] ?? 1,
          totalItems: pagination['total'] ?? 0,
        );
      } else {
        throw response.data['message'] ?? 'Failed to load departments';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Load department by ID
  Future<void> loadDepartment(String id) async {
    try {
      state = state.copyWith(isFormLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/departments/$id');

      if (response.data['success'] == true) {
        final department = Department.fromJson(response.data['data']['department']);
        state = state.copyWith(
          selectedDepartment: department,
          isFormLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Department not found';
      }
    } catch (e) {
      state = state.copyWith(
        isFormLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Create department
  Future<void> createDepartment(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isFormLoading: true, error: null);

      final response = await dio.post('/v1/nawassco/human_resource/departments', data: data);

      if (response.data['success'] == true) {
        final department = Department.fromJson(response.data['data']['department']);

        // Add to list
        final updatedDepartments = List<Department>.from(state.departments)
          ..add(department);

        state = state.copyWith(
          departments: updatedDepartments,
          selectedDepartment: department,
          isFormLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Department created successfully',
          key: scaffoldMessengerKey,
        );
      } else {
        throw response.data['message'] ?? 'Failed to create department';
      }
    } catch (e) {
      state = state.copyWith(
        isFormLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Update department
  Future<void> updateDepartment(String id, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isFormLoading: true, error: null);

      final response = await dio.put('/v1/nawassco/human_resource/departments/$id', data: data);

      if (response.data['success'] == true) {
        final updatedDepartment = Department.fromJson(response.data['data']['department']);

        // Update in list
        final updatedDepartments = state.departments.map((dept) =>
        dept.id == id ? updatedDepartment : dept
        ).toList();

        state = state.copyWith(
          departments: updatedDepartments,
          selectedDepartment: updatedDepartment,
          isFormLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Department updated successfully',
          key: scaffoldMessengerKey,
        );
      } else {
        throw response.data['message'] ?? 'Failed to update department';
      }
    } catch (e) {
      state = state.copyWith(
        isFormLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Delete department (soft delete)
  Future<void> deleteDepartment(String id, {String? deletedBy}) async {
    try {
      state = state.copyWith(isFormLoading: true, error: null);

      await dio.delete('/v1/nawassco/human_resource/departments/$id');

      // Remove from list
      final updatedDepartments = state.departments
          .where((dept) => dept.id != id)
          .toList();

      state = state.copyWith(
        departments: updatedDepartments,
        selectedDepartment: null,
        isFormLoading: false,
      );

      ToastUtils.showSuccessToast(
        'Department deleted successfully',
        key: scaffoldMessengerKey,
      );
    } catch (e) {
      state = state.copyWith(
        isFormLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Update department status
  Future<void> updateDepartmentStatus(
      String id,
      bool isActive,
      ) async {
    try {
      state = state.copyWith(isFormLoading: true, error: null);

      final response = await dio.patch('/v1/nawassco/human_resource/departments/$id/status', data: {
        'isActive': isActive,
      });

      if (response.data['success'] == true) {
        final updatedDepartment = Department.fromJson(response.data['data']['department']);

        // Update in list
        final updatedDepartments = state.departments.map((dept) =>
        dept.id == id ? updatedDepartment : dept
        ).toList();

        state = state.copyWith(
          departments: updatedDepartments,
          selectedDepartment: updatedDepartment,
          isFormLoading: false,
        );

        ToastUtils.showSuccessToast(
          'Department ${isActive ? 'activated' : 'deactivated'} successfully',
          key: scaffoldMessengerKey,
        );
      } else {
        throw response.data['message'] ?? 'Failed to update department status';
      }
    } catch (e) {
      state = state.copyWith(
        isFormLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Load department employees
  Future<void> loadDepartmentEmployees(String departmentId) async {
    try {
      state = state.copyWith(isLoadingEmployees: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/departments/$departmentId/employees');

      if (response.data['success'] == true) {
        final result = response.data['data']['result'];
        final employees = (result['employees'] as List)
            .map((emp) => Employee.fromJson(emp))
            .toList();

        state = state.copyWith(
          departmentEmployees: employees,
          isLoadingEmployees: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to load department employees';
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingEmployees: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Add employee to department
  Future<void> addEmployeeToDepartment(
      String departmentId,
      String employeeId,
      ) async {
    try {
      final response = await dio.post('/v1/nawassco/human_resource/departments/$departmentId/employees', data: {
        'employeeId': employeeId,
      });

      if (response.data['success'] == true) {
        // Refresh department employees
        await loadDepartmentEmployees(departmentId);

        ToastUtils.showSuccessToast(
          'Employee added to department successfully',
          key: scaffoldMessengerKey,
        );
      } else {
        throw response.data['message'] ?? 'Failed to add employee';
      }
    } catch (e) {
      _showError(e);
      rethrow;
    }
  }

  // Remove employee from department
  Future<void> removeEmployeeFromDepartment(
      String departmentId,
      String employeeId,
      ) async {
    try {
      final response = await dio.delete('/v1/nawassco/human_resource/departments/$departmentId/employees/$employeeId');

      if (response.data['success'] == true) {
        // Refresh department employees
        await loadDepartmentEmployees(departmentId);

        ToastUtils.showSuccessToast(
          'Employee removed from department successfully',
          key: scaffoldMessengerKey,
        );
      } else {
        throw response.data['message'] ?? 'Failed to remove employee';
      }
    } catch (e) {
      _showError(e);
      rethrow;
    }
  }

  // Get department statistics
  Future<void> loadDepartmentStatistics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/departments/stats');

      if (response.data['success'] == true) {
        final stats = DepartmentStats.fromJson(response.data['data']['stats']);
        state = state.copyWith(
          stats: stats,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to load statistics';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Load department hierarchy
  Future<void> loadDepartmentHierarchy() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/departments/hierarchy');

      if (response.data['success'] == true) {
        final hierarchy = (response.data['data']['hierarchy'] as List)
            .map((item) => DepartmentHierarchy.fromJson(item))
            .toList();

        state = state.copyWith(
          hierarchy: hierarchy,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Failed to load hierarchy';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Search departments
  Future<void> searchDepartments(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await dio.get('/v1/nawassco/human_resource/departments/search', queryParameters: {
        'query': query,
        'page': 1,
        'limit': 50,
      });

      if (response.data['success'] == true) {
        final result = response.data['data']['result'];
        final departments = (result['departments'] as List)
            .map((dept) => Department.fromJson(dept))
            .toList();

        state = state.copyWith(
          departments: departments,
          isLoading: false,
        );
      } else {
        throw response.data['message'] ?? 'Search failed';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _showError(e);
    }
  }

  // Get potential department heads
  Future<List<Map<String, dynamic>>> getPotentialDepartmentHeads() async {
    try {
      // First load all active employees
      final response = await dio.get('/v1/nawassco/human_resource/employees', queryParameters: {
        'page': 1,
        'limit': 100,
        'employmentStatus': 'active',
      });

      if (response.data['success'] == true) {
        final employees = (response.data['data']['result']['employees'] as List)
            .map((emp) => Employee.fromJson(emp))
            .toList();

        // Return employees as potential heads
        return employees.map((employee) => {
          'id': employee.id,
          'name': employee.fullName,
          'employeeNumber': employee.employeeNumber,
          'department': employee.department,
          'jobTitle': employee.jobTitle,
        }).toList();
      }
      return [];
    } catch (e) {
      _showError(e);
      return [];
    }
  }

  // Initial load
  Future<void> initialize() async {
    await Future.wait([
      _loadDepartments(),
      loadDepartmentStatistics(),
      loadDepartmentHierarchy(),
    ]);
  }

  // Error handler
  void _showError(dynamic error) {
    String errorMessage = 'An error occurred';

    if (error is DioException) {
      if (error.response?.data is Map) {
        errorMessage = error.response?.data['message'] ?? error.message ?? errorMessage;
      } else {
        errorMessage = error.message ?? errorMessage;
      }
    } else if (error is String) {
      errorMessage = error;
    }

    ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
  }
}

// Provider
final departmentProvider = StateNotifierProvider<DepartmentProvider, DepartmentState>((ref) {
  final dio = ref.read(dioProvider);
  return DepartmentProvider(dio, scaffoldMessengerKey);
});