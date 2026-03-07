import 'package:flutter/material.dart';

class PaginatedTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int rowsPerPage;
  final bool sortAscending;
  final int? sortColumnIndex;
  final Function(int, bool)? onSort;
  final String? emptyMessage;
  final Widget? header;

  const PaginatedTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowsPerPage = 10,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
    this.emptyMessage,
    this.header,
  });

  @override
  State<PaginatedTable> createState() => _PaginatedTableState();
}

class _PaginatedTableState extends State<PaginatedTable> {
  int _currentPage = 0;

  List<DataRow> get _currentPageRows {
    final startIndex = _currentPage * widget.rowsPerPage;
    final endIndex = startIndex + widget.rowsPerPage;
    return widget.rows.sublist(
      startIndex,
      endIndex < widget.rows.length ? endIndex : widget.rows.length,
    );
  }

  int get _totalPages => (widget.rows.length / widget.rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        if (widget.header != null) widget.header!,

        // Table
        Expanded(
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                // Table
                Expanded(
                  child: widget.rows.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: widget.columns,
                        rows: _currentPageRows,
                        sortAscending: widget.sortAscending,
                        sortColumnIndex: widget.sortColumnIndex,
                        headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[50],
                        ),
                        dataRowMaxHeight: 60,
                        showCheckboxColumn: false,
                        dividerThickness: 1,
                        columnSpacing: 20,
                      ),
                    ),
                  ),
                ),

                // Pagination
                if (widget.rows.isNotEmpty) _buildPagination(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.table_chart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No data available',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rows per page info
          Text(
            'Showing ${_currentPageRows.length} of ${widget.rows.length} entries',
            style: const TextStyle(fontSize: 12),
          ),

          // Pagination controls
          Row(
            children: [
              // Items per page
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: widget.rowsPerPage,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 25, child: Text('25')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                  DropdownMenuItem(value: 100, child: Text('100')),
                ],
                onChanged: (value) {
                  // This would typically be handled by parent widget
                },
              ),
              const SizedBox(width: 32),

              // Page navigation
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 0 ? _goToFirstPage : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? _previousPage : null,
              ),

              // Page info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages - 1 ? _goToLastPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToFirstPage() {
    setState(() => _currentPage = 0);
  }

  void _previousPage() {
    setState(() => _currentPage--);
  }

  void _nextPage() {
    setState(() => _currentPage++);
  }

  void _goToLastPage() {
    setState(() => _currentPage = _totalPages - 1);
  }
}

// Helper extension for creating data rows easily
extension DataRowExtension on Map<String, dynamic> {
  DataRow toDataRow({
    required List<String> columns,
    Function()? onSelectChanged,
    bool selected = false,
  }) {
    return DataRow(
      cells: columns.map((column) {
        return DataCell(
          Text(
            _formatValue(this[column]),
            style: _getCellStyle(column, this[column]),
          ),
        );
      }).toList(),
      selected: selected,
      onSelectChanged: onSelectChanged != null ? (value) => onSelectChanged() : null,
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }

  TextStyle _getCellStyle(String column, dynamic value) {
    if (column.toLowerCase().contains('balance') && value is num) {
      return TextStyle(
        color: value > 0 ? Colors.red : Colors.green,
        fontWeight: FontWeight.w500,
      );
    }
    if (column.toLowerCase().contains('amount') && value is num) {
      return const TextStyle(fontWeight: FontWeight.w500);
    }
    if (column.toLowerCase().contains('status')) {
      final color = _getStatusColor(value.toString());
      return TextStyle(color: color, fontWeight: FontWeight.w500);
    }
    return const TextStyle();
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'active' => Colors.green,
      'paid' => Colors.green,
      'completed' => Colors.green,
      'overdue' => Colors.orange,
      'pending' => Colors.orange,
      'delinquent' => Colors.red,
      'cancelled' => Colors.red,
      'failed' => Colors.red,
      _ => Colors.grey,
    };
  }
}