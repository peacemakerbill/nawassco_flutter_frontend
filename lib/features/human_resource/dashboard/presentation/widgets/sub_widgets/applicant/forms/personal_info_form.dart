import 'package:flutter/material.dart';
import '../../../../../../models/applicant/applicant_model.dart';

class PersonalInfoForm extends StatefulWidget {
  final ApplicantModel? applicant;
  final Function(Map<String, String?>) onSubmit;

  const PersonalInfoForm({
    super.key,
    this.applicant,
    required this.onSubmit,
  });

  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _headlineController;
  late TextEditingController _summaryController;
  late TextEditingController _dateOfBirthController;
  String? _gender;
  String? _nationality;

  final List<String> _genders = ['male', 'female', 'non_binary', 'prefer_not_to_say', 'other'];
  final List<String> _countries = ['Kenya', 'USA', 'UK', 'Canada', 'Germany', 'France', 'India', 'China'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.applicant?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.applicant?.lastName ?? '');
    _emailController = TextEditingController(text: widget.applicant?.email ?? '');
    _phoneController = TextEditingController(text: widget.applicant?.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.applicant?.address ?? '');
    _cityController = TextEditingController(text: widget.applicant?.city ?? '');
    _countryController = TextEditingController(text: widget.applicant?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.applicant?.postalCode ?? '');
    _headlineController = TextEditingController(text: widget.applicant?.headline ?? '');
    _summaryController = TextEditingController(text: widget.applicant?.summary ?? '');
    _dateOfBirthController = TextEditingController(text: widget.applicant?.dateOfBirth ?? '');
    _gender = widget.applicant?.gender;
    _nationality = widget.applicant?.nationality;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Personal Information Section
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Date of Birth
          TextFormField(
            controller: _dateOfBirthController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectDate(context),
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 12),

          // Gender
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: _genders.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Nationality
          DropdownButtonFormField<String>(
            value: _nationality,
            decoration: const InputDecoration(
              labelText: 'Nationality',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: _countries.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _nationality = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Address Information
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // City
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Country
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.public),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your country';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Postal Code
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(
              labelText: 'Postal Code',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_post_office),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Professional Information
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // Headline
          TextFormField(
            controller: _headlineController,
            decoration: const InputDecoration(
              labelText: 'Professional Headline',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
              hintText: 'e.g. Senior Software Engineer',
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 12),

          // Summary
          TextFormField(
            controller: _summaryController,
            decoration: const InputDecoration(
              labelText: 'Professional Summary',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 2000,
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit({
                  'firstName': _firstNameController.text,
                  'lastName': _lastNameController.text,
                  'email': _emailController.text,
                  'phoneNumber': _phoneController.text,
                  'address': _addressController.text,
                  'city': _cityController.text,
                  'country': _countryController.text,
                  'postalCode': _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
                  'headline': _headlineController.text.isNotEmpty ? _headlineController.text : null,
                  'summary': _summaryController.text.isNotEmpty ? _summaryController.text : null,
                  'dateOfBirth': _dateOfBirthController.text.isNotEmpty ? _dateOfBirthController.text : null,
                  'gender': _gender,
                  'nationality': _nationality,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Information'),
          ),
        ],
      ),
    );
  }
}