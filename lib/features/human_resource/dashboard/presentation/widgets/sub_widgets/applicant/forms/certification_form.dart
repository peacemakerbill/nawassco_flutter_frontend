import 'package:flutter/material.dart';
import '../../../../../../models/applicant/certification_model.dart';

class CertificationForm extends StatefulWidget {
  final CertificationModel? certification;
  final Function(CertificationModel) onSubmit;

  const CertificationForm({
    super.key,
    this.certification,
    required this.onSubmit,
  });

  @override
  _CertificationFormState createState() => _CertificationFormState();
}

class _CertificationFormState extends State<CertificationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _issuingAuthorityController;
  late TextEditingController _credentialIdController;
  late TextEditingController _credentialUrlController;
  late TextEditingController _issueDateController;
  late TextEditingController _expiryDateController;
  bool _isVerified = false;
  bool _hasExpiryDate = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.certification?.name ?? '');
    _issuingAuthorityController = TextEditingController(
        text: widget.certification?.issuingAuthority ?? '');
    _credentialIdController =
        TextEditingController(text: widget.certification?.credentialId ?? '');
    _credentialUrlController =
        TextEditingController(text: widget.certification?.credentialUrl ?? '');
    _issueDateController = TextEditingController(
        text: widget.certification != null
            ? widget.certification!.issueDate.toIso8601String().split('T')[0]
            : '');
    _expiryDateController = TextEditingController(
        text: widget.certification?.expiryDate != null
            ? widget.certification!.expiryDate!.toIso8601String().split('T')[0]
            : '');
    _isVerified = widget.certification?.isVerified ?? false;
    _hasExpiryDate = widget.certification?.expiryDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuingAuthorityController.dispose();
    _credentialIdController.dispose();
    _credentialUrlController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _issueDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _expiryDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Certification Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Certification Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_user),
              hintText: 'e.g. AWS Certified Solutions Architect, PMP',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter certification name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Issuing Authority
          TextFormField(
            controller: _issuingAuthorityController,
            decoration: const InputDecoration(
              labelText: 'Issuing Authority',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
              hintText: 'e.g. Amazon Web Services, PMI',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter issuing authority';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Credential ID
          TextFormField(
            controller: _credentialIdController,
            decoration: const InputDecoration(
              labelText: 'Credential ID (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
              hintText: 'e.g. AWS-12345',
            ),
          ),
          const SizedBox(height: 12),

          // Credential URL
          TextFormField(
            controller: _credentialUrlController,
            decoration: const InputDecoration(
              labelText: 'Credential URL (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
              hintText: 'e.g. https://verify.aws/certificate/12345',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),

          // Issue Date
          TextFormField(
            controller: _issueDateController,
            decoration: InputDecoration(
              labelText: 'Issue Date',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectIssueDate(context),
              ),
            ),
            readOnly: true,
            onTap: () => _selectIssueDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select issue date';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Expiry Date Toggle
          Row(
            children: [
              Checkbox(
                value: _hasExpiryDate,
                onChanged: (value) {
                  setState(() {
                    _hasExpiryDate = value ?? false;
                    if (!_hasExpiryDate) {
                      _expiryDateController.clear();
                    }
                  });
                },
              ),
              const Text('Has expiry date'),
            ],
          ),
          const SizedBox(height: 8),

          // Expiry Date
          if (_hasExpiryDate)
            TextFormField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectExpiryDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectExpiryDate(context),
              validator: (value) {
                if (_hasExpiryDate && (value == null || value.isEmpty)) {
                  return 'Please select expiry date';
                }
                return null;
              },
            ),
          if (_hasExpiryDate) const SizedBox(height: 12),

          // Verified Checkbox
          Row(
            children: [
              Checkbox(
                value: _isVerified,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value ?? false;
                  });
                },
              ),
              const Text('Verified'),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final certification = CertificationModel(
                  id: widget.certification?.id,
                  name: _nameController.text,
                  issuingAuthority: _issuingAuthorityController.text,
                  issueDate: DateTime.parse(_issueDateController.text),
                  expiryDate:
                      _hasExpiryDate && _expiryDateController.text.isNotEmpty
                          ? DateTime.parse(_expiryDateController.text)
                          : null,
                  credentialId: _credentialIdController.text.isNotEmpty
                      ? _credentialIdController.text
                      : null,
                  credentialUrl: _credentialUrlController.text.isNotEmpty
                      ? _credentialUrlController.text
                      : null,
                  isVerified: _isVerified,
                );

                widget.onSubmit(certification);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Certification'),
          ),
        ],
      ),
    );
  }
}
