import 'package:flutter/material.dart';
import '../../../../../../models/job_application_model.dart';

class ApplicationTimeline extends StatelessWidget {
  final List<ApplicationStageHistory> stageHistory;
  final List<ReviewHistory> reviewHistory;
  final List<CommunicationEntry> communicationHistory;

  const ApplicationTimeline({
    super.key,
    required this.stageHistory,
    this.reviewHistory = const [],
    this.communicationHistory = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allEvents = <_TimelineEvent>[];

    // Add stage history events
    for (final stage in stageHistory) {
      allEvents.add(_TimelineEvent(
        date: stage.enteredDate,
        title: stage.stageName,
        description: 'Entered stage ${stage.stageNumber}',
        type: _EventType.STAGE,
        status: stage.status,
      ));
    }

    // Add review events
    for (final review in reviewHistory) {
      allEvents.add(_TimelineEvent(
        date: review.reviewDate,
        title: 'Review by ${review.reviewedBy}',
        description: '${review.decision.name} - ${review.comments}',
        type: _EventType.REVIEW,
        rating: review.rating,
      ));
    }

    // Add communication events
    for (final comm in communicationHistory) {
      allEvents.add(_TimelineEvent(
        date: comm.date,
        title: '${comm.type.name} - ${comm.status.name}',
        description: comm.content,
        type: _EventType.COMMUNICATION,
      ));
    }

    // Sort by date
    allEvents.sort((a, b) => b.date.compareTo(a.date));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Timeline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (allEvents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No timeline events yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allEvents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final event = allEvents[index];
                  return _TimelineEventCard(event: event);
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum _EventType { STAGE, REVIEW, COMMUNICATION }

class _TimelineEvent {
  final DateTime date;
  final String title;
  final String description;
  final _EventType type;
  final StageStatus? status;
  final double? rating;

  _TimelineEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.status,
    this.rating,
  });
}

class _TimelineEventCard extends StatelessWidget {
  final _TimelineEvent event;

  const _TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getEventColor() {
      switch (event.type) {
        case _EventType.STAGE:
          return event.status == StageStatus.COMPLETED
              ? Colors.green
              : event.status == StageStatus.FAILED
              ? Colors.red
              : Colors.blue;
        case _EventType.REVIEW:
          return Colors.orange;
        case _EventType.COMMUNICATION:
          return Colors.purple;
      }
    }

    IconData getEventIcon() {
      switch (event.type) {
        case _EventType.STAGE:
          return Icons.flag;
        case _EventType.REVIEW:
          return Icons.star;
        case _EventType.COMMUNICATION:
          return Icons.message;
      }
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getEventColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getEventIcon(),
                size: 20,
                color: getEventColor(),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(event.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < event.rating!.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          event.rating!.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}