import 'package:flutter/material.dart';

class ForumSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final String hintText;

  const ForumSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.hintText = 'Search threads, topics, or users...',
  });

  @override
  State<ForumSearchBar> createState() => _ForumSearchBarState();
}

class _ForumSearchBarState extends State<ForumSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: widget.onSearch,
                onSubmitted: widget.onSearch,
              ),
            ),
            if (_hasText)
              IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear();
                },
                icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.5), size: 20),
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }
}