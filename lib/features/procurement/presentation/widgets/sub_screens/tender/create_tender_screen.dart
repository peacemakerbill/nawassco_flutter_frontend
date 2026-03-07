import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tender_model.dart';
import '../../../../providers/tender_provider.dart';

class CreateTenderScreen extends ConsumerStatefulWidget {
  final Tender? tender;

  const CreateTenderScreen({super.key, this.tender});

  @override
  ConsumerState<CreateTenderScreen> createState() => _CreateTenderScreenState();
}

class _CreateTenderScreenState extends ConsumerState<CreateTenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _estimatedBudgetController = TextEditingController();
  final _tenderFeeController = TextEditingController();
  final _bidSecurityAmountController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactDepartmentController = TextEditingController();
  final _bidOpeningVenueController = TextEditingController();

  TenderCategory _selectedCategory = TenderCategory.WORKS;
  TenderType _selectedType = TenderType.NATIONAL;
  ProcurementMethod _selectedMethod = ProcurementMethod.OPEN_TENDER;
  BidSecurityType _selectedBidSecurity = BidSecurityType.BANK_GUARANTEE;
  BidSubmissionMethod _selectedSubmissionMethod = BidSubmissionMethod.ONLINE;

  DateTime _closingDate = DateTime.now().add(const Duration(days: 30));
  DateTime _openingDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _preBidMeetingDate;
  DateTime? _siteVisitDate;

  int _bidValidityPeriod = 90;
  int _contractDuration = 12;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tender != null) {
      _populateForm(widget.tender!);
    }
  }

  void _populateForm(Tender tender) {
    _titleController.text = tender.title;
    _descriptionController.text = tender.description;
    _referenceController.text = tender.referenceNumber ?? '';
    _estimatedBudgetController.text = tender.estimatedBudget.toString();
    _tenderFeeController.text = tender.tenderFee.toString();
    _bidSecurityAmountController.text = tender.bidSecurityAmount.toString();
    _contactPersonController.text = tender.contactPerson;
    _contactEmailController.text = tender.contactEmail;
    _contactPhoneController.text = tender.contactPhone;
    _contactDepartmentController.text = tender.contactDepartment;
    _bidOpeningVenueController.text = tender.bidOpeningVenue;

    _selectedCategory = tender.category;
    _selectedType = tender.tenderType;
    _selectedMethod = tender.procurementMethod;
    _selectedBidSecurity = tender.bidSecurityType;
    _selectedSubmissionMethod = tender.bidSubmissionMethod;

    _closingDate = tender.closingDate;
    _openingDate = tender.openingDate;
    _preBidMeetingDate = tender.preBidMeetingDate;
    _siteVisitDate = tender.siteVisitDate;

    _bidValidityPeriod = tender.bidValidityPeriod;
    _contractDuration = tender.contractDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tender == null ? 'Create Tender' : 'Edit Tender'),
        actions: [
          if (widget.tender != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTender,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTender,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information'),
              _buildTextFormField(
                controller: _titleController,
                label: 'Tender Title *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tender title';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description *',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _referenceController,
                label: 'Reference Number',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<TenderCategory>(
                      value: _selectedCategory,
                      items: TenderCategory.values,
                      label: 'Category *',
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<TenderType>(
                      value: _selectedType,
                      items: TenderType.values,
                      label: 'Type *',
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown<ProcurementMethod>(
                value: _selectedMethod,
                items: ProcurementMethod.values,
                label: 'Procurement Method *',
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Dates & Timeline'),
              _buildDateField(
                label: 'Closing Date *',
                value: _closingDate,
                onChanged: (date) {
                  setState(() {
                    _closingDate = date!;
                  });
                },
              ),
              _buildDateField(
                label: 'Opening Date *',
                value: _openingDate,
                onChanged: (date) {
                  setState(() {
                    _openingDate = date!;
                  });
                },
              ),
              _buildDateField(
                label: 'Pre-Bid Meeting Date',
                value: _preBidMeetingDate,
                onChanged: (date) {
                  setState(() {
                    _preBidMeetingDate = date;
                  });
                },
                isRequired: false,
              ),
              _buildDateField(
                label: 'Site Visit Date',
                value: _siteVisitDate,
                onChanged: (date) {
                  setState(() {
                    _siteVisitDate = date;
                  });
                },
                isRequired: false,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Financial Information'),
              _buildTextFormField(
                controller: _estimatedBudgetController,
                label: 'Estimated Budget (KES) *',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _tenderFeeController,
                label: 'Tender Fee (KES)',
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _bidSecurityAmountController,
                      label: 'Bid Security Amount (KES)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<BidSecurityType>(
                      value: _selectedBidSecurity,
                      items: BidSecurityType.values,
                      label: 'Bid Security Type',
                      onChanged: (value) {
                        setState(() {
                          _selectedBidSecurity = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Contract Details'),
              _buildNumberField(
                label: 'Bid Validity Period (days)',
                value: _bidValidityPeriod,
                onChanged: (value) {
                  setState(() {
                    _bidValidityPeriod = value;
                  });
                },
              ),
              _buildNumberField(
                label: 'Contract Duration (months)',
                value: _contractDuration,
                onChanged: (value) {
                  setState(() {
                    _contractDuration = value;
                  });
                },
              ),
              _buildDropdown<BidSubmissionMethod>(
                value: _selectedSubmissionMethod,
                items: BidSubmissionMethod.values,
                label: 'Bid Submission Method *',
                onChanged: (value) {
                  setState(() {
                    _selectedSubmissionMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Contact Information'),
              _buildTextFormField(
                controller: _contactPersonController,
                label: 'Contact Person *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact person';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _contactEmailController,
                label: 'Contact Email *',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _contactPhoneController,
                label: 'Contact Phone *',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact phone';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _contactDepartmentController,
                label: 'Contact Department *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact department';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _bidOpeningVenueController,
                label: 'Bid Opening Venue *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bid opening venue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String label,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(_formatEnumName(item.toString())),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (selectedDate != null) {
            onChanged(selectedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            value != null ? _formatDate(value) : 'Select date',
            style: TextStyle(
              color: value != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (value > 1) {
                    onChanged(value - 1);
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(value.toString()),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  onChanged(value + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveTender,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.tender == null ? 'Create Tender' : 'Update Tender',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _saveTender() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final tenderData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'referenceNumber': _referenceController.text.trim(),
          'category': _selectedCategory.name,
          'tenderType': _selectedType.name,
          'procurementMethod': _selectedMethod.name,
          'closingDate': _closingDate.toIso8601String(),
          'openingDate': _openingDate.toIso8601String(),
          'preBidMeetingDate': _preBidMeetingDate?.toIso8601String(),
          'siteVisitDate': _siteVisitDate?.toIso8601String(),
          'estimatedBudget': double.parse(_estimatedBudgetController.text),
          'tenderFee': double.tryParse(_tenderFeeController.text) ?? 0,
          'bidSecurityAmount': double.tryParse(_bidSecurityAmountController.text) ?? 0,
          'bidSecurityType': _selectedBidSecurity.name,
          'bidValidityPeriod': _bidValidityPeriod,
          'contractDuration': _contractDuration,
          'bidSubmissionMethod': _selectedSubmissionMethod.name,
          'contactPerson': _contactPersonController.text.trim(),
          'contactEmail': _contactEmailController.text.trim(),
          'contactPhone': _contactPhoneController.text.trim(),
          'contactDepartment': _contactDepartmentController.text.trim(),
          'bidOpeningVenue': _bidOpeningVenueController.text.trim(),
        };

        final success = widget.tender == null
            ? await ref.read(tenderProvider.notifier).createTender(tenderData)
            : await ref.read(tenderProvider.notifier).updateTender(widget.tender!.id, tenderData);

        if (success && mounted) {
          Navigator.pop(context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteTender() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tender'),
        content: const Text('Are you sure you want to delete this tender? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.tender != null) {
      final success = await ref.read(tenderProvider.notifier).deleteTender(widget.tender!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatEnumName(String enumValue) {
    return enumValue.split('.').last.replaceAll('_', ' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _estimatedBudgetController.dispose();
    _tenderFeeController.dispose();
    _bidSecurityAmountController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactDepartmentController.dispose();
    _bidOpeningVenueController.dispose();
    super.dispose();
  }
}