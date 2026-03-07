import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/sewerage_bill_model.dart';
import '../../../../providers/sewerage_bill_provider.dart';
import '../../../sub_widgets/sewerage_bill/bill_filter.dart';
import '../../../sub_widgets/sewerage_bill/bill_statistics.dart';
import '../../../sub_widgets/sewerage_bill/bill_summary.dart';
import '../../../sub_widgets/sewerage_bill/create_bill_form.dart';
import '../../../sub_widgets/sewerage_bill/payment_form.dart';
import '../../../sub_widgets/sewerage_bill/responsive_grid.dart';
import '../../../sub_widgets/sewerage_bill/sewerage_bill_card.dart';
import '../../../sub_widgets/sewerage_bill/sewerage_bill_details.dart';
import '../../../sub_widgets/sewerage_bill/update_bill_form.dart';

class SewerageManagementContent extends ConsumerStatefulWidget {
  const SewerageManagementContent({super.key});

  @override
  ConsumerState<SewerageManagementContent> createState() => _SewerageManagementContentState();
}

class _SewerageManagementContentState extends ConsumerState<SewerageManagementContent> {
  final ScrollController _scrollController = ScrollController();
  SewerageBill? _selectedBill;
  bool _showCreateForm = false;
  bool _showUpdateForm = false;
  bool _showPaymentForm = false;
  bool _showBillDetails = false;
  bool _showBillSummary = false;
  bool _showStatistics = true;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sewerageBillProvider.notifier).getBills();
      ref.read(sewerageBillProvider.notifier).getStatistics();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshBills() {
    ref.read(sewerageBillProvider.notifier).getBills(filters: _filters);
    ref.read(sewerageBillProvider.notifier).getStatistics();
  }

  void _showCreateBillForm() {
    setState(() {
      _showCreateForm = true;
      _showUpdateForm = false;
      _showPaymentForm = false;
      _showBillDetails = false;
      _showBillSummary = false;
      _selectedBill = null;
    });
  }

  void _showUpdateBillForm(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showUpdateForm = true;
      _showCreateForm = false;
      _showPaymentForm = false;
      _showBillDetails = false;
      _showBillSummary = false;
    });
  }

  void _showBillDetail(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showBillDetails = true;
      _showCreateForm = false;
      _showUpdateForm = false;
      _showPaymentForm = false;
      _showBillSummary = false;
    });
  }

  void _showPaymentScreen(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showPaymentForm = true;
      _showCreateForm = false;
      _showUpdateForm = false;
      _showBillDetails = false;
      _showBillSummary = false;
    });
  }

  void _showBillSummaryScreen(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showBillSummary = true;
      _showCreateForm = false;
      _showUpdateForm = false;
      _showPaymentForm = false;
      _showBillDetails = false;
    });
  }

  void _closeSidePanel() {
    setState(() {
      _selectedBill = null;
      _showCreateForm = false;
      _showUpdateForm = false;
      _showPaymentForm = false;
      _showBillDetails = false;
      _showBillSummary = false;
    });
  }

  void _deleteBill(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(sewerageBillProvider.notifier).deleteBill(id);
      if (success) {
        _closeSidePanel();
        _refreshBills();
      }
    }
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() => _filters = filters);
    _refreshBills();
  }

  void _toggleStatistics() {
    setState(() => _showStatistics = !_showStatistics);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sewerageBillProvider);
    final authState = ref.watch(authProvider);
    final isStaff = authState.hasAnyRole(['Admin', 'Manager', 'Accounts', 'SalesAgent']);

    if (!isStaff) {
      return const Center(
        child: Text(
          'Access denied. Only staff members can access bill management.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.manage_accounts,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sewerage Bill Management',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.bills.length} bills • ${state.statistics?.totalRevenue ?? 0} TSh total revenue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleStatistics,
                        icon: Icon(
                          _showStatistics ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        tooltip: _showStatistics ? 'Hide statistics' : 'Show statistics',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _refreshBills,
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        tooltip: 'Refresh',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showCreateBillForm,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('New Bill'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistics
                if (_showStatistics && state.statistics != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BillStatistics(
                      statistics: state.statistics!,
                      onRefresh: _refreshBills,
                    ),
                  ),

                // Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BillFilter(
                    onFilterChanged: _onFilterChanged,
                    initialFilters: _filters,
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            ),
          ),

          // Side Panel
          if (_selectedBill != null || _showCreateForm)
            Container(
              width: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Side Panel Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _closeSidePanel,
                          icon: const Icon(Icons.close),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _showCreateForm
                                ? 'Create New Bill'
                                : _showUpdateForm
                                ? 'Update Bill'
                                : _showPaymentForm
                                ? 'Make Payment'
                                : _showBillSummary
                                ? 'Bill Summary'
                                : 'Bill Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedBill != null && !_showCreateForm && !_showUpdateForm && !_showPaymentForm)
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, size: 20, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showUpdateBillForm(_selectedBill!);
                              } else if (value == 'delete') {
                                _deleteBill(_selectedBill!.id!);
                              }
                            },
                          ),
                      ],
                    ),
                  ),

                  // Side Panel Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSidePanelContent(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(SewerageBillState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshBills,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            const Text(
              'No bills found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first bill to get started.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateBillForm,
              icon: const Icon(Icons.add),
              label: const Text('Create Bill'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshBills(),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: ResponsiveGrid(
          padding: const EdgeInsets.all(16),
          children: state.bills.map((bill) {
            return SewerageBillCard(
              bill: bill,
              onTap: () => _showBillDetail(bill),
              onPay: () => _showPaymentScreen(bill),
              onViewDetails: () => _showBillDetail(bill),
              showActions: true,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSidePanelContent() {
    if (_showCreateForm) {
      return CreateBillForm(
        onSuccess: () {
          _closeSidePanel();
          _refreshBills();
        },
        onCancel: _closeSidePanel,
      );
    }

    if (_selectedBill == null) return const SizedBox();

    if (_showUpdateForm) {
      return UpdateBillForm(
        bill: _selectedBill!,
        onSuccess: () {
          _closeSidePanel();
          _refreshBills();
        },
        onCancel: _closeSidePanel,
      );
    } else if (_showPaymentForm) {
      return PaymentForm(
        bill: _selectedBill!,
        onSuccess: () {
          _closeSidePanel();
          _refreshBills();
        },
        onCancel: _closeSidePanel,
      );
    } else if (_showBillSummary) {
      return BillSummary(
        bill: _selectedBill!,
        onPrint: () {
          // Handle print
        },
        onShare: () {
          // Handle share
        },
      );
    } else {
      return SewerageBillDetails(
        bill: _selectedBill!,
        onPay: _selectedBill!.canPay ? () => _showPaymentScreen(_selectedBill!) : null,
        onPrint: () => _showBillSummaryScreen(_selectedBill!),
        onShare: () {
          // Handle share
        },
        onCancel: () {
          // Handle cancel
        },
      );
    }
  }
}