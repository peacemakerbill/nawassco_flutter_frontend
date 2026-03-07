import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/contract_provider.dart';
import '../../../../domain/models/contract.dart';

class RenewContractScreen extends ConsumerStatefulWidget {
  final Contract contract;

  const RenewContractScreen({super.key, required this.contract});

  @override
  ConsumerState<RenewContractScreen> createState() => _RenewContractScreenState();
}

class _RenewContractScreenState extends ConsumerState<RenewContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _renewalTermsController = TextEditingController();
  DateTime? _newEndDate;
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_newEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select new end date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(contractsProvider.notifier).renewContract(
        widget.contract.id,
        newEndDate: _newEndDate!,
        renewalTerms: _renewalTermsController.text.isEmpty ? null : _renewalTermsController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract renewed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to renew contract: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectNewEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.contract.endDate.add(const Duration(days: 30)),
      firstDate: widget.contract.endDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _newEndDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Contract'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contract.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Contract No: ${widget.contract.contractNumber}'),
                      Text('Supplier: ${widget.contract.supplierName}'),
                      Text('Current End Date: ${_formatDate(widget.contract.endDate)}'),
                      Text('Renewal Count: ${widget.contract.renewalCount}/${widget.contract.maxRenewals}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _selectNewEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'New End Date*',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_newEndDate != null
                          ? _formatDate(_newEndDate!)
                          : 'Select new end date'),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _renewalTermsController,
                decoration: const InputDecoration(
                  labelText: 'Renewal Terms (Optional)',
                  border: OutlineInputBorder(),
                  helperText: 'Describe any changes to the contract terms',
                ),
                maxLines: 4,
              ),
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
                    : const Text('Renew Contract'),
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