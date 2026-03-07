import 'package:flutter/material.dart';
import '../../../../models/customer.model.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelected;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Customer Avatar/Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCustomerColor(customer.customerType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _getCustomerColor(customer.customerType),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getCustomerIcon(customer.customerType),
                      color: _getCustomerColor(customer.customerType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(customer.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(customer.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                customer.status.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(customer.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.customerNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Contact Info
              _buildInfoRow(
                Icons.email_outlined,
                customer.email,
                theme,
              ),
              _buildInfoRow(
                Icons.phone_outlined,
                customer.phone,
                theme,
              ),

              if (customer.primaryAddress != null) ...[
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  '${customer.primaryAddress!.city}, ${customer.primaryAddress!.state}',
                  theme,
                ),
              ],

              const SizedBox(height: 12),

              // Bottom Row - Stats and Actions
              Row(
                children: [
                  // Customer Type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customer.customerType.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Balance
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: customer.hasOverdueBalance
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: customer.hasOverdueBalance
                            ? Colors.red
                            : Colors.green,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      customer.formattedBalance,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: customer.hasOverdueBalance
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Priority Badge
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(customer.priorityLevel),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outlined,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),

              // Active Services/Meters
              if (customer.activeServices.isNotEmpty ||
                  customer.activeMeters.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (customer.activeServices.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.plumbing_outlined,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.activeServices.length} Services',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (customer.activeMeters.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.speed_outlined,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.activeMeters.length} Meters',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCustomerColor(CustomerType type) {
    return switch (type) {
      CustomerType.residential => const Color(0xFF2196F3), // Blue
      CustomerType.commercial => const Color(0xFF4CAF50), // Green
      CustomerType.industrial => const Color(0xFFFF9800), // Orange
      CustomerType.institutional => const Color(0xFF9C27B0), // Purple
      CustomerType.government => const Color(0xFFF44336), // Red
    };
  }

  IconData _getCustomerIcon(CustomerType type) {
    return switch (type) {
      CustomerType.residential => Icons.home_outlined,
      CustomerType.commercial => Icons.business_outlined,
      CustomerType.industrial => Icons.factory_outlined,
      CustomerType.institutional => Icons.school_outlined,
      CustomerType.government => Icons.account_balance_outlined,
    };
  }

  Color _getStatusColor(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.active => const Color(0xFF4CAF50), // Green
      CustomerStatus.prospect => const Color(0xFF2196F3), // Blue
      CustomerStatus.inactive => const Color(0xFF9E9E9E), // Grey
      CustomerStatus.suspended => const Color(0xFFFF9800), // Orange
      CustomerStatus.blacklisted => const Color(0xFFF44336), // Red
    };
  }

  Color _getPriorityColor(PriorityLevel priority) {
    return switch (priority) {
      PriorityLevel.low => const Color(0xFF4CAF50), // Green
      PriorityLevel.medium => const Color(0xFFFF9800), // Orange
      PriorityLevel.high => const Color(0xFFF44336), // Red
      PriorityLevel.critical => const Color(0xFFD32F2F), // Dark Red
    };
  }
}
