import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/lead_models.dart';
import '../../../../models/opportunity.model.dart';
import '../../../../providers/customer_provider.dart';
import '../../../../providers/lead_provider.dart';
import '../../../../providers/opportunity_provider.dart';
import '../../../../providers/sales_rep_provider.dart';

class OpportunityFormWidget extends ConsumerStatefulWidget {
  final Opportunity? opportunity;
  const OpportunityFormWidget({super.key, this.opportunity});

  @override
  ConsumerState<OpportunityFormWidget> createState() => _OpportunityFormWidgetState();
}

class _OpportunityFormWidgetState extends ConsumerState<OpportunityFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _probabilityController = TextEditingController();
  final _nextStepController = TextEditingController();
  final _competitiveAdvantageController = TextEditingController();
  final _winLossReasonController = TextEditingController();

  DateTime? _nextStepDate;
  DateTime? _decisionDate;
  String? _selectedLeadId;
  String? _selectedCustomerId;
  String? _selectedSalesRepId;
  OpportunityType _selectedType = OpportunityType.new_business;
  SalesStage _selectedStage = SalesStage.prospecting;
  final List<String> _customRequirements = [];
  final List<String> _keyFactors = [];
  final List<String> _lessonsLearned = [];

  // Decision Process
  final _decisionProcessController = TextEditingController();
  final _decisionTimelineController = TextEditingController();
  bool _approvalRequired = false;
  int _approvalLevels = 1;

  @override
  void initState() {
    super.initState();
    if (widget.opportunity != null) {
      _initializeForm(widget.opportunity!);
    } else {
      // Set default decision process
      _decisionProcessController.text = 'Standard Sales Process';
      _decisionTimelineController.text = '30 days';
    }

    // Load data for dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDropdownData();
    });
  }

  Future<void> _loadDropdownData() async {
    // Load leads if not already loaded
    final leadState = ref.read(leadProvider);
    if (leadState.leads.isEmpty) {
      await ref.read(leadProvider.notifier).fetchLeads();
    }

    // Load customers if not already loaded
    final customerState = ref.read(customerProvider);
    if (customerState.customers.isEmpty) {
      await ref.read(customerProvider.notifier).loadCustomers();
    }

    // Load sales reps if not already loaded
    final salesRepState = ref.read(salesRepProvider);
    if (salesRepState.salesReps.isEmpty) {
      await ref.read(salesRepProvider.notifier).fetchSalesReps();
    }
  }

  void _initializeForm(Opportunity opportunity) {
    _descriptionController.text = opportunity.description;
    _estimatedValueController.text = opportunity.estimatedValue.toString();
    _probabilityController.text = opportunity.probability.toString();
    _nextStepController.text = opportunity.nextStep;
    _competitiveAdvantageController.text = opportunity.competitiveAdvantage ?? '';
    _winLossReasonController.text = opportunity.winLossReason ?? '';

    _selectedLeadId = opportunity.leadId;
    _selectedCustomerId = opportunity.customerId;
    _selectedSalesRepId = opportunity.assignedToId;
    _selectedType = opportunity.opportunityType;
    _selectedStage = opportunity.salesStage;
    _nextStepDate = opportunity.nextStepDate;

    // Decision Process
    _decisionProcessController.text = opportunity.decisionProcess.process ?? 'Standard Sales Process';
    _decisionTimelineController.text = opportunity.decisionProcess.timeline ?? '30 days';
    _decisionDate = opportunity.decisionProcess.decisionDate;
    _approvalRequired = opportunity.decisionProcess.approvalRequired;
    _approvalLevels = opportunity.decisionProcess.approvalLevels;

    // Lists
    _customRequirements.clear();
    _customRequirements.addAll(opportunity.customRequirements);

    _keyFactors.clear();
    _keyFactors.addAll(opportunity.keyFactors);

    _lessonsLearned.clear();
    _lessonsLearned.addAll(opportunity.lessonsLearned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final state = ref.watch(opportunityProvider);

    // Watch providers for dropdown data
    final leadState = ref.watch(leadProvider);
    final customerState = ref.watch(customerProvider);
    final salesRepState = ref.watch(salesRepProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              Expanded(child: isSmallScreen ?
              _buildMobileForm(theme, leadState, customerState, salesRepState) :
              _buildDesktopForm(theme, leadState, customerState, salesRepState)
              ),
              _buildActionButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(Icons.business_center, color: theme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(widget.opportunity == null ? 'Create New Opportunity' : 'Edit Opportunity',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OpportunityState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: state.isCreating || state.isUpdating ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 3,
          ),
          child: Row(children: [
            if (state.isCreating || state.isUpdating)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else
              const Icon(Icons.save, size: 18),
            const SizedBox(width: 8),
            Text(widget.opportunity == null ? 'Create Opportunity' : 'Save Changes'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMobileForm(ThemeData theme, LeadListState leadState, CustomerState customerState, SalesRepState salesRepState) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildBasicInfoSection(theme, leadState, customerState, salesRepState),
        const SizedBox(height: 16),
        _buildFinancialInfoSection(theme),
        const SizedBox(height: 16),
        _buildSalesProcessSection(theme),
        const SizedBox(height: 16),
        _buildDecisionProcessSection(theme),
        const SizedBox(height: 16),
        _buildRequirementsSection(theme),
      ],
    );
  }

  Widget _buildDesktopForm(ThemeData theme, LeadListState leadState, CustomerState customerState, SalesRepState salesRepState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(children: [
          _buildBasicInfoSection(theme, leadState, customerState, salesRepState),
          const SizedBox(height: 16),
          _buildFinancialInfoSection(theme)
        ])),
        const SizedBox(width: 32),
        Expanded(child: Column(children: [
          _buildSalesProcessSection(theme),
          const SizedBox(height: 16),
          _buildDecisionProcessSection(theme),
          const SizedBox(height: 16),
          _buildRequirementsSection(theme)
        ])),
      ]),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme, LeadListState leadState, CustomerState customerState, SalesRepState salesRepState) {
    return _FormSection(
      title: 'Basic Information',
      icon: Icons.info,
      children: [
        _buildOpportunityTypeSelector(),
        const SizedBox(height: 20),
        _buildLeadSelector(leadState),
        const SizedBox(height: 16),
        _buildCustomerSelector(customerState),
        const SizedBox(height: 16),
        _buildSalesRepSelector(salesRepState),
        const SizedBox(height: 16),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildOpportunityTypeSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Opportunity Type'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: OpportunityType.values.map((type) {
        return ChoiceChip(
          label: Text(type.displayName),
          selected: _selectedType == type,
          onSelected: (_) => setState(() => _selectedType = type),
          selectedColor: type.color.withOpacity(0.2),
          backgroundColor: Colors.grey[100],
          checkmarkColor: type.color,
          labelStyle: TextStyle(color: _selectedType == type ? type.color : Colors.grey[800], fontWeight: _selectedType == type ? FontWeight.bold : FontWeight.normal),
          avatar: Icon(type.icon, size: 16, color: type.color),
        );
      }).toList()),
    ]);
  }

  Widget _buildLeadSelector(LeadListState leadState) {
    // Filter out converted leads and ensure we have valid leads
    final leads = leadState.leads
        .where((lead) => lead.status != LeadStatus.converted && lead.id != null && lead.id!.isNotEmpty)
        .toList();

    // Ensure we have unique values for dropdown
    final uniqueLeads = <Lead>[];
    final seenIds = <String>{};

    for (final lead in leads) {
      if (!seenIds.contains(lead.id!)) {
        seenIds.add(lead.id!);
        uniqueLeads.add(lead);
      }
    }

    // Create dropdown items list - MUST have unique values
    final dropdownItems = <DropdownMenuItem<String>>[];

    // Add placeholder item first
    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: '',
        child: Text('Select a lead', style: TextStyle(color: Colors.grey)),
      ),
    );

    // Add all unique leads
    for (final lead in uniqueLeads) {
      final leadId = lead.id!;
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: leadId,
          child: Text('${lead.leadNumber} - ${lead.contactDetails.fullName}'),
        ),
      );
    }

    // When editing, we need to ensure the current lead is in the list
    // If not, we need to add it even if it's not in the filtered list
    if (widget.opportunity != null &&
        _selectedLeadId != null &&
        _selectedLeadId!.isNotEmpty &&
        !seenIds.contains(_selectedLeadId)) {

      // Find the lead from the opportunity
      final opportunityLead = widget.opportunity!.lead;
      if (opportunityLead != null) {
        final leadNumber = opportunityLead['leadNumber'] ?? 'Unknown';
        final fullName = opportunityLead['contactDetails']?['fullName'] ?? 'Unknown Lead';

        // Check if this item already exists in dropdownItems
        if (!dropdownItems.any((item) => item.value == _selectedLeadId)) {
          dropdownItems.add(
            DropdownMenuItem<String>(
              value: _selectedLeadId!,
              child: Text('$leadNumber - $fullName'),
            ),
          );
        }
      }
    }

    // Ensure we have a valid value for DropdownButton
    // If the selected lead ID doesn't exist in dropdown items, use empty string
    final validSelectedValue = _selectedLeadId != null &&
        _selectedLeadId!.isNotEmpty &&
        dropdownItems.any((item) => item.value == _selectedLeadId)
        ? _selectedLeadId
        : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Lead *'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!)
        ),
        child: DropdownButton<String>(
          value: validSelectedValue,
          isExpanded: true,
          underline: const SizedBox(),
          items: dropdownItems,
          onChanged: (value) => setState(() => _selectedLeadId = value == '' ? null : value),
        ),
      ),
      if (leadState.isLoading) const Padding(
        padding: EdgeInsets.only(top: 8),
        child: SizedBox(height: 20, child: LinearProgressIndicator()),
      ),
      // Show message if no leads available
      if (uniqueLeads.isEmpty && !leadState.isLoading) const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'No available leads. Please create a lead first.',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    ]);
  }

  Widget _buildCustomerSelector(CustomerState customerState) {
    // Ensure we have unique customers with valid IDs
    final dropdownItems = <DropdownMenuItem<String>>[];
    final seenIds = <String>{};

    // Add placeholder item with empty string value
    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: '',
        child: Text('No customer selected', style: TextStyle(color: Colors.grey)),
      ),
    );

    // Add all unique customers
    for (final customer in customerState.customers) {
      if (customer.id != null &&
          customer.id!.isNotEmpty &&
          !seenIds.contains(customer.id!)) {
        seenIds.add(customer.id!);
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: customer.id!,
            child: Text('${customer.customerNumber} - ${customer.displayName}'),
          ),
        );
      }
    }

    // When editing, add the current customer if it's not in the list
    if (widget.opportunity != null &&
        _selectedCustomerId != null &&
        _selectedCustomerId!.isNotEmpty &&
        !seenIds.contains(_selectedCustomerId)) {

      final opportunityCustomer = widget.opportunity!.customer;
      if (opportunityCustomer != null) {
        final customerNumber = opportunityCustomer['customerNumber'] ?? 'N/A';
        final displayName = opportunityCustomer['companyName'] ??
            '${opportunityCustomer['firstName'] ?? ''} ${opportunityCustomer['lastName'] ?? ''}'.trim();

        if (!dropdownItems.any((item) => item.value == _selectedCustomerId)) {
          dropdownItems.add(
            DropdownMenuItem<String>(
              value: _selectedCustomerId!,
              child: Text('$customerNumber - $displayName'),
            ),
          );
        }
      }
    }

    // Ensure valid selected value
    final validSelectedValue = _selectedCustomerId != null &&
        _selectedCustomerId!.isNotEmpty &&
        dropdownItems.any((item) => item.value == _selectedCustomerId)
        ? _selectedCustomerId
        : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Customer (Optional)'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!)
        ),
        child: DropdownButton<String>(
          value: validSelectedValue,
          isExpanded: true,
          underline: const SizedBox(),
          items: dropdownItems,
          onChanged: (value) => setState(() => _selectedCustomerId = value == '' ? null : value),
        ),
      ),
      if (customerState.isLoading) const Padding(
        padding: EdgeInsets.only(top: 8),
        child: SizedBox(height: 20, child: LinearProgressIndicator()),
      ),
    ]);
  }

  Widget _buildSalesRepSelector(SalesRepState salesRepState) {
    // Create dropdown items list
    final dropdownItems = <DropdownMenuItem<String>>[];
    final seenIds = <String>{};

    // Add placeholder item with empty string value
    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: '',
        child: Text('No sales rep selected', style: TextStyle(color: Colors.grey)),
      ),
    );

    // Add all unique sales reps
    for (final rep in salesRepState.salesReps) {
      if (rep.id != null && rep.id!.isNotEmpty && !seenIds.contains(rep.id!)) {
        seenIds.add(rep.id!);
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: rep.id!,
            child: Text('${rep.employeeNumber} - ${rep.fullName}'),
          ),
        );
      }
    }

    // When editing, add the current sales rep if it's not in the list
    if (widget.opportunity != null &&
        _selectedSalesRepId != null &&
        _selectedSalesRepId!.isNotEmpty &&
        !seenIds.contains(_selectedSalesRepId)) {

      final assignedToName = widget.opportunity!.assignedToName;
      if (!dropdownItems.any((item) => item.value == _selectedSalesRepId)) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: _selectedSalesRepId!,
            child: Text('Unknown - $assignedToName'),
          ),
        );
      }
    }

    // Ensure valid selected value
    final validSelectedValue = _selectedSalesRepId != null &&
        _selectedSalesRepId!.isNotEmpty &&
        dropdownItems.any((item) => item.value == _selectedSalesRepId)
        ? _selectedSalesRepId
        : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Assigned To (Optional)'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!)
        ),
        child: DropdownButton<String>(
          value: validSelectedValue,
          isExpanded: true,
          underline: const SizedBox(),
          items: dropdownItems,
          onChanged: (value) => setState(() => _selectedSalesRepId = value == '' ? null : value),
        ),
      ),
      if (salesRepState.isLoading) const Padding(
        padding: EdgeInsets.only(top: 8),
        child: SizedBox(height: 20, child: LinearProgressIndicator()),
      ),
    ]);
  }

  Widget _buildDescriptionField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Description *'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Describe the opportunity...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
      ),
    ]);
  }

  Widget _buildFinancialInfoSection(ThemeData theme) {
    return _FormSection(
      title: 'Financial Information',
      icon: Icons.attach_money,
      children: [
        Row(children: [
          Expanded(child: _buildNumberField('Estimated Value (KES)', _estimatedValueController,
            prefix: 'KES ',
            validator: _validateNumber,
            onChanged: (_) => setState(() {}),
          )),
          const SizedBox(width: 16),
          Expanded(child: _buildNumberField('Probability (%)', _probabilityController,
            suffix: '%',
            validator: _validateProbability,
            onChanged: (_) => setState(() {}),
          )),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[100]!)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Expected Revenue:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green)),
            Text(_calculateExpectedRevenue(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ]),
        ),
        const SizedBox(height: 16),
        _buildTextField('Competitive Advantage', _competitiveAdvantageController,
          maxLines: 3,
          hint: 'Describe your competitive advantage...',
          optional: true,
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('$label *'),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixText: prefix,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    int maxLines = 1,
    String? hint,
    bool optional = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(optional ? label : '$label *'),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: optional ? null : (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    ]);
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter estimated value';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Please enter a valid number';
    if (numValue <= 0) return 'Value must be greater than 0';
    return null;
  }

  String? _validateProbability(String? value) {
    if (value == null || value.isEmpty) return 'Please enter probability';
    final intValue = int.tryParse(value);
    if (intValue == null) return 'Please enter a valid number';
    if (intValue < 0 || intValue > 100) return 'Please enter a value between 0-100';
    return null;
  }

  Widget _buildSalesProcessSection(ThemeData theme) {
    return _FormSection(
      title: 'Sales Process',
      icon: Icons.timeline,
      children: [
        _buildSalesStageSelector(),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _buildTextField('Next Step', _nextStepController, hint: 'e.g., Send proposal, Schedule meeting')),
          const SizedBox(width: 16),
          Expanded(child: _buildDateSelector('Next Step Date', _nextStepDate, _pickNextStepDate, optional: true)),
        ]),
        if (_selectedStage.isClosed) ...[
          const SizedBox(height: 20),
          _buildTextField(
            _selectedStage.isWon ? 'Win Reason' : 'Loss Reason',
            _winLossReasonController,
            maxLines: 3,
            hint: _selectedStage.isWon ? 'Why did we win this opportunity?' : 'Why did we lose this opportunity?',
            optional: true,
          ),
        ],
      ],
    );
  }

  Widget _buildSalesStageSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('Sales Stage *'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: SalesStage.values.map((stage) {
        return FilterChip(
          label: Text(stage.displayName),
          selected: _selectedStage == stage,
          onSelected: (_) => setState(() => _selectedStage = stage),
          selectedColor: stage.color.withOpacity(0.2),
          backgroundColor: Colors.grey[100],
          checkmarkColor: stage.color,
          labelStyle: TextStyle(
              color: _selectedStage == stage ? stage.color : Colors.grey[800],
              fontWeight: _selectedStage == stage ? FontWeight.bold : FontWeight.normal
          ),
          avatar: Icon(stage.icon, size: 16, color: stage.color),
        );
      }).toList()),
    ]);
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap, {bool optional = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(optional ? label : '$label *'),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: date != null ? Theme.of(context).primaryColor : Colors.grey[300]!),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select date',
              style: TextStyle(color: date != null ? Colors.black : Colors.grey),
            ),
            Icon(Icons.calendar_today, color: date != null ? Theme.of(context).primaryColor : Colors.grey, size: 18),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildDecisionProcessSection(ThemeData theme) {
    return _FormSection(
      title: 'Decision Process',
      icon: Icons.gavel,
      children: [
        _buildTextField('Process', _decisionProcessController, hint: 'e.g., Standard Sales Process'),
        const SizedBox(height: 16),
        _buildTextField('Timeline', _decisionTimelineController, hint: 'e.g., 30 days'),
        const SizedBox(height: 16),
        _buildDateSelector('Decision Date', _decisionDate, _pickDecisionDate, optional: true),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SectionLabel('Approval Required'),
            const SizedBox(height: 8),
            Switch(
              value: _approvalRequired,
              onChanged: (value) => setState(() => _approvalRequired = value),
              activeColor: Theme.of(context).primaryColor,
            ),
          ])),
          if (_approvalRequired) ...[
            const SizedBox(width: 16),
            Expanded(child: _buildNumberField('Approval Levels', TextEditingController(text: _approvalLevels.toString()),
              validator: (value) {
                if (_approvalRequired && (value == null || value.isEmpty)) return 'Required';
                final intValue = int.tryParse(value ?? '');
                if (intValue != null && (intValue < 1 || intValue > 5)) return '1-5 levels';
                return null;
              },
              onChanged: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue >= 1 && intValue <= 5) {
                  setState(() => _approvalLevels = intValue);
                }
              },
            )),
          ],
        ]),
      ],
    );
  }

  Widget _buildRequirementsSection(ThemeData theme) {
    final requirementController = TextEditingController();
    final keyFactorController = TextEditingController();
    final lessonController = TextEditingController();

    return _FormSection(
      title: 'Requirements & Analysis',
      icon: Icons.checklist,
      children: [
        _buildChipList('Custom Requirements', requirementController, _customRequirements,
            onAdd: (text) => setState(() => _customRequirements.add(text))),
        const SizedBox(height: 20),
        _buildChipList('Key Factors', keyFactorController, _keyFactors,
            onAdd: (text) => setState(() => _keyFactors.add(text))),
        if (_selectedStage.isClosed) ...[
          const SizedBox(height: 20),
          _buildChipList('Lessons Learned', lessonController, _lessonsLearned,
              onAdd: (text) => setState(() => _lessonsLearned.add(text))),
        ],
      ],
    );
  }

  Widget _buildChipList(String label, TextEditingController controller, List<String> items, {required Function(String) onAdd}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(label),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Add a $label',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onAdd(controller.text);
              controller.clear();
              setState(() {});
            }
          },
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ]),
      const SizedBox(height: 8),
      if (items.isNotEmpty) Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Chip(
            label: Text(item),
            onDeleted: () {
              items.remove(item);
              setState(() {});
            },
            deleteIconColor: Colors.red,
          );
        }).toList(),
      ),
    ]);
  }

  Future<void> _pickNextStepDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextStepDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _nextStepDate = picked);
  }

  Future<void> _pickDecisionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _decisionDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _decisionDate = picked);
  }

  String _calculateExpectedRevenue() {
    final estimatedValue = double.tryParse(_estimatedValueController.text) ?? 0;
    final probability = int.tryParse(_probabilityController.text) ?? 0;
    final expectedRevenue = estimatedValue * (probability / 100);
    return 'KES ${expectedRevenue.toStringAsFixed(2)}';
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the errors in the form');
      return;
    }

    if (_selectedLeadId == null || _selectedLeadId!.isEmpty) {
      _showError('Please select a lead');
      return;
    }

    // Prepare form data
    final formData = {
      'lead': _selectedLeadId,
      if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) 'customer': _selectedCustomerId,
      'opportunityType': _selectedType.name,
      'description': _descriptionController.text,
      'estimatedValue': double.parse(_estimatedValueController.text),
      'probability': int.parse(_probabilityController.text),
      'salesStage': _selectedStage.name,
      'nextStep': _nextStepController.text,
      if (_nextStepDate != null) 'nextStepDate': _nextStepDate!.toIso8601String(),
      if (_competitiveAdvantageController.text.isNotEmpty)
        'competitiveAdvantage': _competitiveAdvantageController.text,
      if (_selectedSalesRepId != null && _selectedSalesRepId!.isNotEmpty) 'assignedTo': _selectedSalesRepId,
      'customRequirements': _customRequirements,
      'keyFactors': _keyFactors,
      'decisionProcess': {
        'process': _decisionProcessController.text,
        'timeline': _decisionTimelineController.text,
        if (_decisionDate != null) 'decisionDate': _decisionDate!.toIso8601String(),
        'approvalRequired': _approvalRequired,
        'approvalLevels': _approvalLevels,
      },
      if (_selectedStage.isClosed && _winLossReasonController.text.isNotEmpty)
        'winLossReason': _winLossReasonController.text,
      if (_selectedStage.isClosed) 'lessonsLearned': _lessonsLearned,
    };

    final provider = ref.read(opportunityProvider.notifier);
    if (widget.opportunity == null) {
      await provider.createOpportunity(formData);
    } else {
      await provider.updateOpportunity(widget.opportunity!.id, formData);
    }

    // Close dialog after successful submission
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedValueController.dispose();
    _probabilityController.dispose();
    _nextStepController.dispose();
    _competitiveAdvantageController.dispose();
    _winLossReasonController.dispose();
    _decisionProcessController.dispose();
    _decisionTimelineController.dispose();
    super.dispose();
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _FormSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A)
          )),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.grey,
        fontSize: 14
    ));
  }
}