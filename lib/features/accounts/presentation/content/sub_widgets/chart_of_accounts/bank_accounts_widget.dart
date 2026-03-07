import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/chart_of_account_model.dart';
import '../../../../providers/chart_of_accounts_provider.dart';

class BankAccountsWidget extends ConsumerWidget {
  const BankAccountsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartOfAccountsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: state.isLoadingBankAccounts && state.bankAccounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.bankAccounts.isEmpty
          ? _buildEmptyState()
          : _buildBankAccountsGrid(state.bankAccounts),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Bank Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bank accounts will appear here once they are configured',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountsGrid(List<ChartOfAccount> bankAccounts) {
    return Column(
      children: [
        // Header
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Bank Accounts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${bankAccounts.length} accounts',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final crossAxisCount = isMobile ? 1 : 2;
              final childAspectRatio = isMobile ? 1.5 : 1.8;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: bankAccounts.length,
                itemBuilder: (context, index) {
                  return _buildBankAccountCard(bankAccounts[index], isMobile);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountCard(ChartOfAccount account, bool isMobile) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: isMobile ? 36 : 40,
                  height: isMobile ? 36 : 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance,
                    color: Colors.blue[700],
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 14 : 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        account.accountCode,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Bank Details
            if (account.bankAccountNumber != null)
              _buildDetailRow('Account Number', account.bankAccountNumber!, isMobile),
            if (account.bankName != null)
              _buildDetailRow('Bank Name', account.bankName!, isMobile),

            const Spacer(),

            // Status
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: isMobile ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: account.isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: account.isActive
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (account.budgetAllowed)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Budget Allowed',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 80 : 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}