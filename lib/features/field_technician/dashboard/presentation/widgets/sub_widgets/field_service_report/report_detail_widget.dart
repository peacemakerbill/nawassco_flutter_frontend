import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/utils/toast_utils.dart';
import '../../../../../../../main.dart';
import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/field_service_report_model.dart';
import '../../../../providers/field_service_report_provider.dart';


class ReportDetailWidget extends ConsumerStatefulWidget {
  final FieldServiceReport report;
  final AuthState authState;
  final VoidCallback? onReportUpdated;

  const ReportDetailWidget({
    super.key,
    required this.report,
    required this.authState,
    this.onReportUpdated,
  });

  @override
  ConsumerState<ReportDetailWidget> createState() => _ReportDetailWidgetState();
}

class _ReportDetailWidgetState extends ConsumerState<ReportDetailWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingPDF = false;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPDF() async {
    if (_pdfBytes != null) return;

    setState(() {
      _isLoadingPDF = true;
    });

    final pdf = await ref.read(fieldServiceReportProvider.notifier).generateReportPDF(widget.report.id);

    setState(() {
      _pdfBytes = pdf;
      _isLoadingPDF = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final canEdit = widget.authState.user?['_id'] == report.technicianId ||
        widget.authState.hasAnyRole(['Admin', 'Manager']);
    final canApprove = report.canApprove && widget.authState.hasAnyRole(['Admin', 'Manager']);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context, report, canEdit, canApprove),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Tasks'),
                Tab(text: 'Materials'),
                Tab(text: 'Photos'),
                Tab(text: 'PDF'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(report),
                _buildTasksTab(report),
                _buildMaterialsTab(report),
                _buildPhotosTab(report),
                _buildPDFTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FieldServiceReport report, bool canEdit, bool canApprove) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.approvalStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.approvalStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      report.approvalStatus.displayName,
                      style: TextStyle(
                        color: _getStatusColor(report.approvalStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];

                  if (canEdit) {
                    items.add(
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit Report'),
                        ),
                      ),
                    );
                  }

                  if (report.canSubmit && canEdit) {
                    items.add(
                      const PopupMenuItem(
                        value: 'submit',
                        child: ListTile(
                          leading: Icon(Icons.send),
                          title: Text('Submit for Approval'),
                        ),
                      ),
                    );
                  }

                  if (canApprove) {
                    items.add(
                      const PopupMenuItem(
                        value: 'approve',
                        child: ListTile(
                          leading: Icon(Icons.check_circle),
                          title: Text('Approve Report'),
                        ),
                      ),
                    );
                    items.add(
                      const PopupMenuItem(
                        value: 'reject',
                        child: ListTile(
                          leading: Icon(Icons.cancel),
                          title: Text('Reject Report'),
                        ),
                      ),
                    );
                  }

                  items.addAll([
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'pdf',
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Generate PDF'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share Report'),
                      ),
                    ),
                  ]);

                  if (widget.authState.hasAnyRole(['Admin', 'Manager'])) {
                    items.add(
                      // const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                    );
                  }

                  return items;
                },
                onSelected: (value) => _handleAction(value, report),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Report Info
          Text(
            report.reportNumber,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            report.workOrderTitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          // Quick Stats
          Row(
            children: [
              _buildQuickStat('Technician', report.technicianName),
              const SizedBox(width: 16),
              _buildQuickStat('Date', DateFormat('MMM dd, yyyy').format(report.serviceDate)),
              const SizedBox(width: 16),
              _buildQuickStat('Time', '${report.totalTime} min'),
              if (report.totalMaterialCost > 0) ...[
                const SizedBox(width: 16),
                _buildQuickStat('Cost', '\$${report.totalMaterialCost.toStringAsFixed(2)}'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(FieldServiceReport report) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Work Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Work Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(report.workSummary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Service Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow('Work Order', report.workOrderNumber),
                  _buildDetailRow('Service Date', DateFormat('MMM dd, yyyy').format(report.serviceDate)),
                  _buildDetailRow('Arrival Time', DateFormat('HH:mm').format(report.arrivalTime)),
                  _buildDetailRow('Departure Time', DateFormat('HH:mm').format(report.departureTime)),
                  _buildDetailRow('Total Time', '${report.totalTime} minutes'),
                  _buildDetailRow('Technician', report.technicianName),
                  if (report.technicianPhone.isNotEmpty)
                    _buildDetailRow('Technician Phone', report.technicianPhone),
                  if (report.technicianEmail.isNotEmpty)
                    _buildDetailRow('Technician Email', report.technicianEmail),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Customer Feedback
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text('Satisfaction: '),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 20,
                            color: index < report.customerSatisfaction
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                      ),
                      Text(' (${report.customerSatisfaction}/5)'),
                    ],
                  ),

                  if (report.customerComments != null && report.customerComments!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Comments:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(report.customerComments!),
                  ],

                  if (report.hasSignature) ...[
                    const SizedBox(height: 16),
                    const Text('Customer Signature:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Signature on file',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Issues & Recommendations
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Issues Found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (report.issuesFound.isEmpty)
                          Text('No issues reported', style: TextStyle(color: Colors.grey[600])),
                        ...report.issuesFound.map((issue) => Text('• $issue')),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommendations',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (report.recommendations.isEmpty)
                          Text('No recommendations', style: TextStyle(color: Colors.grey[600])),
                        ...report.recommendations.map((rec) => Text('• $rec')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tools Used
          if (report.toolsUsed.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tools Used',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: report.toolsUsed.map((tool) {
                        return Chip(label: Text(tool));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Safety Observations
          if (report.safetyObservations.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Safety Observations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...report.safetyObservations.map((obs) => Text('• $obs')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Incidents
          if (report.hasIncidents) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incidents',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...report.incidents.map((incident) {
                      return _buildIncidentCard(incident);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Approval Info
          if (report.approvedByName != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approval Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _buildDetailRow('Approved By', report.approvedByName!),
                    if (report.approvalDate != null)
                      _buildDetailRow('Approval Date', DateFormat('MMM dd, yyyy HH:mm').format(report.approvalDate!)),

                    if (report.qualityCheck != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Quality Check',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Checked By', report.qualityCheck!.checkedByName),
                      _buildDetailRow('Check Date', DateFormat('MMM dd, yyyy').format(report.qualityCheck!.checkDate)),
                      _buildDetailRow('Overall Rating', '${report.qualityCheck!.overallRating}/5'),
                      if (report.qualityCheck!.comments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Comments:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(report.qualityCheck!.comments),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTasksTab(FieldServiceReport report) {
    return Column(
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: _buildTaskStat('Total Tasks', '${report.tasksCompleted.length}'),
              ),
              Expanded(
                child: _buildTaskStat('Completed', '${report.completedTasksCount}'),
              ),
              Expanded(
                child: _buildTaskStat('Completion', '${report.completionRate.toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _buildTaskStat('Total Time', '${report.totalTaskTime} min'),
              ),
            ],
          ),
        ),

        // Task List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: report.tasksCompleted.length,
            itemBuilder: (context, index) {
              final task = report.tasksCompleted[index];
              return _buildTaskItem(task, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(CompletedTask task, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.task,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status.displayName,
                    style: TextStyle(
                      color: _getTaskStatusColor(task.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              task.description,
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Chip(
                  label: Text('${task.timeTaken} min'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                if (task.notes != null && task.notes!.isNotEmpty)
                  Chip(
                    label: Text('Notes'),
                    backgroundColor: Colors.grey[200],
                    onDeleted: () {
                      _showNotesDialog(task.notes!);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsTab(FieldServiceReport report) {
    final totalCost = report.totalMaterialCost;

    return Column(
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: _buildMaterialStat('Total Items', '${report.materialsUsed.length}'),
              ),
              Expanded(
                child: _buildMaterialStat('Total Cost', '\$${totalCost.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),

        // Material List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: report.materialsUsed.length,
            itemBuilder: (context, index) {
              final material = report.materialsUsed[index];
              return _buildMaterialItem(material, index);
            },
          ),
        ),

        // Measurements
        if (report.measurements.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: const Text(
              'Measurements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: report.measurements.length,
            itemBuilder: (context, index) {
              final measurement = report.measurements[index];
              return _buildMeasurementItem(measurement, index);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialItem(ReportMaterialUsage material, int index) {
    final totalCost = material.cost * material.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory, color: Colors.blue),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${material.quantity} ${material.unit}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${material.cost.toStringAsFixed(2)}/unit',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(Measurement measurement, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              measurement.parameter,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${measurement.value} ${measurement.unit}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                if (measurement.beforeValue != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${measurement.beforeValue} ${measurement.unit}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],

                if (measurement.afterValue != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'After',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${measurement.afterValue} ${measurement.unit}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab(FieldServiceReport report) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Site Photos'),
                Tab(text: 'Before'),
                Tab(text: 'After'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buildPhotoGallery(report.siteImages, 'No site photos available'),
                _buildPhotoGallery(report.beforePhotos, 'No before photos available'),
                _buildPhotoGallery(report.afterPhotos, 'No after photos available'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(List<String> photos, String emptyMessage) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showPhotoFullScreen(photos[index]),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(photos[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPDFTab() {
    if (_isLoadingPDF) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pdfBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No PDF generated yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPDF,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate PDF'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'PDF Viewer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: _downloadPDF,
                icon: const Icon(Icons.download),
                tooltip: 'Download PDF',
              ),
              IconButton(
                onPressed: _sharePDF,
                icon: const Icon(Icons.share),
                tooltip: 'Share PDF',
              ),
              IconButton(
                onPressed: _printPDF,
                icon: const Icon(Icons.print),
                tooltip: 'Print PDF',
              ),
            ],
          ),
        ),

        Expanded(
          child: SfPdfViewer.memory(
            _pdfBytes!,
            controller: _pdfViewerController,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _pdfViewerController.previousPage();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  _pdfViewerController.zoomLevel = 1.0;
                },
                icon: const Icon(Icons.zoom_out),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _pdfViewerController.zoomLevel = 1.5;
                },
                icon: const Icon(Icons.zoom_in),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  _pdfViewerController.nextPage();
                },
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(IncidentReport incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getSeverityColor(incident.severity).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(incident.severity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    incident.severity.displayName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident.incidentType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(incident.description),

            if (incident.actionsTaken.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Actions Taken:', style: TextStyle(fontWeight: FontWeight.w500)),
              ...incident.actionsTaken.map((action) => Text('• $action')),
            ],

            const SizedBox(height: 4),

            Text(
              'Reported: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.reportedDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    return switch (status) {
      ApprovalStatus.pending => Colors.orange,
      ApprovalStatus.approved => Colors.green,
      ApprovalStatus.rejected => Colors.red,
      ApprovalStatus.revised => Colors.blue,
    };
  }

  Color _getTaskStatusColor(TaskCompletionStatus status) {
    return switch (status) {
      TaskCompletionStatus.completed => Colors.green,
      TaskCompletionStatus.partiallyCompleted => Colors.orange,
      TaskCompletionStatus.notCompleted => Colors.red,
    };
  }

  Color _getSeverityColor(SeverityLevel severity) {
    return switch (severity) {
      SeverityLevel.low => Colors.green,
      SeverityLevel.medium => Colors.orange,
      SeverityLevel.high => Colors.red,
      SeverityLevel.critical => Colors.purple,
    };
  }

  Future<void> _handleAction(String action, FieldServiceReport report) async {
    final provider = ref.read(fieldServiceReportProvider.notifier);

    switch (action) {
      case 'edit':
      // Navigate to edit
        break;
      case 'submit':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Submit for Approval'),
            content: const Text('Are you sure you want to submit this report for approval?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Submit'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await provider.submitForApproval(report.id);
          widget.onReportUpdated?.call();
          Navigator.pop(context);
        }
        break;

      case 'approve':
        final qualityCheck = await _showQualityCheckDialog();
        if (qualityCheck != null) {
          await provider.approveReport(report.id, qualityCheck: qualityCheck);
          widget.onReportUpdated?.call();
          Navigator.pop(context);
        }
        break;

      case 'reject':
        final comments = await _showRejectDialog();
        if (comments != null) {
          await provider.rejectReport(report.id, comments: comments);
          widget.onReportUpdated?.call();
          Navigator.pop(context);
        }
        break;

      case 'pdf':
        await _loadPDF();
        _tabController.animateTo(4); // Switch to PDF tab
        break;

      case 'share':
        await _shareReport(report);
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Report'),
            content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await provider.deleteFieldServiceReport(report.id);
          widget.onReportUpdated?.call();
          Navigator.pop(context);
        }
        break;
    }
  }

  Future<Map<String, dynamic>?> _showQualityCheckDialog() async {
    final overallRating = ValueNotifier(3);
    final parameters = <Map<String, dynamic>>[];
    final commentsController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
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
                      'Quality Check',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    const Text('Overall Rating'),
                    ValueListenableBuilder<int>(
                      valueListenable: overallRating,
                      builder: (context, value, child) {
                        return Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              onPressed: () {
                                overallRating.value = index + 1;
                              },
                              icon: Icon(
                                Icons.star,
                                color: index < value ? Colors.amber : Colors.grey,
                                size: 32,
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text('Quality Parameters'),
                    ...parameters.map((param) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: param['parameter'],
                              decoration: const InputDecoration(labelText: 'Parameter'),
                              onChanged: (value) {
                                param['parameter'] = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: param['rating'].toString(),
                              decoration: const InputDecoration(labelText: 'Rating'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                param['rating'] = int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          parameters.add({'parameter': '', 'rating': 3});
                        });
                      },
                      child: const Text('Add Parameter'),
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: commentsController,
                      decoration: const InputDecoration(
                        labelText: 'Comments',
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
                            Navigator.pop(context, {
                              'overallRating': overallRating.value,
                              'parameters': parameters,
                              'comments': commentsController.text,
                            });
                          },
                          child: const Text('Approve with Quality Check'),
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

  Future<String?> _showRejectDialog() async {
    final commentsController = TextEditingController();

    final confirmed = await showDialog<bool>(
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
                  'Reject Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Please provide reason for rejection'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Comments *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (commentsController.text.isNotEmpty) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reject Report'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      return commentsController.text;
    }
    return null;
  }

  void _showNotesDialog(String notes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(notes),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoFullScreen(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                photoUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPDF() async {
    if (_pdfBytes == null) return;

    // Use file_saver or share_plus to save the file
    ToastUtils.showSuccessToast('PDF downloaded', key: scaffoldMessengerKey);
  }

  Future<void> _sharePDF() async {
    if (_pdfBytes == null) return;

    // Use share_plus to share the PDF
    ToastUtils.showInfoToast('Sharing PDF...', key: scaffoldMessengerKey);
  }

  Future<void> _printPDF() async {
    if (_pdfBytes == null) return;

    // Use printing package to print the PDF
    ToastUtils.showInfoToast('Printing PDF...', key: scaffoldMessengerKey);
  }

  Future<void> _shareReport(FieldServiceReport report) async {
    // Share report details
    final shareText = '''
Field Service Report: ${report.reportNumber}
Work Order: ${report.workOrderNumber}
Technician: ${report.technicianName}
Service Date: ${DateFormat('MMM dd, yyyy').format(report.serviceDate)}
Status: ${report.approvalStatus.displayName}
Customer Rating: ${report.customerSatisfaction}/5
    ''';

    // Use share_plus to share the text
    ToastUtils.showInfoToast('Sharing report...', key: scaffoldMessengerKey);
  }
}