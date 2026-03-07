import 'package:flutter/material.dart';
import '../../../../models/decision_log_model.dart';
import '../../../../providers/decision_log_provider.dart';
import 'decision_log_card.dart';

class DecisionLogList extends StatefulWidget {
  final DecisionLogState state;
  final Function(DecisionLog) onViewDetail;
  final Function(DecisionLog) onEdit;
  final VoidCallback onCreateNew;
  final VoidCallback onRefresh;

  const DecisionLogList({
    super.key,
    required this.state,
    required this.onViewDetail,
    required this.onEdit,
    required this.onCreateNew,
    required this.onRefresh,
  });

  @override
  State<DecisionLogList> createState() => _DecisionLogListState();
}

class _DecisionLogListState extends State<DecisionLogList> {
  final TextEditingController _searchController = TextEditingController();
  DecisionStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onRefresh();
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    setState(() {});
    widget.onRefresh();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with filters
        _buildHeader(),
        const SizedBox(height: 16),

        // Content
        Expanded(
          child: widget.state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.state.decisionLogs.isEmpty
                  ? _buildEmptyState()
                  : _buildListContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and stats
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Decision Logs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.state.totalItems} logs',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search decision logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
            const SizedBox(height: 16),

            // Filters
            Row(
              children: [
                // Status filter
                Expanded(
                  child: DropdownButtonFormField<DecisionStatus?>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...DecisionStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, color: status.color, size: 16),
                              const SizedBox(width: 8),
                              Text(status.label),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Date range filters
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null
                          ? 'From: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Start Date',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate != null
                          ? 'To: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'End Date',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.state.decisionLogs.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.state.decisionLogs.length) {
            return _buildPagination();
          }
          final log = widget.state.decisionLogs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecisionLogCard(
              decisionLog: log,
              onViewDetail: () => widget.onViewDetail(log),
              onEdit: () => widget.onEdit(log),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagination() {
    if (widget.state.totalPages <= 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: widget.state.currentPage > 1
                ? () {
                    // Load previous page
                  }
                : null,
          ),
          ...List.generate(widget.state.totalPages, (index) {
            final pageNumber = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  // Load specific page
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.state.currentPage == pageNumber
                        ? Colors.blue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.state.currentPage == pageNumber
                          ? Colors.blue
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    pageNumber.toString(),
                    style: TextStyle(
                      color: widget.state.currentPage == pageNumber
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: widget.state.currentPage == pageNumber
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: widget.state.currentPage < widget.state.totalPages
                ? () {
                    // Load next page
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Decision Logs Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.state.filters.isNotEmpty
                  ? 'Try adjusting your filters or search term'
                  : 'Start by creating your first decision log',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onCreateNew,
              icon: const Icon(Icons.add),
              label: const Text('Create Decision Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
