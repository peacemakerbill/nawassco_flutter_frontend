import 'package:flutter/material.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_task,
        'label': 'New Task',
        'color': Colors.blue,
        'description': 'Create a new work order',
      },
      {
        'icon': Icons.report_problem,
        'label': 'Report Issue',
        'color': Colors.orange,
        'description': 'Report equipment or safety issue',
      },
      {
        'icon': Icons.inventory_2,
        'label': 'Stock Check',
        'color': Colors.green,
        'description': 'Check inventory levels',
      },
      {
        'icon': Icons.emergency,
        'label': 'Emergency',
        'color': Colors.red,
        'description': 'Report emergency situation',
      },
      {
        'icon': Icons.photo_camera,
        'label': 'Take Photo',
        'color': Colors.purple,
        'description': 'Document work with photos',
      },
      {
        'icon': Icons.note_add,
        'label': 'Add Note',
        'color': Colors.teal,
        'description': 'Add notes to current task',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenHeight < 600 || screenWidth < 350;

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          constraints: BoxConstraints(
            maxHeight: isSmallScreen ? screenHeight * 0.75 : screenHeight * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              // FIX: Use Expanded instead of Flexible and enable scrolling
              Expanded(
                child: GridView.builder(
                  shrinkWrap: false, // Changed to false for proper scrolling
                  physics: const ClampingScrollPhysics(), // Better for modal bottom sheets
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(screenWidth),
                    crossAxisSpacing: isSmallScreen ? 8 : 12,
                    mainAxisSpacing: isSmallScreen ? 8 : 12,
                    childAspectRatio: _getChildAspectRatio(screenWidth),
                  ),
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return _buildActionCard(
                      action['icon'] as IconData,
                      action['label'] as String,
                      action['color'] as Color,
                      action['description'] as String,
                      isSmallScreen,
                          () {
                        Navigator.pop(context);
                        _handleAction(action['label'] as String, context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 4; // Large screens: 4 columns
    } else if (screenWidth > 800) {
      return 3; // Medium screens: 3 columns
    } else if (screenWidth > 500) {
      return 3; // Small tablets: 3 columns
    } else if (screenWidth > 350) {
      return 2; // Small phones: 2 columns
    } else {
      return 2; // Very small phones: 2 columns
    }
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 1200) {
      return 1.0; // Wider items for large screens
    } else if (screenWidth > 800) {
      return 0.9;
    } else if (screenWidth > 500) {
      return 0.8;
    } else if (screenWidth > 350) {
      return 0.9; // Taller items for 2-column layout
    } else {
      return 0.8; // More compact for very small screens
    }
  }

  Widget _buildActionCard(
      IconData icon,
      String label,
      Color color,
      String description,
      bool isSmallScreen,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isSmallScreen) ...[
                SizedBox(height: 2),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(String action, BuildContext context) {
    switch (action) {
      case 'New Task':
        _showNewTaskDialog(context);
        break;
      case 'Report Issue':
        _showReportIssueDialog(context);
        break;
      case 'Stock Check':
      // Navigate to inventory
        break;
      case 'Emergency':
        _showEmergencyDialog(context);
        break;
      case 'Take Photo':
      // Open camera
        break;
      case 'Add Note':
        _showAddNoteDialog(context);
        break;
    }
  }

  void _showNewTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New task created')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Issue Type'),
              items: ['Equipment', 'Safety', 'Quality', 'Other']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue reported successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Report'),
          ],
        ),
        content: const Text('This will notify emergency services and your supervisor. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency reported! Help is on the way.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('REPORT EMERGENCY'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextFormField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your notes here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note added successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}