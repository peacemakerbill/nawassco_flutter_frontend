import 'package:flutter/material.dart';

class CustomerSearchWidget extends StatefulWidget {
  final Function(String, String) onSearch;
  final Function() onNewCustomer;

  const CustomerSearchWidget({
    super.key,
    required this.onSearch,
    required this.onNewCustomer,
  });

  @override
  State<CustomerSearchWidget> createState() => _CustomerSearchWidgetState();
}

class _CustomerSearchWidgetState extends State<CustomerSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'name';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getHintText(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'account', child: Text('Account')),
                    DropdownMenuItem(value: 'service', child: Text('Meter')),
                  ],
                  onChanged: (value) => setState(() {
                    _searchType = value!;
                    _performSearch();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                      DropdownMenuItem(value: 'delinquent', child: Text('Delinquent')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) => setState(() {
                      _filterStatus = value!;
                      _performSearch();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: widget.onNewCustomer,
                  icon: const Icon(Icons.add),
                  label: const Text('New Customer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    return switch (_searchType) {
      'name' => 'Search by customer name...',
      'account' => 'Search by account number...',
      'service' => 'Search by service number...',
      _ => 'Search...',
    };
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      widget.onSearch(_searchController.text, _filterStatus);
    }
  }

  Widget _buildQuickFilters() {
    final quickFilters = [
      {'label': 'High Balance', 'count': '23', 'color': Colors.red},
      {'label': 'Due Today', 'count': '15', 'color': Colors.orange},
      {'label': 'New Accounts', 'count': '8', 'color': Colors.green},
      {'label': 'Need Follow-up', 'count': '42', 'color': Colors.blue},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickFilters.map((filter) => _buildQuickFilterChip(filter)).toList(),
    );
  }

  Widget _buildQuickFilterChip(Map<String, dynamic> filter) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(filter['label']!),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: filter['color'],
              shape: BoxShape.circle,
            ),
            child: Text(
              filter['count']!,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
      selected: false,
      onSelected: (selected) {
        // Apply quick filter
        _searchController.text = filter['label']!;
        _performSearch();
      },
    );
  }
}