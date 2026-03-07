import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/receipt_model.dart';
import '../../providers/receipt_provider.dart';
import 'sub_widgets/receipt/receipt_details_widget.dart';
import 'sub_widgets/receipt/receipt_form_widget.dart';
import 'sub_widgets/receipt/receipt_list_widget.dart';

class ReceiptContent extends ConsumerStatefulWidget {
  const ReceiptContent({super.key});

  @override
  ConsumerState<ReceiptContent> createState() => _ReceiptContentState();
}

class _ReceiptContentState extends ConsumerState<ReceiptContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load receipts when the tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptProvider.notifier).fetchReceipts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCreate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReceiptFormWidget(),
    );
  }

  void _navigateToDetails(Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptDetailsWidget(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptState = ref.watch(receiptProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: Color(0xFF0D47A1), size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Receipt Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const Spacer(),
                      if (receiptState.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _navigateToCreate,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('New Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF0D47A1),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF0D47A1),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'All Receipts'),
                    Tab(text: 'Summary'),
                    Tab(text: 'Recent Activity'),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Receipts Tab
                ReceiptListWidget(
                  onReceiptTap: _navigateToDetails,
                  scrollController: _scrollController,
                ),
                // Summary Tab
                const ReceiptSummaryWidget(),
                // Recent Activity Tab
                const RecentActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivityTab extends ConsumerWidget {
  const RecentActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptState = ref.watch(receiptProvider);
    final recentReceipts = receiptState.receipts.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Receipt Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (recentReceipts.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No recent receipts',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: recentReceipts.length,
                itemBuilder: (context, index) {
                  final receipt = recentReceipts[index];
                  return _buildActivityItem(receipt);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Receipt receipt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: receipt.receiptType.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            receipt.receiptType.icon,
            color: receipt.receiptType.color,
            size: 20,
          ),
        ),
        title: Text(
          receipt.receiptNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${receipt.payerName} • ${receipt.formattedAmount}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: receipt.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                receipt.status.displayName,
                style: TextStyle(
                  color: receipt.status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              receipt.formattedDateOnly,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptSummaryWidget extends ConsumerWidget {
  const ReceiptSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptState = ref.watch(receiptProvider);
    final receipts = receiptState.receipts;

    // Calculate summary
    final totalAmount = receipts.fold<double>(0, (sum, r) => sum + r.amount);
    final totalAllocated = receipts.fold<double>(0, (sum, r) => sum + r.allocatedAmount);
    final totalUnallocated = receipts.fold<double>(0, (sum, r) => sum + r.unallocatedAmount);
    final totalTax = receipts.fold<double>(0, (sum, r) => sum + r.taxAmount);
    final allocationRate = totalAmount > 0 ? (totalAllocated / totalAmount) * 100 : 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // Responsive Summary Cards using GridView
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: _getAspectRatio(constraints.maxWidth),
                  children: [
                    _buildSummaryCard(
                      'Total Receipts',
                      receiptState.totalReceipts.toString(),
                      Icons.receipt,
                      Colors.blue,
                    ),
                    _buildSummaryCard(
                      'Total Amount',
                      'KES ${totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    _buildSummaryCard(
                      'Allocation Rate',
                      '${allocationRate.toStringAsFixed(1)}%',
                      Icons.pie_chart,
                      Colors.orange,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Detailed Breakdown
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _buildBreakdownItem(
                          'Total Allocated',
                          'KES ${totalAllocated.toStringAsFixed(2)}',
                        ),
                        _buildBreakdownItem(
                          'Total Unallocated',
                          'KES ${totalUnallocated.toStringAsFixed(2)}',
                        ),
                        _buildBreakdownItem(
                          'Total Tax',
                          'KES ${totalTax.toStringAsFixed(2)}',
                        ),
                        const Divider(),
                        _buildBreakdownItem(
                          'Average Receipt Amount',
                          'KES ${(receipts.isNotEmpty ? totalAmount / receipts.length : 0).toStringAsFixed(2)}',
                        ),
                        _buildBreakdownItem(
                          'Confirmed Receipts',
                          receipts.where((r) => r.isConfirmed).length.toString(),
                        ),
                        _buildBreakdownItem(
                          'Draft Receipts',
                          receipts.where((r) => r.isDraft).length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 400) {
      return 1; // Very small screens: single column
    } else if (width < 600) {
      return 2; // Small screens: 2 columns
    } else {
      return 3; // Larger screens: 3 columns
    }
  }

  double _getAspectRatio(double width) {
    if (width < 400) {
      return 3.5; // Taller cards on very small screens
    } else if (width < 600) {
      return 2.5; // Medium aspect ratio for small screens
    } else {
      return 2.0; // Wider cards on larger screens
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D47A1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}