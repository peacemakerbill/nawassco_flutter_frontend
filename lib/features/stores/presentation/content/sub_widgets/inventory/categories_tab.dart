import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/inventory/inventory_category_model.dart';
import '../../../../providers/inventory_category_provider.dart';
import 'add_edit_category_dialog.dart';

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({super.key});

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(inventoryCategoryProvider.notifier).getCategories();
    ref.read(inventoryCategoryProvider.notifier).getCategoryHierarchy();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(inventoryCategoryProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // View Toggle
          Row(
            children: [
              FilterChip(
                selected: true,
                label: const Text('Grid View'),
                onSelected: (selected) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: false,
                label: const Text('Hierarchy View'),
                onSelected: (selected) {},
              ),
              const Spacer(),
              FloatingActionButton(
                onPressed: () => _showAddEditCategoryDialog(null),
                mini: true,
                child: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content
          if (categoryState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (categoryState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${categoryState.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (categoryState.categories.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No categories found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first category to organize inventory items',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditCategoryDialog(null),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Category'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: categoryState.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryState.categories[index];
                    return CategoryCard(
                      category: category,
                      onTap: () => _showCategoryDetails(category),
                      onEdit: () => _showAddEditCategoryDialog(category),
                      onDelete: () => _showDeleteDialog(category),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  void _showCategoryDetails(InventoryCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: CategoryDetailsSheet(category: category),
      ),
    );
  }

  void _showAddEditCategoryDialog(InventoryCategory? category) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        onSaved: () => _loadData(),
      ),
    );
  }

  void _showDeleteDialog(InventoryCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(inventoryCategoryProvider.notifier).deleteCategory(category.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.categoryName} deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting category: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final InventoryCategory category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.category, color: Colors.blue, size: 20),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 16),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category Info
              Text(
                category.categoryName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                category.categoryCode,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Characteristics
              if (category.characteristics.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: category.characteristics.take(3).map((char) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      char,
                      style: const TextStyle(fontSize: 10),
                    ),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryDetailsSheet extends StatelessWidget {
  final InventoryCategory category;

  const CategoryDetailsSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Basic Information', [
              _buildInfoRow('Category Code', category.categoryCode),
              _buildInfoRow('Category Name', category.categoryName),
              _buildInfoRow('Parent Category', category.parentCategory ?? 'None'),
              _buildInfoRow('Status', category.isActive ? 'Active' : 'Inactive'),
            ]),

            const SizedBox(height: 16),

            _buildInfoCard('Description', [
              Text(category.description),
            ]),

            if (category.characteristics.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Characteristics', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.characteristics.map((char) => Chip(
                    label: Text(char),
                    backgroundColor: Colors.blue[50],
                  )).toList(),
                ),
              ]),
            ],

            if (category.storageRequirements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Storage Requirements', [
                Column(
                  children: category.storageRequirements.map((req) => ListTile(
                    leading: const Icon(Icons.storage, size: 20),
                    title: Text(req),
                    dense: true,
                  )).toList(),
                ),
              ]),
            ],

            if (category.handlingInstructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Handling Instructions', [
                Column(
                  children: category.handlingInstructions.map((instruction) => ListTile(
                    leading: const Icon(Icons.construction, size: 20),
                    title: Text(instruction),
                    dense: true,
                  )).toList(),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}