import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/supplier_category_model.dart';
import '../../providers/supplier_category_provider.dart';
import 'sub_widgets/category_form_widget.dart';
import 'sub_widgets/category_list_widget.dart';


class SupplierCategoryManagementContent extends ConsumerStatefulWidget {
  const SupplierCategoryManagementContent({super.key});

  @override
  ConsumerState<SupplierCategoryManagementContent> createState() => _SupplierCategoryManagementContentState();
}

class _SupplierCategoryManagementContentState extends ConsumerState<SupplierCategoryManagementContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load categories when component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierCategoryProvider.notifier).getAllCategories();
      ref.read(supplierCategoryProvider.notifier).getCategoryHierarchy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(supplierCategoryProvider);

    return Column(
      children: [
        // Header
        _buildHeader(),

        // Tabs
        Container(
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
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0066A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0066A1),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'All Categories'),
              Tab(text: 'Add Category'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Categories Tab
              CategoryListWidget(
                categories: categoryState.categories,
                hierarchy: categoryState.categoryHierarchy,
                isLoading: categoryState.isLoading,
                error: categoryState.error,
                onRefresh: () {
                  ref.read(supplierCategoryProvider.notifier).getAllCategories();
                  ref.read(supplierCategoryProvider.notifier).getCategoryHierarchy();
                },
                onEdit: (category) {
                  // Switch to add tab with edit mode
                  _tabController.animateTo(1);
                },
                onDelete: (category) => _showDeleteDialog(category),
              ),

              // Add Category Tab
              CategoryFormWidget(
                categories: categoryState.categories,
                onSubmit: (data) async {
                  final success = await ref.read(supplierCategoryProvider.notifier).createCategory(data);
                  if (success && mounted) {
                    _tabController.animateTo(0); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category created successfully')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Color(0xFF0066A1), size: 24),
                SizedBox(width: 12),
                Text(
                  'Category Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage supplier categories, hierarchy, and evaluation criteria.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(SupplierCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.categoryName}? This will affect suppliers in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierCategoryProvider.notifier).deleteCategory(category.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.categoryName} deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}