import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../models/tariff_model.dart';
import '../../../providers/tariff_provider.dart';
import 'consumption_tier_widget.dart';
import 'service_charge_widget.dart';

// Extension for string formatting
extension StringExtension on String {
  String toTitleCase() {
    return split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

class TariffFormWidget extends ConsumerStatefulWidget {
  final Tariff? tariff;
  final VoidCallback? onSuccess;
  final bool isEditing;

  const TariffFormWidget({
    super.key,
    this.tariff,
    this.onSuccess,
    this.isEditing = false,
  });

  @override
  ConsumerState<TariffFormWidget> createState() => _TariffFormWidgetState();
}

class _TariffFormWidgetState extends ConsumerState<TariffFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Tariff _tariff;
  bool _isLoading = false;
  int _currentStep = 0;

  final List<ConsumptionTier> _consumptionTiers = [];
  final List<ServiceCharge> _serviceCharges = [];
  final List<ServiceCharge> _fixedCharges = [];
  final List<TaxLevy> _taxesLevis = [];
  final List<PenaltyStructure> _penalties = [];
  final List<NakuruServiceRegion> _selectedRegions = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _baseRateController = TextEditingController();
  final TextEditingController _minChargeController = TextEditingController();
  final TextEditingController _minConsumptionController =
      TextEditingController();
  final TextEditingController _decimalPlacesController =
      TextEditingController();

  BillingCycle _billingCycle = BillingCycle.monthly;
  RoundingRule _roundingRule = RoundingRule.nearest;
  DateTime _effectiveFrom = DateTime.now();
  DateTime? _effectiveTo;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.tariff != null) {
      _tariff = widget.tariff!;
      _nameController.text = _tariff.name;
      _codeController.text = _tariff.code;
      _descriptionController.text = _tariff.description;
      _baseRateController.text = _tariff.baseRate.toString();
      _minChargeController.text = _tariff.minimumCharge.toString();
      _minConsumptionController.text = _tariff.minimumConsumption.toString();
      _decimalPlacesController.text = _tariff.decimalPlaces.toString();

      _billingCycle = _tariff.billingCycle;
      _roundingRule = _tariff.roundingRule;
      _effectiveFrom = _tariff.effectiveFrom;
      _effectiveTo = _tariff.effectiveTo;

      _consumptionTiers.addAll(_tariff.consumptionTiers);
      _serviceCharges.addAll(_tariff.serviceCharges);
      _fixedCharges.addAll(_tariff.fixedCharges);
      _taxesLevis.addAll(_tariff.taxesLevis);
      _penalties.addAll(_tariff.penalties);
      _selectedRegions.addAll(_tariff.serviceRegions);
    } else {
      _tariff = Tariff(
        name: '',
        code: '',
        description: '',
        billingCycle: BillingCycle.monthly,
        effectiveFrom: DateTime.now(),
        serviceRegions: [],
        consumptionTiers: [],
        baseRate: 0.0,
        minimumCharge: 0.0,
        serviceCharges: [],
        fixedCharges: [],
        taxesLevis: [],
        penalties: [],
        meterRentalCharges: [],
        connectionCharges: [],
        roundingRule: RoundingRule.nearest,
        decimalPlaces: 2,
        minimumConsumption: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _baseRateController.dispose();
    _minChargeController.dispose();
    _minConsumptionController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Basic Info'),
        subtitle: const Text('Name, code, description'),
        content: _buildBasicInfoStep(),
        isActive: _currentStep == 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Service Regions'),
        subtitle: const Text('Select applicable regions'),
        content: _buildRegionsStep(),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Pricing'),
        subtitle: const Text('Consumption tiers and rates'),
        content: _buildPricingStep(),
        isActive: _currentStep == 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Charges & Taxes'),
        subtitle: const Text('Service charges and taxes'),
        content: _buildChargesStep(),
        isActive: _currentStep == 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Settings'),
        subtitle: const Text('Rounding and validation rules'),
        content: _buildSettingsStep(),
        isActive: _currentStep == 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Review'),
        subtitle: const Text('Confirm all details'),
        content: _buildReviewStep(),
        isActive: _currentStep == 5,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the basic details for this tariff',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tariff Name *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tariff name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Tariff Code *',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                  helperText: 'Unique code (e.g., RES-2024)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tariff code is required';
                  }
                  if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(value)) {
                    return 'Only uppercase letters, numbers, underscores and hyphens allowed';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description *',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<BillingCycle>(
                value: _billingCycle,
                decoration: const InputDecoration(
                  labelText: 'Billing Cycle *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: BillingCycle.values.map((cycle) {
                  return DropdownMenuItem(
                    value: cycle,
                    child: Text(cycle.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _billingCycle = value);
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(_effectiveFrom),
                ),
                decoration: const InputDecoration(
                  labelText: 'Effective From *',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _effectiveFrom,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date != null) {
                    setState(() => _effectiveFrom = date);
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _effectiveTo != null
                      ? DateFormat('dd/MM/yyyy').format(_effectiveTo!)
                      : '',
                ),
                decoration: const InputDecoration(
                  labelText: 'Effective To (Optional)',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty for indefinite',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _effectiveTo ??
                        _effectiveFrom.add(const Duration(days: 365)),
                    firstDate: _effectiveFrom,
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 10)),
                  );
                  if (date != null) {
                    setState(() => _effectiveTo = date);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_effectiveTo != null && _effectiveTo!.isBefore(_effectiveFrom))
          Text(
            'Effective To cannot be before Effective From',
            style: TextStyle(color: Colors.red.shade600),
          ),
      ],
    );
  }

  Widget _buildRegionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Service Regions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the regions where this tariff applies',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Regions: ${_selectedRegions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedRegions.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _selectedRegions.clear()),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedRegions.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedRegions.map((region) {
                    return Chip(
                      label: Text(region.displayName),
                      onDeleted: () {
                        setState(() => _selectedRegions.remove(region));
                      },
                      backgroundColor: Colors.blue.shade50,
                      deleteIconColor: Colors.blue.shade700,
                    );
                  }).toList(),
                )
              else
                Text(
                  'No regions selected. Please select at least one region.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Available Regions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: NakuruServiceRegion.values.length,
          itemBuilder: (context, index) {
            final region = NakuruServiceRegion.values[index];
            final isSelected = _selectedRegions.contains(region);

            return FilterChip(
              label: Text(region.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRegions.add(region);
                  } else {
                    _selectedRegions.remove(region);
                  }
                });
              },
              avatar: isSelected ? const Icon(Icons.check, size: 16) : null,
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
            );
          },
        ),
        const SizedBox(height: 8),
        if (_selectedRegions.isEmpty)
          Text(
            'Please select at least one service region',
            style: TextStyle(color: Colors.red.shade600),
          ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Pricing Configuration',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure consumption tiers and base rates',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _baseRateController,
                decoration: const InputDecoration(
                  labelText: 'Base Rate (KES)',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                  helperText: 'Default rate per unit',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Base rate is required';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _minChargeController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Charge (KES)',
                  prefixIcon: Icon(Icons.minimize_rounded),
                  border: OutlineInputBorder(),
                  helperText: 'Minimum billable amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Minimum charge is required';
                  }
                  final charge = double.tryParse(value);
                  if (charge == null || charge < 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ConsumptionTierWidget(
          tiers: _consumptionTiers,
          onTiersUpdated: (tiers) {
            setState(() => _consumptionTiers
              ..clear()
              ..addAll(tiers));
          },
        ),
        const SizedBox(height: 16),
        if (_consumptionTiers.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Tier Configuration Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._consumptionTiers.map((tier) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Tier ${tier.tier}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${tier.minUnits} - ${tier.maxUnits ?? "∞"} units @ KES ${tier.rate}/unit',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChargesStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Charges & Taxes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure service charges, fixed charges, taxes, and penalties',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Service Charges
          ServiceChargeWidget(
            charges: _serviceCharges,
            title: 'Service Charges',
            description: 'Variable charges based on consumption',
            onChargesUpdated: (charges) {
              setState(() => _serviceCharges
                ..clear()
                ..addAll(charges));
            },
          ),

          const SizedBox(height: 24),

          // Fixed Charges
          ServiceChargeWidget(
            charges: _fixedCharges,
            title: 'Fixed Charges',
            description: 'Fixed monthly charges',
            onChargesUpdated: (charges) {
              setState(() => _fixedCharges
                ..clear()
                ..addAll(charges));
            },
          ),

          const SizedBox(height: 24),

          // Add Taxes Section
          _buildTaxesSection(),

          const SizedBox(height: 24),

          // Add Penalties Section
          _buildPenaltiesSection(),
        ],
      ),
    );
  }

  Widget _buildTaxesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taxes & Levies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => _addTaxLevy(),
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure applicable taxes and levies',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            if (_taxesLevis.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.receipt,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text('No taxes configured'),
                    const SizedBox(height: 8),
                    Text(
                      'Add taxes that apply to this tariff',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              ..._taxesLevis.asMap().entries.map((entry) {
                final index = entry.key;
                final tax = entry.value;
                return _buildTaxLevyCard(tax, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxLevyCard(TaxLevy tax, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: tax.isActive ? null : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      tax.isActive ? Icons.check_circle : Icons.remove_circle,
                      color: tax.isActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tax.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editTaxLevy(index),
                      icon: const Icon(Icons.edit, size: 18),
                    ),
                    IconButton(
                      onPressed: () => _removeTaxLevy(index),
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Chip(
                  label: Text('${tax.rate}%'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(tax.calculationType.displayName),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description display
            if (tax.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  tax.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),

            if (tax.appliesTo.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  const Text('Applies to:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  ...tax.appliesTo.map((item) {
                    return Chip(
                      label: Text(item.replaceAll('_', ' ').toTitleCase()),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltiesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Penalties',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => _addPenalty(),
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure late payment penalties',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            if (_penalties.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.alertCircle,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text('No penalties configured'),
                    const SizedBox(height: 8),
                    Text(
                      'Add penalty structures for late payments',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              ..._penalties.asMap().entries.map((entry) {
                final index = entry.key;
                final penalty = entry.value;
                return _buildPenaltyCard(penalty, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyCard(PenaltyStructure penalty, int index) {
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
                  penalty.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editPenalty(index),
                      icon: const Icon(Icons.edit, size: 18),
                    ),
                    IconButton(
                      onPressed: () => _removePenalty(index),
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                      '${penalty.rate}${penalty.calculationType == PenaltyCalculationType.percentage ? '%' : ' KES'}'),
                  backgroundColor: Colors.red.shade50,
                  labelStyle: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 8),
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

  Widget _buildSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Calculation Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure rounding rules and validation',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<RoundingRule>(
                value: _roundingRule,
                decoration: const InputDecoration(
                  labelText: 'Rounding Rule *',
                  prefixIcon: Icon(Icons.roundabout_left),
                  border: OutlineInputBorder(),
                ),
                items: RoundingRule.values.map((rule) {
                  return DropdownMenuItem(
                    value: rule,
                    child: Text(rule.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _roundingRule = value);
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _decimalPlacesController,
                decoration: const InputDecoration(
                  labelText: 'Decimal Places *',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  helperText: 'Number of decimal places (0-4)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final places = int.tryParse(value);
                  if (places == null || places < 0 || places > 4) {
                    return 'Enter a number between 0 and 4';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _minConsumptionController,
          decoration: const InputDecoration(
            labelText: 'Minimum Consumption (Units)',
            prefixIcon: Icon(Icons.minimize),
            border: OutlineInputBorder(),
            helperText: 'Minimum billable consumption units',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final consumption = double.tryParse(value);
            if (consumption == null || consumption < 0) {
              return 'Enter a valid positive number';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Calculation Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('• Rounding: ${_roundingRule.displayName}'),
                Text('• Decimal Places: ${_decimalPlacesController.text}'),
                Text(
                    '• Minimum Consumption: ${_minConsumptionController.text} units'),
                Text('• Minimum Charge: KES ${_minChargeController.text}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Review & Confirm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review all details before creating the tariff',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Summary Cards
          _buildSummaryCard(
            'Basic Information',
            [
              _buildSummaryItem('Name', _nameController.text),
              _buildSummaryItem('Code', _codeController.text),
              _buildSummaryItem('Description', _descriptionController.text),
              _buildSummaryItem('Billing Cycle', _billingCycle.displayName),
              _buildSummaryItem('Effective From',
                  DateFormat('dd/MM/yyyy').format(_effectiveFrom)),
              if (_effectiveTo != null)
                _buildSummaryItem('Effective To',
                    DateFormat('dd/MM/yyyy').format(_effectiveTo!)),
            ],
            Colors.blue,
          ),

          const SizedBox(height: 16),

          _buildSummaryCard(
            'Service Regions',
            [
              for (final region in _selectedRegions)
                _buildSummaryItem(region.displayName, '', showDivider: false),
            ],
            Colors.green,
          ),

          const SizedBox(height: 16),

          _buildSummaryCard(
            'Pricing',
            [
              _buildSummaryItem(
                  'Base Rate', 'KES ${_baseRateController.text}/unit'),
              _buildSummaryItem(
                  'Minimum Charge', 'KES ${_minChargeController.text}'),
              _buildSummaryItem(
                  'Consumption Tiers', '${_consumptionTiers.length} tier(s)'),
              for (var i = 0; i < _consumptionTiers.length; i++)
                _buildSummaryItem(
                  '  Tier ${i + 1}',
                  '${_consumptionTiers[i].minUnits} - ${_consumptionTiers[i].maxUnits ?? "∞"} units @ KES ${_consumptionTiers[i].rate}/unit',
                  showDivider: false,
                  indent: true,
                ),
            ],
            Colors.orange,
          ),

          const SizedBox(height: 16),

          _buildSummaryCard(
            'Charges & Taxes',
            [
              _buildSummaryItem(
                  'Service Charges', '${_serviceCharges.length} charge(s)'),
              _buildSummaryItem(
                  'Fixed Charges', '${_fixedCharges.length} charge(s)'),
              _buildSummaryItem(
                  'Taxes & Levies', '${_taxesLevis.length} tax(es)'),
              _buildSummaryItem(
                  'Penalties', '${_penalties.length} penalty(ies)'),
            ],
            Colors.purple,
          ),

          const SizedBox(height: 16),

          _buildSummaryCard(
            'Calculation Settings',
            [
              _buildSummaryItem('Rounding Rule', _roundingRule.displayName),
              _buildSummaryItem(
                  'Decimal Places', _decimalPlacesController.text),
              _buildSummaryItem('Minimum Consumption',
                  '${_minConsumptionController.text} units'),
            ],
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    List<Widget> items,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    bool showDivider = true,
    bool indent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent ? 24 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _addTaxLevy() async {
    final result = await showDialog<TaxLevy>(
      context: context,
      builder: (context) => const _TaxLevyDialog(),
    );

    if (result != null) {
      setState(() => _taxesLevis.add(result));
    }
  }

  Future<void> _editTaxLevy(int index) async {
    final original = _taxesLevis[index];
    final result = await showDialog<TaxLevy>(
      context: context,
      builder: (context) => _TaxLevyDialog(taxLevy: original),
    );

    if (result != null) {
      setState(() => _taxesLevis[index] = result);
    }
  }

  void _removeTaxLevy(int index) {
    setState(() => _taxesLevis.removeAt(index));
  }

  Future<void> _addPenalty() async {
    final result = await showDialog<PenaltyStructure>(
      context: context,
      builder: (context) => const _PenaltyDialog(),
    );

    if (result != null) {
      setState(() => _penalties.add(result));
    }
  }

  Future<void> _editPenalty(int index) async {
    final original = _penalties[index];
    final result = await showDialog<PenaltyStructure>(
      context: context,
      builder: (context) => _PenaltyDialog(penalty: original),
    );

    if (result != null) {
      setState(() => _penalties[index] = result);
    }
  }

  void _removePenalty(int index) {
    setState(() => _penalties.removeAt(index));
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateBasicInfo()) return;
    if (_currentStep == 1 && !_validateRegions()) return;
    if (_currentStep == 2 && !_validatePricing()) return;
    if (_currentStep == 5) {
      _submitForm();
      return;
    }

    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateBasicInfo() {
    if (_nameController.text.isEmpty) return false;
    if (_codeController.text.isEmpty) return false;
    if (_descriptionController.text.isEmpty) return false;
    if (_effectiveTo != null && _effectiveTo!.isBefore(_effectiveFrom)) {
      return false;
    }
    return true;
  }

  bool _validateRegions() {
    return _selectedRegions.isNotEmpty;
  }

  bool _validatePricing() {
    if (_baseRateController.text.isEmpty) return false;
    if (_minChargeController.text.isEmpty) return false;
    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service region'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tariff = Tariff(
        id: widget.tariff?.id,
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        billingCycle: _billingCycle,
        effectiveFrom: _effectiveFrom,
        effectiveTo: _effectiveTo,
        serviceRegions: _selectedRegions,
        consumptionTiers: _consumptionTiers,
        baseRate: double.parse(_baseRateController.text),
        minimumCharge: double.parse(_minChargeController.text),
        serviceCharges: _serviceCharges,
        fixedCharges: _fixedCharges,
        taxesLevis: _taxesLevis,
        penalties: _penalties,
        meterRentalCharges: widget.tariff?.meterRentalCharges ?? [],
        connectionCharges: widget.tariff?.connectionCharges ?? [],
        roundingRule: _roundingRule,
        decimalPlaces: int.parse(_decimalPlacesController.text),
        minimumConsumption: double.parse(_minConsumptionController.text),
        createdAt: widget.tariff?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdByUser: widget.tariff?.createdByUser,
        updatedByUser: widget.tariff?.updatedByUser,
        approvedByUser: widget.tariff?.approvedByUser,
        isActive: widget.tariff?.isActive ?? true,
        isApproved: widget.tariff?.isApproved ?? false,
        version: widget.tariff?.version ?? 1,
        previousVersionId: widget.tariff?.previousVersionId,
      );

      final notifier = ref.read(tariffProvider.notifier);
      final success = widget.isEditing && widget.tariff?.id != null
          ? await notifier.updateTariff(widget.tariff!.id!, tariff)
          : await notifier.createTariff(tariff);

      if (success && mounted) {
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (error) {
      // Error is handled by the provider
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Tariff' : 'Create New Tariff',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
                onStepTapped: (step) {
                  if (step < _currentStep) {
                    setState(() => _currentStep = step);
                  }
                },
                steps: _buildSteps(),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : details.onStepContinue,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep == 5
                                      ? (widget.isEditing
                                          ? 'Update Tariff'
                                          : 'Create Tariff')
                                      : 'Next',
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Dialog for Tax Levy
class _TaxLevyDialog extends StatefulWidget {
  final TaxLevy? taxLevy;

  const _TaxLevyDialog({this.taxLevy});

  @override
  _TaxLevyDialogState createState() => _TaxLevyDialogState();
}

class _TaxLevyDialogState extends State<_TaxLevyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _legalReferenceController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  TaxCalculationType _calculationType = TaxCalculationType.percentage;
  bool _isActive = true;
  final List<String> _appliesTo = [];

  @override
  void initState() {
    super.initState();
    if (widget.taxLevy != null) {
      final tax = widget.taxLevy!;
      _nameController.text = tax.name;
      _rateController.text = tax.rate.toString();
      _descriptionController.text = tax.description;
      _legalReferenceController.text = tax.legalReference ?? '';
      _minAmountController.text = tax.minAmount?.toString() ?? '';
      _maxAmountController.text = tax.maxAmount?.toString() ?? '';
      _calculationType = tax.calculationType;
      _isActive = tax.isActive;
      _appliesTo.addAll(tax.appliesTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.taxLevy == null ? 'Add Tax/Levy' : 'Edit Tax/Levy'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tax/Levy Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate *',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TaxCalculationType>(
                      value: _calculationType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: TaxCalculationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _calculationType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildAppliesToSection(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _legalReferenceController,
                decoration: const InputDecoration(
                  labelText: 'Legal Reference',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Min Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final taxLevy = TaxLevy(
                name: _nameController.text,
                rate: double.parse(_rateController.text),
                calculationType: _calculationType,
                appliesTo: _appliesTo,
                minAmount: _minAmountController.text.isNotEmpty
                    ? double.parse(_minAmountController.text)
                    : null,
                maxAmount: _maxAmountController.text.isNotEmpty
                    ? double.parse(_maxAmountController.text)
                    : null,
                isActive: _isActive,
                legalReference: _legalReferenceController.text.isNotEmpty
                    ? _legalReferenceController.text
                    : null,
                description: _descriptionController.text,
              );
              Navigator.pop(context, taxLevy);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildAppliesToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Applies To:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAppliesToChip('consumption'),
            _buildAppliesToChip('service_charges'),
            _buildAppliesToChip('fixed_charges'),
            _buildAppliesToChip('meter_rental'),
            _buildAppliesToChip('connection_charges'),
          ],
        ),
        if (_appliesTo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 4,
              children: _appliesTo.map((item) {
                return Chip(
                  label: Text(item.replaceAll('_', ' ').toTitleCase()),
                  onDeleted: () {
                    setState(() => _appliesTo.remove(item));
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAppliesToChip(String label) {
    final isSelected = _appliesTo.contains(label);
    return FilterChip(
      label: Text(label.replaceAll('_', ' ').toTitleCase()),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _appliesTo.add(label);
          } else {
            _appliesTo.remove(label);
          }
        });
      },
    );
  }
}

// Helper Dialog for Penalty
class _PenaltyDialog extends StatefulWidget {
  final PenaltyStructure? penalty;

  const _PenaltyDialog({this.penalty});

  @override
  _PenaltyDialogState createState() => _PenaltyDialogState();
}

class _PenaltyDialogState extends State<_PenaltyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gracePeriodController = TextEditingController();
  final _maxAmountController = TextEditingController();
  final _capAmountController = TextEditingController();

  PenaltyCalculationType _calculationType = PenaltyCalculationType.percentage;
  PenaltyFrequency _frequency = PenaltyFrequency.monthly;

  @override
  void initState() {
    super.initState();
    if (widget.penalty != null) {
      final penalty = widget.penalty!;
      _typeController.text = penalty.type;
      _rateController.text = penalty.rate.toString();
      _descriptionController.text = penalty.description;
      _gracePeriodController.text = penalty.gracePeriod.toString();
      _maxAmountController.text = penalty.maxAmount?.toString() ?? '';
      _capAmountController.text = penalty.capAmount?.toString() ?? '';
      _calculationType = penalty.calculationType;
      _frequency = penalty.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.penalty == null ? 'Add Penalty' : 'Edit Penalty'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Penalty Type *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Late Payment',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate *',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<PenaltyCalculationType>(
                      value: _calculationType,
                      decoration: const InputDecoration(
                        labelText: 'Calculation',
                        border: OutlineInputBorder(),
                      ),
                      items: PenaltyCalculationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _calculationType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PenaltyFrequency>(
                      value: _frequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: PenaltyFrequency.values.map((freq) {
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freq.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _frequency = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gracePeriodController,
                      decoration: const InputDecoration(
                        labelText: 'Grace Period (Days) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final days = int.tryParse(value);
                        if (days == null || days < 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _capAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Cap Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final penalty = PenaltyStructure(
                type: _typeController.text,
                rate: double.parse(_rateController.text),
                calculationType: _calculationType,
                frequency: _frequency,
                gracePeriod: int.parse(_gracePeriodController.text),
                maxAmount: _maxAmountController.text.isNotEmpty
                    ? double.parse(_maxAmountController.text)
                    : null,
                capAmount: _capAmountController.text.isNotEmpty
                    ? double.parse(_capAmountController.text)
                    : null,
                description: _descriptionController.text,
              );
              Navigator.pop(context, penalty);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
