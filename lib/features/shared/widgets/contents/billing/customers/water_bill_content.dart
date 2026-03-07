import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../providers/water_bill_provider.dart';
import '../../../sub_widgets/water_bill/stats_summary.dart';
import '../../../sub_widgets/water_bill/water_bill_card.dart';
import '../../../sub_widgets/water_bill/water_bill_details.dart';


class WaterBillContent extends ConsumerStatefulWidget {
  const WaterBillContent({super.key});

  @override
  ConsumerState<WaterBillContent> createState() => _WaterBillContentState();
}

class _WaterBillContentState extends ConsumerState<WaterBillContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterBillProvider.notifier).toggleView(false);
    });
  }

  void _refreshBills() {
    ref.read(waterBillProvider.notifier).fetchUserBills();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waterBillProvider);
    final authState = ref.watch(authProvider);
    final notifier = ref.read(waterBillProvider.notifier);

    // Show loading
    if (state.isLoading && state.bills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error
    if (state.error != null && state.bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading bills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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

    // Show bill details if selected
    if (state.selectedBill != null) {
      return WaterBillDetails(
        bill: state.selectedBill!,
        isManagementView: false,
        onBack: () => notifier.selectBill(null),
        onRefresh: _refreshBills,
      );
    }

    // Show empty state
    if (state.bills.isEmpty) {
      return Center(
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
            Text(
              authState.user?['email'] != null
                  ? 'No bills found for ${authState.user!['email']}'
                  : 'Please log in to view your bills',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshBills,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Show bills list
    return RefreshIndicator(
      onRefresh: () async {
        _refreshBills();
        return;
      },
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Water Bills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.bills.length} bill${state.bills.length != 1 ? 's' : ''} found',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshBills,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Summary
          if (state.bills.isNotEmpty)
            StatsSummary(
              stats: {
                'totalBills': state.bills.length,
                'totalAmount': state.bills.fold(0.0, (sum, bill) => sum + bill.totalAmount),
                'totalPaid': state.bills.fold(0.0, (sum, bill) => sum + bill.paidAmount),
                'totalBalance': state.bills.fold(0.0, (sum, bill) => sum + bill.balance),
                'statusCounts': {
                  'pending': state.bills.where((b) => b.status == 'pending').length,
                  'paid': state.bills.where((b) => b.status == 'paid').length,
                  'overdue': state.bills.where((b) => b.status == 'overdue').length,
                  'partially_paid': state.bills.where((b) => b.status == 'partially_paid').length,
                  'cancelled': state.bills.where((b) => b.status == 'cancelled').length,
                },
                'averageConsumption': state.bills.isNotEmpty
                    ? state.bills.fold(0.0, (sum, bill) => sum + bill.consumption) / state.bills.length
                    : 0,
              },
              isManagementView: false,
            ),

          // Bills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: state.bills.length,
              itemBuilder: (context, index) {
                final bill = state.bills[index];
                return WaterBillCard(
                  bill: bill,
                  isManagementView: false,
                  onTap: () => notifier.selectBill(bill),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}