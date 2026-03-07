import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/tax_calculation_model.dart';
import '../../../../providers/tax_calculation_provider.dart';

class TaxCalculationDetailsWidget extends ConsumerStatefulWidget {
  final TaxCalculation calculation;
  final VoidCallback onUpdate;
  final bool isDialog;

  const TaxCalculationDetailsWidget({
    super.key,
    required this.calculation,
    required this.onUpdate,
    this.isDialog = false,
  });

  @override
  ConsumerState<TaxCalculationDetailsWidget> createState() =>
      _TaxCalculationDetailsWidgetState();
}

class _TaxCalculationDetailsWidgetState
    extends ConsumerState<TaxCalculationDetailsWidget> {
  late TaxCalculation _calculation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculation = widget.calculation;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDialog
        ? _buildDialogContent()
        : _buildFullScreenContent();
  }

  Widget _buildDialogContent() {
    return Column(
      children: [
        // Dialog header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF0D47A1), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _calculation.calculationNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_calculation.taxType.label} • ${_calculation.taxPeriod}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status chips
                  _buildStatusChips(),
                  const SizedBox(height: 20),

                  // Amounts overview
                  _buildAmountsOverview(),
                  const SizedBox(height: 20),

                  // Action buttons
                  _buildActionButtons(),
                  const SizedBox(height: 20),

                  // Details sections
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return isMobile
                          ? Column(
                        children: [
                          _buildCalculationDetailsCard(),
                          const SizedBox(height: 16),
                          _buildPaymentDetailsCard(),
                        ],
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCalculationDetailsCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPaymentDetailsCard()),
                        ],
                      );
                    },
                  ),

                  // Transactions section
                  if (_calculation.transactions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildTransactionsCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Header Card
          SliverToBoxAdapter(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            color: Color(0xFF0D47A1), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _calculation.calculationNumber,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_calculation.taxType.label} • ${_calculation.taxPeriod}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChips(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amounts Overview
                    _buildAmountsOverview(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Details Cards
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? Column(
                  children: [
                    _buildCalculationDetailsCard(),
                    const SizedBox(height: 16),
                    _buildPaymentDetailsCard(),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCalculationDetailsCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPaymentDetailsCard()),
                  ],
                );
              },
            ),
          ),

          // Transactions Section
          if (_calculation.transactions.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: _buildTransactionsCard(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _calculation.status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _calculation.status.color),
          ),
          child: Text(
            _calculation.status.label,
            style: TextStyle(
              color: _calculation.status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _calculation.paymentStatus.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _calculation.paymentStatus.color),
          ),
          child: Text(
            _calculation.paymentStatus.label,
            style: TextStyle(
              color: _calculation.paymentStatus.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D47A1).withOpacity(0.1),
            const Color(0xFF1976D2).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAmountItem(
              'Taxable Amount',
              'KES ${_calculation.taxableAmount.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildAmountItem(
              'Tax Amount',
              'KES ${_calculation.taxAmount.toStringAsFixed(2)}',
              Icons.percent,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildAmountItem(
              'Net Payable',
              'KES ${_calculation.netTaxPayable.toStringAsFixed(2)}',
              Icons.payment,
              isMain: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(String label, String value, IconData icon,
      {bool isMain = false}) {
    return Column(
      children: [
        Icon(icon,
            color: isMain ? const Color(0xFF0D47A1) : Colors.grey[600],
            size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMain ? 16 : 14,
            fontWeight: isMain ? FontWeight.w700 : FontWeight.w600,
            color: isMain ? const Color(0xFF0D47A1) : Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Edit button
        if (_calculation.canEdit)
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),

        // Calculate button
        if (_calculation.canCalculate)
          ElevatedButton.icon(
            onPressed: () => _calculateTax(),
            icon: const Icon(Icons.calculate, size: 20),
            label: const Text('Calculate Tax'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),

        // Approve button
        if (_calculation.canApprove)
          ElevatedButton.icon(
            onPressed: () => _approveCalculation(),
            icon: const Icon(Icons.thumb_up, size: 20),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

        // File button
        if (_calculation.canFile)
          ElevatedButton.icon(
            onPressed: () => _showFileTaxDialog(),
            icon: const Icon(Icons.file_upload, size: 20),
            label: const Text('File Tax'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),

        // Record Payment button
        if (_calculation.canRecordPayment)
          ElevatedButton.icon(
            onPressed: () => _showRecordPaymentDialog(),
            icon: const Icon(Icons.payment, size: 20),
            label: const Text('Record Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
          ),

        // Delete button (only for draft)
        if (_calculation.canEdit)
          ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmation(),
            icon: const Icon(Icons.delete, size: 20),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),

        // Upload Document button
        OutlinedButton.icon(
          onPressed: () => _showUploadDocumentDialog(),
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Document'),
        ),

        // Print/Export button
        OutlinedButton.icon(
          onPressed: () => _exportCalculation(),
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
      ],
    );
  }

  Widget _buildCalculationDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Calculation Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Tax Type', _calculation.taxType.label),
            _buildDetailRow('Tax Period', _calculation.taxPeriod),
            _buildDetailRow('Tax Rate', '${_calculation.taxRate}%'),
            _buildDetailRow('Withholding Tax',
                'KES ${_calculation.withholdingTax.toStringAsFixed(2)}'),
            _buildDetailRow('Created', _formatDate(_calculation.createdAt)),
            _buildDetailRow('Due Date', _formatDate(_calculation.dueDate)),
            if (_calculation.filedDate != null)
              _buildDetailRow(
                  'Filed Date', _formatDate(_calculation.filedDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Payment Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Net Tax Payable',
                'KES ${_calculation.netTaxPayable.toStringAsFixed(2)}'),
            _buildDetailRow('Paid Amount',
                'KES ${_calculation.paidAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Outstanding',
                'KES ${_calculation.outstandingAmount.toStringAsFixed(2)}'),
            if (_calculation.paymentDate != null)
              _buildDetailRow(
                  'Payment Date', _formatDate(_calculation.paymentDate!)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _calculation.netTaxPayable > 0
                  ? _calculation.paidAmount / _calculation.netTaxPayable
                  : 0,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF0D47A1),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${((_calculation.paidAmount / (_calculation.netTaxPayable > 0 ? _calculation.netTaxPayable : 1)) * 100).toStringAsFixed(1)}% Paid',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${((_calculation.outstandingAmount / (_calculation.netTaxPayable > 0 ? _calculation.netTaxPayable : 1)) * 100).toStringAsFixed(1)}% Due',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _calculation.outstandingAmount > 0
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Color(0xFF0D47A1), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Add transaction button
                if (_calculation.canEdit)
                  TextButton.icon(
                    onPressed: () => _showAddTransactionDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Transaction'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_calculation.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.receipt, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text(
                      'No Transactions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._calculation.transactions
                  .map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
            TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TaxTransaction transaction) {
    final transactionId = '${transaction.transactionDate.millisecondsSinceEpoch}-${transaction.reference.hashCode}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: const Color(0xFF0D47A1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.transactionType.label} • ${_formatDate(transaction.transactionDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Ref: ${transaction.reference}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${transaction.taxableAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Tax: KES ${transaction.taxAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          // Edit/Delete transaction buttons
          if (_calculation.canEdit) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _showEditTransactionDialog(transaction, transactionId),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _showDeleteTransactionDialog(transactionId),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // =============== CRUD OPERATIONS ===============

  Future<void> _setLoading(bool loading) async {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Calculate tax
  Future<void> _calculateTax() async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .calculateTax(_calculation.id!);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Tax calculated successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to calculate tax: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Approve calculation
  Future<void> _approveCalculation() async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .approveTaxCalculation(_calculation.id!);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Tax calculation approved!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to approve calculation: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // File tax
  Future<void> _fileTax(String filingReference) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .fileTax(_calculation.id!, filingReference);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Tax filed successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to file tax: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Record payment
  Future<void> _recordPayment(double amount, DateTime date) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .recordPayment(_calculation.id!, amount, date);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Payment recorded successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to record payment: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Delete calculation
  Future<void> _deleteCalculation() async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .deleteTaxCalculation(_calculation.id!);

      if (success) {
        _showSuccessSnackbar('Tax calculation deleted successfully!');
        if (widget.isDialog) {
          Navigator.of(context).pop();
        }
        widget.onUpdate();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete calculation: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Update calculation
  Future<void> _updateCalculation(Map<String, dynamic> data) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .updateTaxCalculation(_calculation.id!, data);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Tax calculation updated successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update calculation: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Add transaction
  Future<void> _addTransaction(Map<String, dynamic> transactionData) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .addTransaction(_calculation.id!, transactionData);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Transaction added successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to add transaction: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Update transaction
  Future<void> _updateTransaction(String transactionId, Map<String, dynamic> transactionData) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .updateTransaction(_calculation.id!, transactionId, transactionData);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Transaction updated successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update transaction: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Delete transaction
  Future<void> _deleteTransaction(String transactionId) async {
    await _setLoading(true);
    try {
      final success = await ref
          .read(taxCalculationProvider.notifier)
          .deleteTransaction(_calculation.id!, transactionId);

      if (success) {
        _refreshCalculation();
        _showSuccessSnackbar('Transaction deleted successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete transaction: ${e.toString()}');
    } finally {
      await _setLoading(false);
    }
  }

  // Upload document
  Future<void> _uploadDocument() async {
    // This would typically use a file picker
    _showSuccessSnackbar('Document upload functionality will be implemented');
  }

  // Export/Print
  void _exportCalculation() {
    _showSuccessSnackbar('Export/Print functionality will be implemented');
  }

  // Refresh calculation data
  void _refreshCalculation() {
    ref
        .read(taxCalculationProvider.notifier)
        .getTaxCalculationById(_calculation.id!)
        .then((_) {
      final updatedState = ref.read(taxCalculationProvider);
      if (updatedState.selectedCalculation != null) {
        setState(() {
          _calculation = updatedState.selectedCalculation!;
        });
      }
    });
  }

  // =============== DIALOG METHODS ===============

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditTaxCalculationDialog(
        calculation: _calculation,
        onSave: (updatedData) async {
          Navigator.of(context).pop();
          await _updateCalculation(updatedData);
        },
      ),
    );
  }

  void _showFileTaxDialog() {
    showDialog(
      context: context,
      builder: (context) => FileTaxDialog(
        calculation: _calculation,
        onFile: (reference) async {
          Navigator.of(context).pop();
          await _fileTax(reference);
        },
      ),
    );
  }

  void _showRecordPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        calculation: _calculation,
        onRecord: (amount, date) async {
          Navigator.of(context).pop();
          await _recordPayment(amount, date);
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tax Calculation'),
        content: const Text(
            'Are you sure you want to delete this tax calculation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCalculation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        onSave: (transactionData) async {
          Navigator.of(context).pop();
          await _addTransaction(transactionData);
        },
      ),
    );
  }

  void _showEditTransactionDialog(TaxTransaction transaction, String transactionId) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        onSave: (updatedData) async {
          Navigator.of(context).pop();
          await _updateTransaction(transactionId, updatedData);
        },
      ),
    );
  }

  void _showDeleteTransactionDialog(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTransaction(transactionId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUploadDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: const Text('Please select a document to upload.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadDocument();
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

// =============== DIALOG WIDGETS ===============

class EditTaxCalculationDialog extends StatefulWidget {
  final TaxCalculation calculation;
  final Function(Map<String, dynamic>) onSave;

  const EditTaxCalculationDialog({
    super.key,
    required this.calculation,
    required this.onSave,
  });

  @override
  State<EditTaxCalculationDialog> createState() => _EditTaxCalculationDialogState();
}

class _EditTaxCalculationDialogState extends State<EditTaxCalculationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taxPeriodController = TextEditingController();
  final _taxableAmountController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _withholdingTaxController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _taxPeriodController.text = widget.calculation.taxPeriod;
    _taxableAmountController.text = widget.calculation.taxableAmount.toStringAsFixed(2);
    _taxRateController.text = widget.calculation.taxRate.toStringAsFixed(2);
    _withholdingTaxController.text = widget.calculation.withholdingTax.toStringAsFixed(2);
    _dueDate = widget.calculation.dueDate;
  }

  @override
  void dispose() {
    _taxPeriodController.dispose();
    _taxableAmountController.dispose();
    _taxRateController.dispose();
    _withholdingTaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Tax Calculation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _taxPeriodController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Period',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax period';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxableAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Taxable Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter taxable amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Rate (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Please enter a valid tax rate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _withholdingTaxController,
                  decoration: const InputDecoration(
                    labelText: 'Withholding Tax (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _dueDate != null
                        ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                        : '',
                  ),
                  onTap: () => _selectDueDate(context),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedData = {
                            'taxPeriod': _taxPeriodController.text,
                            'taxableAmount': double.parse(_taxableAmountController.text),
                            'taxRate': double.parse(_taxRateController.text),
                            'withholdingTax': double.parse(_withholdingTaxController.text),
                            'dueDate': _dueDate!.toIso8601String(),
                          };
                          widget.onSave(updatedData);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddTransactionDialog({super.key, required this.onSave});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _taxableAmountController = TextEditingController();
  final _taxAmountController = TextEditingController();
  TransactionType _selectedType = TransactionType.sales;
  DateTime _transactionDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _referenceController.dispose();
    _taxableAmountController.dispose();
    _taxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                  items: TransactionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reference';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxableAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Taxable Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter taxable amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Transaction Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                  ),
                  onTap: () => _selectTransactionDate(context),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final transactionData = {
                            'description': _descriptionController.text,
                            'reference': _referenceController.text,
                            'taxableAmount': double.parse(_taxableAmountController.text),
                            'taxAmount': double.parse(_taxAmountController.text),
                            'transactionType': _selectedType.name,
                            'transactionDate': _transactionDate.toIso8601String(),
                          };
                          widget.onSave(transactionData);
                        }
                      },
                      child: const Text('Add Transaction'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTransactionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _transactionDate = picked);
    }
  }
}

class EditTransactionDialog extends StatefulWidget {
  final TaxTransaction transaction;
  final Function(Map<String, dynamic>) onSave;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.onSave,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _taxableAmountController = TextEditingController();
  final _taxAmountController = TextEditingController();
  late TransactionType _selectedType;
  late DateTime _transactionDate;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.transaction.description;
    _referenceController.text = widget.transaction.reference;
    _taxableAmountController.text = widget.transaction.taxableAmount.toStringAsFixed(2);
    _taxAmountController.text = widget.transaction.taxAmount.toStringAsFixed(2);
    _selectedType = widget.transaction.transactionType;
    _transactionDate = widget.transaction.transactionDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _referenceController.dispose();
    _taxableAmountController.dispose();
    _taxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                  items: TransactionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reference';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxableAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Taxable Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter taxable amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Transaction Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                  ),
                  onTap: () => _selectTransactionDate(context),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final transactionData = {
                            'description': _descriptionController.text,
                            'reference': _referenceController.text,
                            'taxableAmount': double.parse(_taxableAmountController.text),
                            'taxAmount': double.parse(_taxAmountController.text),
                            'transactionType': _selectedType.name,
                            'transactionDate': _transactionDate.toIso8601String(),
                          };
                          widget.onSave(transactionData);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTransactionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _transactionDate = picked);
    }
  }
}

class FileTaxDialog extends StatefulWidget {
  final TaxCalculation calculation;
  final Function(String) onFile;

  const FileTaxDialog(
      {super.key, required this.calculation, required this.onFile});

  @override
  State<FileTaxDialog> createState() => _FileTaxDialogState();
}

class _FileTaxDialogState extends State<FileTaxDialog> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('File Tax Calculation'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the filing reference for ${widget.calculation.calculationNumber}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Filing Reference*',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter filing reference';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onFile(_referenceController.text);
            }
          },
          child: const Text('File Tax'),
        ),
      ],
    );
  }
}

class RecordPaymentDialog extends StatefulWidget {
  final TaxCalculation calculation;
  final Function(double, DateTime) onRecord;

  const RecordPaymentDialog(
      {super.key, required this.calculation, required this.onRecord});

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Tax Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Record payment for ${widget.calculation.calculationNumber}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter valid amount';
                }
                if (amount > widget.calculation.outstandingAmount) {
                  return 'Amount cannot exceed outstanding amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Payment Date*',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
              ),
              onTap: () => _selectPaymentDate(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Outstanding: KES ${widget.calculation.outstandingAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.orange),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              widget.onRecord(amount, _paymentDate);
            }
          },
          child: const Text('Record Payment'),
        ),
      ],
    );
  }

  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() => _paymentDate = picked);
    }
  }
}