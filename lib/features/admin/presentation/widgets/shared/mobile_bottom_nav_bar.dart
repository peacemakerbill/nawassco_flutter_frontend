import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class MobileBottomNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> visibleTabs;
  final List<Map<String, dynamic>> moreTabs;
  final int currentIndex;
  final Function(String) onTabSelected;
  final VoidCallback onMoreSelected;

  const MobileBottomNavBar({
    super.key,
    required this.visibleTabs,
    required this.moreTabs,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onMoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        onTap: (index) {
          if (index == 4 && moreTabs.isNotEmpty) {
            onMoreSelected();
          } else if (index < visibleTabs.length) {
            final route = visibleTabs[index]['route'];
            onTabSelected(route);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AdminColors.primary,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        items: [
          ...visibleTabs
              .map(
                (item) => BottomNavigationBarItem(
              icon: Icon(item['icon']),
              label: item['label'],
            ),
          )
              .toList(),
          if (moreTabs.isNotEmpty)
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
        ],
      ),
    );
  }
}