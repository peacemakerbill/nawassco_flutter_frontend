import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/tariff_model.dart';
import '../../../providers/tariff_provider.dart';
import 'tariff_calculator_widget.dart';
import 'tariff_form_widget.dart';

class TariffDetailWidget extends ConsumerStatefulWidget {
  final Tariff tariff;

  const TariffDetailWidget({super.key, required this.tariff});

  @override
  ConsumerState<TariffDetailWidget> createState() => _TariffDetailWidgetState();
}

class _TariffDetailWidgetState extends ConsumerState<TariffDetailWidget> {
  int _selectedTab = 0;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KES ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final tariff = widget.tariff;
    final notifier = ref.read(tariffProvider.notifier);
    final canManage = notifier.canManageTariffs;
    final canApprove = notifier.canApproveTariffs;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _getStatusColor(tariff).withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: _getStatusColor(tariff).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tariff.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(tariff),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _getStatusText(tariff),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tariff.code,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tariff.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canManage)
                      Row(
                        children: [
                          if (tariff.isCurrent)
                            OutlinedButton.icon(
                              onPressed: () => _showCalculatorDialog(tariff),
                              icon: const Icon(Icons.calculate, size: 16),
                              label: const Text('Calculate Bill'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () => _editTariff(),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) =>
                                _buildPopupMenuItems(tariff, canApprove),
                            onSelected: (value) => _handlePopupAction(
                              value,
                              tariff,
                              notifier,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'Billing Cycle',
                      value: tariff.billingCycle.displayName,
                    ),
                    _buildInfoItem(
                      icon: Icons.access_time,
                      label: 'Effective Period',
                      value: tariff.formattedEffectivePeriod,
                    ),
                    _buildInfoItem(
                      icon: Icons.backup,
                      label: 'Version',
                      value: 'v${tariff.version}',
                    ),
                    _buildInfoItem(
                      icon: Icons.person,
                      label: 'Created By',
                      value: tariff.createdByUser?['firstName'] ?? 'N/A',
                    ),
                    if (tariff.approvedByUser != null)
                      _buildInfoItem(
                        icon: Icons.verified,
                        label: 'Approved By',
                        value: tariff.approvedByUser?['firstName'] ?? 'N/A',
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              onTap: (index) => setState(() => _selectedTab = index),
              controller: TabController(
                length: 6,
                initialIndex: _selectedTab,
                vsync: ScaffoldState(),
              ),
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Pricing'),
                Tab(text: 'Charges'),
                Tab(text: 'Regions'),
                Tab(text: 'Taxes'),
                Tab(text: 'History'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildTabContent(tariff),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Tariff tariff) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(tariff);
      case 1:
        return _buildPricingTab(tariff);
      case 2:
        return _buildChargesTab(tariff);
      case 3:
        return _buildRegionsTab(tariff);
      case 4:
        return _buildTaxesTab(tariff);
      case 5:
        return _buildHistoryTab(tariff);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab(Tariff tariff) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              _buildStatCard(
                'Base Rate',
                _currencyFormat.format(tariff.baseRate),
                Colors.blue,
                Icons.attach_money,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Min Charge',
                _currencyFormat.format(tariff.minimumCharge),
                Colors.green,
                Icons.remove_circle,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Regions',
                tariff.serviceRegions.length.toString(),
                Colors.orange,
                Icons.location_on,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Tiers',
                tariff.consumptionTiers.length.toString(),
                Colors.purple,
                Icons.layers,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Current Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusIndicator('Active', tariff.isActive),
                      const SizedBox(width: 16),
                      _buildStatusIndicator('Approved', tariff.isApproved),
                      const SizedBox(width: 16),
                      _buildStatusIndicator('Current', tariff.isCurrent),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Calculation Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculation Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      _buildTableRow('Rounding Rule', tariff.roundingRule.displayName),
                      _buildTableRow('Decimal Places', tariff.decimalPlaces.toString()),
                      _buildTableRow('Minimum Consumption', '${tariff.minimumConsumption} units'),
                      _buildTableRow('Created', DateFormat('dd/MM/yyyy HH:mm').format(tariff.createdAt)),
                      _buildTableRow('Last Updated', DateFormat('dd/MM/yyyy HH:mm').format(tariff.updatedAt)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildPricingTab(Tariff tariff) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Base Rate and Minimum Charge
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Base Pricing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPricingItem(
                          'Base Rate',
                          _currencyFormat.format(tariff.baseRate),
                          'Per unit',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPricingItem(
                          'Minimum Charge',
                          _currencyFormat.format(tariff.minimumCharge),
                          'Minimum billable amount',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Consumption Tiers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Consumption Tiers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.consumptionTiers.length} tier(s)'),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (tariff.consumptionTiers.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.layers_clear,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No consumption tiers configured'),
                        ],
                      ),
                    )
                  else
                    ...tariff.consumptionTiers.map((tier) {
                      return _buildTierCard(tier);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingItem(
      String label,
      String value,
      String description,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(ConsumptionTier tier) {
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
                Chip(
                  label: Text('Tier ${tier.tier}'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
                Chip(
                  label: Text(tier.isProgressive ? 'Progressive' : 'Block'),
                  backgroundColor: tier.isProgressive
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  labelStyle: TextStyle(
                    color: tier.isProgressive
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTierDetail(
                    'Range',
                    '${tier.minUnits} - ${tier.maxUnits ?? "∞"} units',
                  ),
                ),
                Expanded(
                  child: _buildTierDetail(
                    'Rate',
                    _currencyFormat.format(tier.rate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (tier.description.isNotEmpty)
              Text(
                tier.description,
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChargesTab(Tariff tariff) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Charges
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Charges',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.serviceCharges.length} charge(s)'),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (tariff.serviceCharges.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No service charges configured'),
                        ],
                      ),
                    )
                  else
                    ...tariff.serviceCharges.map((charge) {
                      return _buildServiceChargeCard(charge);
                    }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Fixed Charges
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fixed Charges',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.fixedCharges.length} charge(s)'),
                        backgroundColor: Colors.orange.shade50,
                        labelStyle: TextStyle(color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (tariff.fixedCharges.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No fixed charges configured'),
                        ],
                      ),
                    )
                  else
                    ...tariff.fixedCharges.map((charge) {
                      return _buildServiceChargeCard(charge);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChargeCard(ServiceCharge charge) {
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
                Text(
                  charge.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(charge.calculationType.displayName),
                  backgroundColor: _getChargeColor(charge.calculationType),
                  labelStyle: TextStyle(
                    color: _getChargeTextColor(charge.calculationType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChargeDetail(
                    'Amount',
                    charge.calculationType == CalculationType.percentage
                        ? '${charge.amount}%'
                        : _currencyFormat.format(charge.amount),
                  ),
                ),
                Expanded(
                  child: _buildChargeDetail(
                    'Taxable',
                    charge.isTaxable ? 'Yes' : 'No',
                  ),
                ),
              ],
            ),
            if (charge.basis != null && charge.basis!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildChargeDetail('Basis', charge.basis!),
              ),
            if (charge.minAmount != null || charge.maxAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (charge.minAmount != null)
                      Expanded(
                        child: _buildChargeDetail(
                          'Min Amount',
                          _currencyFormat.format(charge.minAmount!),
                        ),
                      ),
                    if (charge.maxAmount != null)
                      Expanded(
                        child: _buildChargeDetail(
                          'Max Amount',
                          _currencyFormat.format(charge.maxAmount!),
                        ),
                      ),
                  ],
                ),
              ),
            if (charge.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  charge.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getChargeColor(CalculationType type) {
    switch (type) {
      case CalculationType.fixed:
        return Colors.blue.shade50;
      case CalculationType.percentage:
        return Colors.green.shade50;
      case CalculationType.perUnit:
        return Colors.orange.shade50;
    }
  }

  Color _getChargeTextColor(CalculationType type) {
    switch (type) {
      case CalculationType.fixed:
        return Colors.blue.shade700;
      case CalculationType.percentage:
        return Colors.green.shade700;
      case CalculationType.perUnit:
        return Colors.orange.shade700;
    }
  }

  Widget _buildChargeDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionsTab(Tariff tariff) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Regions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.serviceRegions.length} region(s)'),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: tariff.serviceRegions.map((region) {
                      return Chip(
                        label: Text(region.displayName),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: Colors.green.shade700),
                        avatar: const Icon(Icons.location_on, size: 16),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Region Coverage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This tariff applies to the following service regions in Nakuru County:',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tariff.serviceRegions.length,
                    itemBuilder: (context, index) {
                      final region = tariff.serviceRegions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: Text(region.displayName),
                        subtitle: Text(region.code),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxesTab(Tariff tariff) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Taxes & Levies
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taxes & Levies',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.taxesLevis.length} tax(es)'),
                        backgroundColor: Colors.purple.shade50,
                        labelStyle: TextStyle(color: Colors.purple.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (tariff.taxesLevis.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No taxes configured'),
                        ],
                      ),
                    )
                  else
                    ...tariff.taxesLevis.map((tax) {
                      return _buildTaxCard(tax);
                    }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Penalties
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penalties',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('${tariff.penalties.length} penalty(ies)'),
                        backgroundColor: Colors.red.shade50,
                        labelStyle: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (tariff.penalties.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_alert,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No penalties configured'),
                        ],
                      ),
                    )
                  else
                    ...tariff.penalties.map((penalty) {
                      return _buildPenaltyCard(penalty);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxCard(TaxLevy tax) {
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
                Text(
                  tax.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text('${tax.rate}%'),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      tax.isActive ? Icons.check_circle : Icons.remove_circle,
                      color: tax.isActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tax.calculationType.displayName,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (tax.appliesTo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    const Text('Applies to:', style: TextStyle(fontWeight: FontWeight.w500)),
                    ...tax.appliesTo.map((item) {
                      return Chip(
                        label: Text(item),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.orange.shade50,
                        labelStyle: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            if (tax.legalReference != null && tax.legalReference!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Reference: ${tax.legalReference}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyCard(PenaltyStructure penalty) {
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
                Text(
                  penalty.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    '${penalty.rate}${penalty.calculationType == PenaltyCalculationType.percentage ? '%' : ' KES'}',
                  ),
                  backgroundColor: Colors.red.shade50,
                  labelStyle: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(penalty.frequency.displayName),
                  backgroundColor: Colors.orange.shade50,
                  labelStyle: TextStyle(color: Colors.orange.shade700),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${penalty.gracePeriod} days grace'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
            if (penalty.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  penalty.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(Tariff tariff) {
    final notifier = ref.read(tariffProvider.notifier);
    final history = ref.watch(tariffProvider).tariffHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Version History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => notifier.getTariffHistory(tariff.code),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (history == null || history.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No history available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final version = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('v${version.version}'),
                    ),
                    title: Text(version.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code: ${version.code}'),
                        Text('Effective: ${version.formattedEffectivePeriod}'),
                        Row(
                          children: [
                            Icon(
                              version.isApproved
                                  ? Icons.verified
                                  : Icons.pending,
                              size: 14,
                              color: version.isApproved
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              version.isApproved ? 'Approved' : 'Pending',
                              style: TextStyle(
                                color: version.isApproved
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _showVersionDetails(version),
                      icon: const Icon(Icons.visibility),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(
      Tariff tariff,
      bool canApprove,
      ) {
    final items = <PopupMenuEntry<String>>[];

    if (tariff.isCurrent) {
      items.add(
        const PopupMenuItem(
          value: 'calculate',
          child: Row(
            children: [
              Icon(Icons.calculate, size: 20),
              SizedBox(width: 8),
              Text('Calculate Bill'),
            ],
          ),
        ),
      );
    }

    if (!tariff.isApproved) {
      items.add(
        PopupMenuItem(
          value: 'approve',
          enabled: canApprove,
          child: const Row(
            children: [
              Icon(Icons.verified, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
      );
    }

    if (tariff.isApproved && tariff.isActive) {
      items.add(
        const PopupMenuItem(
          value: 'new_version',
          child: Row(
            children: [
              Icon(Icons.upgrade, size: 20),
              SizedBox(width: 8),
              Text('Create New Version'),
            ],
          ),
        ),
      );
    }

    if (tariff.isActive) {
      items.add(
        const PopupMenuItem(
          value: 'deactivate',
          child: Row(
            children: [
              Icon(Icons.pause_circle, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Deactivate'),
            ],
          ),
        ),
      );
    } else {
      items.add(
        const PopupMenuItem(
          value: 'activate',
          child: Row(
            children: [
              Icon(Icons.play_circle, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Activate'),
            ],
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider());

    items.add(
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 20, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
      ),
    );

    return items;
  }

  void _handlePopupAction(
      String value,
      Tariff tariff,
      TariffProvider notifier,
      ) async {
    switch (value) {
      case 'calculate':
        _showCalculatorDialog(tariff);
        break;
      case 'approve':
        await _approveTariff(tariff, notifier);
        break;
      case 'new_version':
        await _createNewVersion(tariff, notifier);
        break;
      case 'activate':
        await _toggleTariffStatus(tariff, notifier, true);
        break;
      case 'deactivate':
        await _toggleTariffStatus(tariff, notifier, false);
        break;
      case 'delete':
        await _deleteTariff(tariff, notifier);
        break;
    }
  }

  Future<void> _approveTariff(Tariff tariff, TariffProvider notifier) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Tariff'),
        content: const Text('Are you sure you want to approve this tariff?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.approveTariff(tariff.id!);
    }
  }

  Future<void> _createNewVersion(Tariff tariff, TariffProvider notifier) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Version'),
        content: const Text(
          'Are you sure you want to create a new version of this tariff?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.createNewVersion(tariff.id!);
    }
  }

  Future<void> _toggleTariffStatus(
      Tariff tariff,
      TariffProvider notifier,
      bool activate,
      ) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activate ? 'Activate Tariff' : 'Deactivate Tariff'),
        content: Text(
          activate
              ? 'Are you sure you want to activate this tariff?'
              : 'Are you sure you want to deactivate this tariff?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: activate ? Colors.green : Colors.red,
            ),
            child: Text(activate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.toggleTariffStatus(tariff.id!, activate);
    }
  }

  Future<void> _deleteTariff(Tariff tariff, TariffProvider notifier) async {
    if (tariff.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tariff'),
        content: const Text(
          'Are you sure you want to delete this tariff? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteTariff(tariff.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showCalculatorDialog(Tariff tariff) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TariffCalculatorWidget(tariff: tariff),
        ),
      ),
    );
  }

  void _editTariff() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: TariffFormWidget(
            tariff: widget.tariff,
            isEditing: true,
            onSuccess: () {
              Navigator.pop(context);
              // Refresh the details
              if (widget.tariff.id != null) {
                final notifier = ref.read(tariffProvider.notifier);
                notifier.getTariffById(widget.tariff.id!);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showVersionDetails(Tariff version) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TariffDetailWidget(tariff: version),
        ),
      ),
    );
  }

  Color _getStatusColor(Tariff tariff) {
    if (tariff.isCurrent) return Colors.green;
    if (!tariff.isActive) return Colors.red;
    if (!tariff.isApproved) return Colors.orange;
    return Colors.grey;
  }

  String _getStatusText(Tariff tariff) {
    if (tariff.isCurrent) return 'Current';
    if (!tariff.isActive) return 'Inactive';
    if (!tariff.isApproved) return 'Pending Approval';
    return 'Future';
  }
}