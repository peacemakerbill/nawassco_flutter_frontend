import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' hide File;

import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/resource_model.dart';

final resourceProvider = StateNotifierProvider<ResourceProvider, ResourceState>((ref) {
  final dio = ref.watch(dioProvider);
  final authState = ref.watch(authProvider);
  return ResourceProvider(dio, authState);
});

class ResourceState {
  final List<Resource> resources;
  final List<Resource> filteredResources;
  final ResourceCategory? selectedCategory;
  final ResourceType? selectedType;
  final bool isLoading;
  final String? error;
  final Resource? selectedResource;
  final bool isUploading;
  final double uploadProgress;
  final String searchQuery;
  final bool showManagementView;

  ResourceState({
    this.resources = const [],
    this.filteredResources = const [],
    this.selectedCategory,
    this.selectedType,
    this.isLoading = false,
    this.error,
    this.selectedResource,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.searchQuery = '',
    this.showManagementView = false,
  });

  ResourceState copyWith({
    List<Resource>? resources,
    List<Resource>? filteredResources,
    ResourceCategory? selectedCategory,
    ResourceType? selectedType,
    bool? isLoading,
    String? error,
    Resource? selectedResource,
    bool? isUploading,
    double? uploadProgress,
    String? searchQuery,
    bool? showManagementView,
  }) {
    return ResourceState(
      resources: resources ?? this.resources,
      filteredResources: filteredResources ?? this.filteredResources,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedResource: selectedResource ?? this.selectedResource,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      searchQuery: searchQuery ?? this.searchQuery,
      showManagementView: showManagementView ?? this.showManagementView,
    );
  }
}

class ResourceProvider extends StateNotifier<ResourceState> {
  final Dio _dio;
  final AuthState _authState;

  ResourceProvider(this._dio, this._authState) : super(ResourceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadResources();
  }

  bool get canManageResources {
    return _authState.hasAnyRole([
      'Admin',
      'Manager',
      'SalesAgent',
      'Accounts',
      'HR',
      'Procurement',
      'Technician',
      'StoreManager',
    ]);
  }

  // ==================== CRUD OPERATIONS ====================

  Future<void> loadResources() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/resources', queryParameters: {
        'page': 1,
        'limit': 100,
        'status': 'published',
      });

      if (response.data['success'] == true) {
        final resources = List<Resource>.from(
          (response.data['data']['resources'] as List<dynamic>)
              .map((x) => Resource.fromMap(x)),
        );

        state = state.copyWith(
          resources: resources,
          filteredResources: _filterResources(resources),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load resources',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load resources: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> loadUserResources() async {
    if (!_authState.isAuthenticated) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/resources/my-uploads');

      if (response.data['success'] == true) {
        final resources = List<Resource>.from(
          (response.data['data']['resources'] as List<dynamic>)
              .map((x) => Resource.fromMap(x)),
        );

        state = state.copyWith(
          resources: resources,
          filteredResources: _filterResources(resources),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to load resources',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load resources: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<Resource?> createResource({
    required String title,
    required String description,
    required ResourceType resourceType,
    required ResourceCategory category,
    required List<PlatformFile> files,
    AccessLevel accessLevel = AccessLevel.public,
    List<String> allowedRoles = const [],
    List<String>? allowedServiceZones,
    List<String> tags = const [],
    List<String> keywords = const [],
    bool isFeatured = false,
    bool requiresAuth = false,
    int sortOrder = 0,
    String? metaTitle,
    String? metaDescription,
  }) async {
    try {
      state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);

      // Prepare form data
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('resourceType', resourceType.name),
        MapEntry('category', category.name),
        MapEntry('accessLevel', accessLevel.name),
        MapEntry('isFeatured', isFeatured.toString()),
        MapEntry('requiresAuth', requiresAuth.toString()),
        MapEntry('sortOrder', sortOrder.toString()),
      ]);

      if (allowedRoles.isNotEmpty) {
        formData.fields.add(MapEntry('allowedRoles', allowedRoles.join(',')));
      }

      if (allowedServiceZones != null && allowedServiceZones.isNotEmpty) {
        formData.fields.add(MapEntry('allowedServiceZones', allowedServiceZones.join(',')));
      }

      if (tags.isNotEmpty) {
        formData.fields.add(MapEntry('tags', tags.join(',')));
      }

      if (keywords.isNotEmpty) {
        formData.fields.add(MapEntry('keywords', keywords.join(',')));
      }

      if (metaTitle != null) {
        formData.fields.add(MapEntry('metaTitle', metaTitle));
      }

      if (metaDescription != null) {
        formData.fields.add(MapEntry('metaDescription', metaDescription));
      }

      // Add files
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ));
      }

      // Upload with progress tracking
      final response = await _dio.post(
        '/resources',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            state = state.copyWith(uploadProgress: progress);
          }
        },
      );

      state = state.copyWith(isUploading: false, uploadProgress: 0.0);

      if (response.data['success'] == true) {
        final resource = Resource.fromMap(response.data['data']);
        final updatedResources = [resource, ...state.resources];
        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
        );
        return resource;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to create resource',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        error: 'Failed to create resource: ${e.toString()}',
      );
      return null;
    }
  }

  Future<Resource?> updateResource({
    required String id,
    String? title,
    String? description,
    ResourceCategory? category,
    AccessLevel? accessLevel,
    List<String>? allowedRoles,
    List<String>? allowedServiceZones,
    List<String>? tags,
    List<String>? keywords,
    bool? isFeatured,
    bool? requiresAuth,
    int? sortOrder,
    String? metaTitle,
    String? metaDescription,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category.name;
      if (accessLevel != null) updateData['accessLevel'] = accessLevel.name;
      if (allowedRoles != null) updateData['allowedRoles'] = allowedRoles.join(',');
      if (allowedServiceZones != null) updateData['allowedServiceZones'] = allowedServiceZones.join(',');
      if (tags != null) updateData['tags'] = tags.join(',');
      if (keywords != null) updateData['keywords'] = keywords.join(',');
      if (isFeatured != null) updateData['isFeatured'] = isFeatured.toString();
      if (requiresAuth != null) updateData['requiresAuth'] = requiresAuth.toString();
      if (sortOrder != null) updateData['sortOrder'] = sortOrder.toString();
      if (metaTitle != null) updateData['metaTitle'] = metaTitle;
      if (metaDescription != null) updateData['metaDescription'] = metaDescription;

      final response = await _dio.put('/resources/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == id ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == id ? updatedResource : state.selectedResource,
          isLoading: false,
        );
        return updatedResource;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to update resource',
          isLoading: false,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update resource: ${e.toString()}',
        isLoading: false,
      );
      return null;
    }
  }

  Future<bool> deleteResource(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/resources/$id');

      if (response.data['success'] == true) {
        final updatedResources = state.resources.where((r) => r.id != id).toList();
        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == id ? null : state.selectedResource,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to delete resource',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete resource: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<Resource?> addFilesToResource({
    required String resourceId,
    required List<PlatformFile> files,
  }) async {
    try {
      state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);

      final formData = FormData();
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ));
      }

      final response = await _dio.post(
        '/resources/$resourceId/files',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            state = state.copyWith(uploadProgress: progress);
          }
        },
      );

      state = state.copyWith(isUploading: false, uploadProgress: 0.0);

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == resourceId ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == resourceId ? updatedResource : state.selectedResource,
        );
        return updatedResource;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to add files',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        error: 'Failed to add files: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool> removeFileFromResource({
    required String resourceId,
    required int fileIndex,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/resources/$resourceId/files/$fileIndex');

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == resourceId ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == resourceId ? updatedResource : state.selectedResource,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to remove file',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to remove file: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> setPrimaryFile({
    required String resourceId,
    required int fileIndex,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch('/resources/$resourceId/primary-file/$fileIndex');

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == resourceId ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == resourceId ? updatedResource : state.selectedResource,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to set primary file',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to set primary file: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> publishResource(String resourceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch('/resources/$resourceId/publish');

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == resourceId ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == resourceId ? updatedResource : state.selectedResource,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to publish resource',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to publish resource: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> archiveResource(String resourceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch('/resources/$resourceId/archive');

      if (response.data['success'] == true) {
        final updatedResource = Resource.fromMap(response.data['data']);
        final updatedResources = state.resources.map((r) => r.id == resourceId ? updatedResource : r).toList();

        state = state.copyWith(
          resources: updatedResources,
          filteredResources: _filterResources(updatedResources),
          selectedResource: state.selectedResource?.id == resourceId ? updatedResource : state.selectedResource,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.data['message'] ?? 'Failed to archive resource',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to archive resource: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // ==================== FILE DOWNLOAD & VIEW ====================

  Future<String?> downloadFile({
    required String resourceId,
    required int fileIndex,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    try {
      // Request storage permission for mobile
      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return null;
        }
      }

      final response = await _dio.get(
        '/resources/$resourceId/files/$fileIndex/download',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      if (kIsWeb) {
        // For web, create a download link
        final bytes = response.data as List<int>;
        final blob = Blob([bytes]);
        final url = Url.createObjectUrlFromBlob(blob);
        final anchor = AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        Url.revokeObjectUrl(url);
        return fileName;
      } else {
        // For mobile, save to downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) return null;

        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.data);
        return file.path;
      }
    } catch (e) {
      if (kDebugMode) print('Download error: $e');
      return null;
    }
  }

  Future<Uint8List?> previewFile({
    required String resourceId,
    required int fileIndex,
  }) async {
    try {
      final response = await _dio.get(
        '/resources/$resourceId/files/$fileIndex/preview',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as Uint8List;
    } catch (e) {
      if (kDebugMode) print('Preview error: $e');
      return null;
    }
  }

  // ==================== FILTERING & SEARCH ====================

  void selectCategory(ResourceCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      filteredResources: _filterResources(state.resources),
    );
  }

  void selectType(ResourceType? type) {
    state = state.copyWith(
      selectedType: type,
      filteredResources: _filterResources(state.resources),
    );
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredResources: _filterResources(state.resources),
    );
  }

  List<Resource> _filterResources(List<Resource> resources) {
    List<Resource> filtered = resources;

    // Filter by category
    if (state.selectedCategory != null) {
      filtered = filtered.where((r) => r.category == state.selectedCategory).toList();
    }

    // Filter by type
    if (state.selectedType != null) {
      filtered = filtered.where((r) => r.resourceType == state.selectedType).toList();
    }

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
      r.title.toLowerCase().contains(query) ||
          r.description?.toLowerCase().contains(query) == true ||
          r.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          r.keywords.any((keyword) => keyword.toLowerCase().contains(query)),
      ).toList();
    }

    // For management view, show all resources
    if (!state.showManagementView) {
      filtered = filtered.where((r) => r.isPublished && !r.isExpired).toList();
    }

    // Sort: featured first, then by sortOrder, then by date
    filtered.sort((a, b) {
      if (a.isFeatured != b.isFeatured) {
        return a.isFeatured ? -1 : 1;
      }
      if (a.sortOrder != b.sortOrder) {
        return b.sortOrder.compareTo(a.sortOrder);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  void selectResource(Resource? resource) {
    state = state.copyWith(selectedResource: resource);
  }

  void toggleManagementView() {
    final newState = !state.showManagementView;
    state = state.copyWith(showManagementView: newState);

    if (newState) {
      loadUserResources();
    } else {
      loadResources();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearFilters() {
    state = state.copyWith(
      selectedCategory: null,
      selectedType: null,
      searchQuery: '',
      filteredResources: _filterResources(state.resources),
    );
  }

  List<Resource> get resourcesByCategory {
    final Map<ResourceCategory, List<Resource>> categorized = {};

    for (final resource in state.filteredResources) {
      categorized.putIfAbsent(resource.category, () => []);
      categorized[resource.category]!.add(resource);
    }

    return categorized.entries
        .expand((entry) => entry.value)
        .toList();
  }
}