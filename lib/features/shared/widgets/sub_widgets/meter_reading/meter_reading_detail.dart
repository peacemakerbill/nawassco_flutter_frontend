import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/meter_reading_model.dart';
import '../../../providers/meter_reading_provider.dart';

class MeterReadingDetail extends ConsumerWidget {
  final MeterReading reading;

  const MeterReadingDetail({super.key, required this.reading});

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Reading'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for rejecting this reading:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Enter rejection reason',
                ),
                maxLines: 3,
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
                if (reasonController.text.isNotEmpty) {
                  ref
                      .read(meterReadingProvider.notifier)
                      .rejectReading(reading.id, reasonController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(meterReadingProvider.notifier);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 24,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            reading.meterNumber,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reading ID: ${reading.id.substring(0, 8)}...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      if (reading.canEdit)
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),

                      if (reading.canVerify)
                        ElevatedButton.icon(
                          onPressed: () => provider.verifyReading(reading.id),
                          icon: const Icon(Icons.verified),
                          label: const Text('Verify'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),

                      if (reading.canReject)
                        OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(context, ref),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),

                      if (reading.canGenerateBill)
                        ElevatedButton.icon(
                          onPressed: () => provider.generateBill(reading.id),
                          icon: const Icon(Icons.receipt),
                          label: const Text('Generate Bill'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Main Content Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 :
            MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // Reading Details Card
              _buildDetailCard(
                title: 'Reading Details',
                icon: Icons.water_drop,
                children: [
                  _buildDetailItem('Current Reading',
                      '${reading.currentReading.toStringAsFixed(2)} m³'),
                  if (reading.previousReading != null)
                    _buildDetailItem('Previous Reading',
                        '${reading.previousReading!.toStringAsFixed(2)} m³'),
                  _buildDetailItem('Consumption',
                      '${reading.consumption.toStringAsFixed(2)} m³'),
                  _buildDetailItem('Reading Date',
                      dateFormat.format(reading.readingDate)),
                  _buildDetailItem('Reading Month', reading.readingMonth),
                ],
              ),

              // Status & Type Card
              _buildDetailCard(
                title: 'Status & Type',
                icon: Icons.info,
                children: [
                  _buildDetailItem('Status', reading.readingStatus.name,
                      isHighlighted: true,
                      color: reading.isVerified ? Colors.green :
                      reading.isRejected ? Colors.red :
                      reading.isProcessed ? Colors.blue : Colors.orange),
                  _buildDetailItem('Reading Type', reading.readingType.name),
                  _buildDetailItem('Reading Method', reading.readingMethod.name),
                  _buildDetailItem('Estimated', reading.isEstimated ? 'Yes' : 'No'),
                  if (reading.estimationReason != null)
                    _buildDetailItem('Estimation Reason', reading.estimationReason!),
                ],
              ),

              // Reader & Verification Card
              _buildDetailCard(
                title: 'Reader & Verification',
                icon: Icons.person,
                children: [
                  if (reading.readerName != null)
                    _buildDetailItem('Reader', reading.readerName!),
                  if (reading.readerId != null)
                    _buildDetailItem('Reader ID', reading.readerId!),
                  _buildDetailItem('Verified', reading.readingVerified ? 'Yes' : 'No'),
                  if (reading.verifiedBy != null)
                    _buildDetailItem('Verified By', reading.verifiedBy!),
                  if (reading.verifiedAt != null)
                    _buildDetailItem('Verified At',
                        dateFormat.format(reading.verifiedAt!)),
                ],
              ),

              // Billing Information Card
              _buildDetailCard(
                title: 'Billing Information',
                icon: Icons.receipt,
                children: [
                  _buildDetailItem('Bill Generated',
                      reading.billGenerated ? 'Yes' : 'No'),
                  if (reading.billNumber != null)
                    _buildDetailItem('Bill Number', reading.billNumber!),
                  if (reading.billId != null)
                    _buildDetailItem('Bill ID', reading.billId!),
                  _buildDetailItem('Disputed', reading.isDisputed ? 'Yes' : 'No'),
                  if (reading.disputeReason != null)
                    _buildDetailItem('Dispute Reason', reading.disputeReason!),
                ],
              ),

              // Audit Trail Card
              _buildDetailCard(
                title: 'Audit Trail',
                icon: Icons.history,
                children: [
                  _buildDetailItem('Created At',
                      dateFormat.format(reading.createdAt)),
                  if (reading.createdBy != null)
                    _buildDetailItem('Created By', reading.createdBy!),
                  _buildDetailItem('Updated At',
                      dateFormat.format(reading.updatedAt)),
                  if (reading.updatedBy != null)
                    _buildDetailItem('Updated By', reading.updatedBy!),
                ],
              ),

              // Actions Card
              _buildActionCard(context, ref),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, WidgetRef ref) {
    final provider = ref.read(meterReadingProvider.notifier);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.build, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Verify Button
                if (reading.canVerify)
                  ElevatedButton.icon(
                    onPressed: () => provider.verifyReading(reading.id),
                    icon: const Icon(Icons.verified, size: 16),
                    label: const Text('Verify Reading'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // Reject Button
                if (reading.canReject)
                  OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, ref),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Reject Reading'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),

                // Generate Bill Button
                if (reading.canGenerateBill)
                  ElevatedButton.icon(
                    onPressed: () => provider.generateBill(reading.id),
                    icon: const Icon(Icons.receipt, size: 16),
                    label: const Text('Generate Bill'),
                  ),

                // Process Button
                if (reading.canProcess)
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement process functionality
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Mark as Processed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // Delete Button
                if (reading.canEdit)
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Reading'),
                            content: const Text(
                                'Are you sure you want to delete this reading? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  provider.deleteMeterReading(reading.id);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}