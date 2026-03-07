import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/lead_models.dart';
import '../../../../providers/lead_provider.dart';
import '../../../../providers/sales_rep_provider.dart';

class LeadFormWidget extends ConsumerStatefulWidget {
  final Lead? lead;

  const LeadFormWidget({super.key, this.lead});

  @override
  ConsumerState<LeadFormWidget> createState() => _LeadFormWidgetState();
}

class _LeadFormWidgetState extends ConsumerState<LeadFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Lead? _editingLead;
  bool _initialized = false;

  // Form controllers
  final _salutationController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _budgetController = TextEditingController();
  final _campaignController = TextEditingController();
  final _referralSourceController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _serviceSpecificNeedsController = TextEditingController();
  final _timelineExpectedController = TextEditingController();
  final _annualRevenueController = TextEditingController();

  // Dropdown values with defaults
  String _selectedSalutation = 'Mr.';
  String _selectedSource = LeadSource.website.name;
  String _selectedPriority = PriorityLevel.medium.name;
  String _selectedStatus = LeadStatus.newLead.name;
  String? _selectedSalesRep;
  String _selectedContactMethod = ContactMethod.email.name;
  String _selectedLeadType = LeadType.newConnection.name;
  String _selectedUrgency = UrgencyLevel.medium.name;
  String _selectedServiceType = ServiceType.residentialWater.name;
  String _selectedCompanySize = CompanySize.small.name;
  String _selectedIndustry = 'Water Services';

  // Qualification criteria
  bool _budgetAvailable = false;
  bool _decisionMaker = false;
  bool _timeframe = false;
  bool _needIdentified = false;
  bool _authority = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeForm();
      _initialized = true;
    }
  }

  void _initializeForm() {
    if (widget.lead != null) {
      _editingLead = widget.lead;
      _populateFormWithLeadData();
    } else {
      final state = ref.read(leadProvider);
      if (state.selectedLead != null && state.showForm) {
        _editingLead = state.selectedLead;
        _populateFormWithLeadData();
      } else {
        _editingLead = null;
        _resetForm();
      }
    }
  }

  void _resetForm() {
    // Reset all form fields to default values
    _salutationController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _countryController.clear();
    _companyNameController.clear();
    _industryController.clear();
    _websiteController.clear();
    _estimatedValueController.clear();
    _budgetController.clear();
    _campaignController.clear();
    _referralSourceController.clear();
    _serviceDescriptionController.clear();
    _serviceSpecificNeedsController.clear();
    _timelineExpectedController.clear();
    _annualRevenueController.clear();

    // Reset dropdowns to default values
    _selectedSalutation = 'Mr.';
    _selectedSource = LeadSource.website.name;
    _selectedPriority = PriorityLevel.medium.name;
    _selectedStatus = LeadStatus.newLead.name;
    _selectedSalesRep = null;
    _selectedContactMethod = ContactMethod.email.name;
    _selectedLeadType = LeadType.newConnection.name;
    _selectedUrgency = UrgencyLevel.medium.name;
    _selectedServiceType = ServiceType.residentialWater.name;
    _selectedCompanySize = CompanySize.small.name;
    _selectedIndustry = 'Water Services';

    // Reset qualification criteria
    _budgetAvailable = false;
    _decisionMaker = false;
    _timeframe = false;
    _needIdentified = false;
    _authority = false;
  }

  void _populateFormWithLeadData() {
    if (_editingLead != null) {
      final contact = _editingLead!.contactDetails;

      // Contact Information
      _salutationController.text = contact.salutation;
      _selectedSalutation = contact.salutation.isNotEmpty ? contact.salutation : 'Mr.';
      _firstNameController.text = contact.firstName;
      _lastNameController.text = contact.lastName;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _addressController.text = contact.address;
      _cityController.text = contact.city;
      _countryController.text = contact.country;
      _selectedContactMethod = contact.communicationPreference.name;

      // Lead Information
      _selectedSource = _editingLead!.source.name;
      _selectedPriority = _editingLead!.priority.name;
      _selectedStatus = _editingLead!.status.name;
      _estimatedValueController.text = _editingLead!.estimatedValue.toString();
      _budgetController.text = _editingLead!.budget?.toString() ?? '';
      _campaignController.text = _editingLead!.campaign ?? '';
      _referralSourceController.text = _editingLead!.referralSource ?? '';
      _selectedLeadType = _editingLead!.leadType.name;

      // Company Information
      if (_editingLead!.companyDetails != null) {
        final company = _editingLead!.companyDetails!;
        _companyNameController.text = company.companyName;
        _industryController.text = company.industry;
        _selectedIndustry = company.industry;
        _selectedCompanySize = company.size.name;
        _annualRevenueController.text = company.annualRevenue.toString();
        _websiteController.text = company.website;
      }

      // Service Requirements
      if (_editingLead!.serviceRequirements.isNotEmpty) {
        final service = _editingLead!.serviceRequirements.first;
        _selectedServiceType = service.serviceType.name;
        _selectedUrgency = service.urgency.name;
        _serviceDescriptionController.text = service.description;
        _serviceSpecificNeedsController.text = service.specificNeeds.join(', ');
      }

      // Timeline
      _timelineExpectedController.text = _editingLead!.timeline.expectedTimeframe;
      _selectedUrgency = _editingLead!.timeline.urgency.name;

      // Qualification Criteria
      final criteria = _editingLead!.qualificationCriteria;
      _budgetAvailable = criteria.budgetAvailable;
      _decisionMaker = criteria.decisionMaker;
      _timeframe = criteria.timeframe;
      _needIdentified = criteria.needIdentified;
      _authority = criteria.authority;

      // Assignment
      _selectedSalesRep = _editingLead!.assignedTo;
    }
  }

  @override
  void dispose() {
    _salutationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _companyNameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _estimatedValueController.dispose();
    _budgetController.dispose();
    _campaignController.dispose();
    _referralSourceController.dispose();
    _serviceDescriptionController.dispose();
    _serviceSpecificNeedsController.dispose();
    _timelineExpectedController.dispose();
    _annualRevenueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(leadProvider.notifier);

      // Prepare lead data matching backend structure
      final leadData = {
        'contactDetails': {
          'salutation': _selectedSalutation,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'communicationPreference': _selectedContactMethod,
        },
        'source': _selectedSource,
        'priority': _selectedPriority,
        'status': _selectedStatus,
        'leadType': _selectedLeadType,
        'estimatedValue': double.tryParse(_estimatedValueController.text) ?? 0,
        'timeline': {
          'expectedTimeframe': _timelineExpectedController.text.isNotEmpty
              ? _timelineExpectedController.text.trim()
              : '1 month',
          'urgency': _selectedUrgency,
        },
        'qualificationCriteria': {
          'budgetAvailable': _budgetAvailable,
          'decisionMaker': _decisionMaker,
          'timeframe': _timeframe,
          'needIdentified': _needIdentified,
          'authority': _authority,
        },
        'serviceRequirements': [
          {
            'serviceType': _selectedServiceType,
            'description': _serviceDescriptionController.text.isNotEmpty
                ? _serviceDescriptionController.text.trim()
                : 'Water connection service',
            'urgency': _selectedUrgency,
            'specificNeeds': _serviceSpecificNeedsController.text.isNotEmpty
                ? _serviceSpecificNeedsController.text.split(',').map((s) => s.trim()).toList()
                : ['Standard connection'],
          }
        ],
      };

      // Add optional fields
      final campaignText = _campaignController.text.trim();
      if (campaignText.isNotEmpty) {
        leadData['campaign'] = campaignText;
      }

      final referralText = _referralSourceController.text.trim();
      if (referralText.isNotEmpty) {
        leadData['referralSource'] = referralText;
      }

      final budgetText = _budgetController.text.trim();
      if (budgetText.isNotEmpty) {
        final budgetValue = double.tryParse(budgetText);
        if (budgetValue != null) {
          leadData['budget'] = budgetValue;
        }
      }

      if (_selectedSalesRep != null && _selectedSalesRep!.isNotEmpty) {
        leadData['assignedTo'] = _selectedSalesRep!;
      }

      final companyNameText = _companyNameController.text.trim();
      if (companyNameText.isNotEmpty) {
        leadData['companyDetails'] = {
          'companyName': companyNameText,
          'industry': _industryController.text.isNotEmpty
              ? _industryController.text.trim()
              : _selectedIndustry,
          'size': _selectedCompanySize,
          'annualRevenue': double.tryParse(_annualRevenueController.text) ?? 0,
          'website': _websiteController.text.trim(),
        };
      }

      // Create or update lead based on _editingLead
      if (_editingLead != null) {
        await notifier.updateLead(_editingLead!.id, leadData);
      } else {
        await notifier.createLead(leadData);
      }

      // Close the dialog if this is being shown as a dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType? keyboardType,
    int? maxLines,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          hintText: hintText,
        ),
        validator: required
            ? (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String? value,
    required List<T> items,
    required String Function(T) getValue,
    required String Function(T) getDisplayName,
    required void Function(String?) onChanged,
    bool required = false,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: getValue(item),
          child: Text(getDisplayName(item)),
        ))
            .toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadProvider);
    final salesReps = ref.watch(salesRepProvider).salesReps;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _editingLead != null ? 'Edit Lead' : 'Create New Lead',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ref.read(leadProvider.notifier).showLeadList();
            }
          },
          color: const Color(0xFF1E3A8A),
        ),
        actions: [
          if (_editingLead != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Lead'),
                    content:
                    const Text('Are you sure you want to delete this lead?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final notifier = ref.read(leadProvider.notifier);
                  await notifier.deleteLead(_editingLead!.id);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Contact Information'),

                        // Salutation
                        _buildDropdown<String>(
                          label: 'Salutation',
                          value: _selectedSalutation,
                          items: ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.'],
                          getValue: (item) => item,
                          getDisplayName: (item) => item,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSalutation = value;
                              });
                            }
                          },
                          required: true,
                          prefixIcon: Icons.person,
                        ),

                        // First Name
                        _buildTextField(
                          label: 'First Name',
                          controller: _firstNameController,
                          required: true,
                          prefixIcon: Icons.person,
                        ),

                        // Last Name
                        _buildTextField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          required: true,
                          prefixIcon: Icons.person,
                        ),

                        // Email
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          required: true,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                        ),

                        // Phone
                        _buildTextField(
                          label: 'Phone',
                          controller: _phoneController,
                          required: true,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone,
                        ),

                        // Address
                        _buildTextField(
                          label: 'Address',
                          controller: _addressController,
                          required: true,
                          maxLines: 2,
                          prefixIcon: Icons.location_on,
                        ),

                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'City',
                                  controller: _cityController,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Country',
                                  controller: _countryController,
                                  required: true,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildTextField(
                            label: 'City',
                            controller: _cityController,
                            required: true,
                          ),
                          _buildTextField(
                            label: 'Country',
                            controller: _countryController,
                            required: true,
                          ),
                        ],

                        // Contact Method
                        _buildDropdown<ContactMethod>(
                          label: 'Preferred Contact Method',
                          value: _selectedContactMethod,
                          items: ContactMethod.values,
                          getValue: (item) => item.name,
                          getDisplayName: (item) => item.displayName,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedContactMethod = value;
                              });
                            }
                          },
                          prefixIcon: Icons.contact_mail,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Lead Information'),

                        // Source and Status
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<LeadSource>(
                                  label: 'Source',
                                  value: _selectedSource,
                                  items: LeadSource.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedSource = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.source,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown<LeadStatus>(
                                  label: 'Status',
                                  value: _selectedStatus,
                                  items: LeadStatus.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.info,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildDropdown<LeadSource>(
                            label: 'Source',
                            value: _selectedSource,
                            items: LeadSource.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedSource = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.source,
                          ),
                          _buildDropdown<LeadStatus>(
                            label: 'Status',
                            value: _selectedStatus,
                            items: LeadStatus.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.info,
                          ),
                        ],

                        // Priority and Lead Type
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<PriorityLevel>(
                                  label: 'Priority',
                                  value: _selectedPriority,
                                  items: PriorityLevel.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPriority = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.flag,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown<LeadType>(
                                  label: 'Lead Type',
                                  value: _selectedLeadType,
                                  items: LeadType.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedLeadType = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.category,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildDropdown<PriorityLevel>(
                            label: 'Priority',
                            value: _selectedPriority,
                            items: PriorityLevel.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.flag,
                          ),
                          _buildDropdown<LeadType>(
                            label: 'Lead Type',
                            value: _selectedLeadType,
                            items: LeadType.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLeadType = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.category,
                          ),
                        ],

                        // Estimated Value and Budget
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Estimated Value (KES)',
                                  controller: _estimatedValueController,
                                  required: true,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.money,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Budget (KES)',
                                  controller: _budgetController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildTextField(
                            label: 'Estimated Value (KES)',
                            controller: _estimatedValueController,
                            required: true,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.money,
                          ),
                          _buildTextField(
                            label: 'Budget (KES)',
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.account_balance_wallet,
                          ),
                        ],

                        // Campaign and Referral Source
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Campaign',
                                  controller: _campaignController,
                                  prefixIcon: Icons.campaign,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Referral Source',
                                  controller: _referralSourceController,
                                  prefixIcon: Icons.group,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildTextField(
                            label: 'Campaign',
                            controller: _campaignController,
                            prefixIcon: Icons.campaign,
                          ),
                          _buildTextField(
                            label: 'Referral Source',
                            controller: _referralSourceController,
                            prefixIcon: Icons.group,
                          ),
                        ],

                        // Sales Rep Assignment
                        if (salesReps.isNotEmpty)
                          _buildDropdown<Map<String, dynamic>>(
                            label: 'Assign to Sales Rep',
                            value: _selectedSalesRep,
                            items: [
                              {'id': null, 'name': 'Unassigned'},
                              ...salesReps.map((rep) => {
                                'id': rep.id,
                                'name': rep.fullName,
                              }),
                            ],
                            getValue: (item) => item['id'],
                            getDisplayName: (item) => item['name'],
                            onChanged: (value) {
                              setState(() {
                                _selectedSalesRep = value;
                              });
                            },
                            prefixIcon: Icons.person_add,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Service Requirements'),

                        // Service Type and Urgency
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<ServiceType>(
                                  label: 'Service Type',
                                  value: _selectedServiceType,
                                  items: ServiceType.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedServiceType = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.build,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown<UrgencyLevel>(
                                  label: 'Urgency',
                                  value: _selectedUrgency,
                                  items: UrgencyLevel.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedUrgency = value;
                                      });
                                    }
                                  },
                                  required: true,
                                  prefixIcon: Icons.schedule,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildDropdown<ServiceType>(
                            label: 'Service Type',
                            value: _selectedServiceType,
                            items: ServiceType.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedServiceType = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.build,
                          ),
                          _buildDropdown<UrgencyLevel>(
                            label: 'Urgency',
                            value: _selectedUrgency,
                            items: UrgencyLevel.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedUrgency = value;
                                });
                              }
                            },
                            required: true,
                            prefixIcon: Icons.schedule,
                          ),
                        ],

                        // Service Description
                        _buildTextField(
                          label: 'Description',
                          controller: _serviceDescriptionController,
                          required: true,
                          maxLines: 3,
                          hintText: 'Describe the service needed...',
                          prefixIcon: Icons.description,
                        ),

                        // Specific Needs
                        _buildTextField(
                          label: 'Specific Needs',
                          controller: _serviceSpecificNeedsController,
                          maxLines: 2,
                          hintText: 'Enter specific requirements separated by commas',
                          prefixIcon: Icons.checklist,
                        ),

                        // Timeline
                        _buildSectionTitle('Timeline'),
                        _buildTextField(
                          label: 'Expected Timeframe',
                          controller: _timelineExpectedController,
                          hintText: 'e.g., 1 month, 2 weeks, ASAP',
                          prefixIcon: Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Company Information (Optional)'),

                        _buildTextField(
                          label: 'Company Name',
                          controller: _companyNameController,
                          prefixIcon: Icons.business,
                        ),

                        // Industry and Company Size
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Industry',
                                  controller: _industryController,
                                  hintText: 'e.g., Water Services, Manufacturing',
                                  prefixIcon: Icons.work,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown<CompanySize>(
                                  label: 'Company Size',
                                  value: _selectedCompanySize,
                                  items: CompanySize.values,
                                  getValue: (item) => item.name,
                                  getDisplayName: (item) => item.displayName,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCompanySize = value;
                                      });
                                    }
                                  },
                                  prefixIcon: Icons.people,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildTextField(
                            label: 'Industry',
                            controller: _industryController,
                            hintText: 'e.g., Water Services, Manufacturing',
                            prefixIcon: Icons.work,
                          ),
                          _buildDropdown<CompanySize>(
                            label: 'Company Size',
                            value: _selectedCompanySize,
                            items: CompanySize.values,
                            getValue: (item) => item.name,
                            getDisplayName: (item) => item.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCompanySize = value;
                                });
                              }
                            },
                            prefixIcon: Icons.people,
                          ),
                        ],

                        // Annual Revenue and Website
                        if (!isSmallScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Annual Revenue (KES)',
                                  controller: _annualRevenueController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.attach_money,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Website',
                                  controller: _websiteController,
                                  keyboardType: TextInputType.url,
                                  prefixIcon: Icons.web,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildTextField(
                            label: 'Annual Revenue (KES)',
                            controller: _annualRevenueController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.attach_money,
                          ),
                          _buildTextField(
                            label: 'Website',
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                            prefixIcon: Icons.web,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Qualification Criteria'),

                        _buildCheckbox(
                          label: 'Budget Available',
                          value: _budgetAvailable,
                          onChanged: (value) {
                            setState(() {
                              _budgetAvailable = value ?? false;
                            });
                          },
                        ),

                        _buildCheckbox(
                          label: 'Decision Maker Contacted',
                          value: _decisionMaker,
                          onChanged: (value) {
                            setState(() {
                              _decisionMaker = value ?? false;
                            });
                          },
                        ),

                        _buildCheckbox(
                          label: 'Timeframe Defined',
                          value: _timeframe,
                          onChanged: (value) {
                            setState(() {
                              _timeframe = value ?? false;
                            });
                          },
                        ),

                        _buildCheckbox(
                          label: 'Need Identified',
                          value: _needIdentified,
                          onChanged: (value) {
                            setState(() {
                              _needIdentified = value ?? false;
                            });
                          },
                        ),

                        _buildCheckbox(
                          label: 'Authority to Purchase',
                          value: _authority,
                          onChanged: (value) {
                            setState(() {
                              _authority = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            ref.read(leadProvider.notifier).showLeadList();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          _editingLead != null
                              ? 'Update Lead'
                              : 'Create Lead',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}