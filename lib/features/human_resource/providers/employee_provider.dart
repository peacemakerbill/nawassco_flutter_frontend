import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/employee_model.dart';

class EmployeeState {
  final List<Employee> employees;
  final Employee? currentEmployee;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final String? error;
  final String? success;
  final List<Employee> filteredEmployees;
  final String searchQuery;
  final String selectedDepartment;
  final String selectedStatus;
  final int currentPage;
  final bool hasMore;

  EmployeeState({
    this.employees = const [],
    this.currentEmployee,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.error,
    this.success,
    List<Employee>? filteredEmployees,
    this.searchQuery = '',
    this.selectedDepartment = 'All',
    this.selectedStatus = 'All',
    this.currentPage = 1,
    this.hasMore = true,
  }) : filteredEmployees = filteredEmployees ?? employees;

  EmployeeState copyWith({
    List<Employee>? employees,
    Employee? currentEmployee,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    String? error,
    String? success,
    List<Employee>? filteredEmployees,
    String? searchQuery,
    String? selectedDepartment,
    String? selectedStatus,
    int? currentPage,
    bool? hasMore,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      currentEmployee: currentEmployee ?? this.currentEmployee,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      success: success,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class EmployeeProvider extends StateNotifier<EmployeeState> {
  final Ref ref;
  final Dio dio;
  final ImagePicker _imagePicker = ImagePicker();

  EmployeeProvider(this.ref, this.dio) : super(EmployeeState()) {
    _loadMyEmployeeProfile();
  }

  // Load current user's employee profile
  Future<void> _loadMyEmployeeProfile() async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/employees/my-profile');
      if (response.data['success'] == true && response.data['data'] != null) {
        final employee = Employee.fromJson(response.data['data']);
        state = state.copyWith(currentEmployee: employee);
      }
    } catch (e) {
      print('No employee profile found or error loading: $e');
    }
  }

  // Load all employees (for HR/Admin/Manager)
  Future<void> loadEmployees({bool loadMore = false}) async {
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

      if (state.searchQuery.isNotEmpty) {
        queryParams['search'] = state.searchQuery;
      }
      if (state.selectedDepartment != 'All') {
        queryParams['department'] = state.selectedDepartment;
      }
      if (state.selectedStatus != 'All') {
        queryParams['employmentStatus'] = state.selectedStatus.toLowerCase();
      }

      final response =
          await dio.get('/v1/nawassco/human_resource/employees', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final List<dynamic> employeeData =
            response.data['data']['result']['employees'] ?? [];
        final employees =
            employeeData.map((e) => Employee.fromJson(e)).toList();

        final total =
            response.data['data']['result']['pagination']['total'] ?? 0;
        final hasMore = employees.length < total;

        state = state.copyWith(
          employees: loadMore ? [...state.employees, ...employees] : employees,
          filteredEmployees:
              loadMore ? [...state.employees, ...employees] : employees,
          isLoading: false,
          currentPage: page,
          hasMore: hasMore,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to load employees',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading employees: ${e.toString()}',
      );
    }
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String id) async {
    try {
      final response = await dio.get('/v1/nawassco/human_resource/employees/$id');
      if (response.data['success'] == true) {
        return Employee.fromJson(response.data['data']['employee']);
      }
      return null;
    } catch (e) {
      print('Error getting employee: $e');
      return null;
    }
  }

  // Create employee
  Future<bool> createEmployee(Map<String, dynamic> data,
      {List<XFile>? documents}) async {
    state = state.copyWith(isCreating: true, error: null, success: null);

    try {
      // Create FormData for multipart request
      final formData = FormData.fromMap(data);

      // Add documents if any
      if (documents != null && documents.isNotEmpty) {
        for (var doc in documents) {
          formData.files.add(MapEntry(
            'documents',
            await MultipartFile.fromFile(doc.path, filename: doc.name),
          ));
        }
      }

      final response = await dio.post('/v1/nawassco/human_resource/employees', data: formData);

      if (response.data['success'] == true) {
        final newEmployee =
            Employee.fromJson(response.data['data']['employee']);

        state = state.copyWith(
          isCreating: false,
          success: 'Employee created successfully',
          employees: [newEmployee, ...state.employees],
          filteredEmployees: [newEmployee, ...state.filteredEmployees],
        );

        // Refresh list
        await loadEmployees();
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.data['message'] ?? 'Failed to create employee',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Error creating employee: ${e.toString()}',
      );
      return false;
    }
  }

  // Update employee
  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, error: null, success: null);

    try {
      final response = await dio.put('/v1/nawassco/human_resource/employees/$id', data: data);

      if (response.data['success'] == true) {
        final updatedEmployee =
            Employee.fromJson(response.data['data']['employee']);

        // Update in list
        final updatedEmployees = state.employees
            .map((e) => e.id == id ? updatedEmployee : e)
            .toList();

        state = state.copyWith(
          isUpdating: false,
          success: 'Employee updated successfully',
          employees: updatedEmployees,
          filteredEmployees: updatedEmployees,
          currentEmployee: state.currentEmployee?.id == id
              ? updatedEmployee
              : state.currentEmployee,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'Failed to update employee',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error updating employee: ${e.toString()}',
      );
      return false;
    }
  }

  // Delete employee (soft delete)
  Future<bool> deleteEmployee(String id) async {
    try {
      final response = await dio.delete('/v1/nawassco/human_resource/employees/$id');

      if (response.data['success'] == true) {
        // Remove from lists
        final updatedEmployees =
            state.employees.where((e) => e.id != id).toList();

        state = state.copyWith(
          employees: updatedEmployees,
          filteredEmployees: updatedEmployees,
          success: 'Employee deleted successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete employee',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error deleting employee: ${e.toString()}',
      );
      return false;
    }
  }

  // Update employment status
  Future<bool> updateEmploymentStatus(
      String id, String status, String reason) async {
    try {
      final response = await dio.patch('/v1/nawassco/human_resource/employees/$id/status', data: {
        'status': status,
        'reason': reason,
      });

      if (response.data['success'] == true) {
        await loadEmployees(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  // Upload document
  Future<bool> uploadDocument(
      String employeeId, XFile file, String documentType) async {
    try {
      final formData = FormData.fromMap({
        'documentType': documentType,
        'document':
            await MultipartFile.fromFile(file.path, filename: file.name),
      });

      final response =
          await dio.post('/v1/nawassco/human_resource/employees/$employeeId/documents', data: formData);

      if (response.data['success'] == true) {
        // Refresh employee data
        if (employeeId == state.currentEmployee?.id) {
          await _loadMyEmployeeProfile();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error uploading document: $e');
      return false;
    }
  }

  // Filter and search
  void filterEmployees({
    String? searchQuery,
    String? department,
    String? status,
  }) {
    String query = searchQuery ?? state.searchQuery;
    String dept = department ?? state.selectedDepartment;
    String empStatus = status ?? state.selectedStatus;

    List<Employee> filtered = state.employees.where((employee) {
      bool matchesSearch = query.isEmpty ||
          employee.fullName.toLowerCase().contains(query.toLowerCase()) ||
          employee.employeeNumber.toLowerCase().contains(query.toLowerCase()) ||
          employee.personalEmail.toLowerCase().contains(query.toLowerCase());

      bool matchesDepartment = dept == 'All' || employee.department == dept;
      bool matchesStatus = empStatus == 'All' ||
          employee.employmentStatus
              .toString()
              .contains(empStatus.toLowerCase());

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();

    state = state.copyWith(
      filteredEmployees: filtered,
      searchQuery: query,
      selectedDepartment: dept,
      selectedStatus: empStatus,
    );
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedDepartment: 'All',
      selectedStatus: 'All',
      filteredEmployees: state.employees,
    );
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, success: null);
  }

  // Check if current user can manage employees
  bool get canManageEmployees {
    final authState = ref.read(authProvider);
    return authState.isAdmin || authState.isHR || authState.isManager;
  }

  // Get departments for filter
  List<String> get departments {
    final Set<String> depts = {'All'};
    for (var employee in state.employees) {
      depts.add(employee.department);
    }
    return depts.toList();
  }

  // Get statuses for filter
  List<String> get statuses {
    return ['All', 'Active', 'On Leave', 'Suspended', 'Terminated', 'Retired'];
  }
}

// Provider
final employeeProvider =
    StateNotifierProvider<EmployeeProvider, EmployeeState>((ref) {
  final dio = ref.read(dioProvider);
  return EmployeeProvider(ref, dio);
});
