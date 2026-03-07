import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';
import '../models/tool.dart';

class ToolState {
  final List<Tool> tools;
  final Tool? selectedTool;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final ToolType? typeFilter;
  final ToolStatus? statusFilter;
  final String? locationFilter;
  final Map<String, dynamic> metrics;

  const ToolState({
    this.tools = const [],
    this.selectedTool,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.typeFilter,
    this.statusFilter,
    this.locationFilter,
    this.metrics = const {},
  });

  ToolState copyWith({
    List<Tool>? tools,
    Tool? selectedTool,
    bool? isLoading,
    String? error,
    String? searchQuery,
    ToolType? typeFilter,
    ToolStatus? statusFilter,
    String? locationFilter,
    Map<String, dynamic>? metrics,
  }) {
    return ToolState(
      tools: tools ?? this.tools,
      selectedTool: selectedTool ?? this.selectedTool,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      locationFilter: locationFilter ?? this.locationFilter,
      metrics: metrics ?? this.metrics,
    );
  }

  List<Tool> get filteredTools {
    var filtered = tools.where((tool) => tool.isActive).toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((tool) =>
      tool.toolCode.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tool.toolName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tool.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tool.serialNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tool.toolModel.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Apply type filter
    if (typeFilter != null) {
      filtered = filtered.where((tool) => tool.toolType == typeFilter).toList();
    }

    // Apply status filter
    if (statusFilter != null) {
      filtered = filtered.where((tool) => tool.currentStatus == statusFilter).toList();
    }

    // Apply location filter
    if (locationFilter != null && locationFilter!.isNotEmpty) {
      filtered = filtered.where((tool) =>
          tool.currentLocation.toLowerCase().contains(locationFilter!.toLowerCase())).toList();
    }

    return filtered;
  }

  List<Tool> get toolsNeedingMaintenance {
    return tools.where((tool) => tool.needsMaintenanceSoon).toList();
  }

  List<Tool> get toolsNeedingCalibration {
    return tools.where((tool) => tool.needsCalibrationSoon).toList();
  }
}

class ToolProvider extends StateNotifier<ToolState> {
  final Dio dio;

  ToolProvider(this.dio) : super(const ToolState());

  // Load all tools
  Future<void> loadTools() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.get('/v1/nawassco/field_technician/tools');

      if (response.data['success'] == true) {
        final List<Tool> tools = (response.data['data']['tools'] as List)
            .map((toolData) => Tool.fromJson(toolData))
            .toList();

        state = state.copyWith(
          tools: tools,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load tools',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load tools: $e',
        isLoading: false,
      );
    }
  }

  // Load tool metrics
  Future<void> loadToolMetrics() async {
    try {
      final response = await dio.get('/v1/nawassco/field_technician/tools/metrics');

      if (response.data['success'] == true) {
        state = state.copyWith(
          metrics: response.data['data']['metrics'] ?? {},
        );
      }
    } catch (e) {
      print('Failed to load tool metrics: $e');
    }
  }

  // Create tool
  Future<bool> createTool(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.post('/v1/nawassco/field_technician/tools', data: data);

      if (response.data['success'] == true) {
        final tool = Tool.fromJson(response.data['data']['tool']);
        state = state.copyWith(
          tools: [...state.tools, tool],
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create tool',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create tool: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update tool
  Future<bool> updateTool(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.put('/v1/nawassco/field_technician/tools/$id', data: data);

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == id ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == id ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update tool',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update tool: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete tool (soft delete)
  Future<bool> deleteTool(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.delete('/v1/nawassco/field_technician/tools/$id');

      if (response.data['success'] == true) {
        final updatedTools = state.tools.where((tool) => tool.id != id).toList();
        final selectedTool = state.selectedTool?.id == id ? null : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete tool',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete tool: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Assign tool to technician
  Future<bool> assignTool(String toolId, String technicianId, String condition, {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.patch('/v1/nawassco/field_technician/tools/$toolId/assign', data: {
        'technicianId': technicianId,
        'condition': condition,
        'notes': notes,
      });

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == toolId ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == toolId ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to assign tool',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to assign tool: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Return tool
  Future<bool> returnTool(String toolId, String condition, bool maintenanceRequired, {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.patch('/v1/nawassco/field_technician/tools/$toolId/return', data: {
        'condition': condition,
        'maintenanceRequired': maintenanceRequired,
        'notes': notes,
      });

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == toolId ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == toolId ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to return tool',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to return tool: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Record service
  Future<bool> recordService(String toolId, Map<String, dynamic> serviceData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.patch('/v1/nawassco/field_technician/tools/$toolId/service', data: serviceData);

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == toolId ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == toolId ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to record service',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to record service: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Record calibration
  Future<bool> recordCalibration(String toolId, Map<String, dynamic> calibrationData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.patch('/v1/nawassco/field_technician/tools/$toolId/calibration', data: calibrationData);

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == toolId ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == toolId ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to record calibration',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to record calibration: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Update usage
  Future<bool> updateUsage(String toolId, double usageHours) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await dio.patch('/v1/nawassco/field_technician/tools/$toolId/usage', data: {
        'usageHours': usageHours,
      });

      if (response.data['success'] == true) {
        final updatedTool = Tool.fromJson(response.data['data']['tool']);
        final updatedTools = state.tools.map((tool) =>
        tool.id == toolId ? updatedTool : tool).toList();

        final selectedTool = state.selectedTool?.id == toolId ? updatedTool : state.selectedTool;

        state = state.copyWith(
          tools: updatedTools,
          selectedTool: selectedTool,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update usage',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update usage: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Search tools
  Future<void> searchTools(String query) async {
    state = state.copyWith(searchQuery: query);
  }

  // Set filters
  void setTypeFilter(ToolType? type) {
    state = state.copyWith(typeFilter: type);
  }

  void setStatusFilter(ToolStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void setLocationFilter(String? location) {
    state = state.copyWith(locationFilter: location);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      typeFilter: null,
      statusFilter: null,
      locationFilter: null,
    );
  }

  // Select tool
  void selectTool(Tool? tool) {
    state = state.copyWith(selectedTool: tool);
  }
}

// Provider
final toolProvider = StateNotifierProvider<ToolProvider, ToolState>((ref) {
  final dio = ref.read(dioProvider);
  return ToolProvider(dio);
});