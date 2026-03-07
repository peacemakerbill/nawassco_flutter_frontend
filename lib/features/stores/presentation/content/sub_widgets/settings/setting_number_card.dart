import 'package:flutter/material.dart';

class SettingNumberCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double value;
  final ValueChanged<double> onChanged;
  final ThemeData theme;
  final String? suffix;
  final double min;
  final double max;

  const SettingNumberCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.suffix,
    this.min = 0,
    this.max = 1000,
  });

  @override
  State<SettingNumberCard> createState() => _SettingNumberCardState();
}

class _SettingNumberCardState extends State<SettingNumberCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(SettingNumberCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= widget.min && parsed <= widget.max) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: widget.suffix,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.theme.dividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: _updateValue,
            ),
          ),
        ],
      ),
    );
  }
}