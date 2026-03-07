import 'package:flutter/material.dart';

import '../../../../models/sales_representative_model.dart';
import 'custom_widgets.dart';

class SalesRepListWidget extends StatelessWidget {
  final List<SalesRepresentative> salesReps;
  final Function(SalesRepresentative) onSelect;
  final Function(String) onDelete;

  const SalesRepListWidget({
    super.key,
    required this.salesReps,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (salesReps.isEmpty) {
      return EmptyStateWidget(
        title: 'No Sales Representatives',
        description: 'Add your first sales representative to get started.',
        icon: Icons.people_outline,
        onAction: () {
          // This will be handled by parent
        },
        actionText: 'Add Sales Rep',
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ROLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 40), // For action buttons
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: salesReps.length,
              itemBuilder: (context, index) {
                final salesRep = salesReps[index];
                return _buildListItem(salesRep, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(SalesRepresentative salesRep, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(salesRep),
        hoverColor: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SalesRepresentative.getRoleColor(salesRep.salesRole),
                      SalesRepresentative.getRoleColor(salesRep.salesRole)
                          .withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    salesRep.personalDetails.firstName.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and Email
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salesRep.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salesRep.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      salesRep.employeeNumber,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Role
              Expanded(
                child: StatusBadge(
                  status: SalesRepresentative.getRoleDisplayName(
                      salesRep.salesRole),
                  color: SalesRepresentative.getRoleColor(salesRep.salesRole),
                  fontSize: 11,
                ),
              ),

              // Status
              Expanded(
                child: StatusBadge(
                  status:
                      SalesRepresentative.getStatusDisplayName(salesRep.status),
                  color: SalesRepresentative.getStatusColor(salesRep.status),
                  fontSize: 11,
                ),
              ),

              // Action Buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onSelect(salesRep);
                  } else if (value == 'delete') {
                    onDelete(salesRep.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
