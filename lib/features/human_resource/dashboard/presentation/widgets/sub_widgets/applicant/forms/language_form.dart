import 'package:flutter/material.dart';
import '../../../../../../models/applicant/language_model.dart';

class LanguageForm extends StatefulWidget {
  final LanguageModel? language;
  final Function(LanguageModel) onSubmit;

  const LanguageForm({
    super.key,
    this.language,
    required this.onSubmit,
  });

  @override
  _LanguageFormState createState() => _LanguageFormState();
}

class _LanguageFormState extends State<LanguageForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _languageController;
  late TextEditingController _certificateController;
  String _proficiency = 'intermediate';
  bool _isNative = false;

  final List<String> _proficiencies = [
    'beginner',
    'elementary',
    'intermediate',
    'upper_intermediate',
    'advanced',
    'proficient',
    'native'
  ];

  final List<String> _commonLanguages = [
    'English',
    'Swahili',
    'French',
    'Spanish',
    'German',
    'Arabic',
    'Chinese',
    'Hindi',
    'Japanese',
    'Korean',
    'Portuguese',
    'Russian',
    'Italian'
  ];

  @override
  void initState() {
    super.initState();
    _languageController =
        TextEditingController(text: widget.language?.language ?? '');
    _certificateController =
        TextEditingController(text: widget.language?.certificate ?? '');
    _proficiency = widget.language?.proficiency ?? 'intermediate';
    _isNative = widget.language?.isNative ?? false;
  }

  @override
  void dispose() {
    _languageController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Language Name with Autocomplete
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _languageController.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return _commonLanguages;
              }
              return _commonLanguages.where((String option) {
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _languageController.text = selection;
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              _languageController = fieldTextEditingController;
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a language';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Proficiency Level
          DropdownButtonFormField<String>(
            value: _proficiency,
            decoration: const InputDecoration(
              labelText: 'Proficiency Level',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.star),
            ),
            items: _proficiencies.map((proficiency) {
              return DropdownMenuItem(
                value: proficiency,
                child: Text(_getProficiencyName(proficiency)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _proficiency = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select proficiency level';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Native Speaker Checkbox
          Row(
            children: [
              Checkbox(
                value: _isNative,
                onChanged: (value) {
                  setState(() {
                    _isNative = value ?? false;
                    if (_isNative) {
                      _proficiency = 'native';
                    }
                  });
                },
              ),
              const Text('Native Speaker'),
            ],
          ),
          const SizedBox(height: 12),

          // Certificate
          TextFormField(
            controller: _certificateController,
            decoration: const InputDecoration(
              labelText: 'Certificate (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified),
              hintText: 'e.g. TOEFL, IELTS, DELE',
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final language = LanguageModel(
                  id: widget.language?.id,
                  language: _languageController.text,
                  proficiency: _proficiency,
                  isNative: _isNative,
                  certificate: _certificateController.text.isNotEmpty
                      ? _certificateController.text
                      : null,
                );

                widget.onSubmit(language);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Language'),
          ),
        ],
      ),
    );
  }

  String _getProficiencyName(String proficiency) {
    switch (proficiency) {
      case 'beginner':
        return 'Beginner (A1)';
      case 'elementary':
        return 'Elementary (A2)';
      case 'intermediate':
        return 'Intermediate (B1)';
      case 'upper_intermediate':
        return 'Upper Intermediate (B2)';
      case 'advanced':
        return 'Advanced (C1)';
      case 'proficient':
        return 'Proficient (C2)';
      case 'native':
        return 'Native Speaker';
      default:
        return proficiency.replaceAll('_', ' ').toUpperCase();
    }
  }
}
