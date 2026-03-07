import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';
import '../../../../providers/store_manager_provider.dart';

class PersonalInfoSection extends ConsumerStatefulWidget {
  final StoreManager storeManager;

  const PersonalInfoSection({super.key, required this.storeManager});

  @override
  ConsumerState<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();
  late PersonalDetails _personalDetails;
  late ContactInformation _contactInformation;
  final List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _personalDetails = widget.storeManager.personalDetails;
    _contactInformation = widget.storeManager.contactInformation;
    _emergencyContacts.addAll(widget.storeManager.emergencyContacts);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final notifier = ref.read(storeManagerProvider.notifier);
      await notifier.updatePersonalInformation(_personalDetails);
      await notifier.updateContactInformation(_contactInformation);
      await notifier.updateEmergencyContacts(_emergencyContacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeManagerState = ref.watch(storeManagerProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Personal Details Card
            _buildPersonalDetailsCard(),
            const SizedBox(height: 16),

            // Contact Information Card
            _buildContactInformationCard(),
            const SizedBox(height: 16),

            // Emergency Contacts Card
            _buildEmergencyContactsCard(),
            const SizedBox(height: 24),

            // Save Button
            if (storeManagerState.isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _personalDetails.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _personalDetails = _personalDetails.copyWith(firstName: value ?? ''),
                    validator: (value) => value?.isEmpty == true ? 'First name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _personalDetails.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _personalDetails = _personalDetails.copyWith(lastName: value ?? ''),
                    validator: (value) => value?.isEmpty == true ? 'Last name is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _personalDetails.dateOfBirth.toIso8601String().split('T')[0],
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Gender>(
                    value: _personalDetails.gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: Gender.values.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(_formatGender(gender)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _personalDetails = _personalDetails.copyWith(gender: value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _personalDetails.nationalId,
              decoration: const InputDecoration(
                labelText: 'National ID',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _personalDetails = _personalDetails.copyWith(nationalId: value ?? ''),
              validator: (value) => value?.isEmpty == true ? 'National ID is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInformationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _contactInformation.workEmail,
              decoration: const InputDecoration(
                labelText: 'Work Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _contactInformation = _contactInformation.copyWith(workEmail: value ?? ''),
              validator: (value) => value?.isEmpty == true ? 'Work email is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _contactInformation.personalEmail,
              decoration: const InputDecoration(
                labelText: 'Personal Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _contactInformation = _contactInformation.copyWith(personalEmail: value ?? ''),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _contactInformation.workPhone,
                    decoration: const InputDecoration(
                      labelText: 'Work Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _contactInformation = _contactInformation.copyWith(workPhone: value ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _contactInformation.personalPhone,
                    decoration: const InputDecoration(
                      labelText: 'Personal Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _contactInformation = _contactInformation.copyWith(personalPhone: value ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _contactInformation.officeLocation,
              decoration: const InputDecoration(
                labelText: 'Office Location',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _contactInformation = _contactInformation.copyWith(officeLocation: value ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEmergencyContact,
                  tooltip: 'Add Emergency Contact',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._emergencyContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildEmergencyContactItem(contact, index);
            }).toList(),
            if (_emergencyContacts.isEmpty)
              const Center(
                child: Text(
                  'No emergency contacts added',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactItem(EmergencyContact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Relationship: ${contact.relationship}'),
                Text('Phone: ${contact.phone}'),
                if (contact.email != null) Text('Email: ${contact.email}'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeEmergencyContact(index),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _personalDetails.dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _personalDetails = _personalDetails.copyWith(dateOfBirth: picked);
      });
    }
  }

  void _addEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => EmergencyContactDialog(
        onSave: (contact) {
          setState(() {
            _emergencyContacts.add(contact);
          });
        },
      ),
    );
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }

  String _formatGender(Gender gender) {
    return gender.name[0] + gender.name.substring(1).toLowerCase();
  }
}

class EmergencyContactDialog extends StatefulWidget {
  final Function(EmergencyContact) onSave;

  const EmergencyContactDialog({super.key, required this.onSave});

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Emergency Contact'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            ),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
              validator: (value) => value?.isEmpty == true ? 'Relationship is required' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (Optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final contact = EmergencyContact(
        name: _nameController.text,
        relationship: _relationshipController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      );
      widget.onSave(contact);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}