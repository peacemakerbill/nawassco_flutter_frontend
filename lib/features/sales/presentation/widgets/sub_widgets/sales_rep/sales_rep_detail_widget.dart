import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/sales_representative_model.dart';

class SalesRepDetailWidget extends StatelessWidget {
  final SalesRepresentative salesRep;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const SalesRepDetailWidget({
    super.key,
    required this.salesRep,
    required this.onEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          salesRep.personalDetails.firstName.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salesRep.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          salesRep.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Info
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),
                  _buildBasicInfo(),
                  const SizedBox(height: 24),

                  // Performance Stats
                  _buildSectionHeader('Performance Overview'),
                  const SizedBox(height: 16),
                  _buildPerformanceStats(context),
                  const SizedBox(height: 24),

                  // Targets
                  _buildSectionHeader('Sales Targets'),
                  const SizedBox(height: 16),
                  _buildTargets(),
                  const SizedBox(height: 24),

                  // Contact Details
                  _buildSectionHeader('Contact Details'),
                  const SizedBox(height: 16),
                  _buildContactDetails(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3,
      children: [
        _buildInfoTile('Employee Number', salesRep.employeeNumber, Icons.badge),
        _buildInfoTile(
            'Role',
            SalesRepresentative.getRoleDisplayName(salesRep.salesRole),
            Icons.work,
            SalesRepresentative.getRoleColor(salesRep.salesRole)),
        _buildInfoTile(
            'Status',
            SalesRepresentative.getStatusDisplayName(salesRep.status),
            Icons.circle,
            SalesRepresentative.getStatusColor(salesRep.status)),
        _buildInfoTile(
            'Member Since',
            DateFormat('MMM dd, yyyy').format(salesRep.createdAt),
            Icons.date_range),
      ],
    );
  }

  Widget _buildPerformanceStats(BuildContext context) {
    final performance = salesRep.performance;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricTile(
          'Total Sales',
          'KES ${performance.totalSales.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricTile(
          'Conversion Rate',
          '${performance.conversionRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildMetricTile(
          'Customer Satisfaction',
          '${performance.customerSatisfaction.toStringAsFixed(1)}/10',
          Icons.star,
          Colors.orange,
        ),
        _buildMetricTile(
          'Monthly Average',
          'KES ${performance.monthlyAverage.toStringAsFixed(2)}',
          Icons.timeline,
          Colors.purple,
        ),
        _buildMetricTile(
          'Retention Rate',
          '${performance.retentionRate.toStringAsFixed(1)}%',
          Icons.group,
          Colors.teal,
        ),
        _buildMetricTile(
          'Overall Rating',
          '${performance.overallRating.toStringAsFixed(1)}/10',
          Icons.assessment,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildTargets() {
    final targets = salesRep.salesTargets;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildTargetTile(
            'Monthly', 'KES ${targets.monthlyTarget.toStringAsFixed(2)}'),
        _buildTargetTile(
            'Quarterly', 'KES ${targets.quarterlyTarget.toStringAsFixed(2)}'),
        _buildTargetTile(
            'Annual', 'KES ${targets.annualTarget.toStringAsFixed(2)}'),
        _buildTargetTile(
            'New Customers', targets.newCustomersTarget.toString()),
      ],
    );
  }

  Widget _buildContactDetails() {
    final contact = salesRep.contactInformation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContactTile('Work Email', contact.workEmail, Icons.email),
        const SizedBox(height: 12),
        _buildContactTile('Work Phone', contact.workPhone, Icons.phone),
        const SizedBox(height: 12),
        _buildContactTile(
            'Personal Email', contact.personalEmail, Icons.mail_outline),
        const SizedBox(height: 12),
        _buildContactTile(
            'Personal Phone', contact.personalPhone, Icons.phone_iphone),
        const SizedBox(height: 12),
        _buildContactTile(
            'Address', contact.address.formattedAddress, Icons.location_on),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon,
      [Color? iconColor]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? const Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
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
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTile(String period, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
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
}
