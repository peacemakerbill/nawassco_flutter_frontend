import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/sewerage_bill_model.dart';
import '../../../../providers/sewerage_bill_provider.dart';
import '../../../sub_widgets/sewerage_bill/bill_filter.dart';
import '../../../sub_widgets/sewerage_bill/bill_summary.dart';
import '../../../sub_widgets/sewerage_bill/payment_form.dart';
import '../../../sub_widgets/sewerage_bill/responsive_grid.dart';
import '../../../sub_widgets/sewerage_bill/sewerage_bill_card.dart';
import '../../../sub_widgets/sewerage_bill/sewerage_bill_details.dart';

class SewerageContent extends ConsumerStatefulWidget {
  const SewerageContent({super.key});

  @override
  ConsumerState<SewerageContent> createState() => _SewerageContentState();
}

class _SewerageContentState extends ConsumerState<SewerageContent> {
  final ScrollController _scrollController = ScrollController();
  SewerageBill? _selectedBill;
  bool _showPaymentForm = false;
  bool _showBillDetails = false;
  bool _showBillSummary = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sewerageBillProvider.notifier).getBills();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshBills() {
    ref.read(sewerageBillProvider.notifier).getBills(filters: _filters);
  }

  void _showBillDetail(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showBillDetails = true;
      _showPaymentForm = false;
      _showBillSummary = false;
    });
  }

  void _showPaymentScreen(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showPaymentForm = true;
      _showBillDetails = false;
      _showBillSummary = false;
    });
  }

  void _showBillSummaryScreen(SewerageBill bill) {
    setState(() {
      _selectedBill = bill;
      _showBillSummary = true;
      _showBillDetails = false;
      _showPaymentForm = false;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedBill = null;
      _showBillDetails = false;
      _showPaymentForm = false;
      _showBillSummary = false;
    });
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() => _filters = filters);
    _refreshBills();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sewerageBillProvider);
    final authState = ref.watch(authProvider);
    final userEmail = authState.user?['email'];
    final isStaff =
        authState.hasAnyRole(['Admin', 'Manager', 'Accounts', 'SalesAgent']);

    // Filter bills for current user if not staff
    final userBills = isStaff
        ? state.bills
        : state.bills.where((bill) => bill.customerEmail == userEmail).toList();

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
                        Icons.receipt_long,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sewerage Bills',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isStaff
                                  ? '${userBills.length} bills found'
                                  : 'Your sewerage bills',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isStaff)
                        Chip(
                          label: Text(userEmail ?? 'No email'),
                          backgroundColor: Colors.blue[50],
                        ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _refreshBills,
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),

                // Filter Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BillFilter(
                    onFilterChanged: _onFilterChanged,
                    initialFilters: _filters,
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(userBills, state),
                ),
              ],
            ),
          ),

          // Side Panel for Details/Payment/Summary
          if (_selectedBill != null &&
              (_showBillDetails || _showPaymentForm || _showBillSummary))
            Container(
              width: 500,
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
                          onPressed: _closeDetails,
                          icon: const Icon(Icons.close),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _showPaymentForm
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

  Widget _buildContent(List<SewerageBill> bills, SewerageBillState state) {
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

    if (bills.isEmpty) {
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
              'When bills are available, they will appear here.',
              style: TextStyle(color: Colors.grey),
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
          children: bills.map((bill) {
            return SewerageBillCard(
              bill: bill,
              onTap: () => _showBillDetail(bill),
              onPay: bill.canPay ? () => _showPaymentScreen(bill) : null,
              onViewDetails: () => _showBillDetail(bill),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSidePanelContent() {
    if (_selectedBill == null) return const SizedBox();

    if (_showPaymentForm) {
      return PaymentForm(
        bill: _selectedBill!,
        onSuccess: () {
          _closeDetails();
          _refreshBills();
        },
        onCancel: _closeDetails,
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
        onPay: _selectedBill!.canPay
            ? () => _showPaymentScreen(_selectedBill!)
            : null,
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
