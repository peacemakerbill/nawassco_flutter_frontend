import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/field_service_report_model.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/field_service_report_provider.dart';
import '../../../../providers/work_order_provider.dart';
import 'customer_signature_pad.dart';

class ReportFormWidget extends ConsumerStatefulWidget {
  final AuthState authState;
  final FieldServiceReport? report;
  final Function(FieldServiceReport) onSuccess;
  final VoidCallback onCancel;

  const ReportFormWidget({
    super.key,
    required this.authState,
    this.report,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends ConsumerState<ReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  String? _selectedWorkOrderId;
  final _workSummaryController = TextEditingController();
  final _customerCommentsController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _departureTimeController = TextEditingController();
  int _customerSatisfaction = 3;

  // Lists
  final List<CompletedTask> _tasks = [];
  final List<ReportMaterialUsage> _materials = [];
  final List<Measurement> _measurements = [];
  final List<String> _issues = [];
  final List<String> _recommendations = [];
  final List<String> _tools = [];
  final List<String> _safetyObservations = [];

  // Files
  List<File> _siteImages = [];
  List<File> _beforePhotos = [];
  List<File> _afterPhotos = [];
  Uint8List? _customerSignatureImage;

  // Form state
  bool _isSubmitting = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.report != null;

    if (_isEditMode && widget.report != null) {
      _initializeForm(widget.report!);
    } else {
      _arrivalTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      _departureTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(
          DateTime.now().add(const Duration(hours: 1))
      );
    }
  }

  Future<void> _loadSignatureFromUrl(String signatureUrl) async {
    try {
      if (signatureUrl.startsWith('data:')) {
        // Handle base64 data URL
        final base64String = signatureUrl.split(',').last;
        final bytes = base64.decode(base64String);

        setState(() {
          _customerSignatureImage = Uint8List.fromList(bytes);
        });
      } else if (signatureUrl.startsWith('http')) {
        // Handle regular HTTP URL
        final response = await http.get(Uri.parse(signatureUrl));

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          setState(() {
            _customerSignatureImage = bytes;
          });
        } else {
          print('Failed to load signature image: ${response.statusCode}');
        }
      } else if (signatureUrl.startsWith('file:')) {
        // Handle local file URL
        final file = File(signatureUrl.replaceFirst('file://', ''));
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          setState(() {
            _customerSignatureImage = bytes;
          });
        }
      } else if (signatureUrl.startsWith('/')) {
        // Handle local file path
        final file = File(signatureUrl);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          setState(() {
            _customerSignatureImage = bytes;
          });
        }
      } else {
        // Try to decode as pure base64
        try {
          final bytes = base64.decode(signatureUrl);
          setState(() {
            _customerSignatureImage = bytes;
          });
        } catch (e) {
          print('Failed to parse signature URL: $signatureUrl');
        }
      }
    } catch (error) {
      print('Error loading signature from URL: $error');
    }
  }

  void _initializeForm(FieldServiceReport report) {
    _selectedWorkOrderId = report.workOrderId;
    _workSummaryController.text = report.workSummary;
    _customerCommentsController.text = report.customerComments ?? '';
    _arrivalTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(report.arrivalTime);
    _departureTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(report.departureTime);
    _customerSatisfaction = report.customerSatisfaction;

    _tasks.addAll(report.tasksCompleted);
    _materials.addAll(report.materialsUsed);
    _measurements.addAll(report.measurements);
    _issues.addAll(report.issuesFound);
    _recommendations.addAll(report.recommendations);
    _tools.addAll(report.toolsUsed);
    _safetyObservations.addAll(report.safetyObservations);
    if (report.customerSignature.isNotEmpty) {
      _loadSignatureFromUrl(report.customerSignature);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workOrders = ref.watch(workOrderProvider).workOrders;
    final availableWorkOrders = workOrders.where((wo) =>
    wo.status.apiValue == 'in_progress' || wo.status.apiValue == 'scheduled'
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Report' : 'Create Field Service Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _goToPreviousPage,
              child: const Text('Previous'),
            ),
          if (_currentPage < 4)
            TextButton(
              onPressed: _goToNextPage,
              child: const Text('Next'),
            ),
          if (_currentPage == 4)
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(_isEditMode ? 'Update' : 'Create'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildBasicInfoPage(availableWorkOrders),
            _buildWorkDetailsPage(),
            _buildMaterialsPage(),
            _buildPhotosPage(),
            _buildReviewPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildProgressIndicator(),
    );
  }

  Widget _buildBasicInfoPage(List<WorkOrder> workOrders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            value: _selectedWorkOrderId,
            decoration: const InputDecoration(
              labelText: 'Work Order *',
              border: OutlineInputBorder(),
            ),
            items: workOrders.map((wo) {
              return DropdownMenuItem(
                value: wo.id,
                child: Text('${wo.workOrderNumber} - ${wo.title}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedWorkOrderId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a work order';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _workSummaryController,
            decoration: const InputDecoration(
              labelText: 'Work Summary *',
              border: OutlineInputBorder(),
              hintText: 'Brief description of work performed',
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide a work summary';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _arrivalTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Arrival Time *',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final now = DateTime.now();
                      final dateTime = DateTime(
                        now.year, now.month, now.day,
                        time.hour, time.minute,
                      );
                      _arrivalTimeController.text =
                          DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select arrival time';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: TextFormField(
                  controller: _departureTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Departure Time *',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final now = DateTime.now();
                      final dateTime = DateTime(
                        now.year, now.month, now.day,
                        time.hour, time.minute,
                      );
                      _departureTimeController.text =
                          DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select departure time';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text('Customer Satisfaction'),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _customerSatisfaction = index + 1;
                  });
                },
                icon: Icon(
                  Icons.star,
                  color: index < _customerSatisfaction ? Colors.amber : Colors.grey,
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _customerCommentsController,
            decoration: const InputDecoration(
              labelText: 'Customer Comments',
              border: OutlineInputBorder(),
              hintText: 'Any comments from the customer',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Tasks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks Completed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          ..._tasks.map((task) {
            return _buildTaskCard(task);
          }),

          if (_tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No tasks added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Issues & Recommendations
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Issues Found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          onPressed: () => _addItemToList(_issues, 'Add Issue'),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    ..._issues.map((issue) => _buildListItem(issue, _issues)),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommendations',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          onPressed: () => _addItemToList(_recommendations, 'Add Recommendation'),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    ..._recommendations.map((rec) => _buildListItem(rec, _recommendations)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tools Used
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tools Used',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () => _addItemToList(_tools, 'Add Tool'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tools.map((tool) {
              return Chip(
                label: Text(tool),
                onDeleted: () {
                  setState(() {
                    _tools.remove(tool);
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Safety Observations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Safety Observations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () => _addItemToList(_safetyObservations, 'Add Safety Observation'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          ..._safetyObservations.map((obs) => _buildListItem(obs, _safetyObservations)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(CompletedTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.task,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editTask(task),
                ),
              ],
            ),
            Text(task.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('${task.timeTaken} min'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(task.status.displayName),
                  backgroundColor: _getTaskStatusColor(task.status).withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String item, List<String> list) {
    return ListTile(
      title: Text(item),
      trailing: IconButton(
        icon: const Icon(Icons.delete, size: 18),
        onPressed: () {
          setState(() {
            list.remove(item);
          });
        },
      ),
    );
  }

  Widget _buildMaterialsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materials & Measurements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Materials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Materials Used',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: _addMaterial,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          ..._materials.map((material) {
            return _buildMaterialCard(material);
          }),

          if (_materials.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No materials recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Measurements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Measurements',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: _addMeasurement,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          ..._measurements.map((measurement) {
            return _buildMeasurementCard(measurement);
          }),

          if (_measurements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No measurements recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(ReportMaterialUsage material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${material.quantity} ${material.unit}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '\$${(material.cost * material.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _editMaterial(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(Measurement measurement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  measurement.parameter,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editMeasurement(measurement),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Value: ${measurement.value} ${measurement.unit}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                if (measurement.beforeValue != null)
                  Text(
                    'Before: ${measurement.beforeValue}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(width: 8),
                if (measurement.afterValue != null)
                  Text(
                    'After: ${measurement.afterValue}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visual Documentation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Site Images
          _buildPhotoSection(
            'Site Images',
            _siteImages,
            'Add site images showing the work environment',
            Icons.photo_camera,
                () => _pickPhotos(_siteImages),
          ),

          const SizedBox(height: 24),

          // Before Photos
          _buildPhotoSection(
            'Before Photos',
            _beforePhotos,
            'Add photos showing the situation before work',
            Icons.photo_camera_back,
                () => _pickPhotos(_beforePhotos),
          ),

          const SizedBox(height: 24),

          // After Photos
          _buildPhotoSection(
            'After Photos',
            _afterPhotos,
            'Add photos showing the completed work',
            Icons.photo_camera_front,
                () => _pickPhotos(_afterPhotos),
          ),

          const SizedBox(height: 24),

          // Customer Signature
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Signature',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _customerSignatureImage != null
                        ? 'Signature captured'
                        : 'No signature captured yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  // Show signature preview if exists
                  if (_customerSignatureImage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.memory(
                        _customerSignatureImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openSignaturePad(),
                          icon: const Icon(Icons.edit),
                          label: const Text('Capture Signature'),
                        ),
                      ),
                      if (_customerSignatureImage != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clearSignature,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Clear Signature',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
      String title,
      List<File> files,
      String description,
      IconData icon,
      VoidCallback onAdd,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),

            if (files.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(files[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  files.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            if (files.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 32, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No photos added',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPage() {
    final arrivalTime = DateTime.tryParse(_arrivalTimeController.text);
    final departureTime = DateTime.tryParse(_departureTimeController.text);
    final totalTime = arrivalTime != null && departureTime != null
        ? departureTime.difference(arrivalTime).inMinutes
        : 0;

    final totalMaterialCost = _materials.fold(
        0.0, (sum, material) => sum + (material.cost * material.quantity));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Submit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  _buildReviewItem('Work Order', _selectedWorkOrderId ?? 'Not selected'),
                  _buildReviewItem('Work Summary', _workSummaryController.text),
                  _buildReviewItem('Total Time', '$totalTime minutes'),
                  _buildReviewItem('Customer Rating', '$_customerSatisfaction/5'),
                  _buildReviewItem('Tasks Completed', '${_tasks.length} tasks'),
                  _buildReviewItem('Materials Used', '${_materials.length} items'),
                  _buildReviewItem('Total Material Cost', '\$${totalMaterialCost.toStringAsFixed(2)}'),
                  _buildReviewItem('Site Images', '${_siteImages.length} photos'),
                  _buildReviewItem('Before Photos', '${_beforePhotos.length} photos'),
                  _buildReviewItem('After Photos', '${_afterPhotos.length} photos'),
                  _buildReviewItem('Customer Signature', _customerSignatureImage != null ? 'Captured' : 'Not captured'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (_issues.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issues Found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    ..._issues.map((issue) => Text('• $issue')),
                  ],
                ),
              ),
            ),

          if (_recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommendations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    ..._recommendations.map((rec) => Text('• $rec')),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(_isEditMode ? 'Update Report' : 'Create Report'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPageTitle(_currentPage),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int page) {
    return switch (page) {
      0 => 'Basic Information',
      1 => 'Work Details',
      2 => 'Materials & Measurements',
      3 => 'Photos & Signature',
      4 => 'Review & Submit',
      _ => '',
    };
  }

  Color _getTaskStatusColor(TaskCompletionStatus status) {
    return switch (status) {
      TaskCompletionStatus.completed => Colors.green,
      TaskCompletionStatus.partiallyCompleted => Colors.orange,
      TaskCompletionStatus.notCompleted => Colors.red,
    };
  }

  void _goToNextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _addTask() async {
    final taskController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController(text: '30');
    final notesController = TextEditingController();
    final status = ValueNotifier<TaskCompletionStatus>(TaskCompletionStatus.completed);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Task',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task *',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: timeController,
                            decoration: const InputDecoration(
                              labelText: 'Time Taken (minutes) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: ValueListenableBuilder<TaskCompletionStatus>(
                            valueListenable: status,
                            builder: (context, value, child) {
                              return DropdownButtonFormField<TaskCompletionStatus>(
                                value: value,
                                decoration: const InputDecoration(
                                  labelText: 'Status *',
                                  border: OutlineInputBorder(),
                                ),
                                items: TaskCompletionStatus.values.map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(s.displayName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    status.value = value;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (taskController.text.isEmpty || descController.text.isEmpty) {
                              return;
                            }

                            final task = CompletedTask(
                              task: taskController.text,
                              description: descController.text,
                              timeTaken: int.tryParse(timeController.text) ?? 30,
                              status: status.value,
                              notes: notesController.text.isEmpty ? null : notesController.text,
                            );

                            setState(() {
                              _tasks.add(task);
                            });

                            Navigator.pop(context);
                          },
                          child: const Text('Add Task'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _editTask(CompletedTask task) {
    // Similar to _addTask but with existing values
    // Implementation omitted for brevity
  }

  Future<void> _addItemToList(List<String> list, String title) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          setState(() {
                            list.add(controller.text);
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addMaterial() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'piece');
    final costController = TextEditingController(text: '0');

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Material',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Material Name *',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost per Unit *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty) {
                          return;
                        }

                        final material = ReportMaterialUsage(
                          material: nameController.text,
                          materialName: nameController.text,
                          quantity: int.tryParse(quantityController.text) ?? 1,
                          unit: unitController.text,
                          cost: double.tryParse(costController.text) ?? 0.0,
                        );

                        setState(() {
                          _materials.add(material);
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Add Material'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editMaterial(ReportMaterialUsage material) {
    // Similar to _addMaterial but with existing values
  }

  Future<void> _addMeasurement() async {
    final paramController = TextEditingController();
    final valueController = TextEditingController(text: '0');
    final unitController = TextEditingController();
    final beforeController = TextEditingController();
    final afterController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Measurement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: paramController,
                  decoration: const InputDecoration(
                    labelText: 'Parameter *',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: valueController,
                        decoration: const InputDecoration(
                          labelText: 'Value *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: beforeController,
                        decoration: const InputDecoration(
                          labelText: 'Before Value (optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: afterController,
                        decoration: const InputDecoration(
                          labelText: 'After Value (optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (paramController.text.isEmpty) {
                          return;
                        }

                        final measurement = Measurement(
                          parameter: paramController.text,
                          value: double.tryParse(valueController.text) ?? 0.0,
                          unit: unitController.text,
                          beforeValue: beforeController.text.isNotEmpty
                              ? double.tryParse(beforeController.text)
                              : null,
                          afterValue: afterController.text.isNotEmpty
                              ? double.tryParse(afterController.text)
                              : null,
                        );

                        setState(() {
                          _measurements.add(measurement);
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Add Measurement'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editMeasurement(Measurement measurement) {
    // Similar to _addMeasurement but with existing values
  }

  Future<void> _pickPhotos(List<File> targetList) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        targetList.addAll(result.files.map((file) => File(file.path!)));
      });
    }
  }

  Future<void> _openSignaturePad() async {
    String? existingSignatureUrl;
    if (widget.report != null && widget.report!.customerSignature != null) {
      existingSignatureUrl = widget.report!.customerSignature;
    }

    final signatureData = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerSignaturePad(
          onSignatureSaved: (signatureBytes) {
            Navigator.pop(context, signatureBytes);
          },
          existingSignatureUrl: existingSignatureUrl,
        ),
      ),
    );

    if (signatureData != null && mounted) {
      setState(() {
        _customerSignatureImage = signatureData;
      });
    }
  }

  void _clearSignature() {
    setState(() {
      _customerSignatureImage = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWorkOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a work order')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert signature to base64 if exists
      String? signatureBase64;
      if (_customerSignatureImage != null) {
        signatureBase64 = base64.encode(_customerSignatureImage!);
      }

      final reportData = {
        'workOrder': _selectedWorkOrderId,
        'technician': widget.authState.user?['_id'],
        'serviceDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'arrivalTime': _arrivalTimeController.text,
        'departureTime': _departureTimeController.text,
        'workSummary': _workSummaryController.text,
        'tasksCompleted': _tasks.map((t) => t.toJson()).toList(),
        'issuesFound': _issues,
        'recommendations': _recommendations,
        'materialsUsed': _materials.map((m) => m.toJson()).toList(),
        'toolsUsed': _tools,
        'measurements': _measurements.map((m) => m.toJson()).toList(),
        'customerComments': _customerCommentsController.text.isEmpty
            ? null
            : _customerCommentsController.text,
        'customerSatisfaction': _customerSatisfaction,
        'safetyObservations': _safetyObservations,
        'customerSignature': signatureBase64 != null
            ? 'data:image/png;base64,$signatureBase64'
            : null,
        // Note: In a real app, you would need to upload files separately
        // and include their URLs here
      };

      FieldServiceReport? result;
      final provider = ref.read(fieldServiceReportProvider.notifier);

      if (_isEditMode && widget.report != null) {
        await provider.updateFieldServiceReport(widget.report!.id, reportData);
        result = widget.report!.copyWith(
          workSummary: _workSummaryController.text,
          customerComments: _customerCommentsController.text.isEmpty
              ? null
              : _customerCommentsController.text,
          arrivalTime: DateTime.parse(_arrivalTimeController.text),
          departureTime: DateTime.parse(_departureTimeController.text),
          customerSatisfaction: _customerSatisfaction,
          tasksCompleted: _tasks,
          issuesFound: _issues,
          recommendations: _recommendations,
          materialsUsed: _materials,
          toolsUsed: _tools,
          measurements: _measurements,
          safetyObservations: _safetyObservations,
          customerSignature: signatureBase64 != null
              ? 'data:image/png;base64,$signatureBase64'
              : widget.report!.customerSignature,
        );
      } else {
        result = await provider.createFieldServiceReport(reportData);
      }

      if (result != null && mounted) {
        widget.onSuccess(result);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}