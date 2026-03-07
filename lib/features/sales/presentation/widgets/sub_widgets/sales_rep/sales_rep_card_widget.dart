import 'package:flutter/material.dart';

import '../../../../models/sales_representative_model.dart';
import 'status_badge.dart';

class SalesRepCardWidget extends StatelessWidget {
  final SalesRepresentative salesRep;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SalesRepCardWidget({
    super.key,
    required this.salesRep,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          SalesRepresentative.getRoleColor(salesRep.salesRole),
                          SalesRepresentative.getRoleColor(salesRep.salesRole).withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        salesRep.personalDetails.firstName.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salesRep.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(
                              status: SalesRepresentative.getRoleDisplayName(salesRep.salesRole),
                              color: SalesRepresentative.getRoleColor(salesRep.salesRole),
                              fontSize: 10,
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(
                              status: SalesRepresentative.getStatusDisplayName(salesRep.status),
                              color: SalesRepresentative.getStatusColor(salesRep.status),
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Menu
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact Info
              _buildInfoRow(Icons.email, salesRep.email),
              _buildInfoRow(Icons.phone, salesRep.phone),
              _buildInfoRow(Icons.badge, salesRep.employeeNumber),

              const SizedBox(height: 16),

              // Performance Stats
              _buildPerformanceStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    final performance = salesRep.performance;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Performance Stats',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Sales', 'KES ${performance.totalSales.toStringAsFixed(2)}'),
              _buildStatItem('Conversion', '${performance.conversionRate.toStringAsFixed(1)}%'),
              _buildStatItem('Rating', '${performance.overallRating.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}