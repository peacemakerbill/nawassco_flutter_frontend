import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tender_model.dart';
import '../../../../providers/tender_application_provider.dart';
import '../../../../providers/tender_provider.dart';


class CreateApplicationScreen extends ConsumerStatefulWidget {
  final String? tenderId;

  const CreateApplicationScreen({super.key, this.tenderId});

  @override
  ConsumerState<CreateApplicationScreen> createState() => _CreateApplicationScreenState();
}

class _CreateApplicationScreenState extends ConsumerState<CreateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _yearEstablishedController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _technicalProposalController = TextEditingController();
  final _methodologyController = TextEditingController();
  final _totalBidAmountController = TextEditingController();

  String? _selectedTenderId;
  BidSubmissionMethod _submissionMethod = BidSubmissionMethod.ONLINE;
  int _bidValidityPeriod = 90;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTenderId = widget.tenderId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tenderProvider.notifier).getActiveTenders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenderState = ref.watch(tenderProvider);
    final activeTenders = tenderState.activeTenders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Application'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveApplication,
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
              _buildSectionHeader('Tender Selection'),
              _buildTenderDropdown(activeTenders.cast<Tender>()),
              const SizedBox(height: 24),
              _buildSectionHeader('Company Information'),
              _buildTextFormField(
                controller: _companyNameController,
                label: 'Company Name *',
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _registrationNumberController,
                label: 'Registration Number *',
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _yearEstablishedController,
                label: 'Year Established *',
                keyboardType: TextInputType.number,
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _physicalAddressController,
                label: 'Physical Address *',
                maxLines: 2,
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _postalAddressController,
                label: 'Postal Address *',
                maxLines: 2,
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _contactPersonController,
                label: 'Contact Person *',
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _contactEmailController,
                label: 'Contact Email *',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              _buildTextFormField(
                controller: _contactPhoneController,
                label: 'Contact Phone *',
                keyboardType: TextInputType.phone,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Technical Proposal'),
              _buildTextFormField(
                controller: _technicalProposalController,
                label: 'Technical Proposal *',
                maxLines: 5,
                validator: _requiredValidator,
              ),
              _buildTextFormField(
                controller: _methodologyController,
                label: 'Methodology *',
                maxLines: 3,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Financial Information'),
              _buildTextFormField(
                controller: _totalBidAmountController,
                label: 'Total Bid Amount (KES) *',
                keyboardType: TextInputType.number,
                validator: _amountValidator,
              ),
              const SizedBox(height: 16),
              _buildDropdown<BidSubmissionMethod>(
                value: _submissionMethod,
                items: BidSubmissionMethod.values,
                label: 'Submission Method *',
                onChanged: (value) {
                  setState(() {
                    _submissionMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: 'Bid Validity Period (days)',
                value: _bidValidityPeriod,
                onChanged: (value) {
                  setState(() {
                    _bidValidityPeriod = value;
                  });
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

  Widget _buildTenderDropdown(List<Tender> tenders) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedTenderId,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Select a tender'),
          ),
          ...tenders.map((tender) {
            return DropdownMenuItem<String>(
              value: tender.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tender.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Closes: ${_formatDate(tender.closingDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        onChanged: (value) {
          setState(() {
            _selectedTenderId = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Tender *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a tender';
          }
          return null;
        },
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
              '$label: $value days',
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
        onPressed: _saveApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Create Application',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _amountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  Future<void> _saveApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final applicationData = {
          'tender': _selectedTenderId,
          'submissionMethod': _submissionMethod.name,
          'totalBidAmount': double.parse(_totalBidAmountController.text),
          'bidValidityPeriod': _bidValidityPeriod,
          'technicalProposal': _technicalProposalController.text.trim(),
          'methodology': _methodologyController.text.trim(),
          'companyProfile': {
            'companyName': _companyNameController.text.trim(),
            'registrationNumber': _registrationNumberController.text.trim(),
            'yearEstablished': int.parse(_yearEstablishedController.text),
            'physicalAddress': _physicalAddressController.text.trim(),
            'postalAddress': _postalAddressController.text.trim(),
            'contactPerson': _contactPersonController.text.trim(),
            'contactEmail': _contactEmailController.text.trim(),
            'contactPhone': _contactPhoneController.text.trim(),
          },
        };

        final success = await ref.read(tenderApplicationProvider.notifier).createApplication(applicationData);

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

  String _formatEnumName(String enumValue) {
    return enumValue.split('.').last.replaceAll('_', ' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _yearEstablishedController.dispose();
    _physicalAddressController.dispose();
    _postalAddressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _technicalProposalController.dispose();
    _methodologyController.dispose();
    _totalBidAmountController.dispose();
    super.dispose();
  }
}