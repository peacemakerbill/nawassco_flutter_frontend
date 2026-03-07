import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/tax_calculation_model.dart';
import '../../../../providers/tax_calculation_provider.dart';
import 'tax_calculation_details.dart'; // Add this import

class TaxCalculationListWidget extends ConsumerStatefulWidget {
  const TaxCalculationListWidget({super.key});

  @override
  ConsumerState<TaxCalculationListWidget> createState() =>
      _TaxCalculationListWidgetState();
}

class _TaxCalculationListWidgetState
    extends ConsumerState<TaxCalculationListWidget> {
  final Map<String, dynamic> _filters = {
    'taxType': '',
    'status': '',
    'taxPeriod': '',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxCalculationProvider.notifier).getTaxCalculations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxCalculationProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          // Filter Card
          SliverToBoxAdapter(
            child: _buildFilterCard(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Header with actions
          SliverToBoxAdapter(
            child: Row(
              children: [
                const Text(
                  'Tax Calculations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref
                      .read(taxCalculationProvider.notifier)
                      .getTaxCalculations(),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Loading state
          if (state.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Error state
          if (state.error != null && !state.isLoading)
            SliverToBoxAdapter(
              child: _buildErrorWidget(state.error!),
            ),

          // Empty state
          if (state.calculations.isEmpty &&
              !state.isLoading &&
              state.error == null)
            SliverToBoxAdapter(
              child: _buildEmptyState(),
            ),

          // Calculations list
          if (state.calculations.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final calculation = state.calculations[index];
                  return _buildCalculationCard(calculation);
                },
                childCount: state.calculations.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                  children: [
                    _buildTaxTypeFilter(),
                    const SizedBox(height: 12),
                    _buildStatusFilter(),
                    const SizedBox(height: 12),
                    _buildTaxPeriodFilter(),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: _buildTaxTypeFilter()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusFilter()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTaxPeriodFilter()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxTypeFilter() {
    return DropdownButtonFormField<String>(
      value: _filters['taxType'],
      decoration: InputDecoration(
        labelText: 'Tax Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Types')),
        ...TaxType.values.map((type) => DropdownMenuItem(
          value: type.name,
          child: Text(type.label),
        )),
      ],
      onChanged: (value) => setState(() => _filters['taxType'] = value ?? ''),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _filters['status'],
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Statuses')),
        ...TaxStatus.values.map((status) => DropdownMenuItem(
          value: status.name,
          child: Text(status.label),
        )),
      ],
      onChanged: (value) => setState(() => _filters['status'] = value ?? ''),
    );
  }

  Widget _buildTaxPeriodFilter() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Tax Period (e.g., 2024-Q1)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onChanged: (value) => setState(() => _filters['taxPeriod'] = value),
      controller: TextEditingController(text: _filters['taxPeriod']),
    );
  }

  void _applyFilters() {
    ref.read(taxCalculationProvider.notifier).getTaxCalculations(
      taxType: _filters['taxType']!.isEmpty ? null : _filters['taxType'],
      status: _filters['status']!.isEmpty ? null : _filters['status'],
      taxPeriod:
      _filters['taxPeriod']!.isEmpty ? null : _filters['taxPeriod'],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error loading tax calculations',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(taxCalculationProvider.notifier)
                  .getTaxCalculations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.calculate, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Tax Calculations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Get started by creating your first tax calculation',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                if (tabController != null && tabController.length > 1) {
                  tabController.animateTo(1);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Tax Calculation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationCard(TaxCalculation calculation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTaxCalculationDialog(context, calculation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: calculation.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: calculation.status.color),
                    ),
                    child: Text(
                      calculation.status.label,
                      style: TextStyle(
                        color: calculation.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: calculation.paymentStatus.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border:
                      Border.all(color: calculation.paymentStatus.color),
                    ),
                    child: Text(
                      calculation.paymentStatus.label,
                      style: TextStyle(
                        color: calculation.paymentStatus.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Calculation details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calculation.calculationNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${calculation.taxType.label} • ${calculation.taxPeriod}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KES ${calculation.netTaxPayable.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${_formatDate(calculation.dueDate)}',
                        style: TextStyle(
                          color: calculation.isOverdue
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: calculation.isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Progress bar for payments
              if (calculation.paidAmount > 0)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: calculation.netTaxPayable > 0
                          ? calculation.paidAmount / calculation.netTaxPayable
                          : 0,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF0D47A1),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid: KES ${calculation.paidAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Outstanding: KES ${calculation.outstandingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: calculation.outstandingAmount > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTaxCalculationDialog(BuildContext context, TaxCalculation calculation) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          child: TaxCalculationDetailsWidget(
            calculation: calculation,
            onUpdate: () {
              Navigator.of(context).pop();
              ref.read(taxCalculationProvider.notifier).getTaxCalculations();
            },
            isDialog: true,
          ),
        ),
      ),
    );
  }
}