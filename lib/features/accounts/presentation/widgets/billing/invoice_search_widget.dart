import 'package:flutter/material.dart';

class InvoiceSearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  const InvoiceSearchWidget({super.key, required this.onSearch});

  @override
  State<InvoiceSearchWidget> createState() => _InvoiceSearchWidgetState();
}

class _InvoiceSearchWidgetState extends State<InvoiceSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'invoiceNumber';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(value: 'invoiceNumber', child: Text('Invoice No.')),
                    DropdownMenuItem(value: 'accountNumber', child: Text('Account No.')),
                    DropdownMenuItem(value: 'customerName', child: Text('Customer Name')),
                  ],
                  onChanged: (value) => setState(() => _searchType = value!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getHintText(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    return switch (_searchType) {
      'invoiceNumber' => 'Enter invoice number...',
      'accountNumber' => 'Enter account number...',
      'customerName' => 'Enter customer name...',
      _ => 'Search...',
    };
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      widget.onSearch(_searchController.text);
    }
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      {'type': 'Invoice No.', 'value': 'INV-2024-001234', 'date': 'Today'},
      {'type': 'Account No.', 'value': 'ACC001234', 'date': 'Yesterday'},
      {'type': 'Customer Name', 'value': 'John Kamau', 'date': '2 days ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Searches:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...recentSearches.map((search) => _buildRecentSearchItem(search)),
      ],
    );
  }

  Widget _buildRecentSearchItem(Map<String, String> search) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.history, size: 16),
      title: Text('${search['type']}: ${search['value']}'),
      subtitle: Text(search['date']!),
      trailing: IconButton(
        icon: const Icon(Icons.search, size: 16),
        onPressed: () {
          _searchController.text = search['value']!;
          _performSearch();
        },
      ),
    );
  }
}