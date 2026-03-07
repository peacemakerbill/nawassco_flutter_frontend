import 'package:flutter/material.dart';

import '../../../models/supplier_model.dart';

class EvaluationFormWidget extends StatefulWidget {
  final List<Supplier> suppliers;
  final String? selectedSupplierId;
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? initialData;

  const EvaluationFormWidget({
    super.key,
    required this.suppliers,
    this.selectedSupplierId,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<EvaluationFormWidget> createState() => _EvaluationFormWidgetState();
}

class _EvaluationFormWidgetState extends State<EvaluationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _evaluationDateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _nextEvaluationController = TextEditingController();

  String? _selectedSupplierId;
  final List<String> _strengths = [];
  final List<String> _weaknesses = [];
  final List<String> _recommendations = [];
  final List<String> _improvementAreas = [];
  final List<Map<String, dynamic>> _followUpActions = [];

  // Score controllers
  final TextEditingController _technicalScoreController = TextEditingController();
  final TextEditingController _financialScoreController = TextEditingController();
  final TextEditingController _deliveryScoreController = TextEditingController();
  final TextEditingController _qualityScoreController = TextEditingController();
  final TextEditingController _complianceScoreController = TextEditingController();
  final TextEditingController _relationshipScoreController = TextEditingController();

  // Assessment comments
  final TextEditingController _technicalCommentsController = TextEditingController();
  final TextEditingController _financialCommentsController = TextEditingController();
  final TextEditingController _deliveryCommentsController = TextEditingController();
  final TextEditingController _qualityCommentsController = TextEditingController();
  final TextEditingController _complianceCommentsController = TextEditingController();
  final TextEditingController _relationshipCommentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _selectedSupplierId = widget.selectedSupplierId;

    // Set default dates
    final now = DateTime.now();
    _evaluationDateController.text = _formatDateForInput(now);
    _startDateController.text = _formatDateForInput(now.subtract(const Duration(days: 30)));
    _endDateController.text = _formatDateForInput(now);
    _nextEvaluationController.text = _formatDateForInput(now.add(const Duration(days: 365)));

    if (widget.initialData != null) {
      // Initialize with existing data
      _selectedSupplierId = widget.initialData!['supplier'];

      if (widget.initialData!['evaluationDate'] != null) {
        _evaluationDateController.text = _formatDateForInput(
            DateTime.parse(widget.initialData!['evaluationDate'])
        );
      }

      if (widget.initialData!['evaluationPeriod'] != null) {
        final period = widget.initialData!['evaluationPeriod'];
        _startDateController.text = _formatDateForInput(DateTime.parse(period['startDate']));
        _endDateController.text = _formatDateForInput(DateTime.parse(period['endDate']));
      }

      if (widget.initialData!['nextEvaluationDate'] != null) {
        _nextEvaluationController.text = _formatDateForInput(
            DateTime.parse(widget.initialData!['nextEvaluationDate'])
        );
      }

      // Initialize scores
      _technicalScoreController.text = widget.initialData!['technicalScore']?.toString() ?? '0';
      _financialScoreController.text = widget.initialData!['financialScore']?.toString() ?? '0';
      _deliveryScoreController.text = widget.initialData!['deliveryScore']?.toString() ?? '0';
      _qualityScoreController.text = widget.initialData!['qualityScore']?.toString() ?? '0';
      _complianceScoreController.text = widget.initialData!['complianceScore']?.toString() ?? '0';
      _relationshipScoreController.text = widget.initialData!['relationshipScore']?.toString() ?? '0';

      // Initialize comments
      if (widget.initialData!['technicalAssessment'] != null) {
        _technicalCommentsController.text = widget.initialData!['technicalAssessment']['comments'] ?? '';
      }
      if (widget.initialData!['financialAssessment'] != null) {
        _financialCommentsController.text = widget.initialData!['financialAssessment']['comments'] ?? '';
      }
      if (widget.initialData!['deliveryAssessment'] != null) {
        _deliveryCommentsController.text = widget.initialData!['deliveryAssessment']['comments'] ?? '';
      }
      if (widget.initialData!['qualityAssessment'] != null) {
        _qualityCommentsController.text = widget.initialData!['qualityAssessment']['comments'] ?? '';
      }
      if (widget.initialData!['complianceAssessment'] != null) {
        _complianceCommentsController.text = widget.initialData!['complianceAssessment']['comments'] ?? '';
      }
      if (widget.initialData!['relationshipAssessment'] != null) {
        _relationshipCommentsController.text = widget.initialData!['relationshipAssessment']['comments'] ?? '';
      }

      // Initialize lists
      _strengths.addAll(List<String>.from(widget.initialData!['strengths'] ?? []));
      _weaknesses.addAll(List<String>.from(widget.initialData!['weaknesses'] ?? []));
      _recommendations.addAll(List<String>.from(widget.initialData!['recommendations'] ?? []));
      _improvementAreas.addAll(List<String>.from(widget.initialData!['improvementAreas'] ?? []));
      _followUpActions.addAll(List<Map<String, dynamic>>.from(widget.initialData!['followUpActions'] ?? []));
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
            // Supplier Selection
            _buildSectionHeader('Supplier Selection'),
            _buildSupplierDropdown(),

            // Evaluation Period
            _buildSectionHeader('Evaluation Period'),
            _buildDateField(
              controller: _evaluationDateController,
              label: 'Evaluation Date *',
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _startDateController,
                    label: 'Start Date *',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    controller: _endDateController,
                    label: 'End Date *',
                  ),
                ),
              ],
            ),
            _buildDateField(
              controller: _nextEvaluationController,
              label: 'Next Evaluation Date *',
            ),

            // Scores Section
            _buildSectionHeader('Performance Scores'),
            _buildScoresSection(),

            // Assessment Comments
            _buildSectionHeader('Assessment Comments'),
            _buildCommentsSection(),

            // Strengths & Weaknesses
            _buildSectionHeader('Strengths & Weaknesses'),
            _buildListSection('Strengths', _strengths, Icons.thumb_up),
            _buildListSection('Weaknesses', _weaknesses, Icons.thumb_down),

            // Recommendations & Improvement Areas
            _buildSectionHeader('Recommendations & Improvements'),
            _buildListSection('Recommendations', _recommendations, Icons.lightbulb),
            _buildListSection('Improvement Areas', _improvementAreas, Icons.upgrade),

            // Follow-up Actions
            _buildSectionHeader('Follow-up Actions'),
            _buildFollowUpActionsSection(),

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
                child: const Text('Save Evaluation'),
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

  Widget _buildSupplierDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String?>(
        value: _selectedSupplierId,
        decoration: const InputDecoration(
          labelText: 'Supplier *',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Select a supplier')),
          ...widget.suppliers.map((supplier) => DropdownMenuItem(
            value: supplier.id,
            child: Text(supplier.companyName),
          )),
        ],
        validator: (value) => value == null ? 'Please select a supplier' : null,
        onChanged: (value) => setState(() => _selectedSupplierId = value),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
        readOnly: true,
        validator: (value) => value?.isEmpty == true ? 'Required' : null,
      ),
    );
  }

  Widget _buildScoresSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildScoreField(_technicalScoreController, 'Technical')),
            const SizedBox(width: 16),
            Expanded(child: _buildScoreField(_financialScoreController, 'Financial')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildScoreField(_deliveryScoreController, 'Delivery')),
            const SizedBox(width: 16),
            Expanded(child: _buildScoreField(_qualityScoreController, 'Quality')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildScoreField(_complianceScoreController, 'Compliance')),
            const SizedBox(width: 16),
            Expanded(child: _buildScoreField(_relationshipScoreController, 'Relationship')),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Score:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  _calculateTotalScore().toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0066A1),
                  ),
                ),
                Text(
                  _calculateGrade(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$label Score (0-100)',
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty == true) return 'Required';
        final score = double.tryParse(value!);
        if (score == null || score < 0 || score > 100) {
          return 'Enter 0-100';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      children: [
        _buildCommentField(_technicalCommentsController, 'Technical Assessment'),
        _buildCommentField(_financialCommentsController, 'Financial Assessment'),
        _buildCommentField(_deliveryCommentsController, 'Delivery Assessment'),
        _buildCommentField(_qualityCommentsController, 'Quality Assessment'),
        _buildCommentField(_complianceCommentsController, 'Compliance Assessment'),
        _buildCommentField(_relationshipCommentsController, 'Relationship Assessment'),
      ],
    );
  }

  Widget _buildCommentField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    final itemController = TextEditingController();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0066A1)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => Chip(
                label: Text(item),
                onDeleted: () => setState(() => items.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController,
                    decoration: InputDecoration(
                      labelText: 'Add $title',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (itemController.text.isNotEmpty) {
                      setState(() {
                        items.add(itemController.text);
                        itemController.clear();
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpActionsSection() {
    final actionController = TextEditingController();
    final deadlineController = TextEditingController();
    String selectedResponsible = '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow-up Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._followUpActions.asMap().entries.map((entry) =>
                _buildActionItem(entry.key, entry.value)
            ),
            const SizedBox(height: 16),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(
                labelText: 'Action Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: deadlineController,
                    decoration: const InputDecoration(
                      labelText: 'Deadline',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, deadlineController),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedResponsible.isNotEmpty ? selectedResponsible : null,
                    decoration: const InputDecoration(
                      labelText: 'Responsible',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'procurement', child: Text('Procurement Team')),
                      DropdownMenuItem(value: 'manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) => selectedResponsible = value!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (actionController.text.isNotEmpty && deadlineController.text.isNotEmpty) {
                  setState(() {
                    _followUpActions.add({
                      'action': actionController.text,
                      'deadline': deadlineController.text,
                      'responsible': selectedResponsible,
                      'status': 'pending',
                    });
                    actionController.clear();
                    deadlineController.clear();
                    selectedResponsible = '';
                  });
                }
              },
              child: const Text('Add Action'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(int index, Map<String, dynamic> action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action['action'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('Deadline: ${action['deadline']}', style: const TextStyle(fontSize: 12)),
                  Text('Responsible: ${action['responsible']}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _followUpActions.removeAt(index)),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _formatDateForInput(picked);
    }
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _calculateTotalScore() {
    final scores = [
      double.tryParse(_technicalScoreController.text) ?? 0,
      double.tryParse(_financialScoreController.text) ?? 0,
      double.tryParse(_deliveryScoreController.text) ?? 0,
      double.tryParse(_qualityScoreController.text) ?? 0,
      double.tryParse(_complianceScoreController.text) ?? 0,
      double.tryParse(_relationshipScoreController.text) ?? 0,
    ];
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String _calculateGrade() {
    final score = _calculateTotalScore();
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedSupplierId != null) {
      // Prepare assessment data
      final technicalAssessment = {
        'score': double.parse(_technicalScoreController.text),
        'weight': 20.0,
        'weightedScore': double.parse(_technicalScoreController.text) * 0.2,
        'criteria': [],
        'comments': _technicalCommentsController.text,
      };

      final financialAssessment = {
        'score': double.parse(_financialScoreController.text),
        'weight': 15.0,
        'weightedScore': double.parse(_financialScoreController.text) * 0.15,
        'criteria': [],
        'comments': _financialCommentsController.text,
      };

      final deliveryAssessment = {
        'score': double.parse(_deliveryScoreController.text),
        'weight': 25.0,
        'weightedScore': double.parse(_deliveryScoreController.text) * 0.25,
        'criteria': [],
        'comments': _deliveryCommentsController.text,
      };

      final qualityAssessment = {
        'score': double.parse(_qualityScoreController.text),
        'weight': 20.0,
        'weightedScore': double.parse(_qualityScoreController.text) * 0.2,
        'criteria': [],
        'comments': _qualityCommentsController.text,
      };

      final complianceAssessment = {
        'score': double.parse(_complianceScoreController.text),
        'weight': 10.0,
        'weightedScore': double.parse(_complianceScoreController.text) * 0.1,
        'criteria': [],
        'comments': _complianceCommentsController.text,
      };

      final relationshipAssessment = {
        'score': double.parse(_relationshipScoreController.text),
        'weight': 10.0,
        'weightedScore': double.parse(_relationshipScoreController.text) * 0.1,
        'criteria': [],
        'comments': _relationshipCommentsController.text,
      };

      // Prepare final data
      final data = {
        'supplier': _selectedSupplierId,
        'evaluationDate': _evaluationDateController.text,
        'evaluationPeriod': {
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
        },
        'technicalScore': double.parse(_technicalScoreController.text),
        'financialScore': double.parse(_financialScoreController.text),
        'deliveryScore': double.parse(_deliveryScoreController.text),
        'qualityScore': double.parse(_qualityScoreController.text),
        'complianceScore': double.parse(_complianceScoreController.text),
        'relationshipScore': double.parse(_relationshipScoreController.text),
        'totalScore': _calculateTotalScore(),
        'grade': _calculateGrade(),
        'technicalAssessment': technicalAssessment,
        'financialAssessment': financialAssessment,
        'deliveryAssessment': deliveryAssessment,
        'qualityAssessment': qualityAssessment,
        'complianceAssessment': complianceAssessment,
        'relationshipAssessment': relationshipAssessment,
        'strengths': _strengths,
        'weaknesses': _weaknesses,
        'recommendations': _recommendations,
        'improvementAreas': _improvementAreas,
        'nextEvaluationDate': _nextEvaluationController.text,
        'followUpActions': _followUpActions,
        'status': 'draft',
      };

      widget.onSubmit(data);
    } else if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
    }
  }

  @override
  void dispose() {
    _evaluationDateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _nextEvaluationController.dispose();
    _technicalScoreController.dispose();
    _financialScoreController.dispose();
    _deliveryScoreController.dispose();
    _qualityScoreController.dispose();
    _complianceScoreController.dispose();
    _relationshipScoreController.dispose();
    _technicalCommentsController.dispose();
    _financialCommentsController.dispose();
    _deliveryCommentsController.dispose();
    _qualityCommentsController.dispose();
    _complianceCommentsController.dispose();
    _relationshipCommentsController.dispose();
    super.dispose();
  }
}