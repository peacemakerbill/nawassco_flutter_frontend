import 'package:flutter/material.dart';

class SettingDropdownCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final bool isText;

  const SettingDropdownCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.options = const [],
    required this.onChanged,
    required this.theme,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isText)
            SizedBox(
              width: 150,
              child: TextField(
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            )
          else
            DropdownButton<String>(
              value: value,
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}