import 'package:flutter/material.dart';

class QuotationFormWidget extends StatefulWidget {
  const QuotationFormWidget({super.key});

  @override
  State<QuotationFormWidget> createState() => _QuotationFormWidgetState();
}

class _QuotationFormWidgetState extends State<QuotationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTender = '';
  final List<Map<String, dynamic>> _items = [];

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _validityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_document, color: Color(0xFF0066A1), size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Submit Quotation',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fill in the quotation form for the selected tender opportunity.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Select Tender',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'TDR-2024-001', child: Text('TDR-2024-001 - Water Pipe Supply')),
                        DropdownMenuItem(value: 'TDR-2024-002', child: Text('TDR-2024-002 - Water Meter Supply')),
                        DropdownMenuItem(value: 'TDR-2024-003', child: Text('TDR-2024-003 - Valve Replacement Parts')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTender = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                          children: [
                            TextFormField(
                              controller: _contactPersonController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Person',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _contactPersonController,
                                decoration: const InputDecoration(
                                  labelText: 'Contact Person',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quotation Items',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add Item', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066A1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _items.isEmpty
                        ? const Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2, size: 64, color: Color(0xFF0066A1)),
                          SizedBox(height: 12),
                          Text(
                            'No items added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      children: _items.map((item) => _buildItemRow(item)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quotation Validity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _validityController,
                      decoration: const InputDecoration(
                        labelText: 'Quotation Validity (Days)',
                        border: OutlineInputBorder(),
                        suffixText: 'days',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return isMobile
                    ? Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066A1),
                        side: const BorderSide(color: Color(0xFF0066A1)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('SAVE AS DRAFT'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _submitQuotation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066A1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('SUBMIT QUOTATION'),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066A1),
                          side: const BorderSide(color: Color(0xFF0066A1)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SAVE AS DRAFT'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitQuotation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SUBMIT QUOTATION'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return isMobile
              ? Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Item Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (KES)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(item),
                  ),
                ],
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (KES)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeItem(item),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add({});
    });
  }

  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      _items.remove(item);
    });
  }

  void _submitQuotation() {
    if (_formKey.currentState!.validate()) {
      // Submit quotation logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quotation submitted successfully!')),
      );
    }
  }
}