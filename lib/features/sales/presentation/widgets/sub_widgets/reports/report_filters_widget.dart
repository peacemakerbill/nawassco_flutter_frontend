import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/report.model.dart';
import 'responsive.dart';

class ReportFiltersWidget extends StatefulWidget {
  final ReportFilters filters;
  final ValueChanged<ReportFilters> onFiltersChanged;
  final VoidCallback onClearFilters;

  const ReportFiltersWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<ReportFiltersWidget> createState() => _ReportFiltersWidgetState();
}

class _ReportFiltersWidgetState extends State<ReportFiltersWidget> {
  late TextEditingController _searchController;
  late ReportType? _selectedType;
  late ReportStatus? _selectedStatus;
  late ApprovalStatus? _selectedApproval;
  late DateTime? _startDateFrom;
  late DateTime? _startDateTo;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search);
    _selectedType = widget.filters.reportType;
    _selectedStatus = widget.filters.status;
    _selectedApproval = widget.filters.approvalStatus;
    _startDateFrom = widget.filters.startDateFrom;
    _startDateTo = widget.filters.startDateTo;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      widget.filters.copyWith(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        reportType: _selectedType,
        status: _selectedStatus,
        approvalStatus: _selectedApproval,
        startDateFrom: _startDateFrom,
        startDateTo: _startDateTo,
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedType = null;
    _selectedStatus = null;
    _selectedApproval = null;
    _startDateFrom = null;
    _startDateTo = null;
    widget.onClearFilters();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? _startDateFrom ?? DateTime.now()
          : _startDateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _startDateFrom = picked;
        } else {
          _startDateTo = picked;
        }
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hasFilters = widget.filters.hasFilters;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (hasFilters)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
              onSubmitted: (_) => _applyFilters(),
            ),
            const SizedBox(height: 16),

            if (isMobile)
              Column(
                children: [
                  _buildMobileFilterRow('Type', _buildTypeDropdown()),
                  const SizedBox(height: 12),
                  _buildMobileFilterRow('Status', _buildStatusDropdown()),
                  const SizedBox(height: 12),
                  _buildMobileFilterRow('Approval', _buildApprovalDropdown()),
                  const SizedBox(height: 12),
                  _buildDateFiltersMobile(),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildTypeDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildApprovalDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateFiltersDesktop()),
                ],
              ),

            if (!isMobile) const SizedBox(height: 16),
            if (!isMobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.filter_alt, size: 16),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFilterRow(String label, Widget filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        filter,
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<ReportType?>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Report Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Types'),
        ),
        ...ReportType.values
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ))
            .toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedType = value);
        _applyFilters();
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<ReportStatus?>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Statuses'),
        ),
        ...ReportStatus.values
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                ))
            .toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value);
        _applyFilters();
      },
    );
  }

  Widget _buildApprovalDropdown() {
    return DropdownButtonFormField<ApprovalStatus?>(
      value: _selectedApproval,
      decoration: InputDecoration(
        labelText: 'Approval Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All'),
        ),
        ...ApprovalStatus.values
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                ))
            .toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedApproval = value);
        _applyFilters();
      },
    );
  }

  Widget _buildDateFiltersMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildDateField('From', _startDateFrom, true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateField('To', _startDateTo, false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFiltersDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date Range',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildDateField('From', _startDateFrom, true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateField('To', _startDateTo, false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isFrom) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, size: 18),
          onPressed: () => _selectDate(context, isFrom),
        ),
      ),
      controller: TextEditingController(
        text: date != null ? DateFormat('dd MMM yyyy').format(date) : '',
      ),
    );
  }
}
