import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../models/customer.model.dart';
import '../../../../models/opportunity.model.dart';
import '../../../../models/quote.model.dart';
import '../../../../providers/customer_provider.dart';
import '../../../../providers/opportunity_provider.dart';
import '../../../../providers/quote_provider.dart';
import 'quote_item_widget.dart';

class QuoteFormWidget extends ConsumerStatefulWidget {
  final Quote? initialQuote;

  const QuoteFormWidget({super.key, this.initialQuote});

  @override
  ConsumerState<QuoteFormWidget> createState() => _QuoteFormWidgetState();
}

class _QuoteFormWidgetState extends ConsumerState<QuoteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _deliveryTermsController = TextEditingController();
  final TextEditingController _validityPeriodController = TextEditingController();

  // Add search controllers for TypeAhead
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _opportunitySearchController = TextEditingController();

  DateTime _quoteDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCustomerId;
  String? _selectedOpportunityId;
  List<QuoteItem> _items = [];
  final List<TextEditingController> _specialConditionControllers = [];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialQuote != null) {
      final quote = widget.initialQuote!;
      _selectedCustomerId = quote.customerId;
      _selectedOpportunityId = quote.opportunityId;
      _quoteDate = quote.quoteDate;
      _expiryDate = quote.expiryDate;
      _paymentTermsController.text = quote.paymentTerms;
      _deliveryTermsController.text = quote.deliveryTerms;
      _validityPeriodController.text = quote.validityPeriod.toString();
      _items = List.from(quote.items);

      for (var condition in quote.specialConditions) {
        final controller = TextEditingController(text: condition);
        _specialConditionControllers.add(controller);
      }
    } else {
      _validityPeriodController.text = '30';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDropdownData();
    });
  }

  Future<void> _initializeDropdownData() async {
    try {
      final customerState = ref.read(customerProvider);
      if (customerState.customers.isEmpty) {
        ref.read(customerProvider.notifier).refreshData();
      }

      final opportunityState = ref.read(opportunityProvider);
      if (opportunityState.opportunities.isEmpty) {
        ref.read(opportunityProvider.notifier).refreshData();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Update search controllers with initial values
      _updateSearchControllers();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing dropdown data: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateSearchControllers() {
    final customers = ref.read(customerProvider).customers;
    final opportunities = ref.read(opportunityProvider).opportunities;

    if (_selectedCustomerId != null && customers.isNotEmpty) {
      final customer = customers.firstWhere(
            (c) => c.id == _selectedCustomerId,
        orElse: () => customers.first,
      );
      if (customer.id == _selectedCustomerId) {
        _customerSearchController.text = customer.displayName;
      }
    }

    if (_selectedOpportunityId != null && opportunities.isNotEmpty) {
      final opp = opportunities.firstWhere(
            (o) => o.id == _selectedOpportunityId,
        orElse: () => opportunities.first,
      );
      if (opp.id == _selectedOpportunityId) {
        _opportunitySearchController.text = opp.displayName;
      }
    }
  }

  @override
  void dispose() {
    _paymentTermsController.dispose();
    _deliveryTermsController.dispose();
    _validityPeriodController.dispose();
    _customerSearchController.dispose(); // Don't forget to dispose
    _opportunitySearchController.dispose(); // Don't forget to dispose
    for (var controller in _specialConditionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(QuoteItem.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemCode: '',
        description: '',
        quantity: 1,
        unit: 'pcs',
        unitPrice: 0,
        taxRate: 16,
        discount: 0, // Percentage discount
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, QuoteItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _addSpecialCondition() {
    setState(() {
      _specialConditionControllers.add(TextEditingController());
    });
  }

  void _removeSpecialCondition(int index) {
    setState(() {
      _specialConditionControllers[index].dispose();
      _specialConditionControllers.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateTaxAmount() {
    return _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double _calculateTotalAmount() {
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTaxAmount();
    final discountAmount = _items.fold(0.0, (sum, item) => sum + item.discountAmount);
    return subtotal + taxAmount - discountAmount;
  }

  double _calculateTotalDiscount() {
    return _items.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      // Required fields
      'customer': _selectedCustomerId,
      'quoteDate': _quoteDate.toIso8601String(),
      'expiryDate': _expiryDate.toIso8601String(),
      'paymentTerms': _paymentTermsController.text,
      'validityPeriod': int.tryParse(_validityPeriodController.text) ?? 30,
      'deliveryTerms': _deliveryTermsController.text,
      'items': _items.map((item) => item.toJson()).toList(),

      // Optional fields
      if (_selectedOpportunityId != null && _selectedOpportunityId!.isNotEmpty)
        'opportunity': _selectedOpportunityId,

      // Calculated fields
      'subtotal': _calculateSubtotal(),
      'taxAmount': _calculateTaxAmount(),
      'discountAmount': _calculateTotalDiscount(), // FIXED: Use discount amount, not percentage
      'totalAmount': _calculateTotalAmount(),

      // Default fields
      'currency': 'KES',

      // Special conditions
      'specialConditions': _specialConditionControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => c.text)
          .toList(),
    };

    if (widget.initialQuote != null) {
      ref.read(quoteProvider.notifier).updateQuote(widget.initialQuote!.id, data);
    } else {
      ref.read(quoteProvider.notifier).createQuote(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);
    final customerState = ref.watch(customerProvider);
    final opportunityState = ref.watch(opportunityProvider);

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading form data...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.initialQuote != null ? 'Edit Quote' : 'Create New Quote',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check),
            tooltip: widget.initialQuote != null ? 'Update Quote' : 'Create Quote',
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
                      _buildCustomerTypeAhead(customerState.customers),
                      const SizedBox(height: 16),

                      // Opportunity TypeAhead (Replaced Dropdown with TypeAhead)
                      _buildOpportunityTypeAhead(opportunityState.opportunities),
                      const SizedBox(height: 16),

                      // Dates - Responsive layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Column(
                              children: [
                                _buildDatePicker(
                                  'Quote Date *',
                                  _quoteDate,
                                      (date) {
                                    setState(() {
                                      _quoteDate = date;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildDatePicker(
                                  'Expiry Date *',
                                  _expiryDate,
                                      (date) {
                                    setState(() {
                                      _expiryDate = date;
                                    });
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildDatePicker(
                                    'Quote Date *',
                                    _quoteDate,
                                        (date) {
                                      setState(() {
                                        _quoteDate = date;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDatePicker(
                                    'Expiry Date *',
                                    _expiryDate,
                                        (date) {
                                      setState(() {
                                        _expiryDate = date;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
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
                            'Quote Items *',
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
                                'Add items to create your quote',
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
                            child: QuoteItemWidget(
                              item: item,
                              index: index,
                              onUpdate: (updatedItem) => _updateItem(index, updatedItem),
                              onRemove: () => _removeItem(index),
                            ),
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
              const SizedBox(height: 16),

              // Terms & Conditions Card
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
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Terms (Required)
                      TextFormField(
                        controller: _paymentTermsController,
                        decoration: InputDecoration(
                          labelText: 'Payment Terms *',
                          hintText: 'e.g., Net 30 days',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Payment terms are required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Validity Period and Delivery Terms - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _validityPeriodController,
                                  decoration: InputDecoration(
                                    labelText: 'Validity Period (days) *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Validity period is required';
                                    }
                                    final days = int.tryParse(value);
                                    if (days == null || days <= 0) {
                                      return 'Please enter a valid number of days';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _deliveryTermsController,
                                  decoration: InputDecoration(
                                    labelText: 'Delivery Terms *',
                                    hintText: 'e.g., Within 2 weeks',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Delivery terms are required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _validityPeriodController,
                                    decoration: InputDecoration(
                                      labelText: 'Validity Period (days) *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Validity period is required';
                                      }
                                      final days = int.tryParse(value);
                                      if (days == null || days <= 0) {
                                        return 'Please enter a valid number of days';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _deliveryTermsController,
                                    decoration: InputDecoration(
                                      labelText: 'Delivery Terms *',
                                      hintText: 'e.g., Within 2 weeks',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Delivery terms are required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Special Conditions (Optional)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Special Conditions (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: _addSpecialCondition,
                            icon: const Icon(Icons.add, color: Color(0xFF1E3A8A)),
                            tooltip: 'Add Condition',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),

                      ..._specialConditionControllers
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: 'Enter special condition',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeSpecialCondition(index),
                                icon: const Icon(Icons.remove, color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
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
                          onPressed: quoteState.isCreating || quoteState.isUpdating ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: (quoteState.isCreating || quoteState.isUpdating)
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : Text(
                            widget.initialQuote != null ? 'Update Quote' : 'Create Quote',
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
                            onPressed: quoteState.isCreating || quoteState.isUpdating ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: (quoteState.isCreating || quoteState.isUpdating)
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Text(
                              widget.initialQuote != null ? 'Update Quote' : 'Create Quote',
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

  // Customer TypeAhead widget
  Widget _buildCustomerTypeAhead(List<Customer> customers) {
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
                    _selectedCustomerId = null;
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
            return customers.where((customer) {
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
              _selectedCustomerId = customer.id;
              _customerSearchController.text = customer.displayName;
            });
          },
          validator: (value) {
            if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
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

  // Opportunity TypeAhead widget
  Widget _buildOpportunityTypeAhead(List<Opportunity> opportunities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opportunity (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TypeAheadFormField<Opportunity>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _opportunitySearchController,
            decoration: InputDecoration(
              labelText: 'Search Opportunity',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.business),
              suffixIcon: _opportunitySearchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _opportunitySearchController.clear();
                    _selectedOpportunityId = null;
                  });
                },
              )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          suggestionsCallback: (pattern) {
            return opportunities.where((opportunity) {
              final text = opportunity.displayName.toLowerCase();
              return text.contains(pattern.toLowerCase());
            }).toList();
          },
          itemBuilder: (context, opportunity) {
            return ListTile(
              leading: const Icon(Icons.business, size: 20),
              title: Text(opportunity.displayName),
              subtitle: opportunity.description.isNotEmpty
                  ? Text(
                opportunity.description.length > 50
                    ? '${opportunity.description.substring(0, 50)}...'
                    : opportunity.description,
              )
                  : null,
            );
          },
          onSuggestionSelected: (opportunity) {
            setState(() {
              _selectedOpportunityId = opportunity.id;
              _opportunitySearchController.text = opportunity.displayName;
            });
          },
          noItemsFoundBuilder: (context) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No opportunities found'),
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

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: label.contains('Expiry') ? DateTime.now() : DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTaxAmount();
    final discountAmount = _calculateTotalDiscount();
    final total = _calculateTotalAmount();

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
          _buildTotalRow('Discount', 'KES ${discountAmount.toStringAsFixed(2)}'),
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