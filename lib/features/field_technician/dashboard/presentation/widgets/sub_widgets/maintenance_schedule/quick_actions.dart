import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onCreateSchedule;
  final VoidCallback onViewOverdue;
  final VoidCallback onViewUpcoming;
  final VoidCallback onGenerateReport;

  const QuickActions({
    super.key,
    required this.onCreateSchedule,
    required this.onViewOverdue,
    required this.onViewUpcoming,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide ? _buildWideActions() : _buildNarrowActions();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideActions() {
    return Row(
      children: [
        Expanded(child: _buildActionItem('Create Schedule', Icons.add_circle, Colors.blue, onCreateSchedule)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionItem('View Overdue', Icons.warning, Colors.red, onViewOverdue)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionItem('Upcoming', Icons.schedule, Colors.orange, onViewUpcoming)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionItem('Generate Report', Icons.analytics, Colors.green, onGenerateReport)),
      ],
    );
  }

  Widget _buildNarrowActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionItem('Create Schedule', Icons.add_circle, Colors.blue, onCreateSchedule)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionItem('View Overdue', Icons.warning, Colors.red, onViewOverdue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionItem('Upcoming', Icons.schedule, Colors.orange, onViewUpcoming)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionItem('Generate Report', Icons.analytics, Colors.green, onGenerateReport)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}