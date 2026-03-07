import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(String) onAction;

  const UserCard({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onSelect,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user['isActive'] ?? false;
    final isEmailVerified = user['isEmailVerified'] ?? false;
    final isArchived = user['isArchived'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AdminColors.primary : AdminColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Selection Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 16),

              // User Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AdminColors.primary.withOpacity(0.1),
                ),
                child: user['profilePictureUrl'] != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePictureUrl']!),
                )
                    : Icon(
                  Icons.person,
                  color: AdminColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user['firstName']} ${user['lastName']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? 'No email',
                      style: TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _StatusChip(
                          label: isActive ? 'Active' : 'Inactive',
                          color: isActive ? AdminColors.success : AdminColors.error,
                        ),
                        if (isEmailVerified)
                          _StatusChip(
                            label: 'Verified',
                            color: AdminColors.info,
                          ),
                        if (isArchived)
                          _StatusChip(
                            label: 'Archived',
                            color: AdminColors.warning,
                          ),
                        if (user['roles'] != null)
                          ...(user['roles'] as List<dynamic>).map((role) => _StatusChip(
                            label: role.toString(),
                            color: AdminColors.primary,
                          )),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (action) => onAction(action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit User'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: isActive ? 'deactivate' : 'activate',
                    child: Row(
                      children: [
                        Icon(isActive ? Icons.toggle_off : Icons.toggle_on, size: 18),
                        SizedBox(width: 8),
                        Text(isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: isEmailVerified ? 'unverify' : 'verify',
                    child: Row(
                      children: [
                        Icon(isEmailVerified ? Icons.verified : Icons.verified_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(isEmailVerified ? 'Unverify Email' : 'Verify Email'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: isArchived ? 'unarchive' : 'archive',
                    child: Row(
                      children: [
                        Icon(isArchived ? Icons.unarchive : Icons.archive, size: 18),
                        SizedBox(width: 8),
                        Text(isArchived ? 'Unarchive' : 'Archive'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}