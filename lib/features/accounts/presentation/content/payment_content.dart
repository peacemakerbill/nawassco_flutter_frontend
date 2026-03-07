import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/payment_provider.dart';
import '../../providers/chart_of_accounts_provider.dart'; // Add this import
import 'sub_widgets/payments/payment_form_widget.dart';
import 'sub_widgets/payments/payment_list_widget.dart';
import 'sub_widgets/payments/payment_summary_widget.dart';

class PaymentContent extends ConsumerStatefulWidget {
  const PaymentContent({super.key});

  @override
  ConsumerState<PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends ConsumerState<PaymentContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load data only once when the widget is first built
    if (!_initialized) {
      _initialized = true;

      // Use Future.microtask to avoid state changes during build
      Future.microtask(() {
        final paymentState = ref.read(paymentProvider);
        final chartState = ref.read(chartOfAccountsProvider);

        // Only fetch payments if not already loading and empty
        if (paymentState.payments.isEmpty && !paymentState.isLoading) {
          ref.read(paymentProvider.notifier).fetchPayments();
        }

        // Only fetch summary if not already loading and empty
        if (paymentState.summary == null && !paymentState.isLoading) {
          ref.read(paymentProvider.notifier).fetchPaymentSummary();
        }

        // PRE-LOAD BANK ACCOUNTS when the payment page opens
        if (!chartState.isLoadingBankAccounts && chartState.bankAccounts.isEmpty) {
          ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        _buildHeader(context),

        // Tabs Section
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
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0D47A1),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Payments'),
              Tab(text: 'Summary'),
            ],
          ),
        ),

        // Content Section
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              PaymentListWidget(),
              PaymentSummaryWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D47A1).withOpacity(0.9),
            const Color(0xFF1976D2).withOpacity(0.9),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.payment, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage and track all payments efficiently',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreatePaymentDialog(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D47A1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    // Ensure bank accounts are loaded before showing the form
    final chartState = ref.read(chartOfAccountsProvider);

    if (chartState.isLoadingBankAccounts) {
      // Show loading dialog while fetching
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Loading bank accounts...'),
              ],
            ),
          ),
        ),
      );

      // Wait for loading to complete
      Future.delayed(const Duration(milliseconds: 100), () {
        if (chartState.bankAccounts.isEmpty && !chartState.isLoadingBankAccounts) {
          ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();
        }

        // Close loading dialog and open form
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          _showPaymentForm(context);
        }
      });
    } else if (chartState.bankAccounts.isEmpty) {
      // No bank accounts yet, fetch them first
      ref.read(chartOfAccountsProvider.notifier).fetchBankAccounts();

      // Show the form immediately - it will show loading state
      _showPaymentForm(context);
    } else {
      // Bank accounts are already loaded, show form directly
      _showPaymentForm(context);
    }
  }

  void _showPaymentForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PaymentFormWidget(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}