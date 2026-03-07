import 'package:flutter/material.dart';

class ManagementViewTabs extends StatefulWidget {
  final String selectedView;
  final Function(String) onViewChanged;
  final int tabControllerIndex;
  final Function(int) onTabChanged;

  const ManagementViewTabs({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
    required this.tabControllerIndex,
    required this.onTabChanged,
  });

  @override
  State<ManagementViewTabs> createState() => _ManagementViewTabsState();
}

class _ManagementViewTabsState extends State<ManagementViewTabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildViewTab('All Reports', 'all'),
          const SizedBox(width: 8),
          _buildViewTab('Pending Approval', 'pending'),
          const SizedBox(width: 8),
          _buildViewTab('Approved', 'approved'),
          const SizedBox(width: 8),
          _buildViewTab('Rejected', 'rejected'),
          const SizedBox(width: 8),
          _buildViewTab('Recent (7 days)', 'recent'),

          const Spacer(),

          // View Toggle
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildViewTab(String label, String value) {
    final isSelected = widget.selectedView == value;
    return GestureDetector(
      onTap: () => widget.onViewChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return ToggleButtons(
      isSelected: [
        widget.tabControllerIndex == 0,
        widget.tabControllerIndex == 1
      ],
      onPressed: widget.onTabChanged,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 16),
              SizedBox(width: 4),
              Text('Grid'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.view_list, size: 16),
              SizedBox(width: 4),
              Text('List'),
            ],
          ),
        ),
      ],
    );
  }
}
