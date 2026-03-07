import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final Map<String, String> filters;
  final Function(String) onFilterChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSearchChanged;

  // horizontal controller so we can attach a scrollbar
  final ScrollController _chipsScrollController = ScrollController();

  UserSearchFilter({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.onClearSearch,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClearSearch,
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => onSearchChanged(),
        ),
        const SizedBox(height: 12),

        // Horizontal chips: ListView + Scrollbar for reliable horizontal scrolling on web/desktop
        SizedBox(
          height: 48, // larger height for chips + comfortable hit area
          child: Scrollbar(
            controller: _chipsScrollController,
            thumbVisibility: true, // show thumb so users know it's scrollable
            child: ListView.separated(
              controller: _chipsScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final entry = filters.entries.elementAt(index);
                final isSelected = selectedFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: FilterChip(
                    label: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                    selected: isSelected,
                    onSelected: (_) => onFilterChanged(entry.key),
                    backgroundColor: Colors.transparent,
                    selectedColor: AdminColors.primary.withOpacity(0.1),
                    checkmarkColor: AdminColors.primary,
                    labelStyle: TextStyle(
                      color:
                      isSelected ? AdminColors.primary : AdminColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AdminColors.primary : AdminColors.border,
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
