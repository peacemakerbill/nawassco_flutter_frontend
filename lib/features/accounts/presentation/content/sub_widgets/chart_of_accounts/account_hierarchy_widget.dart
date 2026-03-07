import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class AccountHierarchyWidget extends ConsumerWidget {
  const AccountHierarchyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartOfAccountsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: state.isLoadingHierarchy && state.accountHierarchy.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.accountHierarchy.isEmpty
          ? _buildEmptyState()
          : _buildHierarchyTree(state.accountHierarchy),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Account Hierarchy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Account hierarchy will appear here once accounts are created',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyTree(List<AccountHierarchy> hierarchy) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_tree, size: 20, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text(
                  'Account Hierarchy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  return ListView.builder(
                    itemCount: hierarchy.length,
                    itemBuilder: (context, index) {
                      return _buildHierarchyNode(hierarchy[index], 0, isMobile);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyNode(AccountHierarchy node, int depth, bool isMobile) {
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: (depth * (isMobile ? 16 : 24)).toDouble()),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              left: depth > 0
                  ? BorderSide(color: Colors.grey[300]!, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expand/Collapse Icon
              SizedBox(
                width: isMobile ? 20 : 24,
                child: hasChildren
                    ? Icon(
                  Icons.arrow_right,
                  color: Colors.grey[600],
                  size: isMobile ? 14 : 16,
                )
                    : null,
              ),

              // Account Icon
              Container(
                width: isMobile ? 28 : 32,
                height: isMobile ? 28 : 32,
                decoration: BoxDecoration(
                  color: _getAccountTypeColor(node.accountType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getAccountTypeIcon(node.accountType),
                  color: _getAccountTypeColor(node.accountType),
                  size: isMobile ? 14 : 16,
                ),
              ),
              const SizedBox(width: 8),

              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            node.accountCode,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getAccountTypeColor(node.accountType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatAccountType(node.accountType),
                              style: TextStyle(
                                color: _getAccountTypeColor(node.accountType),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      node.accountName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (isMobile)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getAccountTypeColor(node.accountType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatAccountType(node.accountType),
                          style: TextStyle(
                            color: _getAccountTypeColor(node.accountType),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Children
        if (hasChildren)
          ...node.children
              .map((child) => _buildHierarchyNode(child, depth + 1, isMobile)),
      ],
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Colors.green;
      case AccountType.liability:
        return Colors.orange;
      case AccountType.equity:
        return Colors.blue;
      case AccountType.revenue:
        return Colors.purple;
      case AccountType.expense:
        return Colors.red;
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Icons.account_balance_wallet;
      case AccountType.liability:
        return Icons.credit_card;
      case AccountType.equity:
        return Icons.people;
      case AccountType.revenue:
        return Icons.trending_up;
      case AccountType.expense:
        return Icons.trending_down;
    }
  }

  String _formatAccountType(AccountType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }
}