import 'package:flutter/material.dart';

import '../../../models/tariff_model.dart';

class ConsumptionTierWidget extends StatefulWidget {
  final List<ConsumptionTier> tiers;
  final ValueChanged<List<ConsumptionTier>> onTiersUpdated;

  const ConsumptionTierWidget({
    super.key,
    required this.tiers,
    required this.onTiersUpdated,
  });

  @override
  State<ConsumptionTierWidget> createState() => _ConsumptionTierWidgetState();
}

class _ConsumptionTierWidgetState extends State<ConsumptionTierWidget> {
  late List<ConsumptionTier> _tiers;

  @override
  void initState() {
    super.initState();
    _tiers = List.from(widget.tiers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _addTier,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Tier'),
                ),
                const SizedBox(width: 8),
                if (_tiers.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _clearAllTiers,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure consumption tiers with progressive or block pricing',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        if (_tiers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.layers_clear,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No consumption tiers configured',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add tiers to configure progressive or block pricing',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ..._tiers.asMap().entries.map((entry) {
            final index = entry.key;
            final tier = entry.value;
            return _buildTierCard(tier, index);
          }),
        const SizedBox(height: 16),
        if (_tiers.isNotEmpty)
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
                        'Tier Configuration Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Ensure tiers are sequential without gaps'),
                  const Text('• Last tier should not have a maximum limit'),
                  const Text('• Progressive pricing applies rate to each tier'),
                  const Text(
                      '• Block pricing applies single rate to consumption range'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTierCard(ConsumptionTier tier, int index) {
    final isLast = index == _tiers.length - 1;

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
                  label: Text('Tier ${index + 1}'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
                Row(
                  children: [
                    if (index > 0)
                      IconButton(
                        onPressed: () => _moveTierUp(index),
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        tooltip: 'Move Up',
                      ),
                    if (index < _tiers.length - 1)
                      IconButton(
                        onPressed: () => _moveTierDown(index),
                        icon: const Icon(Icons.arrow_downward, size: 18),
                        tooltip: 'Move Down',
                      ),
                    IconButton(
                      onPressed: () => _editTier(index),
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _removeTier(index),
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTierDetail('Min Units', '${tier.minUnits}'),
                ),
                Expanded(
                  child: _buildTierDetail(
                    'Max Units',
                    isLast ? 'No Limit' : '${tier.maxUnits}',
                  ),
                ),
                Expanded(
                  child: _buildTierDetail('Rate', 'KES ${tier.rate}/unit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
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
                const SizedBox(width: 8),
                if (tier.description.isNotEmpty)
                  Expanded(
                    child: Text(
                      tier.description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
              ],
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

  void _addTier() async {
    final result = await showDialog<ConsumptionTier>(
      context: context,
      builder: (context) => _TierDialog(
        tierCount: _tiers.length,
        existingTiers: _tiers,
      ),
    );

    if (result != null) {
      setState(() {
        _tiers.add(result);
        widget.onTiersUpdated(_tiers);
      });
    }
  }

  void _editTier(int index) async {
    final original = _tiers[index];
    final result = await showDialog<ConsumptionTier>(
      context: context,
      builder: (context) => _TierDialog(
        tier: original,
        tierCount: _tiers.length,
        existingTiers: _tiers,
        isEditing: true,
      ),
    );

    if (result != null) {
      setState(() {
        _tiers[index] = result;
        widget.onTiersUpdated(_tiers);
      });
    }
  }

  void _removeTier(int index) {
    setState(() {
      _tiers.removeAt(index);
      widget.onTiersUpdated(_tiers);
    });
  }

  void _moveTierUp(int index) {
    if (index == 0) return;
    setState(() {
      final tier = _tiers.removeAt(index);
      _tiers.insert(index - 1, tier);
      widget.onTiersUpdated(_tiers);
    });
  }

  void _moveTierDown(int index) {
    if (index == _tiers.length - 1) return;
    setState(() {
      final tier = _tiers.removeAt(index);
      _tiers.insert(index + 1, tier);
      widget.onTiersUpdated(_tiers);
    });
  }

  void _clearAllTiers() {
    setState(() {
      _tiers.clear();
      widget.onTiersUpdated(_tiers);
    });
  }
}

class _TierDialog extends StatefulWidget {
  final ConsumptionTier? tier;
  final int tierCount;
  final List<ConsumptionTier> existingTiers;
  final bool isEditing;

  const _TierDialog({
    this.tier,
    required this.tierCount,
    required this.existingTiers,
    this.isEditing = false,
  });

  @override
  _TierDialogState createState() => _TierDialogState();
}

class _TierDialogState extends State<_TierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _minUnitsController = TextEditingController();
  final _maxUnitsController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _tierNumber = 1;
  bool _isProgressive = true;
  bool _hasMaxLimit = true;

  @override
  void initState() {
    super.initState();
    if (widget.tier != null) {
      final tier = widget.tier!;
      _tierNumber = tier.tier;
      _minUnitsController.text = tier.minUnits.toString();
      if (tier.maxUnits != null) {
        _maxUnitsController.text = tier.maxUnits.toString();
      } else {
        _hasMaxLimit = false;
      }
      _rateController.text = tier.rate.toString();
      _descriptionController.text = tier.description;
      _isProgressive = tier.isProgressive;
    } else {
      _tierNumber = widget.tierCount + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Tier $_tierNumber' : 'Add New Tier'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                readOnly: true,
                initialValue: 'Tier $_tierNumber',
                decoration: const InputDecoration(
                  labelText: 'Tier Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minUnitsController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Units *',
                  border: OutlineInputBorder(),
                  suffixText: 'units',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final minUnits = double.tryParse(value);
                  if (minUnits == null || minUnits < 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Maximum Units Limit'),
                subtitle:
                    const Text('Last tier should not have a maximum limit'),
                value: _hasMaxLimit,
                onChanged: (value) => setState(() => _hasMaxLimit = value),
              ),
              if (_hasMaxLimit)
                TextFormField(
                  controller: _maxUnitsController,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Units *',
                    border: OutlineInputBorder(),
                    suffixText: 'units',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _hasMaxLimit
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final maxUnits = double.tryParse(value);
                          if (maxUnits == null || maxUnits < 0) {
                            return 'Enter a valid positive number';
                          }
                          final minUnits =
                              double.tryParse(_minUnitsController.text) ?? 0;
                          if (maxUnits <= minUnits) {
                            return 'Must be greater than minimum units';
                          }
                          return null;
                        }
                      : null,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate per Unit *',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Progressive Pricing'),
                subtitle: const Text('Uncheck for block pricing'),
                value: _isProgressive,
                onChanged: (value) => setState(() => _isProgressive = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
              final tier = ConsumptionTier(
                tier: _tierNumber,
                minUnits: double.parse(_minUnitsController.text),
                maxUnits: _hasMaxLimit
                    ? double.parse(_maxUnitsController.text)
                    : null,
                rate: double.parse(_rateController.text),
                description: _descriptionController.text,
                isProgressive: _isProgressive,
              );
              Navigator.pop(context, tier);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
