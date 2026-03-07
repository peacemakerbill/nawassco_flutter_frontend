import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forum_category.dart';
import '../providers/forum_provider.dart';
import '../widgets/category_card.widget.dart';

class ForumCategoriesScreen extends ConsumerStatefulWidget {
  final Function(String) onCategorySelect;

  const ForumCategoriesScreen({
    super.key,
    required this.onCategorySelect,
  });

  @override
  ConsumerState<ForumCategoriesScreen> createState() => _ForumCategoriesScreenState();
}

class _ForumCategoriesScreenState extends ConsumerState<ForumCategoriesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    ref.read(forumProvider.notifier).fetchCategories();
  }

  List<ForumCategory> _getFilteredCategories(List<ForumCategory> categories) {
    var filtered = categories;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            category.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply type filter
    if (_selectedFilter == 'public') {
      filtered = filtered.where((category) => !category.isPrivate).toList();
    } else if (_selectedFilter == 'private') {
      filtered = filtered.where((category) => category.isPrivate).toList();
    } else if (_selectedFilter == 'active') {
      filtered = filtered.where((category) => category.threadCount > 0).toList();
    }

    // Sort by activity
    filtered.sort((a, b) {
      if (_selectedFilter == 'most_active') {
        return b.threadCount.compareTo(a.threadCount);
      } else if (_selectedFilter == 'newest') {
        return (b.lastActivityAt ?? DateTime.now())
            .compareTo(a.lastActivityAt ?? DateTime.now());
      }
      return a.order.compareTo(b.order);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(forumProvider).categories;
    final isLoading = ref.watch(forumProvider).isLoading;

    final filteredCategories = _getFilteredCategories(categories);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.8),
                      const Color(0xFF0066FF).withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forum Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${categories.length} categories available',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                color: const Color(0xFF0A0E17).withValues(alpha: 0.95),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00CCFF), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Public', 'public'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Private', 'private'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Most Active', 'most_active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Newest', 'newest'),
                  ],
                ),
              ),
            ),
          ),

          // Categories grid
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: const Color(0xFF00CCFF)),
              ),
            )
          else if (filteredCategories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = filteredCategories[index];
                    return CategoryCard(
                      category: category,
                      onTap: () => widget.onCategorySelect(category.id),
                    );
                  },
                  childCount: filteredCategories.length,
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Try a different search term',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Stats summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.6),
                      const Color(0xFF0F172A).withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.forum,
                      '${categories.fold(0, (sum, cat) => sum + cat.threadCount)}',
                      'Total Threads',
                    ),
                    _buildStatItem(
                      Icons.chat_bubble,
                      '${categories.fold(0, (sum, cat) => sum + cat.replyCount)}',
                      'Total Replies',
                    ),
                    _buildStatItem(
                      Icons.lock,
                      '${categories.where((cat) => cat.isPrivate).length}',
                      'Private Categories',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: const Color(0xFF0066FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0066FF) : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0066FF).withValues(alpha: 0.2),
                const Color(0xFF00CCFF).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00CCFF), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}