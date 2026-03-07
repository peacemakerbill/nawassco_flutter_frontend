import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/contract.dart';
import '../../../../providers/contract_provider.dart';

class CreateContractScreen extends ConsumerStatefulWidget {
  const CreateContractScreen({super.key});

  @override
  ConsumerState<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends ConsumerState<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _categoryController = TextEditingController();
  final _renewalTermsController = TextEditingController();

  String _type = 'SERVICE';
  String _currency = 'KES';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _renewable = false;
  int _maxRenewals = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _contractNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contractValueController.dispose();
    _categoryController.dispose();
    _renewalTermsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final contract = Contract(
        id: '',
        contractNumber: _contractNumberController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        supplierId: 'supplier_id_here', // You'll need to get this from a supplier provider
        supplierName: 'Supplier Name', // You'll need to get this from a supplier provider
        contractValue: double.parse(_contractValueController.text),
        currency: _currency,
        type: _type,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        renewable: _renewable,
        renewalCount: 0,
        maxRenewals: _maxRenewals,
        renewalTerms: _renewalTermsController.text.isEmpty ? null : _renewalTermsController.text,
        status: 'DRAFT',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isExpired: false,
        renewalAllowed: true,
      );

      await ref.read(contractsProvider.notifier).createContract(contract);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create contract: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 365)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Contract'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _contractNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contract Number*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contract number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contract title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contractValueController,
                decoration: const InputDecoration(
                  labelText: 'Contract Value*',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contract value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Contract Type',
                  border: OutlineInputBorder(),
                ),
                items: ['SERVICE', 'FRAMEWORK', 'PURCHASE', 'CONSULTANCY', 'OTHER']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date*',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_startDate != null
                                ? _formatDate(_startDate!)
                                : 'Select date'),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date*',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_endDate != null
                                ? _formatDate(_endDate!)
                                : 'Select date'),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Renewable Contract'),
                value: _renewable,
                onChanged: (value) => setState(() => _renewable = value),
              ),
              if (_renewable) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(text: _maxRenewals.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Maximum Renewals',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxRenewals = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _renewalTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Renewal Terms',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create Contract'),
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
}