import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';

class StageProgressIndicator extends StatelessWidget {
  final int currentStage;
  final int totalStages;
  final List<ApplicationStageHistory> stageHistory;
  final double height;
  final double indicatorSize;
  final bool showLabels;
  final bool showDates;
  final Color? activeColor;
  final Color? inactiveColor;

  const StageProgressIndicator({
    super.key,
    required this.currentStage,
    this.totalStages = 8,
    this.stageHistory = const [],
    this.height = 80,
    this.indicatorSize = 32,
    this.showLabels = true,
    this.showDates = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor =
        inactiveColor ?? theme.colorScheme.surfaceVariant;
    final progress = currentStage.clamp(1, totalStages) / totalStages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar with stage indicators
        SizedBox(
          height: height,
          child: Stack(
            children: [
              // Background track
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.symmetric(horizontal: indicatorSize / 2),
                    decoration: BoxDecoration(
                      color: effectiveInactiveColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Progress fill
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(left: indicatorSize / 2),
                      decoration: BoxDecoration(
                        color: effectiveActiveColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // Stage indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalStages, (index) {
                  final stageNumber = index + 1;
                  final isCurrent = stageNumber == currentStage;
                  final isCompleted = stageNumber < currentStage;
                  final isUpcoming = stageNumber > currentStage;
                  final stageHistoryItem = stageHistory.isNotEmpty
                      ? stageHistory.firstWhere(
                          (item) => item.stageNumber == stageNumber,
                          orElse: () => ApplicationStageHistory(
                            stageNumber: stageNumber,
                            stageName: _getStageName(stageNumber),
                            enteredDate: DateTime.now(),
                          ),
                        )
                      : null;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stage indicator circle
                      Container(
                        width: indicatorSize,
                        height: indicatorSize,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? effectiveActiveColor
                              : isCurrent
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? effectiveActiveColor
                                : isCurrent
                                    ? effectiveActiveColor
                                    : effectiveInactiveColor,
                            width: isCurrent ? 3 : 2,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: effectiveActiveColor.withValues(
                                        alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: indicatorSize * 0.5,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : Text(
                                  '$stageNumber',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: isCurrent
                                        ? effectiveActiveColor
                                        : effectiveInactiveColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Stage label
                      if (showLabels) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Column(
                            children: [
                              Text(
                                _getStageName(stageNumber),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isCompleted || isCurrent
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),

                              // Stage date if available
                              if (showDates && stageHistoryItem != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(stageHistoryItem.enteredDate),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),

        // Progress text
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stage $currentStage of $totalStages',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: effectiveActiveColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStageName(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return 'Applied';
      case 2:
        return 'Screening';
      case 3:
        return 'Shortlisted';
      case 4:
        return 'Interview';
      case 5:
        return 'Technical';
      case 6:
        return 'Reference';
      case 7:
        return 'Offer';
      case 8:
        return 'Hired';
      default:
        return 'Stage $stageNumber';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7}w ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
