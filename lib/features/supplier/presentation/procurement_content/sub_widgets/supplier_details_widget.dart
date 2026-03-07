import 'package:flutter/material.dart';

import '../../../models/supplier_model.dart';

class SupplierDetailsWidget extends StatelessWidget {
  final Supplier? supplier;
  final bool isLoading;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onDelete;

  const SupplierDetailsWidget({
    super.key,
    required this.supplier,
    required this.isLoading,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (supplier == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a supplier to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          _buildHeader(context),
          const SizedBox(height: 24),

          // Basic Information
          _buildInfoSection(
            'Basic Information',
            Icons.business,
            [
              _buildInfoRow('Company Name', supplier!.companyName),
              if (supplier!.tradingName != null)
                _buildInfoRow('Trading Name', supplier!.tradingName!),
              _buildInfoRow('Supplier Number', supplier!.supplierNumber),
              _buildInfoRow('Registration Number', supplier!.registrationNumber),
              _buildInfoRow('Tax ID', supplier!.taxIdentificationNumber),
              _buildInfoRow('Year Established', supplier!.yearEstablished.toString()),
            ],
          ),

          // Business Information
          _buildInfoSection(
            'Business Information',
            Icons.work,
            [
              _buildInfoRow('Business Type', _formatEnum(supplier!.businessType)),
              _buildInfoRow('Ownership Type', _formatEnum(supplier!.ownershipType)),
              _buildInfoRow('Company Type', _formatEnum(supplier!.companyType)),
              _buildInfoRow('Supplier Tier', _formatEnum(supplier!.supplierTier)),
              _buildInfoRow('Risk Rating', _formatEnum(supplier!.riskRating)),
            ],
          ),

          // Categories
          _buildInfoSection(
            'NAWASSCO Categories',
            Icons.category,
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supplier!.nawasscoCategories.map((category) => Chip(
                  label: Text(_formatEnum(category)),
                  backgroundColor: Colors.blue[50],
                )).toList(),
              ),
            ],
          ),

          // Contact Information
          _buildInfoSection(
            'Contact Information',
            Icons.contact_phone,
            [
              _buildInfoRow('Primary Email', supplier!.contactDetails['primaryEmail'] ?? 'N/A'),
              _buildInfoRow('Primary Phone', supplier!.contactDetails['primaryPhone'] ?? 'N/A'),
              if (supplier!.contactDetails['secondaryEmail'] != null)
                _buildInfoRow('Secondary Email', supplier!.contactDetails['secondaryEmail']!),
              if (supplier!.contactDetails['website'] != null)
                _buildInfoRow('Website', supplier!.contactDetails['website']!),
            ],
          ),

          // Performance Metrics
          if (supplier!.performanceMetrics.isNotEmpty)
            _buildInfoSection(
              'Performance Metrics',
              Icons.assessment,
              [
                _buildInfoRow('Overall Score', '${supplier!.performanceMetrics['overallScore']?.toStringAsFixed(1) ?? 'N/A'}%'),
                _buildInfoRow('On-time Delivery', '${supplier!.performanceMetrics['onTimeDelivery']?.toStringAsFixed(1) ?? 'N/A'}%'),
                _buildInfoRow('Quality Rating', '${supplier!.performanceMetrics['qualityRating']?.toStringAsFixed(1) ?? 'N/A'}%'),
                _buildInfoRow('Total Contracts', supplier!.performanceMetrics['totalContracts']?.toString() ?? 'N/A'),
              ],
            ),

          // Dates
          _buildInfoSection(
            'Important Dates',
            Icons.calendar_today,
            [
              _buildInfoRow('Registration Date', _formatDate(supplier!.registrationDate)),
              if (supplier!.approvalDate != null)
                _buildInfoRow('Approval Date', _formatDate(supplier!.approvalDate!)),
              if (supplier!.lastEvaluationDate != null)
                _buildInfoRow('Last Evaluation', _formatDate(supplier!.lastEvaluationDate!)),
              if (supplier!.nextEvaluationDate != null)
                _buildInfoRow('Next Evaluation', _formatDate(supplier!.nextEvaluationDate!)),
            ],
          ),

          // Blacklist Status
          if (supplier!.blacklistStatus['isBlacklisted'] == true)
            _buildBlacklistSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier!.companyName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (supplier!.tradingName != null)
                    Text(
                      supplier!.tradingName!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(supplier!.status),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Supplier'),
                  ),
                ),
                if (supplier!.status.toLowerCase() == 'pending')
                  const PopupMenuItem(
                    value: 'approve',
                    child: ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text('Approve Supplier'),
                    ),
                  ),
                if (supplier!.status.toLowerCase() != 'blacklisted')
                  const PopupMenuItem(
                    value: 'blacklist',
                    child: ListTile(
                      leading: Icon(Icons.block, color: Colors.red),
                      title: Text('Blacklist Supplier'),
                    ),
                  ),
                if (supplier!.status.toLowerCase() == 'blacklisted')
                  const PopupMenuItem(
                    value: 'reinstate',
                    child: ListTile(
                      leading: Icon(Icons.lock_open, color: Colors.orange),
                      title: Text('Reinstate Supplier'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete Supplier'),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                  // Navigate to edit form
                    break;
                  case 'approve':
                    _showApproveDialog(context);
                    break;
                  case 'blacklist':
                    _showBlacklistDialog(context);
                    break;
                  case 'reinstate':
                    _showReinstateDialog(context);
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'approved': Colors.green,
      'pending': Colors.orange,
      'draft': Colors.grey,
      'blacklisted': Colors.red,
      'rejected': Colors.red,
    };

    final color = statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0066A1)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlacklistSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Blacklisted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (supplier!.blacklistStatus['blacklistReason'] != null)
              _buildInfoRow('Reason', supplier!.blacklistStatus['blacklistReason']!),
            if (supplier!.blacklistStatus['blacklistDate'] != null)
              _buildInfoRow('Blacklisted On', _formatDate(DateTime.parse(supplier!.blacklistStatus['blacklistDate']))),
            if (supplier!.blacklistStatus['reinstatementDate'] != null)
              _buildInfoRow('Reinstatement Date', _formatDate(DateTime.parse(supplier!.blacklistStatus['reinstatementDate']))),
          ],
        ),
      ),
    );
  }

  String _formatEnum(String value) {
    return value.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Supplier'),
        content: Text('Are you sure you want to approve ${supplier!.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdate({'status': 'approved'});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showBlacklistDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blacklist Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blacklist ${supplier!.companyName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for blacklisting',
                border: OutlineInputBorder(),
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
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.pop(context);
              onUpdate({
                'blacklistStatus': {
                  'isBlacklisted': true,
                  'blacklistReason': reasonController.text,
                  'blacklistDate': DateTime.now().toIso8601String(),
                },
                'status': 'blacklisted',
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Blacklist'),
          ),
        ],
      ),
    );
  }

  void _showReinstateDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reinstate Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reinstate ${supplier!.companyName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for reinstatement',
                border: OutlineInputBorder(),
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
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.pop(context);
              onUpdate({
                'blacklistStatus': {
                  'isBlacklisted': false,
                  'reinstatementReason': reasonController.text,
                  'reinstatementDate': DateTime.now().toIso8601String(),
                },
                'status': 'approved',
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reinstate'),
          ),
        ],
      ),
    );
  }
}