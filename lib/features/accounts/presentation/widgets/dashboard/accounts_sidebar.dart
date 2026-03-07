import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../public/auth/providers/auth_provider.dart';
import '../../../../public/profile/presentation/widgets/user_avatar.dart';

class AccountsSidebar extends ConsumerWidget {
  final String currentRoute;
  final List<Map<String, dynamic>> menuItems;
  final Function(String) onNavigate;
  final Function onClose;

  const AccountsSidebar({
    super.key,
    required this.currentRoute,
    required this.menuItems,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;

    // Fix: Access the correct user fields from your User model
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? 'accounts@nawassco.com';

    // Create display name from first and last name
    final String displayName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      displayName = firstName;
    } else if (lastName.isNotEmpty) {
      displayName = lastName;
    } else {
      displayName = 'Accounts User';
    }

    return Material(
      elevation: 8,
      child: Container(
        width: 260,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0066CC),  // Deep blue water
              Color(0xFF0080FF),  // Bright blue
              Color(0xFF66B2FF),  // Light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with user info and close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: profilePic,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Accounts Department',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => onClose(),
                  ),
                ],
              ),
            ),

            // Menu items - takes all available space
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: menuItems.map((item) {
                  final isSelected = currentRoute == item['route'];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                    ),
                    child: ListTile(
                      leading: Icon(item['icon'], color: Colors.white, size: 22),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.circle, color: Colors.white, size: 8)
                          : const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                      onTap: () => onNavigate(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer with system info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Revenue Management System',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}