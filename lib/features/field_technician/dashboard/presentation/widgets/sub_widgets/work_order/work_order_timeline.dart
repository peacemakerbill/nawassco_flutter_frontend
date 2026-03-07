import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';

class WorkOrderTimeline extends StatelessWidget {
  final WorkOrder workOrder;

  const WorkOrderTimeline({super.key, required this.workOrder});

  @override
  Widget build(BuildContext context) {
    final timelineEvents = _buildTimelineEvents();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timelineEvents.length,
      itemBuilder: (context, index) => _buildTimelineItem(timelineEvents[index], index),
    );
  }

  List<TimelineEvent> _buildTimelineEvents() {
    final events = <TimelineEvent>[];
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    events.add(TimelineEvent(
      title: 'Work Order Created',
      description: 'Work order was created in the system',
      date: workOrder.createdAt,
      icon: Icons.add_circle,
      color: Colors.blue,
      isCompleted: true,
    ));

    events.add(TimelineEvent(
      title: 'Scheduled',
      description: 'Work order scheduled for ${dateFormat.format(workOrder.scheduledDate)}',
      date: workOrder.scheduledDate,
      icon: Icons.calendar_today,
      color: Colors.orange,
      isCompleted: workOrder.status.index >= WorkOrderStatus.scheduled.index,
    ));

    if (workOrder.assignedTechnicianIds.isNotEmpty) {
      events.add(TimelineEvent(
        title: 'Assigned to Technicians',
        description: 'Assigned to ${workOrder.assignedTechnicianNames.length} technician(s)',
        date: workOrder.updatedAt,
        icon: Icons.people,
        color: Colors.purple,
        // Use scheduled status as the baseline since assignment typically happens after scheduling
        isCompleted: workOrder.status.index >= WorkOrderStatus.scheduled.index,
      ));
    }

    if (workOrder.actualStartDate != null) {
      events.add(TimelineEvent(
        title: 'Work Started',
        description: 'Technician started the work',
        date: workOrder.actualStartDate!,
        icon: Icons.play_arrow,
        color: Colors.green,
        isCompleted: true,
      ));
    }

    final completedTasks = workOrder.tasks.where((task) => task.status == TaskStatus.completed).toList();
    for (final task in completedTasks.take(3)) {
      if (task.completedAt != null) {
        events.add(TimelineEvent(
          title: 'Task Completed: ${task.task}',
          description: 'Task marked as completed',
          date: task.completedAt!,
          icon: Icons.check_circle,
          color: Colors.green,
          isCompleted: true,
        ));
      }
    }

    if (workOrder.actualEndDate != null) {
      events.add(TimelineEvent(
        title: 'Work Completed',
        description: workOrder.completionNotes ?? 'Work order completed successfully',
        date: workOrder.actualEndDate!,
        icon: Icons.check_circle,
        color: Colors.green,
        isCompleted: true,
      ));
    }

    events.sort((a, b) => b.date.compareTo(a.date));

    return events;
  }

  Widget _buildTimelineItem(TimelineEvent event, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color.withOpacity(event.isCompleted ? 0.1 : 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.color.withOpacity(event.isCompleted ? 0.3 : 0.1),
                  ),
                ),
                child: Icon(
                  event.icon,
                  size: 20,
                  color: event.isCompleted ? event.color : event.color.withOpacity(0.3),
                ),
              ),
              if (index != _buildTimelineEvents().length - 1)
                Container(
                  width: 2,
                  height: 16,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(top: 4),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: event.isCompleted ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (!event.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(event.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
}