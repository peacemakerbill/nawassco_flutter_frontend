import 'package:flutter/material.dart';
import '../../constants/admin_colors.dart';

class MoreOptionsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;

  const MoreOptionsBottomSheet({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final itemHeight = 56.0;
    final headerHeight = 120.0;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'More Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: items.map(
                      (item) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'], color: AdminColors.primary),
                    ),
                    title: Text(
                      item['label'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => onItemSelected(item['route']),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}