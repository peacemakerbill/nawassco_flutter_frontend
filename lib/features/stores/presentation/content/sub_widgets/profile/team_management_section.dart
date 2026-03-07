import 'package:flutter/material.dart';
import '../../../../models/store_manager_model.dart';

class TeamManagementSection extends StatelessWidget {
  final StoreManager storeManager;

  const TeamManagementSection({super.key, required this.storeManager});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Reporting Structure Card
          _buildReportingStructureCard(),
          const SizedBox(height: 16),

          // Reporting Staff Card
          _buildReportingStaffCard(),
          const SizedBox(height: 16),

          // Store Staff Card
          _buildStoreStaffCard(),
          const SizedBox(height: 16),

          // Procurement Authority Card
          _buildProcurementAuthorityCard(),
        ],
      ),
    );
  }

  Widget _buildReportingStructureCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Reporting Structure', Icons.account_tree),
            const SizedBox(height: 16),

            _buildStructureRow('Management Level',
                'Level ${storeManager.reportingStructure.level}'),
            _buildStructureRow('Reports To', storeManager.reportingStructure.reportsTo),
            _buildStructureRow('Store Hierarchy', storeManager.reportingStructure.storeHierarchy),

            if (storeManager.reportingStructure.dottedLineReports.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Dotted Line Reports:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...storeManager.reportingStructure.dottedLineReports.map((report) =>
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('• $report'),
                  ),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportingStaffCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Direct Reporting Staff', Icons.supervisor_account),
            const SizedBox(height: 16),

            if (storeManager.reportingStaff.isEmpty)
              const Center(
                child: Text(
                  'No direct reporting staff',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...storeManager.reportingStaff.map((staff) =>
                  _buildStaffMemberItem(staff),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreStaffCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Store Staff Team', Icons.people),
            const SizedBox(height: 16),

            if (storeManager.storeStaff.isEmpty)
              const Center(
                child: Text(
                  'No store staff assigned',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: storeManager.storeStaff.map((staff) =>
                    Chip(
                      label: Text(staff),
                      avatar: Icon(Icons.person, size: 16),
                    ),
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcurementAuthorityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Procurement & Vendor Management', Icons.shopping_cart),
            const SizedBox(height: 16),

            // Procurement Authority
            const Text(
              'Procurement Authority:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            _buildProcurementRow('Can Approve PR',
                storeManager.procurementAuthority.canApprovePR),
            _buildProcurementRow('PR Value Limit',
                'KES ${storeManager.procurementAuthority.prValueLimit.toStringAsFixed(2)}'),
            _buildProcurementRow('Can Approve PO',
                storeManager.procurementAuthority.canApprovePO),
            _buildProcurementRow('PO Value Limit',
                'KES ${storeManager.procurementAuthority.poValueLimit.toStringAsFixed(2)}'),
            _buildProcurementRow('Can Select Suppliers',
                storeManager.procurementAuthority.canSelectSuppliers),
            _buildProcurementRow('Negotiation Authority',
                'KES ${storeManager.procurementAuthority.negotiationAuthority.toStringAsFixed(2)}'),

            const SizedBox(height: 16),

            // Vendor Management
            const Text(
              'Vendor Management:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            _buildVendorRow('Vendor Evaluation',
                storeManager.vendorManagement.vendorEvaluation),
            _buildVendorRow('Vendor Performance',
                storeManager.vendorManagement.vendorPerformance),
            _buildVendorRow('Contract Management',
                storeManager.vendorManagement.contractManagement),
            _buildVendorRow('Supplier Development',
                storeManager.vendorManagement.supplierDevelopment),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffMemberItem(StoreReportingStaff staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: Icon(Icons.person, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.staff,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  staff.role.name.replaceAll('_', ' '),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  staff.reportingLine,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${staff.performance.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: staff.performance >= 80 ? Colors.green :
                  staff.performance >= 60 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: staff.performance / 100,
                backgroundColor: Colors.grey[200],
                color: staff.performance >= 80 ? Colors.green :
                staff.performance >= 60 ? Colors.orange : Colors.red,
                minHeight: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStructureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcurementRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: value is bool
                ? Row(
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.cancel,
                  color: value ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(value ? 'Yes' : 'No'),
              ],
            )
                : Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(value ? 'Enabled' : 'Disabled'),
        ],
      ),
    );
  }
}