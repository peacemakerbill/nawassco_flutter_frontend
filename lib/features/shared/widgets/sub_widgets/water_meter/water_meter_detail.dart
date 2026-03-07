import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/water_meter.model.dart';
import 'alert_form.dart';
import 'issue_form.dart';
import 'maintenance_record_form.dart';

class WaterMeterDetailWidget extends ConsumerStatefulWidget {
  final WaterMeter waterMeter;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WaterMeterDetailWidget({
    super.key,
    required this.waterMeter,
    required this.onBack,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<WaterMeterDetailWidget> createState() =>
      _WaterMeterDetailWidgetState();
}

class _WaterMeterDetailWidgetState
    extends ConsumerState<WaterMeterDetailWidget> {
  final _scrollController = ScrollController();
  int _selectedTab = 0;
  bool _showMaintenanceForm = false;
  bool _showAlertForm = false;
  bool _showIssueForm = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (color ?? Colors.blue).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: color ?? Colors.blue,
                    ),
                  ),
                if (icon != null) const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(MeterStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: status.color.withValues(alpha: 0.1),
      side: BorderSide(color: status.color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildConnectivityChip(ConnectivityStatus connectivity) {
    return Chip(
      label: Text(
        connectivity.displayName,
        style: TextStyle(
          color: connectivity.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: connectivity.color.withValues(alpha: 0.1),
      avatar: Icon(
        connectivity.icon,
        size: 16,
        color: connectivity.color,
      ),
      side: BorderSide(color: connectivity.color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildAlertChip(MeterAlert alert) {
    return Chip(
      label: Text(
        alert.type.displayName,
        style: TextStyle(
          color: alert.type.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: alert.type.color.withValues(alpha: 0.1),
      avatar: Icon(
        alert.type.icon,
        size: 16,
      ),
      side: BorderSide(color: alert.type.color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildMaintenanceTab() {
    final maintenance = widget.waterMeter.maintenance;
    final calibration = widget.waterMeter.calibration;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_showMaintenanceForm)
            MaintenanceRecordFormWidget(
              meterId: widget.waterMeter.id,
              onCancel: () => setState(() => _showMaintenanceForm = false),
              onSuccess: () {
                setState(() => _showMaintenanceForm = false);
                // Refresh data here
              },
            )
          else
            Column(
              children: [
                // Maintenance Records
                _buildInfoCard(
                  title: 'Maintenance History',
                  icon: Icons.build,
                  color: Colors.blue,
                  children: [
                    if (maintenance.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No maintenance records',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...maintenance.map((record) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(record.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        record.type.toUpperCase(),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor:
                                          Colors.blue.withValues(alpha: 0.1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  record.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailItem(
                                  label: 'Technician',
                                  value: record.technician,
                                  icon: Icons.person,
                                ),
                                _buildDetailItem(
                                  label: 'Cost',
                                  value:
                                      'KSH ${record.cost.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                ),
                                if (record.notes != null)
                                  _buildDetailItem(
                                    label: 'Notes',
                                    value: record.notes!,
                                    icon: Icons.note,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 16),

                // Calibration Records
                _buildInfoCard(
                  title: 'Calibration History',
                  icon: Icons.tune,
                  color: Colors.green,
                  children: [
                    if (calibration.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No calibration records',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...calibration.map((record) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(record.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        '${record.newAccuracy}%',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor:
                                          Colors.green.withValues(alpha: 0.1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailItem(
                                  label: 'Calibrated By',
                                  value: record.calibratedBy,
                                  icon: Icons.person,
                                ),
                                _buildDetailItem(
                                  label: 'Accuracy',
                                  value:
                                      '${record.previousAccuracy}% → ${record.newAccuracy}%',
                                  icon: Icons.trending_up,
                                ),
                                _buildDetailItem(
                                  label: 'Next Due',
                                  value: DateFormat('dd MMM yyyy')
                                      .format(record.nextCalibrationDue),
                                  icon: Icons.calendar_today,
                                ),
                                if (record.certificateNumber != null)
                                  _buildDetailItem(
                                    label: 'Certificate',
                                    value: record.certificateNumber!,
                                    icon: Icons.badge,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final alerts = widget.waterMeter.activeAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_showAlertForm)
            AlertFormWidget(
              meterId: widget.waterMeter.id,
              onCancel: () => setState(() => _showAlertForm = false),
              onSuccess: () {
                setState(() => _showAlertForm = false);
                // Refresh data here
              },
            )
          else
            _buildInfoCard(
              title: 'Active Alerts',
              icon: Icons.warning,
              color: Colors.orange,
              children: [
                if (alerts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No active alerts',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...alerts.map((alert) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: alert.severity.color.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildAlertChip(alert),
                                Chip(
                                  label: Text(
                                    alert.severity.displayName,
                                    style: TextStyle(
                                      color: alert.severity.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: alert.severity.color
                                      .withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailItem(
                              label: 'Detected',
                              value: DateFormat('dd MMM yyyy HH:mm')
                                  .format(alert.detectedAt),
                              icon: Icons.access_time,
                            ),
                            if (!alert.resolved && widget.onEdit != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Implement resolve alert
                                  },
                                  icon:
                                      const Icon(Icons.check_circle, size: 16),
                                  label: const Text('Resolve Alert'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildIssuesTab() {
    final issues = widget.waterMeter.issueHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_showIssueForm)
            IssueFormWidget(
              meterId: widget.waterMeter.id,
              onCancel: () => setState(() => _showIssueForm = false),
              onSuccess: () {
                setState(() => _showIssueForm = false);
                // Refresh data here
              },
            )
          else
            _buildInfoCard(
              title: 'Issue History',
              icon: Icons.error,
              color: Colors.red,
              children: [
                if (issues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No issues reported',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...issues.map((issue) {
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
                                  issue.type.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    issue.status.toUpperCase(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor:
                                      _getStatusColor(issue.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              issue.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailItem(
                              label: 'Reported By',
                              value: issue.reportedBy,
                              icon: Icons.person,
                            ),
                            _buildDetailItem(
                              label: 'Reported',
                              value: DateFormat('dd MMM yyyy')
                                  .format(issue.reportedDate),
                              icon: Icons.calendar_today,
                            ),
                            if (issue.assignedTo != null)
                              _buildDetailItem(
                                label: 'Assigned To',
                                value: issue.assignedTo!,
                                icon: Icons.assignment_ind,
                              ),
                            if (issue.costIncurred != null)
                              _buildDetailItem(
                                label: 'Cost',
                                value:
                                    'KSH ${issue.costIncurred!.toStringAsFixed(2)}',
                                icon: Icons.attach_money,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green.withValues(alpha: 0.1);
      case 'in_progress':
        return Colors.blue.withValues(alpha: 0.1);
      case 'closed':
        return Colors.grey.withValues(alpha: 0.1);
      default:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(widget.waterMeter.meterNumber),
        actions: [
          if (widget.onEdit != null)
            IconButton(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
            ),
          if (widget.onDelete != null)
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              color: Colors.red,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with basic info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: widget.waterMeter.status.color
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_damage,
                        size: 32,
                        color: widget.waterMeter.status.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.waterMeter.meterNumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.waterMeter.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildStatusChip(widget.waterMeter.status),
                        const SizedBox(height: 4),
                        _buildConnectivityChip(widget.waterMeter.connectivity),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(widget.waterMeter.type.displayName),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    ),
                    Chip(
                      label: Text(widget.waterMeter.technology.displayName),
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                    ),
                    Chip(
                      label: Text(widget.waterMeter.serviceRegion.displayName),
                      backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    ),
                    if (widget.waterMeter.isUnderWarranty)
                      Chip(
                        label: const Text('UNDER WARRANTY'),
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        avatar: const Icon(Icons.verified, size: 16),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: TabController(
                length: 4,
                vsync: ScrollableState(),
                initialIndex: _selectedTab,
              ),
              onTap: (index) => setState(() => _selectedTab = index),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Maintenance'),
                Tab(text: 'Alerts'),
                Tab(text: 'Issues'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                // Overview Tab
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Installation Details
                      _buildInfoCard(
                        title: 'Installation Details',
                        icon: Icons.install_desktop,
                        color: Colors.blue,
                        children: [
                          _buildDetailItem(
                            label: 'Installation Date',
                            value: DateFormat('dd MMM yyyy').format(
                              widget.waterMeter.installation.installationDate,
                            ),
                            icon: Icons.calendar_today,
                          ),
                          _buildDetailItem(
                            label: 'Installer',
                            value: widget.waterMeter.installation.installerName,
                            icon: Icons.person,
                          ),
                          if (widget.waterMeter.installation.installerCompany !=
                              null)
                            _buildDetailItem(
                              label: 'Company',
                              value: widget
                                  .waterMeter.installation.installerCompany!,
                              icon: Icons.business,
                            ),
                          _buildDetailItem(
                            label: 'Cost',
                            value:
                                'KSH ${widget.waterMeter.installation.installationCost.toStringAsFixed(2)}',
                            icon: Icons.attach_money,
                          ),
                          if (widget.waterMeter.installation.warrantyExpiry !=
                              null)
                            _buildDetailItem(
                              label: 'Warranty Expiry',
                              value: DateFormat('dd MMM yyyy').format(
                                widget.waterMeter.installation.warrantyExpiry!,
                              ),
                              icon: Icons.verified_user,
                            ),
                          if (widget.waterMeter.meterAgeInDays > 0)
                            _buildDetailItem(
                              label: 'Meter Age',
                              value: '${widget.waterMeter.meterAgeInDays} days',
                              icon: Icons.timelapse,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Specifications
                      _buildInfoCard(
                        title: 'Specifications',
                        icon: Icons.settings,
                        color: Colors.green,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Manufacturer',
                                  value: widget
                                      .waterMeter.specifications.manufacturer,
                                  icon: Icons.factory,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Model',
                                  value: widget.waterMeter.specifications.model,
                                  icon: Icons.model_training,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Size',
                                  value: widget.waterMeter.specifications.size,
                                  icon: Icons.straighten,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Material',
                                  value:
                                      widget.waterMeter.specifications.material,
                                  icon: Icons.construction,
                                ),
                              ),
                            ],
                          ),
                          _buildDetailItem(
                            label: 'Max Flow Rate',
                            value:
                                '${widget.waterMeter.specifications.maxFlowRate} m³/h',
                            icon: Icons.speed,
                          ),
                          _buildDetailItem(
                            label: 'Accuracy Class',
                            value:
                                widget.waterMeter.specifications.accuracyClass,
                            icon: Icons.precision_manufacturing,
                          ),
                          _buildDetailItem(
                            label: 'Pressure Rating',
                            value:
                                '${widget.waterMeter.specifications.pressureRating} bar',
                            icon: Icons.compress,
                          ),
                          _buildDetailItem(
                            label: 'Temperature Range',
                            value: widget
                                .waterMeter.specifications.operatingTemperature
                                .toString(),
                            icon: Icons.thermostat,
                          ),
                          _buildDetailItem(
                            label: 'Manufacturing Date',
                            value: DateFormat('dd MMM yyyy').format(
                              widget
                                  .waterMeter.specifications.manufacturingDate,
                            ),
                            icon: Icons.date_range,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location
                      _buildInfoCard(
                        title: 'Location',
                        icon: Icons.location_on,
                        color: Colors.purple,
                        children: [
                          _buildDetailItem(
                            label: 'Address',
                            value: widget.waterMeter.location.address,
                            icon: Icons.home,
                          ),
                          if (widget.waterMeter.location.landmark != null)
                            _buildDetailItem(
                              label: 'Landmark',
                              value: widget.waterMeter.location.landmark!,
                              icon: Icons.flag,
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Accessibility',
                                  value: widget
                                      .waterMeter.location.accessibility
                                      .toUpperCase(),
                                  icon: Icons.accessibility,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Installation Type',
                                  value: widget
                                      .waterMeter.location.installationType
                                      .toUpperCase(),
                                  icon: Icons.place,
                                ),
                              ),
                            ],
                          ),
                          if (widget.waterMeter.location.gpsCoordinates != null)
                            _buildDetailItem(
                              label: 'Coordinates',
                              value: widget.waterMeter.location.gpsCoordinates
                                  .toString(),
                              icon: Icons.gps_fixed,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Transmission
                      _buildInfoCard(
                        title: 'Transmission',
                        icon: Icons.settings_input_antenna,
                        color: Colors.orange,
                        children: [
                          _buildDetailItem(
                            label: 'Protocol',
                            value: widget
                                .waterMeter.transmission.communicationProtocol,
                            icon: Icons.settings,
                          ),
                          if (widget.waterMeter.transmission.simCardNumber !=
                              null)
                            _buildDetailItem(
                              label: 'SIM Card',
                              value:
                                  widget.waterMeter.transmission.simCardNumber!,
                              icon: Icons.sim_card,
                            ),
                          _buildDetailItem(
                            label: 'Transmission Interval',
                            value:
                                '${widget.waterMeter.transmission.dataTransmissionInterval} seconds',
                            icon: Icons.timer,
                          ),
                          _buildDetailItem(
                            label: 'Signal Threshold',
                            value: widget
                                .waterMeter.transmission.signalThreshold
                                .toString(),
                            icon: Icons.signal_cellular_alt,
                          ),
                          if (widget.waterMeter.lastCommunication != null)
                            _buildDetailItem(
                              label: 'Last Communication',
                              value: DateFormat('dd MMM yyyy HH:mm').format(
                                widget.waterMeter.lastCommunication!,
                              ),
                              icon: Icons.access_time,
                            ),
                          if (widget.waterMeter.signalStrength != null)
                            _buildDetailItem(
                              label: 'Signal Strength',
                              value: '${widget.waterMeter.signalStrength}%',
                              icon: Icons.signal_wifi_4_bar,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Battery (if available)
                      if (widget.waterMeter.battery != null)
                        _buildInfoCard(
                          title: 'Battery Information',
                          icon: Icons.battery_charging_full,
                          color: Colors.amber,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    label: 'Type',
                                    value: widget.waterMeter.battery!.type,
                                    icon: Icons.battery_std,
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailItem(
                                    label: 'Status',
                                    value: widget.waterMeter.battery!.status
                                        .toUpperCase(),
                                    icon: Icons.battery_alert,
                                  ),
                                ),
                              ],
                            ),
                            _buildDetailItem(
                              label: 'Voltage',
                              value: '${widget.waterMeter.battery!.voltage}V',
                              icon: Icons.bolt,
                            ),
                            _buildDetailItem(
                              label: 'Installed Date',
                              value: DateFormat('dd MMM yyyy').format(
                                widget.waterMeter.battery!.installedDate,
                              ),
                              icon: Icons.calendar_today,
                            ),
                            _buildDetailItem(
                              label: 'Expected Life',
                              value:
                                  '${widget.waterMeter.battery!.expectedLife} days',
                              icon: Icons.timelapse,
                            ),
                            if (widget
                                    .waterMeter.battery!.lastReplacementDate !=
                                null)
                              _buildDetailItem(
                                label: 'Last Replacement',
                                value: DateFormat('dd MMM yyyy').format(
                                  widget
                                      .waterMeter.battery!.lastReplacementDate!,
                                ),
                                icon: Icons.refresh,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Maintenance Tab
                _buildMaintenanceTab(),

                // Alerts Tab
                _buildAlertsTab(),

                // Issues Tab
                _buildIssuesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  Widget? _getFloatingActionButton() {
    if (_selectedTab == 1 && !_showMaintenanceForm) {
      return FloatingActionButton(
        onPressed: () => setState(() => _showMaintenanceForm = true),
        child: const Icon(Icons.add),
      );
    } else if (_selectedTab == 2 && !_showAlertForm) {
      return FloatingActionButton(
        onPressed: () => setState(() => _showAlertForm = true),
        child: const Icon(Icons.add_alert),
      );
    } else if (_selectedTab == 3 && !_showIssueForm) {
      return FloatingActionButton(
        onPressed: () => setState(() => _showIssueForm = true),
        child: const Icon(Icons.add_circle),
      );
    }
    return null;
  }
}
