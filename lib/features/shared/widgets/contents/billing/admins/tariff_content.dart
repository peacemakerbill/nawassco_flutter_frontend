import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/tariff_model.dart';
import '../../../../providers/tariff_provider.dart';
import '../../../sub_widgets/tariff/tariff_list_widget.dart';

class TariffContent extends ConsumerWidget {
  const TariffContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user is authenticated
    if (!authState.isAuthenticated) {
      return _buildUnauthorizedView(context);
    }

    // Check if user has permission to view tariffs
    final canViewTariffs = authState.hasAnyRole([
      'Admin', 'Manager', 'Accounts', 'SalesAgent',
      'User', 'Technician', 'StoreManager'
    ]);

    if (!canViewTariffs) {
      return _buildNoPermissionView(context);
    }

    return const TariffManagementView();
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please sign in to access tariff management',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // Navigate to login page
                // Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPermissionView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You do not have permission to access tariff management',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                // Navigate to dashboard
                // Navigator.of(context).pushNamed('/dashboard');
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class TariffManagementView extends ConsumerWidget {
  const TariffManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final canManage = authState.isAdmin || authState.isManager;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Stats Bar (for admins/managers)
            if (canManage) _buildQuickStatsBar(ref),

            // Main Content
            Expanded(
              child: TariffListWidget(
                showActions: true,
                onTariffSelected: () {
                  // Handle tariff selection if needed
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsBar(WidgetRef ref) {
    final state = ref.watch(tariffProvider);
    final notifier = ref.read(tariffProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'Total Tariffs',
                value: state.statistics?.totalTariffs.toString() ?? '--',
                color: Colors.blue,
                onTap: () => notifier.getStatistics(),
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStatItem(
                label: 'Active',
                value: state.statistics?.activeTariffs.toString() ?? '--',
                color: Colors.green,
                onTap: () {
                  notifier.updateFilter(
                    TariffFilter(isActive: true),
                  );
                  notifier.fetchTariffs();
                },
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStatItem(
                label: 'Pending Approval',
                value: '--', // You might want to add this to statistics
                color: Colors.orange,
                onTap: () {
                  notifier.updateFilter(
                    TariffFilter(isApproved: false, isActive: true),
                  );
                  notifier.fetchTariffs();
                },
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStatItem(
                label: 'Expiring Soon',
                value: state.statistics?.expiringThisMonth.toString() ?? '--',
                color: Colors.red,
                onTap: () {
                  notifier.getExpiringTariffs();
                  // Show expiring tariffs dialog
                  _showExpiringTariffsDialog(context as BuildContext, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpiringTariffsDialog(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tariffProvider);
    final expiring = state.expiringTariffs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tariffs Expiring Soon'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          child: expiring == null || expiring.isEmpty
              ? const Center(
            child: Text('No tariffs expiring soon'),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: expiring.length,
            itemBuilder: (context, index) {
              final tariff = expiring[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(tariff.name),
                subtitle: Text(
                  'Expires: ${tariff.effectiveTo != null ? "${tariff.effectiveTo!.day}/${tariff.effectiveTo!.month}/${tariff.effectiveTo!.year}" : "N/A"}',
                ),
                trailing: Text('${tariff.daysUntilEffective} days'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}