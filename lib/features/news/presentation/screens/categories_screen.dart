import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/category_provider.dart';
import '../../data/models/news_category.dart';
import '../widgets/category_chip.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await ref.read(categoryProvider.notifier).fetchCategories();
  }

  void _onSearch(String query) {
    ref.read(categoryProvider.notifier).searchCategories(query);
  }

  void _showCreateCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final colorController = TextEditingController(text: '#007bff');
    final iconController = TextEditingController(text: 'newspaper');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (Hex)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createCategory(
                  name: nameController.text,
                  description: descriptionController.text,
                  color: colorController.text,
                  icon: iconController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory({
    required String name,
    required String description,
    required String color,
    required String icon,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
    };

    await ref.read(categoryProvider.notifier).createCategory(data);
  }

  void _showCategoryDetails(NewsCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryDetailSheet(category: category),
    );
  }

  void _toggleCategoryActive(String id) {
    ref.read(categoryProvider.notifier).toggleCategoryActive(id);
  }

  void _deleteCategory(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(categoryProvider.notifier).deleteCategory(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.displayCategories;
    final activeCategories = categories.where((c) => c.isActive).toList();
    final inactiveCategories = categories.where((c) => !c.isActive).toList();

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
                          hintText: 'Search categories...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setState(() => _showInactive = !_showInactive);
                      },
                      icon: Icon(
                        _showInactive ? Icons.visibility_off : Icons.visibility,
                        color: _showInactive ? Colors.blue : Colors.grey,
                      ),
                      tooltip: 'Show/Hide Inactive',
                    ),
                    IconButton(
                      onPressed: _loadCategories,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats summary
                _buildCategoryStats(categoryState),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (activeCategories.isNotEmpty)
                    _buildCategorySection('Active Categories',
                        activeCategories.cast<NewsCategory>()),
                  if (inactiveCategories.isNotEmpty && _showInactive)
                    _buildCategorySection('Inactive Categories',
                        inactiveCategories.cast<NewsCategory>()),
                  if (categories.isEmpty && !categoryState.isLoading)
                    _buildEmptyState(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryStats(CategoryState state) {
    final totalCategories = state.categories.length;
    final activeCount = state.categories.where((c) => c.isActive).length;
    final inactiveCount = totalCategories - activeCount;

    return Row(
      children: [
        _buildStatChip('Total', totalCategories.toString(), Icons.category),
        const SizedBox(width: 12),
        _buildStatChip(
            'Active', activeCount.toString(), Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatChip(
            'Inactive', inactiveCount.toString(), Icons.cancel, Colors.orange),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon,
      [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<NewsCategory> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories
              .map((category) => CategoryChip(
                    category: category,
                    showStats: true,
                    onTap: () => _showCategoryDetails(category),
                    onDelete: () => _deleteCategory(category.id, category.name),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No categories found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create categories to organize your news articles',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Category'),
          ),
        ],
      ),
    );
  }
}

class CategoryDetailSheet extends ConsumerWidget {
  final NewsCategory category;

  const CategoryDetailSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.categoryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.categoryIcon,
                  color: category.categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      category.slug,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Details
          _buildDetailItem('Description', category.description),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildDetailChip('Color', category.color),
              const SizedBox(width: 12),
              _buildDetailChip('Icon', category.icon),
              const SizedBox(width: 12),
              _buildDetailChip('Order', category.order.toString()),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildStatusChip('Active', category.isActive, Colors.green),
              const SizedBox(width: 12),
              _buildStatusChip('Featured', category.isFeatured, Colors.amber),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          if (category.stats != null) _buildCategoryStats(category.stats!),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to edit screen
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(categoryProvider.notifier)
                        .toggleCategoryActive(category.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        category.isActive ? Colors.orange : Colors.green,
                  ),
                  icon: Icon(
                      category.isActive ? Icons.block : Icons.check_circle),
                  label: Text(category.isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(CategoryStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
                'Total News', stats.newsCount.toString(), Icons.article),
            _buildStatCard('Published', stats.publishedCount.toString(),
                Icons.public, Colors.green),
            _buildStatCard('Drafts', stats.draftCount.toString(), Icons.drafts,
                Colors.orange),
            _buildStatCard('Total Views', stats.totalViews.toString(),
                Icons.remove_red_eye, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      [Color? color]) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color ?? Colors.grey),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
