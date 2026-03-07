import 'package:flutter/material.dart';

import '../../../models/supplier_contact_model.dart';
import '../../../models/supplier_evaluation_model.dart';
import '../../../models/supplier_model.dart';


class ProfileOverviewWidget extends StatelessWidget {
  final Supplier? supplier;
  final List<SupplierContact> contacts;
  final List<SupplierEvaluation> evaluations;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const ProfileOverviewWidget({
    super.key,
    required this.supplier,
    required this.contacts,
    required this.evaluations,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (supplier == null) {
      return const Center(
        child: Text('No supplier data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Stats Cards
          _buildStatsRow(),
          const SizedBox(height: 20),

          // Company Information
          _buildInfoSection(
            'Company Information',
            Icons.business,
            [
              _buildInfoItem('Company Name', supplier!.companyName),
              if (supplier!.tradingName != null)
                _buildInfoItem('Trading Name', supplier!.tradingName!),
              _buildInfoItem('Registration Number', supplier!.registrationNumber),
              _buildInfoItem('Tax ID', supplier!.taxIdentificationNumber),
              _buildInfoItem('Year Established', supplier!.yearEstablished.toString()),
              _buildInfoItem('Business Type', _capitalizeWords(supplier!.businessType)),
              _buildInfoItem('Ownership Type', _capitalizeWords(supplier!.ownershipType)),
            ],
          ),
          const SizedBox(height: 20),

          // Contact Information
          _buildInfoSection(
            'Contact Information',
            Icons.contact_phone,
            [
              _buildInfoItem('Primary Email', supplier!.contactDetails['primaryEmail'] ?? 'N/A'),
              _buildInfoItem('Primary Phone', supplier!.contactDetails['primaryPhone'] ?? 'N/A'),
              if (supplier!.contactDetails['secondaryEmail'] != null)
                _buildInfoItem('Secondary Email', supplier!.contactDetails['secondaryEmail']!),
              if (supplier!.contactDetails['website'] != null)
                _buildInfoItem('Website', supplier!.contactDetails['website']!),
            ],
          ),
          const SizedBox(height: 20),

          // Performance Metrics
          _buildPerformanceSection(),
          const SizedBox(height: 20),

          // Key Contacts
          _buildContactsSection(),
          const SizedBox(height: 20),

          // Recent Evaluations
          _buildEvaluationsSection(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Overall Score',
            '${supplier!.performanceMetrics['overallScore']?.toStringAsFixed(1) ?? 'N/A'}',
            Icons.assessment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Contracts',
            supplier!.performanceMetrics['totalContracts']?.toString() ?? '0',
            Icons.assignment,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'On-time Delivery',
            '${supplier!.performanceMetrics['onTimeDelivery']?.toStringAsFixed(1) ?? 'N/A'}%',
            Icons.timer,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
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

  Widget _buildInfoItem(String label, String value) {
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

  Widget _buildPerformanceSection() {
    final metrics = supplier!.performanceMetrics;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Color(0xFF0066A1)),
                SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric('Quality Rating', metrics['qualityRating']?.toStringAsFixed(1)),
            _buildPerformanceMetric('Cost Performance', metrics['costPerformance']?.toStringAsFixed(1)),
            _buildPerformanceMetric('Safety Performance', metrics['safetyPerformance']?.toStringAsFixed(1)),
            _buildPerformanceMetric('Client Satisfaction', metrics['clientSatisfaction']?.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066A1),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: value != null ? double.parse(value) / 100 : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                _getScoreColor(value != null ? double.parse(value) : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection() {
    final primaryContact = contacts.firstWhere(
          (contact) => contact.isPrimary,
      orElse: () => contacts.isNotEmpty ? contacts.first : SupplierContact(
        id: '',
        supplierId: '',
        salutation: '',
        firstName: '',
        lastName: '',
        position: '',
        department: '',
        email: '',
        phone: '',
        mobile: '',
        preferredContactMethod: 'email',
        receiveTenderNotifications: true,
        receiveNewsletters: false,
        isAuthorizedSignatory: false,
        canSubmitBids: true,
        isPrimary: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contacts, color: Color(0xFF0066A1)),
                SizedBox(width: 8),
                Text(
                  'Key Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0066A1),
                child: Text(
                  '${primaryContact.firstName[0]}${primaryContact.lastName[0]}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text('${primaryContact.firstName} ${primaryContact.lastName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(primaryContact.position),
                  Text(primaryContact.email),
                  Text(primaryContact.phone),
                ],
              ),
              trailing: primaryContact.isPrimary
                  ? const Chip(
                label: Text('Primary'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white, fontSize: 10),
              )
                  : null,
            ),
            if (contacts.length > 1)
              Text(
                '+${contacts.length - 1} more contacts',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationsSection() {
    final recentEvaluations = evaluations.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF0066A1)),
                SizedBox(width: 8),
                Text(
                  'Recent Evaluations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentEvaluations.isEmpty)
              const Text(
                'No evaluations yet',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...recentEvaluations.map((evaluation) => _buildEvaluationItem(evaluation)),
            if (evaluations.length > 3)
              TextButton(
                onPressed: () {},
                child: const Text('View All Evaluations'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationItem(SupplierEvaluation evaluation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getScoreColor(evaluation.totalScore).withOpacity(0.1),
            child: Text(
              evaluation.totalScore.toStringAsFixed(0),
              style: TextStyle(
                color: _getScoreColor(evaluation.totalScore),
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
                  evaluation.evaluationNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Grade: ${evaluation.grade} • ${_formatDate(evaluation.evaluationDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(evaluation.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              evaluation.status.replaceAll('_', ' '),
              style: TextStyle(
                color: _getStatusColor(evaluation.status),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'under_review': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatEnum(String value) {
    return value.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}