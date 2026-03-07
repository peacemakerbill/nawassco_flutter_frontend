import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/invoice.dart';
import '../../../providers/invoice_provider.dart';
import '../sub_screens/invoice/invoice_detail_screen.dart';
import '../sub_screens/invoice/invoice_form_screen.dart';


class InvoiceListContent extends ConsumerStatefulWidget {
  const InvoiceListContent({super.key});

  @override
  ConsumerState<InvoiceListContent> createState() => _InvoiceListContentState();
}

class _InvoiceListContentState extends ConsumerState<InvoiceListContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoiceProvider.notifier).getInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),

          // Stats Section
          _buildStatsSection(),

          // Invoice List
          Expanded(
            child: _buildInvoiceList(invoiceState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoiceFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search invoices...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(invoiceProvider.notifier).getInvoices();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3 || value.isEmpty) {
                ref.read(invoiceProvider.notifier).getInvoices(
                  filters: {'search': value.isEmpty ? null : value},
                );
              }
            },
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Draft', 'draft'),
                _buildFilterChip('Submitted', 'submitted'),
                _buildFilterChip('Approved', 'approved'),
                _buildFilterChip('Paid', 'paid'),
                _buildFilterChip('Overdue', 'overdue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
          Map<String, dynamic> filters = {};
          if (value != 'all') {
            if (value == 'overdue') {
              filters['overdue'] = 'true';
            } else {
              filters['status'] = value;
            }
          }
          ref.read(invoiceProvider.notifier).getInvoices(filters: filters);
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final invoiceState = ref.watch(invoiceProvider);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', invoiceState.totalInvoices.toString(), Icons.receipt),
                _buildStatItem('Draft',
                    invoiceState.invoices.where((i) => i.status == InvoiceStatus.draft).length.toString(),
                    Icons.drafts
                ),
                _buildStatItem('Overdue',
                    invoiceState.invoices.where((i) => i.paymentStatus == PaymentStatus.overdue).length.toString(),
                    Icons.warning
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInvoiceList(InvoiceState state) {
    if (state.isLoading && state.invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(invoiceProvider.notifier).getInvoices();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.invoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No invoices found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(invoiceProvider.notifier).getInvoices();
      },
      child: ListView.builder(
        itemCount: state.invoices.length + 1, // +1 for load more
        itemBuilder: (context, index) {
          if (index == state.invoices.length) {
            if (state.currentPage < state.totalPages) {
              // Load more button
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(invoiceProvider.notifier).getInvoices(
                      page: state.currentPage + 1,
                    );
                  },
                  child: const Text('Load More'),
                ),
              );
            } else {
              return const SizedBox();
            }
          }

          final invoice = state.invoices[index];
          return _buildInvoiceListItem(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceListItem(Invoice invoice) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(invoice.status),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(invoice.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.supplierName),
            Text(
              'KES ${invoice.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            Row(
              children: [
                _buildStatusChip(invoice.status),
                const SizedBox(width: 4),
                _buildPaymentChip(invoice.paymentStatus),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Due: ${_formatDate(invoice.dueDate)}',
              style: TextStyle(
                color: invoice.dueDate.isBefore(DateTime.now()) &&
                    invoice.paymentStatus != PaymentStatus.paid
                    ? Colors.red
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (invoice.age > 0)
              Text(
                '${invoice.age} days',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Chip(
      label: Text(
        statusInfo['label'],
        style: TextStyle(fontSize: 10, color: statusInfo['color']),
      ),
      backgroundColor: statusInfo['color'].withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPaymentChip(PaymentStatus status) {
    final paymentInfo = _getPaymentInfo(status);
    return Chip(
      label: Text(
        paymentInfo['label'],
        style: TextStyle(fontSize: 10, color: paymentInfo['color']),
      ),
      backgroundColor: paymentInfo['color'].withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Map<String, dynamic> _getStatusInfo(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return {'label': 'Draft', 'color': Colors.grey};
      case InvoiceStatus.submitted:
        return {'label': 'Submitted', 'color': Colors.orange};
      case InvoiceStatus.verified:
        return {'label': 'Verified', 'color': Colors.blue};
      case InvoiceStatus.approved:
        return {'label': 'Approved', 'color': Colors.green};
      case InvoiceStatus.paid:
        return {'label': 'Paid', 'color': Colors.purple};
      case InvoiceStatus.disputed:
        return {'label': 'Disputed', 'color': Colors.red};
      case InvoiceStatus.cancelled:
        return {'label': 'Cancelled', 'color': Colors.black};
    }
  }

  Map<String, dynamic> _getPaymentInfo(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return {'label': 'Pending', 'color': Colors.orange};
      case PaymentStatus.partially_paid:
        return {'label': 'Partial', 'color': Colors.blue};
      case PaymentStatus.paid:
        return {'label': 'Paid', 'color': Colors.green};
      case PaymentStatus.overdue:
        return {'label': 'Overdue', 'color': Colors.red};
      case PaymentStatus.cancelled:
        return {'label': 'Cancelled', 'color': Colors.black};
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.submitted:
        return Colors.orange;
      case InvoiceStatus.verified:
        return Colors.blue;
      case InvoiceStatus.approved:
        return Colors.green;
      case InvoiceStatus.paid:
        return Colors.purple;
      case InvoiceStatus.disputed:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.drafts;
      case InvoiceStatus.submitted:
        return Icons.send;
      case InvoiceStatus.verified:
        return Icons.verified;
      case InvoiceStatus.approved:
        return Icons.check_circle;
      case InvoiceStatus.paid:
        return Icons.payment;
      case InvoiceStatus.disputed:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}