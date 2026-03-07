import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/receipt_model.dart';
import '../../../../providers/receipt_provider.dart';
import 'receipt_filter_widget.dart';

class ReceiptListWidget extends ConsumerStatefulWidget {
  final Function(Receipt) onReceiptTap;
  final ScrollController scrollController;

  const ReceiptListWidget({
    super.key,
    required this.onReceiptTap,
    required this.scrollController,
  });

  @override
  ConsumerState<ReceiptListWidget> createState() => _ReceiptListWidgetState();
}

class _ReceiptListWidgetState extends ConsumerState<ReceiptListWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ref.read(receiptProvider.notifier).fetchReceipts();
    }
  }

  void _applySearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Implement search logic here
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.all(20),
        child: ReceiptFilterWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptState = ref.watch(receiptProvider);
    final receipts = receiptState.receipts;

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by receipt number, payer name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        // Receipts Count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[50],
          child: Row(
            children: [
              Text(
                '${receiptState.totalReceipts} receipts found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (receiptState.filters.isNotEmpty)
                Chip(
                  label: Text(
                    '${receiptState.filters.length} filter${receiptState.filters.length > 1 ? 's' : ''} applied',
                  ),
                  onDeleted: () {
                    ref.read(receiptProvider.notifier).setFilters({});
                  },
                ),
            ],
          ),
        ),
        // Receipts List
        if (receiptState.isLoading && receipts.isEmpty)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (receipts.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No receipts found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first receipt to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(receiptProvider.notifier).fetchReceipts();
              },
              child: ListView.builder(
                controller: widget.scrollController,
                itemCount: receipts.length + 1,
                itemBuilder: (context, index) {
                  if (index == receipts.length) {
                    return _buildPaginationLoader(receiptState);
                  }
                  return ReceiptListItem(
                    receipt: receipts[index],
                    onTap: () => widget.onReceiptTap(receipts[index]),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaginationLoader(ReceiptState state) {
    if (state.currentPage >= state.totalPages) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No more receipts to load',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container();
  }
}

class ReceiptListItem extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptListItem({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: receipt.receiptType.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            receipt.receiptType.icon,
            color: receipt.receiptType.color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              receipt.receiptNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: receipt.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                receipt.status.displayName,
                style: TextStyle(
                  color: receipt.status.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              receipt.payerName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              '${receipt.receiptType.displayName} • ${receipt.formattedDateOnly}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (receipt.payerEmail.isNotEmpty || receipt.payerPhone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  receipt.payerContactInfo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  receipt.paymentMethod.icon,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  receipt.paymentMethod.displayName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              receipt.formattedAmount,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 4),
            _buildAllocationIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationIndicator() {
    final percentage = receipt.allocationPercentage;
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: percentage == 100
                ? Colors.green
                : percentage > 50
                ? Colors.orange
                : Colors.blue,
          ),
          const SizedBox(height: 2),
          Text(
            '${percentage.toStringAsFixed(1)}% allocated',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}