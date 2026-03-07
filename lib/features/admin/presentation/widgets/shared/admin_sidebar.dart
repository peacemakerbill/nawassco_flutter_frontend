import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class AdminSidebar extends StatelessWidget {
  final bool isOpen;
  final String currentRoute;
  final Function(String) onNavigate;
  final VoidCallback? onToggle;

  const AdminSidebar({
    super.key,
    required this.isOpen,
    required this.currentRoute,
    required this.onNavigate,
    this.onToggle,
  });

  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/admin/dashboard'},
    {'icon': Icons.people, 'label': 'User Management', 'route': '/admin/users'},
    {'icon': Icons.receipt_long, 'label': 'Billing & Revenue', 'route': '/admin/controller'},
    {'icon': Icons.water_drop, 'label': 'Water Operations', 'route': '/admin/operations'},
    {'icon': Icons.support_agent, 'label': 'Service Requests', 'route': '/admin/services'},
    {'icon': Icons.analytics, 'label': 'Analytics & Reports', 'route': '/admin/analytics'},
    {'icon': Icons.settings, 'label': 'System Settings', 'route': '/admin/settings'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Material(
      elevation: 8,
      child: Container(
        width: isMobile ? 280 : 280,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AdminColors.surface,
          border: Border(right: BorderSide(color: AdminColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminColors.border)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/nawassco_logo.png',
                    height: isMobile ? 28 : 32,
                    width: isMobile ? 28 : 32,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.water_drop, color: AdminColors.primary, size: isMobile ? 28 : 32),
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Text(
                      'NAWASSCO Admin',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                  ),
                  if (onToggle != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onToggle,
                      iconSize: isMobile ? 18 : 20,
                    ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                children: _menuItems.map((item) => _SidebarMenuItem(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                  route: item['route'] as String,
                  isSelected: currentRoute == item['route'],
                  onTap: () => onNavigate(item['route']),
                  isMobile: isMobile,
                )).toList(),
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AdminColors.border)),
              ),
              child: Column(
                children: [
                  Text(
                    'NAWASSCO Admin v1.0',
                    style: TextStyle(
                      color: AdminColors.textLight,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    '© 2024 All rights reserved',
                    style: TextStyle(
                      color: AdminColors.textLight,
                      fontSize: isMobile ? 8 : 10,
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

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMobile;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 2 : 4),
      decoration: BoxDecoration(
        color: isSelected ? AdminColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AdminColors.primary.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AdminColors.primary : AdminColors.textSecondary,
          size: isMobile ? 18 : 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AdminColors.primary : AdminColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      ),
    );
  }
}