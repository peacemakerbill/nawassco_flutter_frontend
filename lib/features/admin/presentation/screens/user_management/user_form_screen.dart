import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_textfield.dart';
import '../../../providers/admin_provider.dart';
import '../../constants/admin_colors.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _meterNumberCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _serviceZoneCtrl = TextEditingController();

  String? _selectedRole = 'User';
  bool _loading = false;

  final List<String> _availableRoles = [
    'Admin',
    'User',
    'SalesAgent',
    'Accounts',
    'Manager',
    'HR',
    'Procurement',
    'Supplier',
    'Technician',
    'StoreManager'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Create New User'),
        backgroundColor: AdminColors.surface,
        foregroundColor: AdminColors.textPrimary,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 48, color: AdminColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Create New User Account',
                      style: TextStyle(
                        color: AdminColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in the user details below to create a new account',
                      style: TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Personal Information Section
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                // Use LayoutBuilder for responsive row
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Desktop/tablet layout
                      return Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameCtrl,
                              label: 'First Name *',
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameCtrl,
                              label: 'Last Name *',
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile layout
                      return Column(
                        children: [
                          CustomTextField(
                            controller: _firstNameCtrl,
                            label: 'First Name *',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _lastNameCtrl,
                            label: 'Last Name *',
                            icon: Icons.person_outline,
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email Address *',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'Phone Number *',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Details Section
            _buildSectionCard(
              title: 'Account Details',
              icon: Icons.account_balance_wallet,
              children: [
                CustomTextField(
                  controller: _passCtrl,
                  label: 'Password *',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _meterNumberCtrl,
                  label: 'Meter Number',
                  icon: Icons.speed,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _accountNumberCtrl,
                  label: 'Account Number',
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _serviceZoneCtrl,
                  label: 'Service Zone',
                  icon: Icons.assignment,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Role Section
            _buildSectionCard(
              title: 'User Role *',
              icon: Icons.admin_panel_settings,
              children: [
                Text(
                  'Select a role for this user:',
                  style: TextStyle(color: AdminColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Use Wrap with spacing for better layout with more roles
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableRoles.map((role) {
                    return ChoiceChip(
                      label: Text(
                        role,
                        style: TextStyle(
                          fontSize: 13,
                          color: _selectedRole == role ? Colors.white : AdminColors.textPrimary,
                          fontWeight: _selectedRole == role ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: _selectedRole == role,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedRole = role);
                        }
                      },
                      selectedColor: AdminColors.primary,
                      backgroundColor: AdminColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedRole == role ? AdminColors.primary : AdminColors.border,
                          width: 1.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Role descriptions for better UX
                if (_selectedRole != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getRoleDescription(_selectedRole!),
                      style: TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Buttons - FIXED: Use Column for mobile, Row for larger screens
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: _loading ? null : () => context.pop(),
                          backgroundColor: AdminColors.grey300,
                          textColor: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: _loading ? 'Creating...' : 'Create User',
                          onPressed: _loading ? null : _create,
                          backgroundColor: AdminColors.primary,
                          textColor: Colors.white,
                          isLoading: _loading,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      CustomButton(
                        text: 'Cancel',
                        onPressed: _loading ? null : () => context.pop(),
                        backgroundColor: AdminColors.grey300,
                        textColor: AdminColors.textPrimary,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: _loading ? 'Creating...' : 'Create User',
                        onPressed: _loading ? null : _create,
                        backgroundColor: AdminColors.primary,
                        textColor: Colors.white,
                        isLoading: _loading,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16), // Extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: AdminColors.primary, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AdminColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'Admin':
        return 'Full system access and administrative privileges';
      case 'User':
        return 'Regular customer with basic account access';
      case 'SalesAgent':
        return 'Sales representative with lead management capabilities';
      case 'Accounts':
        return 'Finance and controller management access';
      case 'Manager':
        return 'Team and operational management privileges';
      case 'HR':
        return 'Human resources and personnel management';
      case 'Procurement':
        return 'Supply chain and procurement management';
      case 'Supplier':
        return 'External supplier/vendor access';
      case 'Technician':
        return 'Field service and technical operations';
      case 'StoreManager':
        return 'Store inventory and warehouse management';
      default:
        return 'User role description';
    }
  }

  Future<void> _create() async {
    // Validation and create logic remains the same...
    if (_firstNameCtrl.text.trim().isEmpty || _lastNameCtrl.text.trim().isEmpty) {
      _showError('First name and last name are required');
      return;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Email address is required');
      return;
    }

    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('Phone number is required');
      return;
    }

    if (_passCtrl.text.isEmpty) {
      _showError('Password is required');
      return;
    }

    if (_passCtrl.text.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    if (_selectedRole == null) {
      _showError('Please select a user role');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'password': _passCtrl.text,
        'meterNumber': _meterNumberCtrl.text.trim(),
        'accountNumber': _accountNumberCtrl.text.trim(),
        'serviceZone': _serviceZoneCtrl.text.trim(),
        'roles': [_selectedRole!],
      };

      await ref.read(adminProvider).createUser(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User created successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create user: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _meterNumberCtrl.dispose();
    _accountNumberCtrl.dispose();
    _serviceZoneCtrl.dispose();
    super.dispose();
  }
}