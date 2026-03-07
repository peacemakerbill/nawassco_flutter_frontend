import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/stock/stock_movement_model.dart';
import '../../../../providers/stock_movement_provider.dart';

class EditMovementDialog extends ConsumerStatefulWidget {
  final StockMovement movement;
  final VoidCallback? onMovementUpdated;

  const EditMovementDialog({
    super.key,
    required this.movement,
    this.onMovementUpdated,
  });

  @override
  ConsumerState<EditMovementDialog> createState() => _EditMovementDialogState();
}

class _EditMovementDialogState extends ConsumerState<EditMovementDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _status;
  late String _notes;
  late DateTime _movementDate;

  @override
  void initState() {
    super.initState();
    _status = widget.movement.status;
    _notes = widget.movement.notes ?? '';
    _movementDate = widget.movement.movementDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Stock Movement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.movement.movementNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),

                      // Status
                      _buildStatusSection(),
                      const SizedBox(height: 24),

                      // Notes
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                        ),
                        child: const Text('Update Movement'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InfoDisplay(
                  label: 'Movement Type',
                  value: _getMovementTypeText(widget.movement.movementType),
                ),
                _InfoDisplay(
                  label: 'Reference Number',
                  value: widget.movement.referenceNumber,
                ),
                _InfoDisplay(
                  label: 'Reference Type',
                  value: _getReferenceTypeText(widget.movement.referenceType),
                ),
                _InfoDisplay(
                  label: 'Total Quantity',
                  value: '${widget.movement.totalQuantity} items',
                ),
                _InfoDisplay(
                  label: 'Total Value',
                  value: 'KES ${widget.movement.totalValue.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Movement Status',
                border: OutlineInputBorder(),
              ),
              items: _getAvailableStatuses().map((status) {
                return DropdownMenuItem(
                  value: status.value,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(status.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            InputDatePickerFormField(
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDate: _movementDate,
              fieldLabelText: 'Movement Date',
              onDateSubmitted: (date) {
                setState(() {
                  _movementDate = date;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _notes,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<({String value, String label, Color color})> _getAvailableStatuses() {
    final statuses = <({String value, String label, Color color})>[
      (value: 'draft', label: 'Draft', color: Colors.grey),
      (value: 'pending', label: 'Pending', color: Colors.orange),
      (value: 'in_progress', label: 'In Progress', color: Colors.blue),
    ];

    // Only allow completed if approved
    if (widget.movement.approvalStatus == 'approved') {
      statuses
          .add((value: 'completed', label: 'Completed', color: Colors.green));
    }

    return statuses;
  }

  String _getMovementTypeText(String type) {
    switch (type) {
      case 'receipt':
        return 'Stock Receipt';
      case 'issue':
        return 'Stock Issue';
      case 'transfer':
        return 'Stock Transfer';
      case 'return':
        return 'Stock Return';
      case 'adjustment':
        return 'Stock Adjustment';
      case 'write_off':
        return 'Stock Write Off';
      default:
        return type;
    }
  }

  String _getReferenceTypeText(String referenceType) {
    return referenceType.replaceAll('_', ' ').toUpperCase();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'status': _status,
        'movementDate': _movementDate.toIso8601String(),
        if (_notes.isNotEmpty) 'notes': _notes,
      };

      final authState = ref.read(authProvider);
      await ref.read(stockMovementProvider.notifier).updateStockMovement(
            widget.movement.id,
            updateData,
            authState.user?['_id'] ?? '',
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onMovementUpdated?.call();
      }
    }
  }
}

class _InfoDisplay extends StatelessWidget {
  final String label;
  final String value;

  const _InfoDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
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
}
