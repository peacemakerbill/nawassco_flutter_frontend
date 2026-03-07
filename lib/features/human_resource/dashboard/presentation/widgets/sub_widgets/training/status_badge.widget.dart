import 'package:flutter/material.dart';
import '../../../../../models/training.model.dart';

class StatusBadge extends StatelessWidget {
  final TrainingStatus status;
  final double size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: 60,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case TrainingStatus.planned:
        return Colors.blue.shade400;
      case TrainingStatus.open_for_registration:
        return Colors.green.shade400;
      case TrainingStatus.confirmed:
        return Colors.teal.shade400;
      case TrainingStatus.in_progress:
        return Colors.orange.shade400;
      case TrainingStatus.completed:
        return Colors.purple.shade400;
      case TrainingStatus.cancelled:
        return Colors.red.shade400;
      }
  }
}