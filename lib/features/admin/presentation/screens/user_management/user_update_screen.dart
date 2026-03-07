import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_textfield.dart';
import '../../../providers/admin_provider.dart';
import '../../constants/admin_colors.dart';

class UserUpdateScreen extends ConsumerStatefulWidget {
  final String id;
  const UserUpdateScreen({super.key, required this.id});

  @override
  ConsumerState<UserUpdateScreen> createState() => _UserUpdateScreenState();
}

class _UserUpdateScreenState extends ConsumerState<UserUpdateScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _meterNumberCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _serviceZoneCtrl = TextEditingController();

  String? _selectedGender;
  String? _selectedCustomerType;
  String? _selectedLanguage;
  String? _selectedRole;

  bool _loading = false;
  bool _isLoadingUser = true;

  bool _isActive = true;
  bool _isArchived = false;
  bool _isEmailVerified = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _customerTypes = ['Residential', 'Commercial', 'Institutional'];
  final List<String> _languages = ['en', 'sw'];
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
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ref.read(adminProvider).getUser(widget.id);
      setState(() {
        _firstNameCtrl.text = user['firstName'] ?? '';
        _lastNameCtrl.text = user['lastName'] ?? '';
        _emailCtrl.text = user['email'] ?? '';
        _phoneCtrl.text = user['phoneNumber'] ?? '';
        _nationalIdCtrl.text = user['nationalId'] ?? '';
        _locationCtrl.text = user['location'] ?? '';
        _addressCtrl.text = user['address'] ?? '';
        _meterNumberCtrl.text = user['meterNumber'] ?? '';
        _accountNumberCtrl.text = user['accountNumber'] ?? '';
        _serviceZoneCtrl.text = user['serviceZone'] ?? '';

        _selectedGender = user['gender'];
        _selectedCustomerType = user['customerType'];
        _selectedLanguage = user['preferredLanguage'];

        final roles = List<String>.from(user['roles'] ?? []);
        _selectedRole = roles.isNotEmpty ? roles.first : 'User';

        _isActive = user['isActive'] ?? true;
        _isArchived = user['isArchived'] ?? false;
        _isEmailVerified = user['isEmailVerified'] ?? false;

        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() => _isLoadingUser = false);
      if (mounted) {
        _showError('Failed to load user: $e');
      }
    }
  }

  Future<void> _updateUser() async {
    print('Updating user: ${widget.id}');

    if (_firstNameCtrl.text.trim().isEmpty || _lastNameCtrl.text.trim().isEmpty) {
      _showError('First name and last name are required');
      return;
    }

    if (_selectedRole == null) {
      _showError('Please select a user role');
      return;
    }

    setState(() => _loading = true);

    try {
      final updateData = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'nationalId': _nationalIdCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'gender': _selectedGender,
        'preferredLanguage': _selectedLanguage,
        'customerType': _selectedCustomerType,
        'meterNumber': _meterNumberCtrl.text.trim(),
        'accountNumber': _accountNumberCtrl.text.trim(),
        'serviceZone': _serviceZoneCtrl.text.trim(),
        'roles': [_selectedRole!],
        'isActive': _isActive,
        'isArchived': _isArchived,
        'isEmailVerified': _isEmailVerified,
      };

      // Remove null or empty values
      updateData.removeWhere((key, value) => value == null || value == '');

      print('Update data: $updateData');
      await ref.read(adminProvider).updateUser(widget.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User updated successfully'),
            backgroundColor: AdminColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update user: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Update User'),
        backgroundColor: Colors.transparent,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: AdminColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                Row(
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
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  value: _selectedGender,
                  items: _genders,
                  hint: 'Select Gender',
                  onChanged: (value) => setState(() => _selectedGender = value),
                  icon: Icons.transgender,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Account Details',
              icon: Icons.account_balance_wallet,
              children: [
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
                const SizedBox(height: 16),
                _buildDropdown(
                  value: _selectedCustomerType,
                  items: _customerTypes,
                  hint: 'Select Customer Type',
                  onChanged: (value) => setState(() => _selectedCustomerType = value),
                  icon: Icons.business_center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'User Role & Preferences',
              icon: Icons.settings,
              children: [
                _buildDropdown(
                  value: _selectedRole,
                  items: _availableRoles,
                  hint: 'Select User Role *',
                  onChanged: (value) => setState(() => _selectedRole = value),
                  icon: Icons.admin_panel_settings,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  value: _selectedLanguage,
                  items: _languages,
                  hint: 'Select Preferred Language',
                  onChanged: (value) => setState(() => _selectedLanguage = value),
                  icon: Icons.language,
                ),
                const SizedBox(height: 12),
                // Role description
                if (_selectedRole != null) ...[
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
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Account Status',
              icon: Icons.verified_user,
              children: [
                _StatusToggle(
                  title: 'Active Account',
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: AdminColors.success,
                  icon: Icons.toggle_on,
                ),
                _StatusToggle(
                  title: 'Archived Account',
                  value: _isArchived,
                  onChanged: (value) => setState(() => _isArchived = value),
                  activeColor: AdminColors.warning,
                  icon: Icons.archive,
                ),
                _StatusToggle(
                  title: 'Email Verified',
                  value: _isEmailVerified,
                  onChanged: (value) => setState(() => _isEmailVerified = value),
                  activeColor: AdminColors.info,
                  icon: Icons.verified,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
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
                    text: _loading ? 'Updating...' : 'Update User',
                    onPressed: _loading ? null : _updateUser,
                    backgroundColor: AdminColors.primary,
                    textColor: Colors.white,
                    isLoading: _loading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(icon, color: AdminColors.primary),
            labelText: hint,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AdminColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
    _meterNumberCtrl.dispose();
    _accountNumberCtrl.dispose();
    _serviceZoneCtrl.dispose();
    super.dispose();
  }
}

class _StatusToggle extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color activeColor;
  final IconData icon;

  const _StatusToggle({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? activeColor.withOpacity(0.1) : AdminColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? activeColor : AdminColors.grey400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: value ? activeColor : AdminColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
              activeTrackColor: activeColor.withOpacity(0.3),
              inactiveThumbColor: AdminColors.grey400,
              inactiveTrackColor: AdminColors.grey200,
            ),
          ),
        ],
      ),
    );
  }
}