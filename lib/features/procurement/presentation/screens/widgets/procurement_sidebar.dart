import 'package:flutter/material.dart';
import '../../../../public/profile/presentation/widgets/user_avatar.dart';

class ProcurementSidebar extends StatelessWidget {
  final String currentRoute;
  final List<Map<String, dynamic>> menuItems;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePic;
  final Function(String) onNavigate;
  final VoidCallback onClose;

  const ProcurementSidebar({
    super.key,
    required this.currentRoute,
    required this.menuItems,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePic,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = const Color(0xFF3E76D1);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      imageUrl: profilePic,
                      radius: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $lastName',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.business_center_rounded,
                        size: 16, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'Procurement Department',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final bool isSelected = currentRoute == item['route'];

                return _SidebarMenuItem(
                  icon: item['icon'],
                  label: item['label'],
                  selected: isSelected,
                  primaryColor: primaryColor,
                  onTap: () {
                    onNavigate(item['route']);
                    onClose();
                  },
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Center(
              child: Text(
                '© 2025 Nawassco Portal',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
    widget.selected ? widget.primaryColor : Colors.grey.shade700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: widget.selected
            ? widget.primaryColor.withOpacity(0.12)
            : _hovered
            ? Colors.grey.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(widget.icon, color: color, size: 20),
        title: Text(
          widget.label,
          style: TextStyle(
            color: color,
            fontWeight:
            widget.selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: widget.selected
            ? Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            shape: BoxShape.circle,
          ),
        )
            : null,
        onTap: widget.onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        onFocusChange: (_) => setState(() => _hovered = _),
        onLongPress: widget.onTap,
      ),
    );
  }
}
