import 'package:flutter/material.dart';

import '../../../../models/field_team.dart';

class FieldTeamCard extends StatelessWidget {
  final FieldTeam team;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const FieldTeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with team name and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.groups, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.teamName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          team.teamCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(team.availability.status),
                ],
              ),

              const SizedBox(height: 12),

              // Team details
              Row(
                children: [
                  _buildDetailItem(
                    Icons.people,
                    '${team.totalMembers} members',
                  ),
                  const SizedBox(width: 12),
                  _buildDetailItem(
                    Icons.work,
                    team.department,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Work zones
              if (team.workZones.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  children: team.workZones
                      .take(2)
                      .map((zone) => Chip(
                            label: Text(zone),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Performance and workload
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceIndicator(),
                  ),
                  const SizedBox(width: 8),
                  _buildWorkloadIndicator(),
                ],
              ),

              const SizedBox(height: 8),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Updated ${_formatDate(team.updatedAt)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    tooltip: 'Edit team',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TeamStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: team.performance.overallScore / 100,
                backgroundColor: Colors.grey[200],
                color: team.performance.performanceColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${team.performance.overallScore.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: team.performance.performanceColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkloadIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Workload',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: team.workloadColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: team.workloadColor),
          ),
          child: Text(
            team.workloadStatus,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: team.workloadColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
