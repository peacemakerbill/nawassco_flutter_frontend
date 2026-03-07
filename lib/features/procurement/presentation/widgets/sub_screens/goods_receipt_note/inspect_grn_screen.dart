import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/goods_receipt_note.dart';
import '../../../../providers/goods_receipt_note_provider.dart';

class InspectGRNScreen extends ConsumerStatefulWidget {
  final GoodsReceiptNote grn;

  const InspectGRNScreen({super.key, required this.grn});

  @override
  ConsumerState<InspectGRNScreen> createState() => _InspectGRNScreenState();
}

class _InspectGRNScreenState extends ConsumerState<InspectGRNScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qualityRemarksController = TextEditingController();
  String _qualityStatus = 'pending';
  final Map<String, TextEditingController> _rejectionControllers = {};
  final Map<String, int> _acceptedQuantities = {};
  final Map<String, int> _rejectedQuantities = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize quantities with received quantities
    for (final item in widget.grn.items) {
      _acceptedQuantities[item.poItem] = item.receivedQuantity;
      _rejectedQuantities[item.poItem] = 0;
      _rejectionControllers[item.poItem] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _qualityRemarksController.dispose();
    for (final controller in _rejectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(goodsReceiptNotesProvider.notifier).inspectGRN(
            widget.grn.id,
            qualityStatus: _qualityStatus,
            qualityRemarks: _qualityRemarksController.text.isEmpty
                ? null
                : _qualityRemarksController.text,
            inspectedBy:
                'user_id_here', // You'll need to get this from auth provider
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('GRN inspection completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to inspect GRN: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _updateItemQuantities(String poItem, int accepted, int rejected) {
    setState(() {
      _acceptedQuantities[poItem] = accepted;
      _rejectedQuantities[poItem] = rejected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspect GRN'),
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
                        widget.grn.grnNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('PO: ${widget.grn.purchaseOrderNumber}'),
                      Text('Supplier: ${widget.grn.supplierName}'),
                      Text('Total Items: ${widget.grn.items.length}'),
                      Text('Total Quantity: ${widget.grn.totalQuantity}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quality Status
              DropdownButtonFormField<String>(
                value: _qualityStatus,
                decoration: const InputDecoration(
                  labelText: 'Quality Status*',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('PENDING')),
                  DropdownMenuItem(value: 'passed', child: Text('PASSED')),
                  DropdownMenuItem(value: 'failed', child: Text('FAILED')),
                  DropdownMenuItem(
                      value: 'conditional', child: Text('CONDITIONAL')),
                ],
                onChanged: (value) => setState(() => _qualityStatus = value!),
                validator: (value) =>
                    value == null ? 'Please select quality status' : null,
              ),
              const SizedBox(height: 16),

              // Quality Remarks
              TextFormField(
                controller: _qualityRemarksController,
                decoration: const InputDecoration(
                  labelText: 'Quality Remarks',
                  border: OutlineInputBorder(),
                  helperText:
                      'Additional comments about the quality inspection',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Items Inspection
              const Text(
                'Item Inspection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...widget.grn.items
                  .map((item) => _buildItemInspectionCard(item))
                  .toList(),

              const SizedBox(height: 32),

              // Submit Button
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
                    : const Text('Complete Inspection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemInspectionCard(GRNItem item) {
    final accepted = _acceptedQuantities[item.poItem] ?? 0;
    final rejected = _rejectedQuantities[item.poItem] ?? 0;
    final totalReceived = item.receivedQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('PO Item: ${item.poItem}'),
            Text('Ordered: ${item.orderedQuantity} ${item.unit}'),
            Text('Received: $totalReceived ${item.unit}'),
            const SizedBox(height: 12),

            // Quantity Adjustment
            const Text(
              'Quantity Adjustment:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Accepted:'),
                      TextFormField(
                        initialValue: accepted.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newAccepted = int.tryParse(value) ?? 0;
                          final newRejected = totalReceived - newAccepted;
                          if (newRejected >= 0) {
                            _updateItemQuantities(
                                item.poItem, newAccepted, newRejected);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rejected:'),
                      TextFormField(
                        initialValue: rejected.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newRejected = int.tryParse(value) ?? 0;
                          final newAccepted = totalReceived - newRejected;
                          if (newAccepted >= 0) {
                            _updateItemQuantities(
                                item.poItem, newAccepted, newRejected);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${accepted + rejected}/${totalReceived}',
              style: TextStyle(
                color: (accepted + rejected) == totalReceived
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Rejection Reason
            if (rejected > 0) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _rejectionControllers[item.poItem],
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason',
                  border: OutlineInputBorder(),
                  helperText: 'Why was this item rejected?',
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
