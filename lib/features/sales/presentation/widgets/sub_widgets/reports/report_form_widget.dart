import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/report.model.dart';
import '../../../../providers/report_provider.dart';
import 'responsive.dart';

class ReportFormWidget extends ConsumerStatefulWidget {
  final Report? report;
  final bool isEditing;
  final VoidCallback? onSubmitted;
  final VoidCallback? onCancelled;

  const ReportFormWidget({
    super.key,
    this.report,
    this.isEditing = false,
    this.onSubmitted,
    this.onCancelled,
  });

  @override
  ConsumerState<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends ConsumerState<ReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late ReportType _selectedType;
  late PeriodType _selectedPeriod;
  late DateTime _reportDate;
  late DateTime _startDate;
  late DateTime _endDate;
  late ReportVisibility _visibility;

  // Metrics
  late TextEditingController _salesController;
  late TextEditingController _leadsController;
  late TextEditingController _opportunitiesController;
  late TextEditingController _quotesController;
  late TextEditingController _proposalsController;
  late TextEditingController _dealsController;
  late TextEditingController _callsController;
  late TextEditingController _emailsController;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _reportDate = widget.report?.reportDate ?? now;
    _startDate =
        widget.report?.startDate ?? now.subtract(const Duration(days: 7));
    _endDate = widget.report?.endDate ?? now;

    _selectedType = widget.report?.reportType ?? ReportType.daily;
    _selectedPeriod = widget.report?.periodType ?? PeriodType.week;
    _visibility = widget.report?.visibility ?? ReportVisibility.team;

    _titleController = TextEditingController(text: widget.report?.title ?? '');
    _summaryController =
        TextEditingController(text: widget.report?.executiveSummary ?? '');

    _salesController = TextEditingController(
        text: widget.report?.salesValue.toString() ?? '0');
    _leadsController = TextEditingController(
        text: widget.report?.leadsGenerated.toString() ?? '0');
    _opportunitiesController = TextEditingController(
        text: widget.report?.opportunitiesCreated.toString() ?? '0');
    _quotesController = TextEditingController(
        text: widget.report?.quotesSent.toString() ?? '0');
    _proposalsController = TextEditingController(
        text: widget.report?.proposalsSubmitted.toString() ?? '0');
    _dealsController = TextEditingController(
        text: widget.report?.dealsClosed.toString() ?? '0');
    _callsController =
        TextEditingController(text: widget.report?.callsMade.toString() ?? '0');
    _emailsController = TextEditingController(
        text: widget.report?.emailsSent.toString() ?? '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _salesController.dispose();
    _leadsController.dispose();
    _opportunitiesController.dispose();
    _quotesController.dispose();
    _proposalsController.dispose();
    _dealsController.dispose();
    _callsController.dispose();
    _emailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(reportProvider.notifier);
    final authState = ref.read(authProvider);

    // Ensure dates are in UTC
    final reportDate = DateTime.utc(
      _reportDate.year,
      _reportDate.month,
      _reportDate.day,
    );
    final startDate = DateTime.utc(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
    final endDate = DateTime.utc(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
      999,
    );

    final data = CreateReportData(
      title: _titleController.text.trim(),
      reportType: _selectedType,
      periodType: _selectedPeriod,
      reportDate: reportDate,
      startDate: startDate,
      endDate: endDate,
      department: authState.user?['department'] ?? 'Sales',
      team: authState.user?['team'] ?? 'General',
      executiveSummary: _summaryController.text.trim(),
      salesValue: double.tryParse(_salesController.text) ?? 0,
      leadsGenerated: int.tryParse(_leadsController.text) ?? 0,
      opportunitiesCreated: int.tryParse(_opportunitiesController.text) ?? 0,
      quotesSent: int.tryParse(_quotesController.text) ?? 0,
      proposalsSubmitted: int.tryParse(_proposalsController.text) ?? 0,
      dealsClosed: int.tryParse(_dealsController.text) ?? 0,
      callsMade: int.tryParse(_callsController.text) ?? 0,
      emailsSent: int.tryParse(_emailsController.text) ?? 0,
      visibility: _visibility,
    );

    if (widget.isEditing && widget.report != null) {
      await provider.updateReport(
        widget.report!.id,
        data.toJson(),
      );
    } else {
      await provider.createReport(data);
    }

    if (widget.onSubmitted != null) {
      widget.onSubmitted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          // Dialog Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancelled ?? () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isEditing ? 'Edit Report' : 'Create New Report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Title
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Report Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.title),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a report title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Report Type and Period
                              if (isMobile)
                                Column(
                                  children: [
                                    _buildTypeDropdown(),
                                    const SizedBox(height: 16),
                                    _buildPeriodDropdown(),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(child: _buildTypeDropdown()),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildPeriodDropdown()),
                                  ],
                                ),
                              const SizedBox(height: 16),

                              // Dates
                              if (isMobile)
                                Column(
                                  children: [
                                    _buildDateField(
                                      context,
                                      'Start Date',
                                      _startDate,
                                      true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDateField(
                                      context,
                                      'End Date',
                                      _endDate,
                                      false,
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        context,
                                        'Start Date',
                                        _startDate,
                                        true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDateField(
                                        context,
                                        'End Date',
                                        _endDate,
                                        false,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),

                              // Visibility
                              DropdownButtonFormField<ReportVisibility>(
                                value: _visibility,
                                decoration: InputDecoration(
                                  labelText: 'Visibility',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.visibility),
                                ),
                                items: ReportVisibility.values
                                    .map((visibility) => DropdownMenuItem(
                                  value: visibility,
                                  child: Text(visibility.displayName),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _visibility = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Executive Summary Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Executive Summary',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _summaryController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  labelText: 'Summary',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an executive summary';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Performance Metrics Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Performance Metrics',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isMobile)
                                Column(
                                  children: [
                                    _buildMetricRow('Sales Value (KES)',
                                        _salesController, Icons.attach_money),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Leads Generated',
                                        _leadsController, Icons.leaderboard),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Opportunities Created',
                                        _opportunitiesController,
                                        Icons.trending_up),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Quotes Sent',
                                        _quotesController, Icons.description),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Proposals Submitted',
                                        _proposalsController,
                                        Icons.file_present),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Deals Closed',
                                        _dealsController, Icons.check_circle),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Calls Made', _callsController,
                                        Icons.phone),
                                    const SizedBox(height: 12),
                                    _buildMetricRow('Emails Sent',
                                        _emailsController, Icons.email),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildMetricRow(
                                                'Sales Value (KES)',
                                                _salesController,
                                                Icons.attach_money)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: _buildMetricRow(
                                                'Leads Generated',
                                                _leadsController,
                                                Icons.leaderboard)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildMetricRow(
                                                'Opportunities Created',
                                                _opportunitiesController,
                                                Icons.trending_up)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: _buildMetricRow('Quotes Sent',
                                                _quotesController,
                                                Icons.description)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildMetricRow(
                                                'Proposals Submitted',
                                                _proposalsController,
                                                Icons.file_present)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: _buildMetricRow('Deals Closed',
                                                _dealsController,
                                                Icons.check_circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildMetricRow('Calls Made',
                                                _callsController, Icons.phone)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: _buildMetricRow('Emails Sent',
                                                _emailsController, Icons.email)),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isCreating || state.isUpdating
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.isCreating || state.isUpdating
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            widget.isEditing
                                ? 'Update Report'
                                : 'Create Report',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<ReportType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Report Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.description),
      ),
      items: ReportType.values
          .map((type) => DropdownMenuItem(
        value: type,
        child: Text(type.displayName),
      ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
    );
  }

  Widget _buildPeriodDropdown() {
    return DropdownButtonFormField<PeriodType>(
      value: _selectedPeriod,
      decoration: InputDecoration(
        labelText: 'Period Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      items: PeriodType.values
          .map((period) => DropdownMenuItem(
        value: period,
        child: Text(period.displayName),
      ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedPeriod = value);
        }
      },
    );
  }

  Widget _buildDateField(
      BuildContext context,
      String label,
      DateTime date,
      bool isStartDate,
      ) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () => _selectDate(context, isStartDate),
        ),
      ),
      controller: TextEditingController(
        text: DateFormat('dd MMM yyyy').format(date),
      ),
    );
  }

  Widget _buildMetricRow(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        final numValue = num.tryParse(value);
        if (numValue == null) {
          return 'Please enter a valid number';
        }
        if (numValue < 0) {
          return 'Value cannot be negative';
        }
        return null;
      },
    );
  }
}