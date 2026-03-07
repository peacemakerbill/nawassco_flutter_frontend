import 'package:flutter/material.dart';
import '../../../../../../models/applicant/portfolio_model.dart';

class PortfolioForm extends StatefulWidget {
  final PortfolioModel? portfolio;
  final Function(PortfolioModel) onSubmit;

  const PortfolioForm({
    super.key,
    this.portfolio,
    required this.onSubmit,
  });

  @override
  _PortfolioFormState createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<PortfolioForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _usernameController;
  String _platform = 'linkedin';
  bool _isPrimary = false;

  final List<String> _platforms = [
    'linkedin',
    'github',
    'behance',
    'dribble',
    'personal_website',
    'medium',
    'stack_overflow',
    'other'
  ];

  final Map<String, String> _platformHints = {
    'linkedin': 'https://linkedin.com/in/username',
    'github': 'https://github.com/username',
    'behance': 'https://behance.net/username',
    'dribble': 'https://dribbble.com/username',
    'personal_website': 'https://yourwebsite.com',
    'medium': 'https://medium.com/@username',
    'stack_overflow': 'https://stackoverflow.com/users/id/username',
    'other': 'https://example.com'
  };

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.portfolio?.url ?? '');
    _usernameController =
        TextEditingController(text: widget.portfolio?.username ?? '');
    _platform = widget.portfolio?.platform ?? 'linkedin';
    _isPrimary = widget.portfolio?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String _getPlatformName(String platform) {
    switch (platform) {
      case 'linkedin':
        return 'LinkedIn';
      case 'github':
        return 'GitHub';
      case 'behance':
        return 'Behance';
      case 'dribble':
        return 'Dribbble';
      case 'personal_website':
        return 'Personal Website';
      case 'medium':
        return 'Medium';
      case 'stack_overflow':
        return 'Stack Overflow';
      case 'other':
        return 'Other';
      default:
        return platform.replaceAll('_', ' ').toUpperCase();
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'linkedin':
        return Icons.business;
      case 'github':
        return Icons.code;
      case 'behance':
        return Icons.design_services;
      case 'dribble':
        return Icons.brush;
      case 'personal_website':
        return Icons.public;
      case 'medium':
        return Icons.article;
      case 'stack_overflow':
        return Icons.question_answer;
      case 'other':
        return Icons.link;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Platform Selection
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(
              labelText: 'Platform',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.apps),
            ),
            items: _platforms.map((platform) {
              return DropdownMenuItem(
                value: platform,
                child: Row(
                  children: [
                    Icon(_getPlatformIcon(platform), size: 20),
                    const SizedBox(width: 8),
                    Text(_getPlatformName(platform)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _platform = value!;
                // Update URL hint and auto-fill if possible
                final username = _usernameController.text;
                if (username.isNotEmpty &&
                    _platform != 'personal_website' &&
                    _platform != 'other') {
                  final baseUrl = _platformHints[value]!
                      .replaceFirst('/username', '/$username');
                  _urlController.text = baseUrl;
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a platform';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Username/Identifier
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: _platform == 'personal_website'
                  ? 'Website Name'
                  : 'Username/ID',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_platform == 'personal_website'
                  ? Icons.public
                  : Icons.person),
              hintText: _getUsernameHint(_platform),
            ),
            onChanged: (value) {
              // Auto-generate URL for certain platforms
              if (value.isNotEmpty &&
                  _platform != 'personal_website' &&
                  _platform != 'other' &&
                  !_urlController.text.contains(value)) {
                final baseUrl = _platformHints[_platform]!
                    .replaceFirst('/username', '/$value');
                _urlController.text = baseUrl;
              }
            },
          ),
          const SizedBox(height: 12),

          // URL
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'URL',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
              hintText: _platformHints[_platform],
            ),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter URL';
              }
              if (!Uri.parse(value).isAbsolute) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Primary Portfolio Checkbox
          Row(
            children: [
              Checkbox(
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value ?? false;
                  });
                },
              ),
              const Text('Primary Portfolio Link'),
            ],
          ),
          const SizedBox(height: 20),

          // Platform Preview
          if (_platform != 'other' && _urlController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200] ?? Colors.grey),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(_platform).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPlatformIcon(_platform),
                      color: _getPlatformColor(_platform),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPlatformName(_platform),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _urlController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_platform != 'other' && _urlController.text.isNotEmpty)
            const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final portfolio = PortfolioModel(
                  id: widget.portfolio?.id,
                  platform: _platform,
                  url: _urlController.text,
                  username: _usernameController.text.isNotEmpty
                      ? _usernameController.text
                      : null,
                  isPrimary: _isPrimary,
                );

                widget.onSubmit(portfolio);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Portfolio Link'),
          ),
        ],
      ),
    );
  }

  String _getUsernameHint(String platform) {
    switch (platform) {
      case 'linkedin':
        return 'e.g. john-doe-12345';
      case 'github':
        return 'e.g. johndoe';
      case 'behance':
        return 'e.g. johndoe';
      case 'dribble':
        return 'e.g. johndoe';
      case 'personal_website':
        return 'e.g. John Doe Portfolio';
      case 'medium':
        return 'e.g. @johndoe';
      case 'stack_overflow':
        return 'e.g. 12345/johndoe';
      case 'other':
        return 'Identifier or description';
      default:
        return 'Username';
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'github':
        return const Color(0xFF333333);
      case 'behance':
        return const Color(0xFF0057FF);
      case 'dribble':
        return const Color(0xFFEA4C89);
      case 'personal_website':
        return const Color(0xFF4285F4);
      case 'medium':
        return const Color(0xFF00AB6C);
      case 'stack_overflow':
        return const Color(0xFFF48024);
      case 'other':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
