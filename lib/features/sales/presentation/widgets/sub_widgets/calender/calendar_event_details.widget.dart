import 'package:flutter/material.dart';

import '../../../../models/calendar.model.dart';

class CalendarEventDetails extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const CalendarEventDetails({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: onClose,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),

          // Event Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: event.type.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: event.type.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: event.status.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        event.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: event.status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Event Number
                Text(
                  'Event #${event.eventNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),

                // Type and Priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.type.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: event.type.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(event.type.icon, size: 14, color: event.type.color),
                          const SizedBox(width: 6),
                          Text(
                            event.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: event.type.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.priority.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: event.priority.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        event.priority.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: event.priority.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                _buildSectionTitle('Description'),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Details Grid
                _buildSectionTitle('Event Details'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  children: [
                    _buildDetailItem(
                      Icons.calendar_today,
                      'Start Date',
                      _formatDateTime(event.startDate),
                    ),
                    _buildDetailItem(
                      Icons.calendar_today,
                      'End Date',
                      _formatDateTime(event.endDate),
                    ),
                    if (event.location != null)
                      _buildDetailItem(
                        Icons.location_on,
                        'Location',
                        event.location!,
                      ),
                    _buildDetailItem(
                      Icons.timer,
                      'Duration',
                      event.duration,
                    ),
                    _buildDetailItem(
                      Icons.person,
                      'All Day',
                      event.allDay ? 'Yes' : 'No',
                    ),
                    if (event.organizerName != null)
                      _buildDetailItem(
                        Icons.person,
                        'Organizer',
                        event.organizerName!,
                      ),
                    if (event.attendeeNames.isNotEmpty)
                      _buildDetailItem(
                        Icons.people,
                        'Attendees',
                        '${event.attendeeNames.length} people',
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Attendees
                if (event.attendeeNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Attendees'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: event.attendeeNames.map((name) => Chip(
                          label: Text(name),
                          backgroundColor: const Color(0xFFE5E7EB),
                          labelStyle: const TextStyle(fontSize: 12),
                        )).toList(),
                      ),
                    ],
                  ),

                // Related Entities
                if (_hasRelatedEntities(event))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle('Related Entities'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (event.customerName != null)
                            _buildEntityChip(
                              Icons.person,
                              'Customer: ${event.customerName}',
                              const Color(0xFF10B981),
                            ),
                          if (event.leadName != null)
                            _buildEntityChip(
                              Icons.leaderboard,
                              'Lead: ${event.leadName}',
                              const Color(0xFF3B82F6),
                            ),
                          if (event.opportunityNumber != null)
                            _buildEntityChip(
                              Icons.trending_up,
                              'Opportunity: ${event.opportunityNumber}',
                              const Color(0xFF8B5CF6),
                            ),
                          if (event.quoteNumber != null)
                            _buildEntityChip(
                              Icons.request_quote,
                              'Quote: ${event.quoteNumber}',
                              const Color(0xFFF59E0B),
                            ),
                          if (event.proposalNumber != null)
                            _buildEntityChip(
                              Icons.description,
                              'Proposal: ${event.proposalNumber}',
                              const Color(0xFFEC4899),
                            ),
                        ],
                      ),
                    ],
                  ),

                // Outcome Section
                if (event.outcome != null || event.rating != null || event.feedback != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle('Outcome'),
                      if (event.outcome != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildDetailItem(
                            Icons.assessment,
                            'Outcome',
                            event.outcome!,
                          ),
                        ),
                      if (event.outcomeNotes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.outcomeNotes!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.rating != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Rating: ${event.rating}/5',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.feedback != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Feedback:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.feedback!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                // Cancellation Reason
                if (event.isCancelled && event.cancellationReason != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.cancel, color: Color(0xFFDC2626)),
                                SizedBox(width: 8),
                                Text(
                                  'Cancelled',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${event.cancellationReason!}',
                              style: const TextStyle(
                                color: Color(0xFF7F1D1D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Metadata
                const SizedBox(height: 24),
                _buildSectionTitle('Metadata'),
                const SizedBox(height: 8),
                _buildDetailItem(
                  Icons.person,
                  'Created By',
                  event.createdByName ?? 'Unknown',
                ),
                _buildDetailItem(
                  Icons.calendar_today,
                  'Created On',
                  _formatDate(event.createdAt),
                ),
                _buildDetailItem(
                  Icons.update,
                  'Last Updated',
                  _formatDate(event.updatedAt),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('EDIT'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('DELETE'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntityChip(IconData icon, String label, Color color) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: color),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  bool _hasRelatedEntities(CalendarEvent event) {
    return event.customerName != null ||
        event.leadName != null ||
        event.opportunityNumber != null ||
        event.quoteNumber != null ||
        event.proposalNumber != null;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}