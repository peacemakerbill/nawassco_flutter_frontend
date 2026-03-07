import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../main.dart';
import '../models/field_service_report_model.dart';

class FieldServiceReportState {
  final List<FieldServiceReport> reports;
  final FieldServiceReport? selectedReport;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filters;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool isCreating;
  final bool isUpdating;
  final List<String> uploadingFiles;
  final Map<String, dynamic>? reportMetrics;
  final PdfViewerController? pdfViewerController;

  const FieldServiceReportState({
    this.reports = const [],
    this.selectedReport,
    this.isLoading = false,
    this.error,
    this.filters = const {},
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.uploadingFiles = const [],
    this.reportMetrics,
    this.pdfViewerController,
  });

  FieldServiceReportState copyWith({
    List<FieldServiceReport>? reports,
    FieldServiceReport? selectedReport,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? isCreating,
    bool? isUpdating,
    List<String>? uploadingFiles,
    Map<String, dynamic>? reportMetrics,
    PdfViewerController? pdfViewerController,
  }) {
    return FieldServiceReportState(
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      uploadingFiles: uploadingFiles ?? this.uploadingFiles,
      reportMetrics: reportMetrics ?? this.reportMetrics,
      pdfViewerController: pdfViewerController ?? this.pdfViewerController,
    );
  }
}

class FieldServiceReportProvider
    extends StateNotifier<FieldServiceReportState> {
  final Dio _dio;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final ImagePicker _imagePicker = ImagePicker();

  FieldServiceReportProvider(this._dio, this._scaffoldMessengerKey)
      : super(const FieldServiceReportState());

  // ============ CORE CRUD OPERATIONS ============

  Future<void> getFieldServiceReports({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: page,
      );

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
        ...state.filters,
      };

      final response = await _dio.get('/v1/nawassco/field_technician/field-service-reports',
          queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final resultData = data['result'] ?? data;
        final reportsData = resultData['reports'] as List? ?? [];
        final pagination = resultData['pagination'] ?? {};

        final reports = reportsData
            .map((report) => FieldServiceReport.fromJson(report))
            .toList();

        final newReports = loadMore ? [...state.reports, ...reports] : reports;

        state = state.copyWith(
          reports: newReports,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) <
              (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load reports');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load field service reports: $error');
    }
  }

  Future<void> getFieldServiceReportById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/field-service-reports/$id');

      if (response.data['success'] == true) {
        final reportData = response.data['data']['report'];
        final report = FieldServiceReport.fromJson(reportData);

        state = state.copyWith(
          selectedReport: report,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load report');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load field service report: $error');
    }
  }

  Future<FieldServiceReport?> createFieldServiceReport(
      Map<String, dynamic> reportData) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final response =
          await _dio.post('/v1/nawassco/field_technician/field-service-reports', data: reportData);

      if (response.data['success'] == true) {
        final newReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        state = state.copyWith(
          reports: [newReport, ...state.reports],
          selectedReport: newReport,
          isCreating: false,
        );

        _showSuccess('Field service report created successfully');
        return newReport;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create report');
      }
    } catch (error) {
      state = state.copyWith(
        isCreating: false,
        error: error.toString(),
      );
      _showError('Failed to create field service report: $error');
      return null;
    }
  }

  Future<bool> updateFieldServiceReport(
      String id, Map<String, dynamic> updateData) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final response =
          await _dio.put('/v1/nawassco/field_technician/field-service-reports/$id', data: updateData);

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == id ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == id
              ? updatedReport
              : state.selectedReport,
          isUpdating: false,
        );

        _showSuccess('Field service report updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update report');
      }
    } catch (error) {
      state = state.copyWith(
        isUpdating: false,
        error: error.toString(),
      );
      _showError('Failed to update field service report: $error');
      return false;
    }
  }

  Future<bool> deleteFieldServiceReport(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.delete('/v1/nawassco/field_technician/field-service-reports/$id');

      if (response.data['success'] == true) {
        final updatedReports =
            state.reports.where((report) => report.id != id).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport:
              state.selectedReport?.id == id ? null : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Field service report deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete report');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to delete field service report: $error');
      return false;
    }
  }

  // ============ WORKFLOW OPERATIONS ============

  Future<bool> submitForApproval(String reportId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.patch('/v1/nawassco/field_technician/field-service-reports/$reportId/submit');

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Report submitted for approval successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to submit for approval');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to submit report for approval: $error');
      return false;
    }
  }

  Future<bool> approveReport(String reportId,
      {Map<String, dynamic>? qualityCheck}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/approve',
        data: qualityCheck != null ? {'qualityCheck': qualityCheck} : null,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Report approved successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to approve report');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to approve report: $error');
      return false;
    }
  }

  Future<bool> rejectReport(String reportId, {String? comments}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/reject',
        data: comments != null ? {'comments': comments} : null,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Report rejected successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to reject report');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to reject report: $error');
      return false;
    }
  }

  // ============ ATTACHMENT OPERATIONS ============

  Future<bool> uploadSiteImages(String reportId, List<String> imageUrls) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/site-images',
        data: {'images': imageUrls},
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Site images uploaded successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload images');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to upload site images: $error');
      return false;
    }
  }

  Future<bool> uploadCustomerSignature(
      String reportId, String signatureUrl) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/customer-signature',
        data: {'signature': signatureUrl},
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Customer signature uploaded successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to upload signature');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to upload customer signature: $error');
      return false;
    }
  }

  Future<bool> uploadPhotos(
      String reportId, String photoType, List<String> photoUrls) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.post(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/photos',
        data: {
          'photoType': photoType,
          'photos': photoUrls,
        },
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('$photoType photos uploaded successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload photos');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to upload photos: $error');
      return false;
    }
  }

  // ============ CONTENT OPERATIONS ============

  Future<bool> addTaskCompletion(
      String reportId, Map<String, dynamic> taskData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/tasks',
        data: taskData,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Task completion added successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add task');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to add task completion: $error');
      return false;
    }
  }

  Future<bool> recordMaterialUsage(
      String reportId, Map<String, dynamic> materialData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/materials',
        data: materialData,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Material usage recorded successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to record material usage');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to record material usage: $error');
      return false;
    }
  }

  Future<bool> addMeasurement(
      String reportId, Map<String, dynamic> measurementData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/measurements',
        data: measurementData,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Measurement added successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to add measurement');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to add measurement: $error');
      return false;
    }
  }

  Future<bool> addSafetyObservation(String reportId, String observation) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/safety-observations',
        data: {'observation': observation},
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Safety observation added successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to add safety observation');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to add safety observation: $error');
      return false;
    }
  }

  Future<bool> recordIncident(
      String reportId, Map<String, dynamic> incidentData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.patch(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/incidents',
        data: incidentData,
      );

      if (response.data['success'] == true) {
        final updatedReport =
            FieldServiceReport.fromJson(response.data['data']['report']);

        final updatedReports = state.reports
            .map((report) => report.id == reportId ? updatedReport : report)
            .toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: state.selectedReport?.id == reportId
              ? updatedReport
              : state.selectedReport,
          isLoading: false,
        );

        _showSuccess('Incident recorded successfully');
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to record incident');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to record incident: $error');
      return false;
    }
  }

  // ============ SEARCH & FILTER ============

  Future<void> searchFieldServiceReports(String query,
      {int page = 1, int limit = 20}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.get('/v1/nawassco/field_technician/field-service-reports/search', queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final resultData = data['result'] ?? data;
        final reportsData = resultData['reports'] as List? ?? [];
        final pagination = resultData['pagination'] ?? {};

        final reports = reportsData
            .map((report) => FieldServiceReport.fromJson(report))
            .toList();

        state = state.copyWith(
          reports: reports,
          isLoading: false,
          currentPage: pagination['currentPage'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
          totalItems: pagination['totalItems'] ?? 0,
          hasMore: (pagination['currentPage'] ?? page) <
              (pagination['totalPages'] ?? 1),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Search failed');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Search failed: $error');
    }
  }

  Future<void> getReportMetrics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get('/v1/nawassco/field_technician/field-service-reports/metrics');

      if (response.data['success'] == true) {
        final metrics = response.data['data']['metrics'];

        state = state.copyWith(
          reportMetrics: metrics,
          isLoading: false,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load metrics');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load report metrics: $error');
    }
  }

  // ============ PDF & DOCUMENT OPERATIONS ============

  Future<Map<String, dynamic>?> getReportPDFData(String reportId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response =
          await _dio.get('/v1/nawassco/field_technician/field-service-reports/$reportId/pdf-data');

      if (response.data['success'] == true) {
        state = state.copyWith(isLoading: false);
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load PDF data');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to load PDF data: $error');
      return null;
    }
  }

  Future<Uint8List?> generateReportPDF(String reportId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _dio.get(
        '/v1/nawassco/field_technician/field-service-reports/$reportId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return response.data as Uint8List;
      } else {
        throw Exception('Failed to generate PDF');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      _showError('Failed to generate PDF: $error');
      return null;
    }
  }

  // ============ FILE PICKING HELPERS ============

  Future<List<File>> pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.map((file) => File(file.path!)).toList();
    }
    return [];
  }

  Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!);
    }
    return null;
  }

  Future<File?> pickSignature() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!);
    }
    return null;
  }

  // ============ STATE MANAGEMENT HELPERS ============

  Future<void> refreshReports() async {
    state = state.copyWith(isLoading: true);
    await getFieldServiceReports();
  }

  Future<void> loadMoreReports() async {
    if (state.hasMore && !state.isLoading) {
      await getFieldServiceReports(
        page: state.currentPage + 1,
        loadMore: true,
      );
    }
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
    getFieldServiceReports(page: 1);
  }

  void clearFilters() {
    state = state.copyWith(filters: {});
    getFieldServiceReports(page: 1);
  }

  void clearSelectedReport() {
    state = state.copyWith(selectedReport: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setSearchQuery(String query) {
    if (query.isEmpty) {
      getFieldServiceReports();
    } else {
      searchFieldServiceReports(query);
    }
  }

  // ============ STATISTICS GETTERS ============

  List<FieldServiceReport> getPendingReports() {
    return state.reports.where((report) => report.isPending).toList();
  }

  List<FieldServiceReport> getApprovedReports() {
    return state.reports.where((report) => report.isApproved).toList();
  }

  List<FieldServiceReport> getRejectedReports() {
    return state.reports.where((report) => report.isRejected).toList();
  }

  List<FieldServiceReport> getReportsByTechnician(String technicianId) {
    return state.reports
        .where((report) => report.technicianId == technicianId)
        .toList();
  }

  List<FieldServiceReport> getReportsByWorkOrder(String workOrderId) {
    return state.reports
        .where((report) => report.workOrderId == workOrderId)
        .toList();
  }

  Map<ApprovalStatus, int> getApprovalStatusCounts() {
    final counts = <ApprovalStatus, int>{};
    for (final status in ApprovalStatus.values) {
      counts[status] = state.reports
          .where((report) => report.approvalStatus == status)
          .length;
    }
    return counts;
  }

  double getAverageCustomerSatisfaction() {
    if (state.reports.isEmpty) return 0.0;
    final total = state.reports
        .fold(0, (sum, report) => sum + report.customerSatisfaction);
    return total / state.reports.length;
  }

  double getAverageWorkQuality() {
    final ratedReports = state.reports
        .where((report) => report.workQualityRating != null)
        .toList();
    if (ratedReports.isEmpty) return 0.0;
    final total = ratedReports.fold(
        0.0, (sum, report) => sum + (report.workQualityRating ?? 0));
    return total / ratedReports.length;
  }

  // ============ HELPER METHODS ============

  void _showSuccess(String message) {
    ToastUtils.showSuccessToast(message, key: _scaffoldMessengerKey);
  }

  void _showError(String message) {
    ToastUtils.showErrorToast(message, key: _scaffoldMessengerKey);
  }
}

// ============ PROVIDER DECLARATIONS ============

final fieldServiceReportProvider =
    StateNotifierProvider<FieldServiceReportProvider, FieldServiceReportState>(
        (ref) {
  final dio = ref.read(dioProvider);
  return FieldServiceReportProvider(dio, scaffoldMessengerKey);
});

// Helper provider for reports by technician
final technicianReportsProvider =
    Provider.family<List<FieldServiceReport>, String>((ref, technicianId) {
  final state = ref.watch(fieldServiceReportProvider);
  return state.reports
      .where((report) => report.technicianId == technicianId)
      .toList();
});

// Helper provider for reports by work order
final workOrderReportsProvider =
    Provider.family<List<FieldServiceReport>, String>((ref, workOrderId) {
  final state = ref.watch(fieldServiceReportProvider);
  return state.reports
      .where((report) => report.workOrderId == workOrderId)
      .toList();
});

// Provider for filtered reports
final filteredReportsProvider =
    Provider.family<List<FieldServiceReport>, Map<String, dynamic>>(
        (ref, filters) {
  final state = ref.watch(fieldServiceReportProvider);

  if (filters.isEmpty) return state.reports;

  var filtered = state.reports;

  if (filters.containsKey('approvalStatus') &&
      filters['approvalStatus'] != null) {
    filtered = filtered
        .where((report) =>
            report.approvalStatus.apiValue == filters['approvalStatus'])
        .toList();
  }

  if (filters.containsKey('technician') && filters['technician'] != null) {
    filtered = filtered
        .where((report) => report.technicianName
            .toLowerCase()
            .contains(filters['technician'].toString().toLowerCase()))
        .toList();
  }

  if (filters.containsKey('workOrder') && filters['workOrder'] != null) {
    filtered = filtered
        .where((report) => report.workOrderNumber
            .toLowerCase()
            .contains(filters['workOrder'].toString().toLowerCase()))
        .toList();
  }

  if (filters.containsKey('startDate') && filters['startDate'] != null) {
    final startDate = DateTime.parse(filters['startDate']);
    filtered = filtered
        .where((report) => report.serviceDate.isAfter(startDate))
        .toList();
  }

  if (filters.containsKey('endDate') && filters['endDate'] != null) {
    final endDate = DateTime.parse(filters['endDate']);
    filtered = filtered
        .where((report) => report.serviceDate.isBefore(endDate))
        .toList();
  }

  return filtered;
});

// Provider for report statistics
final reportStatsProvider = Provider((ref) {
  final state = ref.watch(fieldServiceReportProvider);
  final reports = state.reports;

  if (reports.isEmpty) {
    return {
      'total': 0,
      'pending': 0,
      'approved': 0,
      'rejected': 0,
      'averageSatisfaction': 0.0,
      'averageQuality': 0.0,
      'totalMaterialCost': 0.0,
    };
  }

  final approved = reports.where((r) => r.isApproved).length;
  final pending = reports.where((r) => r.isPending).length;
  final rejected = reports.where((r) => r.isRejected).length;

  final totalSatisfaction =
      reports.fold(0, (sum, r) => sum + r.customerSatisfaction);
  final averageSatisfaction = totalSatisfaction / reports.length;

  final ratedReports =
      reports.where((r) => r.workQualityRating != null).toList();
  final averageQuality = ratedReports.isEmpty
      ? 0.0
      : ratedReports.fold(0.0, (sum, r) => sum + (r.workQualityRating ?? 0)) /
          ratedReports.length;

  final totalMaterialCost =
      reports.fold(0.0, (sum, r) => sum + r.totalMaterialCost);

  return {
    'total': reports.length,
    'pending': pending,
    'approved': approved,
    'rejected': rejected,
    'approvalRate': reports.isEmpty ? 0.0 : (approved / reports.length) * 100,
    'averageSatisfaction': averageSatisfaction,
    'averageQuality': averageQuality,
    'totalMaterialCost': totalMaterialCost,
  };
});
