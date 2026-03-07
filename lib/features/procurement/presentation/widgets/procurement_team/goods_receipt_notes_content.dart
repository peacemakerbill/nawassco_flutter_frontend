import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/goods_receipt_note.dart';
import '../../../providers/goods_receipt_note_provider.dart';
import '../sub_screens/goods_receipt_note/create_grn_screen.dart';
import '../sub_screens/goods_receipt_note/grn_detail_screen.dart';
import '../sub_screens/goods_receipt_note/inspect_grn_screen.dart';

class GoodsReceiptNotesContent extends ConsumerStatefulWidget {
  const GoodsReceiptNotesContent({super.key});

  @override
  ConsumerState<GoodsReceiptNotesContent> createState() => _GoodsReceiptNotesContentState();
}

class _GoodsReceiptNotesContentState extends ConsumerState<GoodsReceiptNotesContent> {
  final List<String> _filterStatuses = ['All', 'draft', 'received', 'inspected', 'approved', 'returned'];
  final List<String> _filterQualityStatuses = ['All', 'pending', 'passed', 'failed', 'conditional'];
  String _filterStatus = 'All';
  String _filterQualityStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load GRNs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goodsReceiptNotesProvider.notifier).getGRNs();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteGRN(String grnId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete GRN'),
        content: const Text('Are you sure you want to delete this goods receipt note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(goodsReceiptNotesProvider.notifier).deleteGRN(grnId);
        _showSuccessSnackbar('GRN deleted successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to delete GRN: $e');
      }
    }
  }

  Future<void> _approveGRN(String grnId) async {
    try {
      await ref.read(goodsReceiptNotesProvider.notifier).approveGRN(grnId);
      _showSuccessSnackbar('GRN approved successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to approve GRN: $e');
    }
  }

  void _refreshGRNs() {
    ref.read(goodsReceiptNotesProvider.notifier).getGRNs(
      status: _filterStatus == 'All' ? null : _filterStatus,
      qualityStatus: _filterQualityStatus == 'All' ? null : _filterQualityStatus,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grnsAsync = ref.watch(goodsReceiptNotesProvider);

    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refreshGRNs(),
            child: grnsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshGRNs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (grns) {
                if (grns.isEmpty) {
                  return const Center(
                    child: Text(
                      'No goods receipt notes found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grns.length,
                  itemBuilder: (context, index) => _buildGRNCard(grns[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Goods Receipt Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGRN(),
            icon: const Icon(Icons.add),
            label: const Text('New GRN'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search GRNs...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _refreshGRNs();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterStatuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.toUpperCase()),
                    selected: _filterStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = selected ? status : 'All';
                      });
                      _refreshGRNs();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quality Status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterQualityStatuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.toUpperCase()),
                    selected: _filterQualityStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _filterQualityStatus = selected ? status : 'All';
                      });
                      _refreshGRNs();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGRNCard(GoodsReceiptNote grn) {
    final isDraft = grn.status == 'draft';
    final isReceived = grn.status == 'received';
    final isInspected = grn.status == 'inspected';
    final needsInspection = isReceived && grn.qualityStatus == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grn.grnNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PO: ${grn.purchaseOrderNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(grn.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        grn.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(grn.status),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getQualityStatusColor(grn.qualityStatus).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        grn.qualityStatus.toUpperCase(),
                        style: TextStyle(
                          color: _getQualityStatusColor(grn.qualityStatus),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(child: Text('Supplier: ${grn.supplierName}')),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Received by: ${grn.receivedByName}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Date: ${_formatDate(grn.receiptDate)}'),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Location: ${grn.storageLocation}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items: ${grn.items.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Qty: ${grn.totalQuantity}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Value:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'KES ${grn.totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (grn.hasReturns) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Has Returns',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToGRNDetails(grn),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (needsInspection)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToInspectGRN(grn),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Inspect'),
                    ),
                  ),
                if (isInspected) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveGRN(grn.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
                if (isDraft) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteGRN(grn.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.blue;
      case 'received':
        return Colors.orange;
      case 'inspected':
        return Colors.purple;
      case 'approved':
        return Colors.green;
      case 'returned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getQualityStatusColor(String qualityStatus) {
    switch (qualityStatus) {
      case 'pending':
        return Colors.orange;
      case 'passed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'conditional':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToGRNDetails(GoodsReceiptNote grn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GRNDetailScreen(grnId: grn.id),
      ),
    );
  }

  void _navigateToCreateGRN() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGRNScreen()),
    ).then((_) => _refreshGRNs());
  }

  void _navigateToInspectGRN(GoodsReceiptNote grn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectGRNScreen(grn: grn),
      ),
    ).then((_) => _refreshGRNs());
  }
}