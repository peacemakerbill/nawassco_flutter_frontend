import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class UserProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final String id;

  const UserProfileHeader({super.key, required this.user, required this.id});

  @override
  Widget build(BuildContext context) {
    final isActive = user['isActive'] ?? false;
    final isEmailVerified = user['isEmailVerified'] ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.lightBlue.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.elevatedShadow,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileImage(isActive),
              const SizedBox(height: 20),
              _buildUserInfo(),
              const SizedBox(height: 20),
              _buildStatusBadges(isEmailVerified),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isActive) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.lightBlue.shade600],
            ),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AdminColors.surface,
            child: CircleAvatar(
              radius: 44,
              backgroundImage: user['profilePictureUrl'] != null
                  ? NetworkImage(user['profilePictureUrl']!)
                  : const AssetImage('assets/default-avatar.png') as ImageProvider,
              backgroundColor: Colors.blue.shade50,
              child: user['profilePictureUrl'] == null
                  ? Icon(Icons.person, color: Colors.blue.shade300, size: 40)
                  : null,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade600 : Colors.red.shade400,
            shape: BoxShape.circle,
            border: Border.all(color: AdminColors.surface, width: 3),
            boxShadow: AdminColors.cardShadow,
          ),
          child: Icon(
            isActive ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          '${user['firstName']} ${user['lastName']}',
          style: const TextStyle(
            color: AdminColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          user['email'] ?? 'No email provided',
          style: TextStyle(
            color: AdminColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user['phoneNumber'] ?? 'No phone number',
          style: TextStyle(
            color: AdminColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(bool isEmailVerified) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (user['roles'] != null)
          ...(user['roles'] as List<dynamic>).map((role) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: _getRoleGradient(role),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AdminColors.cardShadow,
            ),
            child: Text(
              role.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isEmailVerified
                ? LinearGradient(
              colors: [Colors.green.shade500, Colors.green.shade700],
            )
                : LinearGradient(
              colors: [Colors.orange.shade500, Colors.orange.shade700],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: AdminColors.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isEmailVerified ? Icons.verified : Icons.warning,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                isEmailVerified ? 'Verified' : 'Unverified',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LinearGradient _getRoleGradient(String role) {
    switch (role) {
      case 'Admin':
        return LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade800],
        );
      case 'SalesAgent':
        return LinearGradient(
          colors: [Colors.orange.shade500, Colors.orange.shade700],
        );
      case 'Accounts':
        return LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
        );
      case 'Manager':
        return LinearGradient(
          colors: [Colors.purple.shade500, Colors.purple.shade700],
        );
      case 'HR':
        return LinearGradient(
          colors: [Colors.pink.shade500, Colors.pink.shade700],
        );
      case 'Procurement':
        return LinearGradient(
          colors: [Colors.teal.shade500, Colors.teal.shade700],
        );
      case 'Supplier':
        return LinearGradient(
          colors: [Colors.blueGrey.shade500, Colors.blueGrey.shade700],
        );
      case 'Technician':
        return LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        );
      default: // User
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.lightBlue.shade600],
        );
    }
  }
}