import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/category_provider.dart';
import '../widgets/news_card.dart';
import '../../data/providers/news_provider.dart';
import '../../data/models/news_article.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';
  String _sortBy = 'publishedAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    await ref.read(newsProvider.notifier).fetchNews();
  }

  void _onSearch(String query) {
    ref.read(newsProvider.notifier).searchNews(query);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedCategory = 'all';
    _selectedStatus = 'all';
    ref.read(newsProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider);
    final news = newsState.displayNews;

    return Scaffold(
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search news...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filter',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quick filters
                _buildQuickFilters(),
              ],
            ),
          ),

          // News list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNews,
              child: news.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final article = news[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NewsCard(
                            article: article,
                            onTap: () {
                              // Navigate to detail
                            },
                            onEdit: () {
                              // Navigate to editor
                            },
                            onDelete: () {
                              _showDeleteDialog(article);
                            },
                            onToggleFeatured: () {
                              ref
                                  .read(newsProvider.notifier)
                                  .toggleFeatured(article.id);
                            },
                            onPublish: article.isPublished
                                ? null
                                : () {
                                    ref
                                        .read(newsProvider.notifier)
                                        .publishNews(article.id);
                                  },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to editor
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedStatus == 'all',
            onSelected: (selected) {
              setState(() => _selectedStatus = 'all');
              ref.read(newsProvider.notifier).clearFilters();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Published'),
            selected: _selectedStatus == 'published',
            onSelected: (selected) {
              setState(() => _selectedStatus = 'published');
              // Filter published news
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Drafts'),
            selected: _selectedStatus == 'drafts',
            onSelected: (selected) {
              setState(() => _selectedStatus = 'drafts');
              // Filter drafts
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pending'),
            selected: _selectedStatus == 'pending',
            onSelected: (selected) {
              setState(() => _selectedStatus = 'pending');
              // Filter pending
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Featured'),
            selected: _selectedStatus == 'featured',
            onSelected: (selected) {
              setState(() => _selectedStatus = 'featured');
              // Filter featured
            },
          ),
          const SizedBox(width: 8),
          if (_searchController.text.isNotEmpty || _selectedStatus != 'all')
            ActionChip(
              label: const Text('Clear Filters'),
              onPressed: _clearFilters,
              backgroundColor: Colors.grey[100],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 24),

          // Category filter
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildCategoryFilter(),
          const SizedBox(height: 16),

          // Status filter
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildStatusFilter(),
          const SizedBox(height: 16),

          // Sort options
          const Text(
            'Sort By',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildSortOptions(),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ref.watch(categoryProvider).categories;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All Categories'),
          selected: _selectedCategory == 'all',
          onSelected: (selected) => setState(() => _selectedCategory = 'all'),
        ),
        ...categories
            .take(5)
            .map((category) => FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategory == category.id,
                  onSelected: (selected) =>
                      setState(() => _selectedCategory = category.id),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: _selectedStatus == 'all',
          onSelected: (selected) => setState(() => _selectedStatus = 'all'),
        ),
        FilterChip(
          label: const Text('Published'),
          selected: _selectedStatus == 'published',
          onSelected: (selected) =>
              setState(() => _selectedStatus = 'published'),
        ),
        FilterChip(
          label: const Text('Draft'),
          selected: _selectedStatus == 'draft',
          onSelected: (selected) => setState(() => _selectedStatus = 'draft'),
        ),
        FilterChip(
          label: const Text('Pending Review'),
          selected: _selectedStatus == 'pending',
          onSelected: (selected) => setState(() => _selectedStatus = 'pending'),
        ),
        FilterChip(
          label: const Text('Scheduled'),
          selected: _selectedStatus == 'scheduled',
          onSelected: (selected) =>
              setState(() => _selectedStatus = 'scheduled'),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Newest First'),
          value: 'publishedAt',
          groupValue: _sortBy,
          onChanged: (value) => setState(() {
            _sortBy = value!;
            _sortDescending = true;
          }),
        ),
        RadioListTile<String>(
          title: const Text('Oldest First'),
          value: 'publishedAt_asc',
          groupValue: _sortBy,
          onChanged: (value) => setState(() {
            _sortBy = value!;
            _sortDescending = false;
          }),
        ),
        RadioListTile<String>(
          title: const Text('Most Viewed'),
          value: 'views',
          groupValue: _sortBy,
          onChanged: (value) => setState(() {
            _sortBy = value!;
            _sortDescending = true;
          }),
        ),
        RadioListTile<String>(
          title: const Text('Most Liked'),
          value: 'likes',
          groupValue: _sortBy,
          onChanged: (value) => setState(() {
            _sortBy = value!;
            _sortDescending = true;
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.newspaper, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No news articles found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Create your first news article',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NewsArticle article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News Article'),
        content: Text('Are you sure you want to delete "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(newsProvider.notifier).deleteNews(article.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
