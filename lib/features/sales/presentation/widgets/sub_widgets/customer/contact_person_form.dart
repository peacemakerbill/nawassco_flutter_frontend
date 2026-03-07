import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';

class ContactPersonForm extends ConsumerStatefulWidget {
  final String customerId;
  final ContactPerson? initialContact;
  final VoidCallback onSuccess;

  const ContactPersonForm({
    super.key,
    required this.customerId,
    this.initialContact,
    required this.onSuccess,
  });

  @override
  ConsumerState<ContactPersonForm> createState() => _ContactPersonFormState();
}

class _ContactPersonFormState extends ConsumerState<ContactPersonForm> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _salutations = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.', 'Eng.'];
  String _selectedSalutation = 'Mr.';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContact != null) {
      final contact = widget.initialContact!;
      _selectedSalutation = contact.salutation;
      _firstNameController.text = contact.firstName;
      _lastNameController.text = contact.lastName;
      _positionController.text = contact.position;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _departmentController.text = contact.department ?? '';
      _isPrimary = contact.isPrimary;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = ref.read(customerProvider.notifier);

      final contactData = {
        'salutation': _selectedSalutation,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'position': _positionController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isPrimary': _isPrimary,
        if (_departmentController.text.isNotEmpty)
          'department': _departmentController.text.trim(),
      };

      // This would be handled via backend API
      // For now, we'll just close the dialog and refresh
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialContact == null ? 'Add Contact Person' : 'Edit Contact Person',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSalutation,
                decoration: const InputDecoration(
                  labelText: 'Salutation *',
                  border: OutlineInputBorder(),
                ),
                items: _salutations.map((salutation) {
                  return DropdownMenuItem<String>(
                    value: salutation,
                    child: Text(salutation),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSalutation = value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select salutation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Set as Primary Contact'),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value ?? false);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}