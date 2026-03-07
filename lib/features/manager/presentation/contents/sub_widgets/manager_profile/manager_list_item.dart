import 'package:flutter/material.dart';

import '../../../../models/manager_model.dart';

class ManagerListItem extends StatelessWidget {
  final ManagerModel manager;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ManagerListItem({
    super.key,
    required this.manager,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
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
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getRoleColor(manager.managementRole),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        manager.personalDetails.firstName
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manager.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          manager.jobTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: manager.isActive
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: manager.isActive
                            ? Colors.green.shade300
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      manager.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: manager.isActive
                            ? Colors.green.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Details row
              Row(
                children: [
                  _buildDetailItem(
                    icon: Icons.badge,
                    label: manager.employeeNumber,
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    icon: Icons.group,
                    label: '${manager.teamSize} team members',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    icon: Icons.work,
                    label: Department.display(manager.department),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Approval limits summary
              Row(
                children: [
                  _buildApprovalChip(
                    'Expense: ${_formatCurrency(manager.approvalLimits.financial.expenseApproval)}',
                    Colors.blue.shade100,
                    Colors.blue.shade800,
                  ),
                  const SizedBox(width: 8),
                  _buildApprovalChip(
                    'Hiring: ${_formatCurrency(manager.approvalLimits.humanResources.hiring)}',
                    Colors.green.shade100,
                    Colors.green.shade800,
                  ),
                  if (manager.signingAuthority.canSignContracts) ...[
                    const SizedBox(width: 8),
                    _buildApprovalChip(
                      'Contract Signing',
                      Colors.purple.shade100,
                      Colors.purple.shade800,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons
              if (onEdit != null || onDelete != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case ManagementRole.ceo:
        return Colors.purple;
      case ManagementRole.managingDirector:
        return Colors.deepPurple;
      case ManagementRole.executiveDirector:
        return Colors.indigo;
      case ManagementRole.departmentDirector:
        return Colors.blue;
      case ManagementRole.seniorManager:
        return Colors.teal;
      case ManagementRole.manager:
        return Colors.green;
      case ManagementRole.teamLead:
        return Colors.orange;
      case ManagementRole.supervisor:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
