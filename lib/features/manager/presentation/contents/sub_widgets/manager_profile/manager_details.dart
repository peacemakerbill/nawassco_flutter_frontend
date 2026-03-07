import 'package:flutter/material.dart';

import '../../../../models/manager_model.dart';

class ManagerDetails extends StatelessWidget {
  final ManagerModel manager;
  final VoidCallback? onEdit;
  final VoidCallback? onBack;

  const ManagerDetails({
    super.key,
    required this.manager,
    this.onEdit,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Manager Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                ],
              ),
            ),
          // Profile card
          _buildProfileCard(),
          const SizedBox(height: 20),
          // Tabs for details
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Employment'),
                      Tab(text: 'Authority'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Team'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildEmploymentTab(),
                      _buildAuthorityTab(),
                      _buildPerformanceTab(),
                      _buildTeamTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getRoleColor(manager.managementRole),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      manager.personalDetails.firstName
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Name and basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        manager.jobTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            icon: Icons.badge,
                            label: manager.employeeNumber,
                          ),
                          _buildInfoChip(
                            icon: Icons.work,
                            label: Department.display(manager.department),
                          ),
                          _buildInfoChip(
                            icon: Icons.star,
                            label: ManagementLevel.display(
                                manager.managementLevel),
                          ),
                          _buildInfoChip(
                            icon: Icons.calendar_today,
                            label:
                                'Since ${_formatDate(manager.employmentDetails.hireDate)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: manager.isActive
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: manager.isActive
                          ? Colors.green.shade300
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        manager.isActive
                            ? Icons.check_circle
                            : Icons.pause_circle,
                        size: 16,
                        color: manager.isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        manager.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: manager.isActive
                              ? Colors.green.shade800
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Contact information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    label: 'Work Email',
                    value: manager.contactInformation.workEmail,
                  ),
                  const SizedBox(width: 20),
                  _buildContactItem(
                    icon: Icons.phone,
                    label: 'Work Phone',
                    value: manager.contactInformation.workPhone,
                  ),
                  const SizedBox(width: 20),
                  _buildContactItem(
                    icon: Icons.location_on,
                    label: 'Office Location',
                    value: manager.contactInformation.officeLocation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildDetailRow('Employment Type',
            EmploymentType.display(manager.employmentDetails.employmentType)),
        _buildDetailRow(
            'Employment Status',
            EmploymentStatus.display(
                manager.employmentDetails.employmentStatus)),
        _buildDetailRow('Management Tenure',
            '${manager.employmentDetails.managementTenure} years'),
        _buildDetailRow(
            'Hire Date', _formatDate(manager.employmentDetails.hireDate)),
        if (manager.employmentDetails.promotionDate != null)
          _buildDetailRow('Promotion Date',
              _formatDate(manager.employmentDetails.promotionDate!)),
        _buildDetailRow('Division', manager.jobInformation.division),
        _buildDetailRow('Location', manager.jobInformation.location),
        _buildDetailRow('Cost Center', manager.jobInformation.costCenter),
        _buildDetailRow(
            'Base Salary', _formatCurrency(manager.compensation.baseSalary)),
        _buildDetailRow('Management Allowance',
            _formatCurrency(manager.compensation.managementAllowance)),
        _buildDetailRow('Total Compensation',
            _formatCurrency(manager.compensation.totalCompensation)),
      ],
    );
  }

  Widget _buildAuthorityTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Text(
          'Financial Authority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildAuthorityItem('Expense Approval',
            manager.approvalLimits.financial.expenseApproval),
        _buildAuthorityItem('Capital Expenditure',
            manager.approvalLimits.financial.capitalExpenditure),
        _buildAuthorityItem('Contract Signing',
            manager.approvalLimits.financial.contractSigning),
        const SizedBox(height: 16),
        const Text(
          'HR Authority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildAuthorityItem(
            'Hiring Limit', manager.approvalLimits.humanResources.hiring),
        _buildAuthorityItem('Salary Adjustment',
            manager.approvalLimits.humanResources.salaryAdjustment),
        _buildAuthorityItem('Promotion Budget',
            manager.approvalLimits.humanResources.promotion),
        const SizedBox(height: 16),
        const Text(
          'Signing Authority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildBooleanAuthority(
            'Can Sign Contracts', manager.signingAuthority.canSignContracts),
        if (manager.signingAuthority.canSignContracts)
          _buildAuthorityItem('Contract Value Limit',
              manager.signingAuthority.contractValueLimit),
        _buildBooleanAuthority(
            'Can Sign Financials', manager.signingAuthority.canSignFinancials),
        _buildBooleanAuthority('Can Represent Company',
            manager.signingAuthority.canRepresentCompany),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Overall rating
        Card(
          color: _getPerformanceColor(manager.performance.overallRating),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Overall Rating',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  manager.performance.overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: manager.performance.overallRating / 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Performance metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Leadership',
                manager.performance.leadershipScore,
                Icons.leaderboard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Strategic',
                manager.performance.strategicContribution,
                Icons.insights,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Team',
                manager.performance.teamPerformance,
                Icons.group,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Next review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Performance Review',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      _formatDate(manager.performance.nextReviewDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Objectives
        if (manager.objectives.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Current Objectives',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...manager.objectives.map((objective) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objective.objective,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: objective.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: _getObjectiveColor(objective.status),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${objective.progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _formatObjectiveStatus(objective.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getObjectiveColor(objective.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildTeamTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Span of control
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Span of Control',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamMetric(
                        'Total Employees',
                        manager.spanOfControl.totalEmployees.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildTeamMetric(
                        'Direct Reports',
                        manager.spanOfControl.directReports.toString(),
                        Icons.supervised_user_circle,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildTeamMetric(
                        'Teams',
                        manager.spanOfControl.teams.toString(),
                        Icons.group_work,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamMetric(
                        'Departments',
                        manager.spanOfControl.departments.toString(),
                        Icons.business,
                        Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: _buildTeamMetric(
                        'Budget Size',
                        _formatCurrency(manager.spanOfControl.budgetSize),
                        Icons.attach_money,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Reporting structure
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reporting Structure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Level', manager.reportingStructure.level.toString()),
                _buildDetailRow('Board Reporting',
                    manager.reportingStructure.boardReporting ? 'Yes' : 'No'),
                if (manager.reportingStructure.committeeReports.isNotEmpty)
                  _buildDetailRow('Committee Reports',
                      manager.reportingStructure.committeeReports.join(', ')),
              ],
            ),
          ),
        ),
        // Direct reports count
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Direct Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${manager.directReports.length} employees report directly',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                if (manager.directReports.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No direct reports assigned',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      {required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: amount > 0 ? Colors.green.shade800 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanAuthority(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value ? Colors.green.shade300 : Colors.grey.shade300,
              ),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: value ? Colors.green.shade800 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.blue.shade700),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 20, color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods
  Color _getRoleColor(String role) {
    switch (role) {
      case ManagementRole.ceo:
        return Colors.purple;
      case ManagementRole.managingDirector:
        return Colors.deepPurple;
      case ManagementRole.executiveDirector:
        return Colors.indigo;
      case ManagementRole.departmentDirector:
        return Colors.blue;
      case ManagementRole.seniorManager:
        return Colors.teal;
      case ManagementRole.manager:
        return Colors.green;
      case ManagementRole.teamLead:
        return Colors.orange;
      case ManagementRole.supervisor:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getPerformanceColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.blue;
    if (rating >= 2.5) return Colors.orange;
    return Colors.red;
  }

  Color _getObjectiveColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'on_track':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'at_risk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatObjectiveStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'on_track':
        return 'On Track';
      case 'in_progress':
        return 'In Progress';
      case 'at_risk':
        return 'At Risk';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}
