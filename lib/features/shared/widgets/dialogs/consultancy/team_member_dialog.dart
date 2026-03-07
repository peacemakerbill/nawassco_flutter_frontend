import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/consultancy_model.dart';

class TeamMemberDialog extends StatefulWidget {
  const TeamMemberDialog({super.key});

  @override
  State<TeamMemberDialog> createState() => _TeamMemberDialogState();
}

class _TeamMemberDialogState extends State<TeamMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  final _rateController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  TeamRole _selectedRole = TeamRole.CONSULTANT;
  final List<String> _responsibilities = [];

  @override
  void dispose() {
    _userIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    _rateController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }

  void _addResponsibility() {
    final responsibility = _responsibilitiesController.text.trim();
    if (responsibility.isNotEmpty && !_responsibilities.contains(responsibility)) {
      setState(() {
        _responsibilities.add(responsibility);
        _responsibilitiesController.clear();
      });
    }
  }

  void _removeResponsibility(String responsibility) {
    setState(() {
      _responsibilities.remove(responsibility);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Team Member'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<TeamRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: TeamRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                  validator: (value) => value == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours Allocated',
                          border: OutlineInputBorder(),
                          suffixText: 'hours',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter hours';
                          }
                          final hours = double.tryParse(value);
                          if (hours == null || hours <= 0) {
                            return 'Please enter valid hours';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hourly Rate',
                          border: OutlineInputBorder(),
                          prefixText: 'KES ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter rate';
                          }
                          final rate = double.tryParse(value);
                          if (rate == null || rate <= 0) {
                            return 'Please enter valid rate';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Responsibilities',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _responsibilitiesController,
                            decoration: const InputDecoration(
                              hintText: 'Add a responsibility...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addResponsibility,
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_responsibilities.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _responsibilities.map((responsibility) {
                          return Chip(
                            label: Text(responsibility),
                            onDeleted: () => _removeResponsibility(responsibility),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'User': _userIdController.text.trim(),
                'role': describeEnum(_selectedRole).toLowerCase(),
                'hoursAllocated': double.parse(_hoursController.text),
                'rate': double.parse(_rateController.text),
                'responsibilities': _responsibilities,
                'firstName': _firstNameController.text.trim(),
                'lastName': _lastNameController.text.trim(),
                'email': _emailController.text.trim(),
              });
            }
          },
          child: const Text('Add Team Member'),
        ),
      ],
    );
  }
}