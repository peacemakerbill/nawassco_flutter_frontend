import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/procurement_officer.dart';
import '../../../../providers/procurement_officer_provider.dart';
import 'procurement_officer_form_screen.dart';

class ProcurementOfficerDetailScreen extends ConsumerStatefulWidget {
  final String officerId;

  const ProcurementOfficerDetailScreen({super.key, required this.officerId});

  @override
  ConsumerState<ProcurementOfficerDetailScreen> createState() => _ProcurementOfficerDetailScreenState();
}

class _ProcurementOfficerDetailScreenState extends ConsumerState<ProcurementOfficerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementOfficerProvider.notifier).getProcurementOfficer(widget.officerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final officerState = ref.watch(procurementOfficerProvider);
    final officer = officerState.selectedOfficer;

    if (officerState.isLoading && officer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (officer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Officer Details'),
        ),
        body: const Center(
          child: Text('Procurement officer not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(officer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProcurementOfficerFormScreen(officer: officer),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(officer),
            const SizedBox(height: 20),

            // Personal Information
            _buildPersonalInfoSection(officer),
            const SizedBox(height: 20),

            // Employment Details
            _buildEmploymentSection(officer),
            const SizedBox(height: 20),

            // Procurement Details
            _buildProcurementSection(officer),
            const SizedBox(height: 20),

            // Performance Section
            _buildPerformanceSection(officer),
            const SizedBox(height: 20),

            // Actions Section
            _buildActionSection(officer),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ProcurementOfficer officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getRoleColor(officer.jobTitle),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(officer.jobTitle),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officer.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    officer.employeeNumber,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _formatRole(officer.jobTitle),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(officer.employmentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProcurementOfficer officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Email', officer.email),
            _buildDetailRow('Phone', officer.phone),
            _buildDetailRow('National ID', officer.nationalId),
            _buildDetailRow('Date of Birth', _formatDate(officer.dateOfBirth)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentSection(ProcurementOfficer officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employment Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Department', officer.department),
            _buildDetailRow('Hire Date', _formatDate(officer.hireDate)),
            _buildDetailRow('Employment Type', _formatEmploymentType(officer.employmentType)),
            _buildDetailRow('Cost Center', officer.costCenter),
            _buildDetailRow('Work Location', officer.workLocation),
            if (officer.supervisorName != null)
              _buildDetailRow('Supervisor', officer.supervisorName!),
          ],
        ),
      ),
    );
  }

  Widget _buildProcurementSection(ProcurementOfficer officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Procurement Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Vendor Management Experience', '${officer.vendorManagementExperience} years'),

            const SizedBox(height: 8),
            const Text(
              'Specialized Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: officer.specializedCategories.map((category) =>
                  Chip(
                    label: Text(_formatCategory(category)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
              ).toList(),
            ),

            const SizedBox(height: 8),
            const Text(
              'Assigned Regions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: officer.assignedRegions.map((region) =>
                  Chip(
                    label: Text(region),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
              ).toList(),
            ),

            const SizedBox(height: 8),
            const Text(
              'Managed Suppliers:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${officer.managedSuppliers.length} suppliers'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(ProcurementOfficer officer) {
    final performance = officer.performance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric('Cost Savings', 'KES ${performance.costSavings.toStringAsFixed(2)}', Icons.savings),
            _buildPerformanceMetric('Procurement Cycle Time', '${performance.procurementCycleTime} days', Icons.schedule),
            _buildPerformanceMetric('Supplier Performance', '${performance.supplierPerformance.toStringAsFixed(1)}/10', Icons.handshake),
            _buildPerformanceMetric('Compliance Rate', '${performance.complianceRate.toStringAsFixed(1)}%', Icons.verified),
            _buildPerformanceMetric('Contract Management', '${performance.contractManagement.toStringAsFixed(1)}/10', Icons.description),
            const Divider(),
            _buildPerformanceMetric('Overall Rating', '${performance.overallRating.toStringAsFixed(1)}/10', Icons.star, isOverall: true),
            if (officer.lastEvaluationDate != null)
              _buildDetailRow('Last Evaluation', _formatDate(officer.lastEvaluationDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(ProcurementOfficer officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _updatePerformance(officer),
                  icon: const Icon(Icons.assessment),
                  label: const Text('Update Performance'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _viewApprovalLimits(officer),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('View Approval Limits'),
                ),
                if (officer.blacklistAuthority)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.block),
                    label: const Text('Supplier Blacklist'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, IconData icon, {bool isOverall = false}) {
    return ListTile(
      leading: Icon(icon, color: isOverall ? Colors.amber : Colors.blue),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: isOverall ? FontWeight.bold : FontWeight.normal,
          fontSize: isOverall ? 16 : 14,
          color: isOverall ? Colors.amber : Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(EmploymentStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo['color']),
      ),
      child: Text(
        statusInfo['label'],
        style: TextStyle(
          color: statusInfo['color'],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _updatePerformance(ProcurementOfficer officer) async {
    final costSavingsController = TextEditingController(text: officer.performance.costSavings.toString());
    final cycleTimeController = TextEditingController(text: officer.performance.procurementCycleTime.toString());
    final supplierPerfController = TextEditingController(text: officer.performance.supplierPerformance.toString());
    final complianceController = TextEditingController(text: officer.performance.complianceRate.toString());
    final contractMgmtController = TextEditingController(text: officer.performance.contractManagement.toString());
    final overallController = TextEditingController(text: officer.performance.overallRating.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Performance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: costSavingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost Savings (KES)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cycleTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Procurement Cycle Time (days)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: supplierPerfController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Supplier Performance (1-10)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: complianceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Compliance Rate (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contractMgmtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Contract Management (1-10)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: overallController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Overall Rating (1-10)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final performanceData = {
                'costSavings': double.tryParse(costSavingsController.text) ?? 0,
                'procurementCycleTime': double.tryParse(cycleTimeController.text) ?? 0,
                'supplierPerformance': double.tryParse(supplierPerfController.text) ?? 0,
                'complianceRate': double.tryParse(complianceController.text) ?? 0,
                'contractManagement': double.tryParse(contractMgmtController.text) ?? 0,
                'overallRating': double.tryParse(overallController.text) ?? 0,
              };

              final success = await ref.read(procurementOfficerProvider.notifier).updateOfficerPerformance(
                officer.id,
                performanceData,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ref.read(procurementOfficerProvider.notifier).getProcurementOfficer(officer.id);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _viewApprovalLimits(ProcurementOfficer officer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approval Limits'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLimitRow('Purchase Requisition', 'KES ${officer.approvalLimits.purchaseRequisition}'),
              _buildLimitRow('Purchase Order', 'KES ${officer.approvalLimits.purchaseOrder}'),
              _buildLimitRow('Contract', 'KES ${officer.approvalLimits.contract}'),
              _buildLimitRow('Emergency Procurement', 'KES ${officer.approvalLimits.emergencyProcurement}'),
              _buildLimitRow('Spot Purchase', 'KES ${officer.approvalLimits.spotPurchase}'),
              const SizedBox(height: 16),
              const Text(
                'Tender Authority:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildAuthorityRow('Can Open Tenders', officer.tenderAuthority.canOpenTenders),
              _buildAuthorityRow('Can Evaluate Tenders', officer.tenderAuthority.canEvaluateTenders),
              _buildAuthorityRow('Can Award Tenders', officer.tenderAuthority.canAwardTenders),
              _buildAuthorityRow('Can Approve Bidders', officer.tenderAuthority.canApproveBidders),
              _buildLimitRow('Tender Value Limit', 'KES ${officer.tenderAuthority.tenderValueLimit}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAuthorityRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  String _formatRole(ProcurementRole role) {
    return role.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatEmploymentType(EmploymentType type) {
    return type.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatEmploymentStatus(EmploymentStatus status) {
    return status.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatCategory(ProcurementCategory category) {
    return category.name.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRoleColor(ProcurementRole role) {
    switch (role) {
      case ProcurementRole.procurement_manager:
        return Colors.purple;
      case ProcurementRole.senior_procurement_officer:
        return Colors.blue;
      case ProcurementRole.procurement_officer:
        return Colors.green;
      case ProcurementRole.junior_procurement_officer:
        return Colors.orange;
      case ProcurementRole.buyer:
        return Colors.teal;
      case ProcurementRole.contracts_officer:
        return Colors.indigo;
      case ProcurementRole.tender_officer:
        return Colors.red;
      case ProcurementRole.supplier_relationship_manager:
        return Colors.pink;
      case ProcurementRole.inventory_controller:
        return Colors.brown;
    }
  }

  IconData _getRoleIcon(ProcurementRole role) {
    switch (role) {
      case ProcurementRole.procurement_manager:
        return Icons.manage_accounts;
      case ProcurementRole.senior_procurement_officer:
        return Icons.supervisor_account;
      case ProcurementRole.procurement_officer:
        return Icons.badge;
      case ProcurementRole.junior_procurement_officer:
        return Icons.work_outline;
      case ProcurementRole.buyer:
        return Icons.shopping_cart;
      case ProcurementRole.contracts_officer:
        return Icons.description;
      case ProcurementRole.tender_officer:
        return Icons.gavel;
      case ProcurementRole.supplier_relationship_manager:
        return Icons.handshake;
      case ProcurementRole.inventory_controller:
        return Icons.inventory;
    }
  }

  Map<String, dynamic> _getStatusInfo(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.active:
        return {'label': 'Active', 'color': Colors.green};
      case EmploymentStatus.inactive:
        return {'label': 'Inactive', 'color': Colors.grey};
      case EmploymentStatus.suspended:
        return {'label': 'Suspended', 'color': Colors.orange};
      case EmploymentStatus.terminated:
        return {'label': 'Terminated', 'color': Colors.red};
      case EmploymentStatus.retired:
        return {'label': 'Retired', 'color': Colors.blue};
      case EmploymentStatus.on_leave:
        return {'label': 'On Leave', 'color': Colors.purple};
    }
  }
}