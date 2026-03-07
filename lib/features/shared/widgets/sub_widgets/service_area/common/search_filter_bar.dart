import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search service areas...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: onSearchChanged,
              controller: TextEditingController(text: searchQuery)
                ..selection = TextSelection.collapsed(offset: searchQuery.length),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onFilterPressed,
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filter',
          ),
        ],
      ),
    );
  }
}