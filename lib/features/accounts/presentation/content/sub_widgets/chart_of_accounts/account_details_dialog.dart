import 'package:flutter/material.dart';
import '../../../../models/chart_of_account_model.dart';

class AccountDetailsDialog extends StatelessWidget {
  final ChartOfAccount account;

  const AccountDetailsDialog({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAccountTypeIcon(account.accountType),
                      color: _getAccountTypeColor(account.accountType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${account.accountCode} - ${account.accountName}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatAccountType(account.accountType),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic Information
                      _buildInfoSection(
                        title: 'Basic Information',
                        icon: Icons.info,
                        children: [
                          _buildInfoRow('Account Code', account.accountCode),
                          _buildInfoRow('Account Name', account.accountName),
                          _buildInfoRow('Account Type', _formatAccountType(account.accountType)),
                          _buildInfoRow('Account Category', _formatAccountCategory(account.accountCategory)),
                          _buildInfoRow('Description', account.description),
                          _buildInfoRow('Level', 'Level ${account.level}'),
                          _buildInfoRow('Normal Balance', _formatNormalBalance(account.normalBalance)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Status & Settings
                      _buildInfoSection(
                        title: 'Status & Settings',
                        icon: Icons.settings,
                        children: [
                          _buildStatusRow('Active', account.isActive),
                          _buildStatusRow('System Account', account.isSystemAccount),
                          _buildStatusRow('Budget Allowed', account.budgetAllowed),
                          _buildStatusRow('Requires Approval', account.requiresApproval),
                          if (account.requiresApproval)
                            _buildInfoRow('Approval Limit', 'KES ${account.approvalLimit?.toStringAsFixed(2)}'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tax Information
                      _buildInfoSection(
                        title: 'Tax Information',
                        icon: Icons.receipt,
                        children: [
                          _buildStatusRow('Tax Applicable', account.taxApplicable),
                          if (account.taxApplicable && account.taxRate != null)
                            _buildInfoRow('Tax Rate', '${account.taxRate}%'),
                        ],
                      ),

                      // Banking Information (if applicable)
                      if (account.isBankAccount) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          title: 'Banking Information',
                          icon: Icons.account_balance,
                          children: [
                            if (account.bankAccountNumber != null)
                              _buildInfoRow('Account Number', account.bankAccountNumber!),
                            if (account.bankName != null)
                              _buildInfoRow('Bank Name', account.bankName!),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Metadata
                      _buildInfoSection(
                        title: 'Metadata',
                        icon: Icons.history,
                        children: [
                          _buildInfoRow('Created', _formatDate(account.createdAt)),
                          _buildInfoRow('Last Updated', _formatDate(account.updatedAt)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: value ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value ? Colors.green : Colors.red, width: 1),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                color: value ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset: return Colors.green;
      case AccountType.liability: return Colors.orange;
      case AccountType.equity: return Colors.blue;
      case AccountType.revenue: return Colors.purple;
      case AccountType.expense: return Colors.red;
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.asset: return Icons.account_balance_wallet;
      case AccountType.liability: return Icons.credit_card;
      case AccountType.equity: return Icons.people;
      case AccountType.revenue: return Icons.trending_up;
      case AccountType.expense: return Icons.trending_down;
    }
  }

  String _formatAccountType(AccountType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  String _formatAccountCategory(AccountCategory category) {
    return category.name.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatNormalBalance(NormalBalance balance) {
    return balance.name[0].toUpperCase() + balance.name.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}