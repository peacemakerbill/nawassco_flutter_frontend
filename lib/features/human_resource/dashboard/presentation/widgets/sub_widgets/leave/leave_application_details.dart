import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../../models/leave/leave_application.dart';
import '../../../../../providers/leave_provider.dart';

class LeaveApplicationDetails extends ConsumerWidget {
  final LeaveApplication application;

  const LeaveApplicationDetails({
    super.key,
    required this.application,
  });

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: application.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: application.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            application.statusIcon,
            size: 18,
            color: application.statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            application.statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: application.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leave Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: application.leaveBalanceAfter < 5
                      ? Colors.orange[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${application.leaveBalanceAfter} days remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: application.leaveBalanceAfter < 5
                        ? Colors.orange[800]
                        : Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: application.leaveBalanceAfter /
                (application.leaveBalanceBefore + application.totalDays),
            backgroundColor: Colors.grey[200],
            color: application.leaveBalanceAfter < 5
                ? Colors.orange
                : Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Before: ${application.leaveBalanceBefore}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'After: ${application.leaveBalanceAfter}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final canManage =
        ref.read(authProvider).hasAnyRole(['Admin', 'HR', 'Manager']);

    if (canManage && application.isPending) {
      return Column(
        children: [
          const Divider(height: 32),
          const Text(
            'Manager Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showApproveDialog(context, ref),
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectDialog(context, ref),
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (application.canCancel) {
      return Column(
        children: [
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, ref),
              icon: const Icon(Icons.cancel, size: 20),
              label: const Text('Cancel Application'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[700]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Leave Application'),
        content: const Text(
            'Are you sure you want to approve this leave application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ref.read(leaveProvider.notifier).updateLeaveStatus(
                        applicationId: application.id,
                        status: LeaveStatus.approved,
                      );

              if (success) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success =
                    await ref.read(leaveProvider.notifier).updateLeaveStatus(
                          applicationId: application.id,
                          status: LeaveStatus.rejected,
                          rejectionReason: reasonController.text.trim(),
                        );

                if (success) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Leave Application'),
        content: const Text(
            'Are you sure you want to cancel this leave application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(leaveProvider.notifier)
                  .cancelLeave(application.id);

              if (success) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                application.leaveType.icon,
                size: 24,
                color: application.leaveType.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.leaveType.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      application.leaveNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 24),

          // Employee Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Employee',
                  application.employeeName,
                  icon: Icons.person,
                ),
                _buildInfoRow(
                  'Employee Number',
                  application.employeeNumber,
                  icon: Icons.badge,
                ),
                _buildInfoRow(
                  'Department',
                  application.department,
                  icon: Icons.business,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Leave Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leave Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Start Date',
                        application.formattedStartDate,
                        icon: Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        'End Date',
                        application.formattedEndDate,
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
                _buildInfoRow(
                  'Total Days',
                  '${application.totalDays} ${application.totalDays == 1 ? 'day' : 'days'}',
                  icon: Icons.date_range,
                ),
                _buildInfoRow(
                  'Applied On',
                  application.formattedAppliedDate,
                  icon: Icons.access_time,
                ),
                if (application.approvedDate != null)
                  _buildInfoRow(
                    '${application.isApproved ? 'Approved' : 'Rejected'} On',
                    application.formattedApprovedDate,
                    icon: application.isApproved
                        ? Icons.check_circle
                        : Icons.cancel,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Balance Indicator
          _buildBalanceIndicator(),

          const SizedBox(height: 24),

          // Reason
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason for Leave',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  application.reason,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

          // Additional Information
          if (application.emergencyContact != null ||
              application.handoverNotes != null ||
              application.urgentTasks.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (application.emergencyContact != null)
                    _buildInfoRow(
                      'Emergency Contact',
                      application.emergencyContact!,
                      icon: Icons.phone,
                    ),
                  if (application.handoverNotes != null)
                    _buildInfoRow(
                      'Handover Notes',
                      application.handoverNotes!,
                      icon: Icons.note,
                    ),
                  if (application.handoverToName != null)
                    _buildInfoRow(
                      'Handover To',
                      application.handoverToName!,
                      icon: Icons.person_add,
                    ),
                  if (application.urgentTasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Urgent Tasks:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...application.urgentTasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),

          // Action Buttons
          _buildActionButtons(context, ref),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
