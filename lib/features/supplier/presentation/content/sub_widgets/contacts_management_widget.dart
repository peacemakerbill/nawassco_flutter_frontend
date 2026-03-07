import 'package:flutter/material.dart';
import '../../../models/supplier_contact_model.dart';
import '../../../models/supplier_model.dart';


class ContactsManagementWidget extends StatefulWidget {
  final Supplier? supplier;
  final List<SupplierContact> contacts;
  final bool isUpdating;
  final Function(String, Map<String, dynamic>) onUpdateContact;
  final Function(Map<String, dynamic>) onAddContact;
  final Function(String) onSetPrimary;
  final Function(String) onDeleteContact;

  const ContactsManagementWidget({
    super.key,
    required this.supplier,
    required this.contacts,
    required this.isUpdating,
    required this.onUpdateContact,
    required this.onAddContact,
    required this.onSetPrimary,
    required this.onDeleteContact,
  });

  @override
  State<ContactsManagementWidget> createState() => _ContactsManagementWidgetState();
}

class _ContactsManagementWidgetState extends State<ContactsManagementWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final TextEditingController _salutationController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedContactMethod = 'email';
  bool _receiveTenderNotifications = true;
  bool _receiveNewsletters = false;
  bool _isAuthorizedSignatory = false;
  bool _canSubmitBids = true;
  bool _isPrimary = false;

  bool _showAddForm = false;
  SupplierContact? _editingContact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with Add Button
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.contacts, color: Color(0xFF0066A1), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Contact Persons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAddForm = true;
                        _editingContact = null;
                        _clearForm();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066A1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add/Edit Form
          if (_showAddForm) _buildContactForm(),

          // Contacts List
          if (widget.contacts.isEmpty && !_showAddForm)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.contacts, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No contacts added yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showAddForm = true;
                          _clearForm();
                        });
                      },
                      child: const Text('Add First Contact'),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.contacts.isNotEmpty)
            ...widget.contacts.map((contact) => _buildContactCard(contact)),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _editingContact != null ? 'Edit Contact' : 'Add New Contact',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0066A1),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                        _editingContact = null;
                        _clearForm();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Personal Information
              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildTextFormField(_salutationController, 'Salutation *', (v) => v?.isEmpty == true ? 'Required' : null),
              _buildTextFormField(_firstNameController, 'First Name *', (v) => v?.isEmpty == true ? 'Required' : null),
              _buildTextFormField(_lastNameController, 'Last Name *', (v) => v?.isEmpty == true ? 'Required' : null),
              _buildTextFormField(_positionController, 'Position *', (v) => v?.isEmpty == true ? 'Required' : null),
              _buildTextFormField(_departmentController, 'Department *', (v) => v?.isEmpty == true ? 'Required' : null),

              const SizedBox(height: 16),
              const Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildTextFormField(_emailController, 'Email *', (v) {
                if (v?.isEmpty == true) return 'Required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!)) return 'Invalid email';
                return null;
              }),
              _buildTextFormField(_phoneController, 'Phone *', (v) => v?.isEmpty == true ? 'Required' : null),
              _buildTextFormField(_mobileController, 'Mobile *', (v) => v?.isEmpty == true ? 'Required' : null),

              const SizedBox(height: 16),
              const Text(
                'Preferences & Authorization',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedContactMethod,
                label: 'Preferred Contact Method',
                items: const [
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'phone', child: Text('Phone')),
                  DropdownMenuItem(value: 'sms', child: Text('SMS')),
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                ],
                onChanged: (value) => setState(() => _selectedContactMethod = value!),
              ),
              SwitchListTile(
                title: const Text('Receive Tender Notifications'),
                value: _receiveTenderNotifications,
                onChanged: (value) => setState(() => _receiveTenderNotifications = value),
              ),
              SwitchListTile(
                title: const Text('Receive Newsletters'),
                value: _receiveNewsletters,
                onChanged: (value) => setState(() => _receiveNewsletters = value),
              ),
              SwitchListTile(
                title: const Text('Authorized Signatory'),
                value: _isAuthorizedSignatory,
                onChanged: (value) => setState(() => _isAuthorizedSignatory = value),
              ),
              SwitchListTile(
                title: const Text('Can Submit Bids'),
                value: _canSubmitBids,
                onChanged: (value) => setState(() => _canSubmitBids = value),
              ),
              if (!_hasPrimaryContact() || _editingContact?.isPrimary == true)
                SwitchListTile(
                  title: const Text('Primary Contact'),
                  value: _isPrimary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showAddForm = false;
                          _editingContact = null;
                          _clearForm();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.isUpdating ? null : _submitContactForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066A1),
                        foregroundColor: Colors.white,
                      ),
                      child: widget.isUpdating
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(_editingContact != null ? 'Update' : 'Add Contact'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(SupplierContact contact) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0066A1),
                  child: Text(
                    '${contact.firstName[0]}${contact.lastName[0]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${contact.firstName} ${contact.lastName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact.position,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (contact.isPrimary)
                  const Chip(
                    label: Text('Primary'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(contact.department),
                  backgroundColor: Colors.blue[50],
                ),
                Chip(
                  label: Text(contact.preferredContactMethod),
                  backgroundColor: Colors.green[50],
                ),
                if (contact.isAuthorizedSignatory)
                  const Chip(
                    label: Text('Signatory'),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                if (contact.canSubmitBids)
                  Chip(
                    label: const Text('Can Bid'),
                    backgroundColor: Colors.purple[50],
                  ),
                if (contact.receiveTenderNotifications)
                  Chip(
                    label: const Text('Gets Tenders'),
                    backgroundColor: Colors.teal[50],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📧 ${contact.email}'),
                      Text('📞 ${contact.phone}'),
                      if (contact.mobile.isNotEmpty) Text('📱 ${contact.mobile}'),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    if (!contact.isPrimary)
                      const PopupMenuItem(
                        value: 'set_primary',
                        child: ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Set as Primary'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editContact(contact);
                        break;
                      case 'set_primary':
                        _setPrimaryContact(contact);
                        break;
                      case 'delete':
                        _deleteContact(contact);
                        break;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller,
      String label,
      String? Function(String?)? validator,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  bool _hasPrimaryContact() {
    return widget.contacts.any((contact) => contact.isPrimary);
  }

  void _editContact(SupplierContact contact) {
    setState(() {
      _editingContact = contact;
      _showAddForm = true;

      // Fill form with contact data
      _salutationController.text = contact.salutation;
      _firstNameController.text = contact.firstName;
      _lastNameController.text = contact.lastName;
      _positionController.text = contact.position;
      _departmentController.text = contact.department;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _mobileController.text = contact.mobile;
      _selectedContactMethod = contact.preferredContactMethod;
      _receiveTenderNotifications = contact.receiveTenderNotifications;
      _receiveNewsletters = contact.receiveNewsletters;
      _isAuthorizedSignatory = contact.isAuthorizedSignatory;
      _canSubmitBids = contact.canSubmitBids;
      _isPrimary = contact.isPrimary;
    });
  }

  void _setPrimaryContact(SupplierContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Primary Contact'),
        content: Text('Set ${contact.firstName} ${contact.lastName} as primary contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSetPrimary(contact.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Primary'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(SupplierContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Delete ${contact.firstName} ${contact.lastName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteContact(contact.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _submitContactForm() {
    if (_formKey.currentState!.validate() && widget.supplier != null) {
      final data = {
        'supplier': widget.supplier!.id,
        'salutation': _salutationController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'position': _positionController.text,
        'department': _departmentController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'mobile': _mobileController.text,
        'preferredContactMethod': _selectedContactMethod,
        'receiveTenderNotifications': _receiveTenderNotifications,
        'receiveNewsletters': _receiveNewsletters,
        'isAuthorizedSignatory': _isAuthorizedSignatory,
        'canSubmitBids': _canSubmitBids,
        'isPrimary': _isPrimary,
      };

      if (_editingContact != null) {
        widget.onUpdateContact(_editingContact!.id, data);
      } else {
        widget.onAddContact(data);
      }

      setState(() {
        _showAddForm = false;
        _editingContact = null;
        _clearForm();
      });
    }
  }

  void _clearForm() {
    _salutationController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _positionController.clear();
    _departmentController.clear();
    _emailController.clear();
    _phoneController.clear();
    _mobileController.clear();
    _selectedContactMethod = 'email';
    _receiveTenderNotifications = true;
    _receiveNewsletters = false;
    _isAuthorizedSignatory = false;
    _canSubmitBids = true;
    _isPrimary = false;
  }

  @override
  void dispose() {
    _salutationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}