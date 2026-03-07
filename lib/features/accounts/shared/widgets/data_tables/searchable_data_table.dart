import 'package:flutter/material.dart';

class SearchableDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final Map<String, String> columnDisplayNames;
  final Function(String, String) onSearch;
  final Function(Map<String, dynamic>) onRowTap;
  final bool paginated;
  final int itemsPerPage;
  final List<Widget>? actions;

  const SearchableDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.columnDisplayNames,
    required this.onSearch,
    required this.onRowTap,
    this.paginated = true,
    this.itemsPerPage = 10,
    this.actions,
  });

  @override
  State<SearchableDataTable> createState() => _SearchableDataTableState();
}

class _SearchableDataTableState extends State<SearchableDataTable> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'all';
  int _currentPage = 0;
  String _sortColumn = '';
  bool _sortAscending = true;

  List<Map<String, dynamic>> get _filteredData {
    var filtered = widget.data;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((row) {
        final searchText = _searchController.text.toLowerCase();
        return row.entries.any((entry) =>
            entry.value.toString().toLowerCase().contains(searchText)
        );
      }).toList();
    }

    // Apply sorting
    if (_sortColumn.isNotEmpty) {
      filtered.sort((a, b) {
        final aValue = a[_sortColumn] ?? '';
        final bValue = b[_sortColumn] ?? '';

        final comparison = _compareValues(aValue, bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedData {
    if (!widget.paginated) return _filteredData;

    final startIndex = _currentPage * widget.itemsPerPage;
    final endIndex = startIndex + widget.itemsPerPage;
    return _filteredData.sublist(
      startIndex,
      endIndex < _filteredData.length ? endIndex : _filteredData.length,
    );
  }

  int get _totalPages => (widget.data.length / widget.itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Controls
        _buildControls(),
        const SizedBox(height: 16),

        // Data Table
        Expanded(
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                // Table Header
                _buildTableHeader(),

                // Table Body
                Expanded(
                  child: _filteredData.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    itemCount: _paginatedData.length,
                    itemBuilder: (context, index) =>
                        _buildTableRow(_paginatedData[index]),
                  ),
                ),

                // Pagination
                if (widget.paginated) _buildPagination(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search across all columns...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch();
                    },
                  )
                      : null,
                ),
                onChanged: (value) => _performSearch(),
              ),
            ),
            if (widget.actions != null) ...[
              const SizedBox(width: 16),
              ...widget.actions!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: widget.columns.map((column) {
          final isSorted = _sortColumn == column;
          return Expanded(
            child: InkWell(
              onTap: () => _sortTable(column),
              child: Row(
                children: [
                  Text(
                    widget.columnDisplayNames[column] ?? column,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isSorted) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> row) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => widget.onRowTap(row),
        title: Row(
          children: widget.columns.map((column) {
            return Expanded(
              child: Text(
                _formatValue(row[column]),
                style: _getTextStyle(column, row[column]),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No data found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(color: Colors.grey),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_paginatedData.length} of ${_filteredData.length} records',
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? _previousPage : null,
              ),
              Text('Page ${_currentPage + 1} of $_totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    widget.onSearch(_searchController.text, _searchType);
    setState(() => _currentPage = 0);
  }

  void _sortTable(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  void _previousPage() {
    setState(() => _currentPage--);
  }

  void _nextPage() {
    setState(() => _currentPage++);
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a is num && b is num) {
      return a.compareTo(b);
    }
    return a.toString().compareTo(b.toString());
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  TextStyle _getTextStyle(String column, dynamic value) {
    if (column.toLowerCase().contains('balance') && value is num) {
      return TextStyle(
        color: value > 0 ? Colors.red : Colors.green,
        fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
      );
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
      'overdue' => Colors.orange,
      'delinquent' => Colors.red,
      'completed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }
}