import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/department.dart';
import '../../../../../providers/department_provider.dart';
import '../../../../../utils/department_constants.dart';


class DepartmentHierarchyWidget extends ConsumerWidget {
  const DepartmentHierarchyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(departmentProvider);
    final hierarchy = state.hierarchy;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization Structure',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visual representation of department hierarchy and reporting structure',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            if (hierarchy.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_tree,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hierarchy data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hierarchy.length,
                itemBuilder: (context, index) =>
                    _buildHierarchyNode(hierarchy[index], 0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyNode(DepartmentHierarchy node, int depth) {
    final color = Color(int.parse(
      DepartmentConstants.getDepartmentColor(node.departmentCode)
          .replaceAll('#', '0xFF'),
    ));

    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      DepartmentConstants.getDepartmentIcon(node.departmentCode),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.departmentCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (node.headName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                node.headName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (node.employeeCount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.people, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${node.employeeCount} employees',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (node.children.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${node.children.length} sub-departments',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (node.children.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 24),
              height: 1,
              color: Colors.grey[200],
            ),
          const SizedBox(height: 8),
          ...node.children.map((child) => _buildHierarchyNode(child, depth + 1)),
          if (depth == 0) const SizedBox(height: 16),
        ],
      ),
    );
  }
}