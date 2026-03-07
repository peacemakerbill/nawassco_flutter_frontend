import 'package:flutter/material.dart';

import '../../../models/supplier_category_model.dart';

class CategoryFormWidget extends StatefulWidget {
  final List<SupplierCategory> categories;
  final Function(Map<String, dynamic>) onSubmit;
  final SupplierCategory? initialData;

  const CategoryFormWidget({
    super.key,
    required this.categories,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _avgContractController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();

  String? _selectedParentCategory;
  int _selectedLevel = 1;
  bool _nawasscoSpecific = false;
  final List<Map<String, dynamic>> _requirements = [];
  final List<String> _mandatoryDocuments = [];
  final List<Map<String, dynamic>> _evaluationCriteria = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      _codeController.text = widget.initialData!.categoryCode;
      _nameController.text = widget.initialData!.categoryName;
      _descriptionController.text = widget.initialData!.description;
      _selectedParentCategory = widget.initialData!.parentCategoryId;
      _selectedLevel = widget.initialData!.level;
      _nawasscoSpecific = widget.initialData!.nawasscoSpecific;
      _avgContractController.text = widget.initialData!.averageContractValue.toString();
      _creditLimitController.text = widget.initialData!.creditLimitDefault.toString();
      _paymentTermsController.text = widget.initialData!.paymentTermsDefault.toString();

      _requirements.addAll(widget.initialData!.minimumRequirements as Iterable<Map<String, dynamic>>);
      _mandatoryDocuments.addAll(widget.initialData!.mandatoryDocuments);
      _evaluationCriteria.addAll(widget.initialData!.evaluationCriteria as Iterable<Map<String, dynamic>>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information
            _buildSectionHeader('Basic Information'),
            _buildTextFormField(
              controller: _codeController,
              label: 'Category Code *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _nameController,
              label: 'Category Name *',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            _buildTextFormField(
              controller: _descriptionController,
              label: 'Description *',
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),

            // Hierarchy
            _buildSectionHeader('Hierarchy'),
            _buildDropdown(
              value: _selectedParentCategory,
              label: 'Parent Category',
              items: [
                const DropdownMenuItem(value: null, child: Text('No Parent (Top Level)')),
                ...widget.categories.where((c) => c.level < 3).map((category) => DropdownMenuItem(
                  value: category.id,
                  child: Text('${category.categoryCode} - ${category.categoryName}'),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedParentCategory = value;
                  // Auto-set level based on parent
                  if (value == null) {
                    _selectedLevel = 1;
                  } else {
                    final parent = widget.categories.firstWhere((c) => c.id == value);
                    _selectedLevel = parent.level + 1;
                  }
                });
              },
            ),
            _buildNumberField(
              value: _selectedLevel,
              label: 'Level',
              min: 1,
              max: 5,
              onChanged: (value) => setState(() => _selectedLevel = value),
            ),

            // Flags
            _buildSectionHeader('Flags'),
            SwitchListTile(
              title: const Text('NAWASSCO Specific Category'),
              value: _nawasscoSpecific,
              onChanged: (value) => setState(() => _nawasscoSpecific = value),
            ),

            // Financial Information
            _buildSectionHeader('Financial Information'),
            _buildTextFormField(
              controller: _avgContractController,
              label: 'Average Contract Value (KES)',
              keyboardType: TextInputType.number,
            ),
            _buildTextFormField(
              controller: _creditLimitController,
              label: 'Default Credit Limit (KES)',
              keyboardType: TextInputType.number,
            ),
            _buildTextFormField(
              controller: _paymentTermsController,
              label: 'Default Payment Terms (days)',
              keyboardType: TextInputType.number,
            ),

            // Requirements
            _buildSectionHeader('Minimum Requirements'),
            _buildRequirementsSection(),

            // Mandatory Documents
            _buildSectionHeader('Mandatory Documents'),
            _buildDocumentsSection(),

            // Evaluation Criteria
            _buildSectionHeader('Evaluation Criteria'),
            _buildCriteriaSection(),

            // Submit Button
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Save Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0066A1),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<DropdownMenuItem<String?>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String?>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField({
    required int value,
    required String label,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 16)),
          const Spacer(),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      children: [
        ..._requirements.asMap().entries.map((entry) => _buildRequirementItem(entry.key, entry.value)),
        ElevatedButton.icon(
          onPressed: _addRequirement,
          icon: const Icon(Icons.add),
          label: const Text('Add Requirement'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRequirementItem(int index, Map<String, dynamic> requirement) {
    final requirementController = TextEditingController(text: requirement['requirement']);
    final descriptionController = TextEditingController(text: requirement['description']);
    final methodController = TextEditingController(text: requirement['verificationMethod']);
    final isMandatory = requirement['isMandatory'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Requirement ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _requirements.removeAt(index)),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            _buildTextFormField(
              controller: requirementController,
              label: 'Requirement',
            ),
            _buildTextFormField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 2,
            ),
            _buildTextFormField(
              controller: methodController,
              label: 'Verification Method',
            ),
            SwitchListTile(
              title: const Text('Mandatory'),
              value: isMandatory,
              onChanged: (value) => setState(() {
                _requirements[index]['isMandatory'] = value;
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _addRequirement() {
    setState(() {
      _requirements.add({
        'requirement': '',
        'description': '',
        'verificationMethod': '',
        'isMandatory': true,
      });
    });
  }

  Widget _buildDocumentsSection() {
    final documentController = TextEditingController();

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _mandatoryDocuments.map((doc) => Chip(
            label: Text(doc),
            onDeleted: () => setState(() => _mandatoryDocuments.remove(doc)),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: documentController,
                decoration: const InputDecoration(
                  labelText: 'Add mandatory document',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (documentController.text.isNotEmpty) {
                  setState(() {
                    _mandatoryDocuments.add(documentController.text);
                    documentController.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCriteriaSection() {
    return Column(
      children: [
        ..._evaluationCriteria.asMap().entries.map((entry) => _buildCriterionItem(entry.key, entry.value)),
        ElevatedButton.icon(
          onPressed: _addCriterion,
          icon: const Icon(Icons.add),
          label: const Text('Add Evaluation Criterion'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCriterionItem(int index, Map<String, dynamic> criterion) {
    final nameController = TextEditingController(text: criterion['criterion']);
    final descriptionController = TextEditingController(text: criterion['description']);
    final weightController = TextEditingController(text: criterion['weight']?.toString() ?? '0');
    final minScoreController = TextEditingController(text: criterion['minimumScore']?.toString() ?? '0');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Criterion ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _evaluationCriteria.removeAt(index)),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            _buildTextFormField(
              controller: nameController,
              label: 'Criterion Name',
            ),
            _buildTextFormField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 2,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: weightController,
                    label: 'Weight (%)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: minScoreController,
                    label: 'Minimum Score',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCriterion() {
    setState(() {
      _evaluationCriteria.add({
        'criterion': '',
        'description': '',
        'weight': 0,
        'minimumScore': 0,
      });
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Prepare data
      final data = {
        'categoryCode': _codeController.text,
        'categoryName': _nameController.text,
        'description': _descriptionController.text,
        'parentCategory': _selectedParentCategory,
        'level': _selectedLevel,
        'nawasscoSpecific': _nawasscoSpecific,
        'averageContractValue': double.tryParse(_avgContractController.text) ?? 0,
        'creditLimitDefault': double.tryParse(_creditLimitController.text) ?? 0,
        'paymentTermsDefault': int.tryParse(_paymentTermsController.text) ?? 30,
        'minimumRequirements': _requirements,
        'mandatoryDocuments': _mandatoryDocuments,
        'evaluationCriteria': _evaluationCriteria,
        'isActive': true,
      };

      widget.onSubmit(data);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _avgContractController.dispose();
    _creditLimitController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }
}