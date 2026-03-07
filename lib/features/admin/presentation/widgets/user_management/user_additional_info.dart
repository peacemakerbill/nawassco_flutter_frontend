import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserAdditionalInfo extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserAdditionalInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.cardShadow,
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            ..._buildInfoRows(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.info, color: AdminColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Additional Information',
          style: TextStyle(
            color: AdminColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInfoRows() {
    return [
      _InfoRow(
        icon: Icons.account_balance_wallet,
        label: 'Account Number',
        value: user['accountNumber'] ?? 'Not assigned',
      ),
      _InfoRow(
        icon: Icons.speed,
        label: 'Meter Number',
        value: user['meterNumber'] ?? 'Not assigned',
      ),
      _InfoRow(
        icon: Icons.account_balance,
        label: 'Billing Balance',
        value: '\$${(user['billingBalance'] ?? 0).toStringAsFixed(2)}',
      ),
      _InfoRow(
        icon: Icons.place,
        label: 'Service Zone',
        value: user['serviceZone'] ?? 'Not assigned',
      ),
      _InfoRow(
        icon: Icons.business,
        label: 'Customer Type',
        value: user['customerType'] ?? 'Residential',
      ),
    ];
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AdminColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AdminColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}