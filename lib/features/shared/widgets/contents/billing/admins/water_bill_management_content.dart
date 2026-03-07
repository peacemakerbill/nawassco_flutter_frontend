import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/water_bill_model.dart';
import '../../../../providers/water_bill_provider.dart';
import '../../../sub_widgets/water_bill/filter_panel.dart';
import '../../../sub_widgets/water_bill/stats_summary.dart';
import '../../../sub_widgets/water_bill/water_bill_card.dart';
import '../../../sub_widgets/water_bill/water_bill_details.dart';
import '../../../sub_widgets/water_bill/water_bill_form.dart';

class WaterBillManagementContent extends ConsumerStatefulWidget {
  const WaterBillManagementContent({super.key});

  @override
  ConsumerState<WaterBillManagementContent> createState() =>
      _WaterBillManagementContentState();
}

class _WaterBillManagementContentState
    extends ConsumerState<WaterBillManagementContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterBillProvider.notifier).toggleView(true);
    });
  }

  void _refreshBills() {
    ref.read(waterBillProvider.notifier).fetchAllBills();
  }

  void _createBill(WaterBill bill) async {
    final success = await ref.read(waterBillProvider.notifier).createBill(bill);
    if (success) {
      setState(() {
        _showCreateForm = false;
      });
      _refreshBills();
    }
  }

  void _updateBill(WaterBill bill) async {
    final success =
        await ref.read(waterBillProvider.notifier).updateBill(bill.id!, bill);
    if (success) {
      _refreshBills();
    }
  }

  void _deleteBill(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text(
            'Are you sure you want to delete this bill? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(waterBillProvider.notifier).deleteBill(id);
      if (success) {
        _refreshBills();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waterBillProvider);
    final authState = ref.watch(authProvider);
    final notifier = ref.read(waterBillProvider.notifier);

    // Check if user has management access
    if (!authState.isAdmin &&
        !authState.isManager &&
        !authState.isAccounts &&
        !authState.isSalesAgent) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to access water bill management.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show bill details if selected
    if (state.selectedBill != null) {
      return WaterBillDetails(
        bill: state.selectedBill!,
        isManagementView: true,
        onBack: () => notifier.selectBill(null),
        onRefresh: _refreshBills,
      );
    }

    // Show create form
    if (_showCreateForm) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _showCreateForm = false;
              });
            },
          ),
          title: const Text('Create New Water Bill'),
        ),
        body: WaterBillForm(
          onSubmit: _createBill,
        ),
      );
    }

    // Show management interface
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showCreateForm = true;
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('NEW BILL'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Water Bill Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_showFilters
                              ? Icons.filter_alt_off
                              : Icons.filter_alt),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          tooltip: 'Toggle Filters',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshBills,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.bills.isNotEmpty
                      ? '${state.bills.length} bill${state.bills.length != 1 ? 's' : ''} found'
                      : 'No bills found',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Filters Panel
          if (_showFilters)
            FilterPanel(
              currentFilters: state.filters,
              onApplyFilters: notifier.applyFilters,
              onClearFilters: notifier.clearFilters,
              isManagementView: true,
            ),

          // Stats Summary
          if (state.bills.isNotEmpty)
            StatsSummary(
              stats: {
                'totalBills': state.bills.length,
                'totalAmount': state.bills
                    .fold(0.0, (sum, bill) => sum + bill.totalAmount),
                'totalPaid':
                    state.bills.fold(0.0, (sum, bill) => sum + bill.paidAmount),
                'totalBalance':
                    state.bills.fold(0.0, (sum, bill) => sum + bill.balance),
                'statusCounts': {
                  'pending':
                      state.bills.where((b) => b.status == 'pending').length,
                  'paid': state.bills.where((b) => b.status == 'paid').length,
                  'overdue':
                      state.bills.where((b) => b.status == 'overdue').length,
                  'partially_paid': state.bills
                      .where((b) => b.status == 'partially_paid')
                      .length,
                  'cancelled':
                      state.bills.where((b) => b.status == 'cancelled').length,
                },
                'averageConsumption': state.bills.isNotEmpty
                    ? state.bills
                            .fold(0.0, (sum, bill) => sum + bill.consumption) /
                        state.bills.length
                    : 0,
              },
              isManagementView: true,
            ),

          // Loading/Error States
          if (state.isLoading && state.bills.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.error != null && state.bills.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading bills',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshBills,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (state.bills.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No water bills found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start by creating a new water bill or adjust your filters',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showCreateForm = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('CREATE NEW BILL'),
                    ),
                  ],
                ),
              ),
            )
          else
            // Bills List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshBills();
                  return;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: state.bills.length,
                  itemBuilder: (context, index) {
                    final bill = state.bills[index];
                    return Dismissible(
                      key: Key(bill.id ?? 'bill_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Bill'),
                            content: const Text(
                                'Are you sure you want to delete this bill?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('DELETE',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _deleteBill(bill.id!);
                      },
                      child: Column(
                        children: [
                          WaterBillCard(
                            bill: bill,
                            isManagementView: true,
                            onTap: () => notifier.selectBill(bill),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          child: WaterBillForm(
                                            initialData: bill,
                                            onSubmit: _updateBill,
                                            isEditing: true,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => notifier.selectBill(bill),
                                    icon:
                                        const Icon(Icons.visibility, size: 16),
                                    label: const Text('View Details'),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
