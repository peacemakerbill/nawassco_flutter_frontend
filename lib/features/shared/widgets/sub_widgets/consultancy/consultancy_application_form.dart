import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../main.dart';
import '../../../../public/auth/providers/auth_provider.dart';
import '../../../models/consultancy_model.dart';
import '../../../providers/consultancy_provider.dart';

class ConsultancyApplicationForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final Consultancy? initialData;

  const ConsultancyApplicationForm({
    super.key,
    this.onSuccess,
    this.initialData,
  });

  @override
  ConsumerState<ConsultancyApplicationForm> createState() =>
      _ConsultancyApplicationFormState();
}

class _ConsultancyApplicationFormState
    extends ConsumerState<ConsultancyApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _clientNameController;
  late TextEditingController _clientEmailController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _clientAddressController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPositionController;
  late TextEditingController _methodologyController;
  late TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;
  ConsultancyCategory _selectedCategory = ConsultancyCategory.TECHNICAL;
  ClientType _selectedClientType = ClientType.PRIVATE;
  final List<String> _objectives = [];
  final List<String> _deliverables = [];
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _deliverableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _endDate = now.add(const Duration(days: 30));

    _titleController =
        TextEditingController(text: widget.initialData?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData?.description ?? '');
    _clientNameController =
        TextEditingController(text: widget.initialData?.client.name ?? '');
    _clientEmailController =
        TextEditingController(text: widget.initialData?.client.email ?? '');
    _clientPhoneController =
        TextEditingController(text: widget.initialData?.client.phone ?? '');
    _clientAddressController =
        TextEditingController(text: widget.initialData?.client.address ?? '');
    _contactNameController = TextEditingController(
        text: widget.initialData?.client.contactPerson.name ?? '');
    _contactPositionController = TextEditingController(
        text: widget.initialData?.client.contactPerson.position ?? '');
    _methodologyController = TextEditingController(
        text: widget.initialData?.scope.methodology ?? '');
    _budgetController = TextEditingController(
        text: widget.initialData?.budget.totalAmount.toString() ?? '');

    if (widget.initialData != null) {
      _selectedCategory = widget.initialData!.category;
      _selectedClientType = widget.initialData!.client.type;
      _objectives.addAll(widget.initialData!.scope.objectives);
      _deliverables.addAll(widget.initialData!.scope.deliverables);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _contactNameController.dispose();
    _contactPositionController.dispose();
    _methodologyController.dispose();
    _budgetController.dispose();
    _objectiveController.dispose();
    _deliverableController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      ToastUtils.showErrorToast('Please login to apply for consultancy',
          key: scaffoldMessengerKey);
      return;
    }

    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': describeEnum(_selectedCategory).toLowerCase(),
        'scope': {
          'objectives': _objectives,
          'deliverables': _deliverables,
          'methodology': _methodologyController.text.trim(),
          'limitations': [],
          'assumptions': [],
        },
        'timeline': {
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
          'duration': _endDate.difference(_startDate).inDays ~/ 30,
        },
        'budget': {
          'totalAmount': double.parse(_budgetController.text),
          'currency': 'KES',
          'breakdown': [],
          'paymentSchedule': [],
          'expenses': [],
        },
        'client': {
          'name': _clientNameController.text.trim(),
          'type': describeEnum(_selectedClientType).toLowerCase(),
          'contactPerson': {
            'name': _contactNameController.text.trim(),
            'position': _contactPositionController.text.trim(),
            'email': _clientEmailController.text.trim(),
            'phone': _clientPhoneController.text.trim(),
          },
          'address': _clientAddressController.text.trim(),
          'email': _clientEmailController.text.trim(),
          'phone': _clientPhoneController.text.trim(),
        },
      };

      if (widget.initialData != null) {
        await ref
            .read(consultancyProvider.notifier)
            .updateConsultancy(widget.initialData!.id, data);
      } else {
        await ref.read(consultancyProvider.notifier).createConsultancy(data);
      }

      ToastUtils.showSuccessToast(
        widget.initialData != null
            ? 'Consultancy updated successfully!'
            : 'Consultancy application submitted successfully!',
        key: scaffoldMessengerKey,
      );

      widget.onSuccess?.call();
    } catch (e) {
      ToastUtils.showErrorToast('Failed to submit application: $e',
          key: scaffoldMessengerKey);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addObjective() {
    final objective = _objectiveController.text.trim();
    if (objective.isNotEmpty && !_objectives.contains(objective)) {
      setState(() {
        _objectives.add(objective);
        _objectiveController.clear();
      });
    }
  }

  void _removeObjective(String objective) {
    setState(() {
      _objectives.remove(objective);
    });
  }

  void _addDeliverable() {
    final deliverable = _deliverableController.text.trim();
    if (deliverable.isNotEmpty && !_deliverables.contains(deliverable)) {
      setState(() {
        _deliverables.add(deliverable);
        _deliverableController.clear();
      });
    }
  }

  void _removeDeliverable(String deliverable) {
    setState(() {
      _deliverables.remove(deliverable);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(consultancyProvider).isLoading;
    final isEdit = widget.initialData != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Edit Consultancy' : 'Apply for Consultancy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Basic Information Section
            _buildSection(
              context,
              title: 'Basic Information',
              icon: Icons.info,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Consultancy Title *',
                    hintText: 'e.g., Water Treatment System Analysis',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ConsultancyCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ConsultancyCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your consultancy needs...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.trim().length < 50) {
                      return 'Description should be at least 50 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),

            // Client Information Section
            _buildSection(
              context,
              title: 'Client Information',
              icon: Icons.business,
              children: [
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client/Organization Name *',
                    hintText: 'e.g., Nakuru Water Company',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter client name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ClientType>(
                  value: _selectedClientType,
                  decoration: const InputDecoration(
                    labelText: 'Client Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.type_specimen),
                  ),
                  items: ClientType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedClientType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Address *',
                    hintText: 'Full physical address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
              ],
            ),

            // Contact Person Section
            _buildSection(
              context,
              title: 'Contact Person',
              icon: Icons.person,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Name *',
                          hintText: 'Full name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter contact name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _contactPositionController,
                        decoration: const InputDecoration(
                          labelText: 'Position *',
                          hintText: 'e.g., Project Manager',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter position';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clientEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'contact@example.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _clientPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          hintText: '0712345678',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Timeline Section
            _buildSection(
              context,
              title: 'Timeline',
              icon: Icons.calendar_today,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('dd MMM yyyy').format(_startDate)),
                              const Icon(Icons.calendar_month,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd MMM yyyy').format(_endDate)),
                              const Icon(Icons.calendar_month,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _endDate.difference(_startDate).inDays / 365,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: ${_endDate.difference(_startDate).inDays} days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Scope Section
            _buildSection(
              context,
              title: 'Scope & Objectives',
              icon: Icons.flag,
              children: [
                TextFormField(
                  controller: _methodologyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Methodology *',
                    hintText: 'Describe the approach and methodology...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter methodology';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Objectives
                Text(
                  'Objectives',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _objectiveController,
                        decoration: const InputDecoration(
                          hintText: 'Add an objective...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addObjective,
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).primaryColor,
                      tooltip: 'Add objective',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_objectives.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _objectives.map((objective) {
                      return Chip(
                        label: Text(objective),
                        onDeleted: () => _removeObjective(objective),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Deliverables
                Text(
                  'Expected Deliverables',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _deliverableController,
                        decoration: const InputDecoration(
                          hintText: 'Add a deliverable...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addDeliverable,
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).primaryColor,
                      tooltip: 'Add deliverable',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_deliverables.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _deliverables.map((deliverable) {
                      return Chip(
                        label: Text(deliverable),
                        onDeleted: () => _removeDeliverable(deliverable),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),

            // Budget Section
            _buildSection(
              context,
              title: 'Budget',
              icon: Icons.attach_money,
              children: [
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Budget (KES) *',
                    hintText: 'e.g., 500000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'KES ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter budget';
                    }
                    final budget = double.tryParse(value);
                    if (budget == null || budget <= 0) {
                      return 'Please enter a valid budget amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Note: Detailed budget breakdown can be provided after initial review.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Submit Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isEdit ? Icons.save : Icons.send),
                          const SizedBox(width: 8),
                          Text(
                            isEdit
                                ? 'UPDATE CONSULTANCY'
                                : 'SUBMIT APPLICATION',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
