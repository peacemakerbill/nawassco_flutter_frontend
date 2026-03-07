import 'package:flutter/material.dart';

import '../../../../models/reports/report_feedback_model.dart';

class FeedbackItem extends StatelessWidget {
  final ReportFeedback feedback;

  const FeedbackItem({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  feedback.reviewerName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (feedback.reviewerTitle != null)
                      Text(
                        feedback.reviewerTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                    feedback.actionRequired ? 'Action Required' : 'Comment'),
                backgroundColor: feedback.actionRequired
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: feedback.actionRequired ? Colors.orange : Colors.grey,
                  fontSize: 12,
                ),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feedback.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                feedback.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
