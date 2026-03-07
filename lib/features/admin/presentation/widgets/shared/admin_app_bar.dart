import 'package:flutter/material.dart';
import '../../../../public/profile/presentation/widgets/user_avatar.dart';
import '../../constants/admin_colors.dart';

class AdminAppBar extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;
  final String currentRoute;
  final List<Map<String, dynamic>> menuItems;
  final VoidCallback onToggleSidebar;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onLogout;

  const AdminAppBar({
    super.key,
    required this.user,
    required this.isMobile,
    required this.currentRoute,
    required this.menuItems,
    required this.onToggleSidebar,
    required this.onNavigateToProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onToggleSidebar,
              tooltip: 'Toggle Menu',
            ),

          // Page title
          Expanded(
            child: Text(
              menuItems.firstWhere(
                    (item) => item['route'] == currentRoute,
                orElse: () => menuItems.first,
              )['label'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
          ),

          // User profile section
          Row(
            children: [
              // Notifications
              IconButton(
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_outlined),
                ),
                onPressed: () {},
                tooltip: 'Notifications',
              ),

              // User profile with dropdown
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'profile') onNavigateToProfile();
                  if (value == 'logout') onLogout();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      UserAvatar(
                        imageUrl: user['profilePictureUrl'] as String?,
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      if (!isMobile)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user['firstName']} ${user['lastName']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user['email'] ?? 'Administrator',
                              style: TextStyle(
                                color: AdminColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}