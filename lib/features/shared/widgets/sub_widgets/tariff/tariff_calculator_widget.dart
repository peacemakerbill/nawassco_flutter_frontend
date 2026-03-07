import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/tariff_model.dart';
import '../../../providers/tariff_provider.dart';

class TariffCalculatorWidget extends ConsumerStatefulWidget {
  final Tariff tariff;

  const TariffCalculatorWidget({super.key, required this.tariff});

  @override
  ConsumerState<TariffCalculatorWidget> createState() =>
      _TariffCalculatorWidgetState();
}

class _TariffCalculatorWidgetState
    extends ConsumerState<TariffCalculatorWidget> {
  final _consumptionController = TextEditingController();
  final _regionController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KES ',
    decimalDigits: 2,
  );

  NakuruServiceRegion? _selectedRegion;
  double _consumption = 0.0;
  bool _isCalculating = false;
  BillCalculationResult? _calculationResult;

  @override
  void dispose() {
    _consumptionController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tariff = widget.tariff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Calculator'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tariff Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.currency_exchange, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tariff.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                tariff.code,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(tariff.billingCycle.displayName),
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tariff.description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Calculator Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bill Calculation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Consumption Input
                    TextFormField(
                      controller: _consumptionController,
                      decoration: InputDecoration(
                        labelText: 'Consumption (Units) *',
                        prefixIcon: const Icon(Icons.water_drop),
                        border: const OutlineInputBorder(),
                        suffixText: 'units',
                        helperText: 'Enter the consumption in units',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final consumption = double.tryParse(value) ?? 0.0;
                        setState(() => _consumption = consumption);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter consumption';
                        }
                        final consumption = double.tryParse(value);
                        if (consumption == null || consumption < 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Region Selection
                    DropdownButtonFormField<NakuruServiceRegion>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: 'Service Region *',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      items: tariff.serviceRegions.map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(region.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRegion = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select a region' : null,
                    ),

                    const SizedBox(height: 24),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isCalculating || !_canCalculate()
                            ? null
                            : _calculateBill,
                        icon: _isCalculating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.calculate),
                        label: Text(
                          _isCalculating ? 'Calculating...' : 'Calculate Bill',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            if (_calculationResult != null) ...[
              _buildResultsSection(_calculationResult!),
              const SizedBox(height: 24),
            ],

            // Tier Information
            if (tariff.consumptionTiers.isNotEmpty) ...[
              _buildTierInfoSection(tariff),
              const SizedBox(height: 24),
            ],

            // Service Charges Info
            if (tariff.serviceCharges.isNotEmpty ||
                tariff.fixedCharges.isNotEmpty) ...[
              _buildChargesInfoSection(tariff),
            ],
          ],
        ),
      ),
    );
  }

  bool _canCalculate() {
    return _consumption > 0 && _selectedRegion != null;
  }

  Future<void> _calculateBill() async {
    if (!_canCalculate()) return;

    setState(() => _isCalculating = true);

    try {
      final notifier = ref.read(tariffProvider.notifier);
      final result = await notifier.calculateBill(
        widget.tariff.id!,
        _consumption,
        _selectedRegion!,
      );

      setState(() => _calculationResult = result);
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  Widget _buildResultsSection(BillCalculationResult result) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Calculation Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(result.total),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Breakdown
            const Text(
              'Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...result.breakdown.map((item) {
              return _buildBreakdownItem(item);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final description = item['description'] as String;
    final amount = (item['amount'] as num).toDouble();
    final details = item['details'] as List<dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _currencyFormat.format(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getBreakdownColor(type),
                  ),
                ),
              ],
            ),
            if (details != null && details.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details.map((detail) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              detail['name'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            detail['type'] == 'percentage'
                                ? '${detail['amount']}%'
                                : _currencyFormat.format(detail['amount']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBreakdownColor(String type) {
    switch (type) {
      case 'consumption':
        return Colors.blue;
      case 'service_charges':
        return Colors.green;
      case 'fixed_charges':
        return Colors.orange;
      case 'taxes':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTierInfoSection(Tariff tariff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.layers, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Consumption Tiers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tariff.consumptionTiers.map((tier) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          tier.tier.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${tier.minUnits} - ${tier.maxUnits ?? "∞"} units',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      _currencyFormat.format(tier.rate),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChargesInfoSection(Tariff tariff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applicable Charges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (tariff.serviceCharges.isNotEmpty) ...[
              const Text(
                'Service Charges:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...tariff.serviceCharges.map((charge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade400,
                        ),
                      ),
                      Expanded(child: Text(charge.name)),
                      Text(
                        charge.calculationType == CalculationType.percentage
                            ? '${charge.amount}%'
                            : _currencyFormat.format(charge.amount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            if (tariff.fixedCharges.isNotEmpty) ...[
              const Text(
                'Fixed Charges:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...tariff.fixedCharges.map((charge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade400,
                        ),
                      ),
                      Expanded(child: Text(charge.name)),
                      Text(
                        _currencyFormat.format(charge.amount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            if (tariff.taxesLevis.isNotEmpty) ...[
              const Text(
                'Taxes & Levies:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              ...tariff.taxesLevis.where((tax) => tax.isActive).map((tax) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.shade400,
                        ),
                      ),
                      Expanded(child: Text(tax.name)),
                      Text(
                        '${tax.rate}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
