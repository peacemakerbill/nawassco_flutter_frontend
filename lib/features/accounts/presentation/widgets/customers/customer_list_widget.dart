import 'package:flutter/material.dart';

class CustomerListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> customers;
  final Function(Map<String, dynamic>) onCustomerSelected;
  final Function(String) onEditCustomer;
  final Function(String) onViewDetails;

  const CustomerListWidget({
    super.key,
    required this.customers,
    required this.onCustomerSelected,
    required this.onEditCustomer,
    required this.onViewDetails,
  });

  @override
  State<CustomerListWidget> createState() => _CustomerListWidgetState();
}

class _CustomerListWidgetState extends State<CustomerListWidget> {
  int _itemsPerPage = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _paginatedCustomers {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return widget.customers.sublist(
      startIndex,
      endIndex < widget.customers.length ? endIndex : widget.customers.length,
    );
  }

  int get _totalPages => (widget.customers.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // List Header
        _buildListHeader(),
        const SizedBox(height: 8),

        // Customer List
        Expanded(
          child: ListView.builder(
            itemCount: _paginatedCustomers.length,
            itemBuilder: (context, index) => _buildCustomerListItem(_paginatedCustomers[index]),
          ),
        ),

        // Pagination
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Account', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Zone', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCustomerListItem(Map<String, dynamic> customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(customer['status'] ?? 'Active').withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: _getStatusColor(customer['status'] ?? 'Active'),
          ),
        ),
        title: Text(
          customer['name'] ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(customer['accountNumber'] ?? 'N/A'),
        trailing: SizedBox(
          width: 200,
          child: Row(
            children: [
              Expanded(child: Text(customer['zone'] ?? 'N/A')),
              Expanded(
                child: Text(
                  'KES ${(customer['balance'] ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: (customer['balance'] ?? 0.0) > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customer['status'] ?? 'Active').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer['status'] ?? 'Active',
                    style: TextStyle(
                      color: _getStatusColor(customer['status'] ?? 'Active'),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                onSelected: (value) => _handleMenuAction(value, customer),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Account')),
                  const PopupMenuItem(value: 'statement', child: Text('Generate Statement')),
                  const PopupMenuItem(value: 'contact', child: Text('Contact Customer')),
                ],
              ),
            ],
          ),
        ),
        onTap: () => widget.onCustomerSelected(customer),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page
          Row(
            children: [
              const Text('Items per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _itemsPerPage,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 25, child: Text('25')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (value) => setState(() {
                  _itemsPerPage = value!;
                  _currentPage = 0;
                }),
              ),
            ],
          ),

          // Page info
          Text('Page ${_currentPage + 1} of $_totalPages'),

          // Pagination buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? _previousPage : null,
              ),
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

  void _previousPage() {
    setState(() => _currentPage--);
  }

  void _nextPage() {
    setState(() => _currentPage++);
  }

  void _handleMenuAction(String action, Map<String, dynamic> customer) {
    final accountNumber = customer['accountNumber'] ?? '';
    switch (action) {
      case 'view':
        widget.onViewDetails(accountNumber);
        break;
      case 'edit':
        widget.onEditCustomer(accountNumber);
        break;
      case 'statement':
        _generateStatement(accountNumber);
        break;
      case 'contact':
        _contactCustomer(customer);
        break;
    }
  }

  void _generateStatement(String accountNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statement generated for $accountNumber')),
    );
  }

  void _contactCustomer(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${customer['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${customer['phone'] ?? 'N/A'}'),
            Text('Email: ${customer['email'] ?? 'N/A'}'),
            Text('Address: ${customer['address'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'active' => Colors.green,
      'overdue' => Colors.orange,
      'delinquent' => Colors.red,
      'inactive' => Colors.grey,
      _ => Colors.blue,
    };
  }
}