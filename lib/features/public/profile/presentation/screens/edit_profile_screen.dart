import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/cloudinary_provider.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _meterNumberCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _imageFile;
  String? _currentProfilePictureUrl;
  bool _isLoading = false;
  bool _isDataLoading = true;
  String? _gender;
  DateTime? _dateOfBirth;
  String? _customerType;
  String? _preferredLanguage;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadProfileData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ref.read(profileProvider).getProfile();

      if (mounted) {
        setState(() {
          _firstNameCtrl.text = profile['firstName'] ?? '';
          _middleNameCtrl.text = profile['middleName'] ?? '';
          _lastNameCtrl.text = profile['lastName'] ?? '';
          _usernameCtrl.text = profile['username'] ?? '';
          _phoneCtrl.text = profile['phoneNumber'] ?? '';
          _locationCtrl.text = profile['location'] ?? '';
          _addressCtrl.text = profile['address'] ?? '';
          _nationalIdCtrl.text = profile['nationalId'] ?? '';
          _accountNumberCtrl.text = profile['accountNumber'] ?? '';
          _meterNumberCtrl.text = profile['meterNumber'] ?? '';
          _gender = profile['gender'] ?? 'Other';
          _customerType = profile['customerType'] ?? 'Residential';
          _preferredLanguage = profile['preferredLanguage'] ?? 'en';
          _currentProfilePictureUrl = profile['profilePictureUrl'];

          // Parse date of birth
          if (profile['dateOfBirth'] != null) {
            try {
              if (profile['dateOfBirth'] is String) {
                _dateOfBirth = DateTime.parse(profile['dateOfBirth'] as String);
              }
            } catch (e) {
              print('Error parsing date of birth: $e');
            }
          }

          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
      _showErrorSnackbar('Failed to load profile data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
    _nationalIdCtrl.dispose();
    _accountNumberCtrl.dispose();
    _meterNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;

    if (_isDataLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/profile'),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _isLoading ? null : _saveProfile,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 40 : 16,
            vertical: 16,
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Profile Picture Section
                  _buildProfilePictureSection(theme),

                  const SizedBox(height: 32),

                  // Personal Information Card
                  _buildSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildTextField(
                        controller: _firstNameCtrl,
                        label: 'First Name',
                        icon: Icons.person_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _middleNameCtrl,
                        label: 'Middle Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lastNameCtrl,
                        label: 'Last Name',
                        icon: Icons.person_outline_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.alternate_email_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Account Information Card
                  _buildSectionCard(
                    title: 'Account Information',
                    icon: Icons.account_balance_wallet_rounded,
                    children: [
                      _buildTextField(
                        controller: _accountNumberCtrl,
                        label: 'Account Number',
                        icon: Icons.numbers_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _meterNumberCtrl,
                        label: 'Meter Number',
                        icon: Icons.speed_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildCustomerTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildPreferredLanguageDropdown(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location & Address Card
                  _buildSectionCard(
                    title: 'Location & Address',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildTextField(
                        controller: _locationCtrl,
                        label: 'Location',
                        icon: Icons.place_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressCtrl,
                        label: 'Address',
                        icon: Icons.home_rounded,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Additional Information Card
                  _buildSectionCard(
                    title: 'Additional Information',
                    icon: Icons.info_outline_rounded,
                    children: [
                      _buildGenderDropdown(),
                      const SizedBox(height: 16),
                      _buildDateOfBirthField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nationalIdCtrl,
                        label: 'National ID',
                        icon: Icons.badge_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: _getProfileImage(),
                child: _imageFile == null && _currentProfilePictureUrl == null
                    ? Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: theme.colorScheme.onSurfaceVariant,
                )
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tap camera icon to update profile picture',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      if (kIsWeb) {
        return NetworkImage(_imageFile!.path);
      } else {
        return FileImage(File(_imageFile!.path));
      }
    } else if (_currentProfilePictureUrl != null && _currentProfilePictureUrl!.isNotEmpty) {
      return NetworkImage(_currentProfilePictureUrl!);
    }
    return null;
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.cardColor,
      ),
      validator: required
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildGenderDropdown() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            onChanged: (value) => setState(() => _gender = value),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerTypeDropdown() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Type',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _customerType,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.business_rounded, color: theme.colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: ['Residential', 'Commercial', 'Institutional']
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) => setState(() => _customerType = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferredLanguageDropdown() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Language',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _preferredLanguage,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.language_rounded, color: theme.colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'sw', child: Text('Swahili')),
            ],
            onChanged: (value) => setState(() => _preferredLanguage = value),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _isLoading ? null : _selectDateOfBirth,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select Date of Birth',
                    style: TextStyle(
                      color: _dateOfBirth != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.go('/profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save_rounded, size: 20),
                SizedBox(width: 8),
                Text('Save Changes'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (picked != null) {
      setState(() {
        _imageFile = picked;
        _currentProfilePictureUrl = null;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: theme.cardColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'firstName': _firstNameCtrl.text.trim(),
        'middleName': _middleNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'gender': _gender,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'nationalId': _nationalIdCtrl.text.trim(),
        'accountNumber': _accountNumberCtrl.text.trim(),
        'meterNumber': _meterNumberCtrl.text.trim(),
        'customerType': _customerType,
        'preferredLanguage': _preferredLanguage,
      };

      // If there's a new image, upload it first
      if (_imageFile != null) {
        try {
          final cloudinary = ref.read(cloudinaryProvider);
          final imageUrl = await cloudinary.uploadImageDirectly(_imageFile!);
          data['profilePictureUrl'] = imageUrl;
        } catch (uploadError) {
          // Fallback to backend upload
          final cloudinary = ref.read(cloudinaryProvider);
          final imageUrl = await cloudinary.uploadImageThroughBackend(_imageFile!);
          data['profilePictureUrl'] = imageUrl;
        }
      }

      final result = await ref.read(profileProvider).updateProfile(data);

      if (mounted) {
        _showSuccessSnackbar('Profile updated successfully!');
        await Future.delayed(const Duration(milliseconds: 500));

        ref.invalidate(profileProvider);
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}