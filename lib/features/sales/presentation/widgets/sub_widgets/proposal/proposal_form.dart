import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../models/customer.model.dart';
import '../../../../models/proposal.model.dart';
import '../../../../providers/proposal.provider.dart';

class ProposalForm extends ConsumerStatefulWidget {
  final Proposal? initialProposal;
  final List<Customer> customers;
  final VoidCallback onSuccess;

  const ProposalForm({
    super.key,
    this.initialProposal,
    required this.customers,
    required this.onSuccess,
  });

  @override
  ConsumerState<ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends ConsumerState<ProposalForm> {
  final _formKey = GlobalKey<FormState>();
  final _executiveSummaryController = TextEditingController();
  final _scopeOfWorkController = TextEditingController();
  final _technicalApproachController = TextEditingController();
  final _methodologyController = TextEditingController();

  // Add customer search controller
  final _customerSearchController = TextEditingController();

  late ProposalStatus _status;
  late PricingModel _pricingModel;
  late ReviewStatus _reviewStatus;
  late ApprovalStatus _approvalStatus;
  String? _customerId;
  double _discountAmount = 0;
  List<ProposalItem> _items = [];

  // Helper method to get unique customers
  List<Customer> _getUniqueCustomers(List<Customer> customers) {
    final seenIds = <String>{};
    return customers.where((customer) {
      if (customer.id.isEmpty) return false; // Skip customers with empty IDs
      if (seenIds.contains(customer.id)) return false;
      seenIds.add(customer.id);
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    final uniqueCustomers = _getUniqueCustomers(widget.customers);

    if (widget.initialProposal != null) {
      final proposal = widget.initialProposal!;
      _status = proposal.status;
      _pricingModel = proposal.pricingModel;
      _reviewStatus = proposal.reviewStatus;
      _approvalStatus = proposal.approvalStatus;

      // Validate that the customer exists in our list
      final customerExists = uniqueCustomers.any((c) => c.id == proposal.customer);
      _customerId = customerExists && proposal.customer.isNotEmpty
          ? proposal.customer
          : null;

      _discountAmount = proposal.discountAmount;
      _items = List.from(proposal.items);

      _executiveSummaryController.text = proposal.executiveSummary;
      _scopeOfWorkController.text = proposal.scopeOfWork;
      _technicalApproachController.text = proposal.technicalApproach;
      _methodologyController.text = proposal.methodology;

      // Update customer search controller text
      _updateCustomerSearchController();
    } else {
      _status = ProposalStatus.draft;
      _pricingModel = PricingModel.fixed_price;
      _reviewStatus = ReviewStatus.pending;
      _approvalStatus = ApprovalStatus.pending;
      _customerId = uniqueCustomers.isNotEmpty ? uniqueCustomers.first.id : null;
      _items = [
        ProposalItem(
          description: 'Initial Service',
          quantity: 1,
          unitPrice: 0,
          totalPrice: 0,
        ),
      ];

      // Update customer search controller text for new proposal
      _updateCustomerSearchController();
    }
  }

  void _updateCustomerSearchController() {
    final uniqueCustomers = _getUniqueCustomers(widget.customers);
    if (_customerId != null && uniqueCustomers.isNotEmpty) {
      final customer = uniqueCustomers.firstWhere(
            (c) => c.id == _customerId,
        orElse: () => uniqueCustomers.first,
      );
      if (customer.id == _customerId) {
        _customerSearchController.text = customer.displayName;
      }
    }
  }

  @override
  void dispose() {
    _executiveSummaryController.dispose();
    _scopeOfWorkController.dispose();
    _technicalApproachController.dispose();
    _methodologyController.dispose();
    _customerSearchController.dispose(); // Don't forget to dispose
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate customer is selected
    if (_customerId == null || _customerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final proposalData = {
      'customer': _customerId!,
      'executiveSummary': _executiveSummaryController.text.trim(),
      'scopeOfWork': _scopeOfWorkController.text.trim(),
      'technicalApproach': _technicalApproachController.text.trim(),
      'methodology': _methodologyController.text.trim(),
      'pricingModel': _pricingModel.name,
      'reviewStatus': _reviewStatus.name,
      'approvalStatus': _approvalStatus.name,
      'items': _items.map((item) => item.toJson()).toList(),
      'discountAmount': _discountAmount,
      'status': _status.name, // Always include status for both create and update
    };

    final provider = ref.read(proposalProvider.notifier);
    Proposal? result;

    if (widget.initialProposal != null) {
      result = await provider.updateProposal(
        widget.initialProposal!.id,
        proposalData,
      );
    } else {
      result = await provider.createProposal(proposalData);
    }

    if (result != null && mounted) {
      widget.onSuccess();
    }
  }

  void _addItem() {
    setState(() {
      _items.add(const ProposalItem(
        description: 'New Item',
        quantity: 1,
        unitPrice: 0,
        totalPrice: 0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, ProposalItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  double _calculateTotal() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0));
    final taxAmount = _items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0));
    return subtotal + taxAmount - _discountAmount;
  }

  Color _getStatusColor(ProposalStatus status) {
    return switch (status) {
      ProposalStatus.draft => const Color(0xFF9E9E9E),
      ProposalStatus.submitted => const Color(0xFF2196F3),
      ProposalStatus.under_review => const Color(0xFFFF9800),
      ProposalStatus.revised => const Color(0xFF9C27B0),
      ProposalStatus.negotiation => const Color(0xFF3F51B5),
      ProposalStatus.accepted => const Color(0xFF4CAF50),
      ProposalStatus.rejected => const Color(0xFFF44336),
      ProposalStatus.expired => const Color(0xFF607D8B),
      ProposalStatus.signed => const Color(0xFF009688),
      ProposalStatus.converted_to_contract => const Color(0xFF795548),
    };
  }

  Color _getReviewStatusColor(ReviewStatus status) {
    return switch (status) {
      ReviewStatus.pending => const Color(0xFF9E9E9E),
      ReviewStatus.in_progress => const Color(0xFFFF9800),
      ReviewStatus.completed => const Color(0xFF4CAF50),
    };
  }

  Color _getApprovalStatusColor(ApprovalStatus status) {
    return switch (status) {
      ApprovalStatus.pending => const Color(0xFF9E9E9E),
      ApprovalStatus.approved => const Color(0xFF4CAF50),
      ApprovalStatus.rejected => const Color(0xFFF44336),
      ApprovalStatus.requires_revision => const Color(0xFFFF9800),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalProvider);
    final isCreating = state.isCreating;
    final isUpdating = state.isUpdating;

    // Get unique customers for typeahead
    final uniqueCustomers = _getUniqueCustomers(widget.customers);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.initialProposal != null ? 'Edit Proposal' : 'Create New Proposal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check),
            tooltip: widget.initialProposal != null ? 'Update Proposal' : 'Create Proposal',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer TypeAhead (Replaced Dropdown with TypeAhead)
                      _buildCustomerTypeAhead(uniqueCustomers),
                      const SizedBox(height: 16),

                      // Status Selection (for both new and existing proposals)
                      _buildStatusDropdown(),
                      const SizedBox(height: 16),

                      // Review and Approval Status Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildReviewStatusDropdown(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildApprovalStatusDropdown(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Proposal Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proposal Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Executive Summary
                      _buildTextField(
                        label: 'Executive Summary *',
                        controller: _executiveSummaryController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an executive summary';
                          }
                          if (value.length < 50) {
                            return 'Summary should be at least 50 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Scope of Work
                      _buildTextField(
                        label: 'Scope of Work *',
                        controller: _scopeOfWorkController,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter scope of work';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Technical Approach
                      _buildTextField(
                        label: 'Technical Approach',
                        controller: _technicalApproachController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Methodology
                      _buildTextField(
                        label: 'Methodology',
                        controller: _methodologyController,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pricing Section Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pricing Model
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing Model *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<PricingModel>(
                              value: _pricingModel,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: PricingModel.values
                                  .map((model) => DropdownMenuItem(
                                value: model,
                                child: Text(model.displayName),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pricingModel = value ?? PricingModel.fixed_price;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Discount Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discount Amount (KES)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: _discountAmount.toStringAsFixed(2),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                              prefixText: 'KES ',
                            ),
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              final discount = double.tryParse(value) ?? 0;
                              setState(() {
                                _discountAmount = discount;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Proposal Items *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No items added',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add items to create your proposal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _items.length - 1 ? 0 : 12,
                            ),
                            child: _buildItemCard(index, item),
                          );
                        }),

                      if (_items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTotalsSection(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: isCreating || isUpdating ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: (isCreating || isUpdating)
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : Text(
                            widget.initialProposal != null ? 'Update Proposal' : 'Create Proposal',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Color(0xFF1E3A8A)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF1E3A8A)),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF1E3A8A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isCreating || isUpdating ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: (isCreating || isUpdating)
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Text(
                              widget.initialProposal != null ? 'Update Proposal' : 'Create Proposal',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Updated customer field using TypeAhead instead of Dropdown
  Widget _buildCustomerTypeAhead(List<Customer> uniqueCustomers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TypeAheadFormField<Customer>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _customerSearchController,
            decoration: InputDecoration(
              labelText: 'Search Customer',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              suffixIcon: _customerSearchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _customerSearchController.clear();
                    _customerId = null;
                  });
                },
              )
                  : null,
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          suggestionsCallback: (pattern) {
            return uniqueCustomers.where((customer) {
              final text = customer.displayName.toLowerCase();
              return text.contains(pattern.toLowerCase());
            }).toList();
          },
          itemBuilder: (context, customer) {
            return ListTile(
              leading: const Icon(Icons.person, size: 20),
              title: Text(customer.displayName),
              subtitle: customer.email.isNotEmpty
                  ? Text(customer.email)
                  : customer.phone.isNotEmpty
                  ? Text(customer.phone)
                  : null,
            );
          },
          onSuggestionSelected: (customer) {
            setState(() {
              _customerId = customer.id;
              _customerSearchController.text = customer.displayName;
            });
          },
          validator: (value) {
            if (_customerId == null || _customerId!.isEmpty) {
              return 'Customer is required';
            }
            return null;
          },
          noItemsFoundBuilder: (context) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No customers found'),
            );
          },
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(8),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      validator: validator,
    );
  }

  Widget _buildItemCard(int index, ProposalItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.description ?? 'Item ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(index),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 1;
                      final updatedItem = item.copyWith(
                        quantity: qty,
                        totalPrice: qty * (item.unitPrice ?? 0),
                      );
                      _updateItem(index, updatedItem);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice?.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price (KES)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      final updatedItem = item.copyWith(
                        unitPrice: price,
                        totalPrice: (item.quantity ?? 1) * price,
                      );
                      _updateItem(index, updatedItem);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      final updatedItem = item.copyWith(description: value);
                      _updateItem(index, updatedItem);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total: KES ${(item.totalPrice ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposal Status *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<ProposalStatus>(
            value: _status,
            isExpanded: true,
            underline: const SizedBox(),
            items: ProposalStatus.values
                .map((status) => DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _status = value ?? ProposalStatus.draft;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<ReviewStatus>(
            value: _reviewStatus,
            isExpanded: true,
            underline: const SizedBox(),
            items: ReviewStatus.values
                .map((status) => DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getReviewStatusColor(status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _reviewStatus = value ?? ReviewStatus.pending;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Approval Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<ApprovalStatus>(
            value: _approvalStatus,
            isExpanded: true,
            underline: const SizedBox(),
            items: ApprovalStatus.values
                .map((status) => DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getApprovalStatusColor(status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _approvalStatus = value ?? ApprovalStatus.pending;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0));
    final taxAmount = _items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0));
    final total = subtotal + taxAmount - _discountAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', 'KES ${subtotal.toStringAsFixed(2)}'),
          _buildTotalRow('Tax Amount', 'KES ${taxAmount.toStringAsFixed(2)}'),
          _buildTotalRow('Discount', 'KES ${_discountAmount.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildTotalRow(
            'Total Amount',
            'KES ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF1E3A8A) : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF1E3A8A) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}