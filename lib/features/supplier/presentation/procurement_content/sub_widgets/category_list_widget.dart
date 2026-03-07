import 'package:flutter/material.dart';

import '../../../models/supplier_category_model.dart';

class CategoryListWidget extends StatelessWidget {
  final List<SupplierCategory> categories;
  final List<dynamic> hierarchy;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(SupplierCategory) onEdit;
  final Function(SupplierCategory) onDelete;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.hierarchy,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              labelColor: const Color(0xFF0066A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0066A1),
              tabs: const [
                Tab(text: 'List View'),
                Tab(text: 'Hierarchy View'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                // List View
                _buildListView(),
                // Hierarchy View
                _buildHierarchyView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No categories found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
      ),
    );
  }

  Widget _buildCategoryCard(SupplierCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${category.categoryCode}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(category.description),
                    ],
                  ),
                ),
                _buildLevelBadge(category.level),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.nawasscoSpecific)
                  const Chip(
                    label: Text('NAWASSCO Specific'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                Chip(
                  label: Text('Level ${category.level}'),
                  backgroundColor: Colors.green[50],
                ),
                Chip(
                  label: Text('${category.mandatoryDocuments.length} required docs'),
                  backgroundColor: Colors.orange[50],
                ),
                Chip(
                  label: Text('KES ${category.averageContractValue.toStringAsFixed(0)} avg. contract'),
                  backgroundColor: Colors.purple[50],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment Terms: ${category.paymentTermsDefault} days',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                IconButton(
                  onPressed: () => onEdit(category),
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => onDelete(category),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    final colors = [Colors.grey, Colors.blue, Colors.green, Colors.orange, Colors.red];
    final color = level < colors.length ? colors[level - 1] : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Level $level',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHierarchyView() {
    if (hierarchy.isEmpty) {
      return const Center(
        child: Text('No hierarchy data available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hierarchy.length,
      itemBuilder: (context, index) => _buildHierarchyNode(hierarchy[index], 0),
    );
  }

  Widget _buildHierarchyNode(Map<String, dynamic> node, int depth) {
    final hasSubcategories = (node['subcategories'] as List).isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: (depth * 24).toDouble()),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node['categoryName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          node['categoryCode'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasSubcategories)
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        if (hasSubcategories)
          ...(node['subcategories'] as List).map((subcategory) =>
              _buildHierarchyNode(subcategory, depth + 1)
          ).toList(),
      ],
    );
  }
}