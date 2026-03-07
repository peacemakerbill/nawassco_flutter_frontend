import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';

class EmploymentDetailsSection extends ConsumerStatefulWidget {
  final StoreManager storeManager;

  const EmploymentDetailsSection({super.key, required this.storeManager});

  @override
  ConsumerState<EmploymentDetailsSection> createState() => _EmploymentDetailsSectionState();
}

class _EmploymentDetailsSectionState extends ConsumerState<EmploymentDetailsSection> {
  late StoreEmploymentDetails _employmentDetails;
  late StoreJobInformation _jobInformation;
  late StoreCompensation _compensation;

  @override
  void initState() {
    super.initState();
    _employmentDetails = widget.storeManager.employmentDetails;
    _jobInformation = widget.storeManager.jobInformation;
    _compensation = widget.storeManager.compensation;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Employment Details Card
          _buildEmploymentDetailsCard(),
          const SizedBox(height: 16),

          // Job Information Card
          _buildJobInformationCard(),
          const SizedBox(height: 16),

          // Compensation Card
          _buildCompensationCard(),
          const SizedBox(height: 16),

          // Previous Roles Card
          _buildPreviousRolesCard(),
        ],
      ),
    );
  }

  Widget _buildEmploymentDetailsCard() {
    final yearsOfExperience = _calculateYearsOfExperience();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Employment Details', Icons.work),
            const SizedBox(height: 16),

            _buildInfoRow('Employee Number', widget.storeManager.employeeNumber),
            _buildInfoRow('Hire Date',
                _employmentDetails.hireDate.toIso8601String().split('T')[0]),
            _buildInfoRow('Promotion Date',
                _employmentDetails.promotionDate?.toIso8601String().split('T')[0] ?? 'Not set'),
            _buildInfoRow('Employment Type',
                _formatEmploymentType(_employmentDetails.employmentType)),
            _buildInfoRow('Employment Status',
                _formatEmploymentStatus(_employmentDetails.employmentStatus)),
            _buildInfoRow('Total Experience',
                '$yearsOfExperience years'),
            _buildInfoRow('Stores Experience',
                '${_employmentDetails.storesExperience} years'),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInformationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Job Information', Icons.business_center),
            const SizedBox(height: 16),

            _buildInfoRow('Job Title', _jobInformation.jobTitle),
            _buildInfoRow('Store Manager Role',
                _formatStoreManagerRole(widget.storeManager.storeManagerRole)),
            _buildInfoRow('Management Level',
                _formatManagementLevel(widget.storeManager.managementLevel)),
            _buildInfoRow('Department', widget.storeManager.department),
            _buildInfoRow('Location', _jobInformation.location),
            _buildInfoRow('Cost Center', _jobInformation.costCenter),
            _buildInfoRow('Reporting To', _jobInformation.reportingTo),

            const SizedBox(height: 8),
            const Text(
              'Stores Managed:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (_jobInformation.storesManaged.isEmpty)
              const Text(
                'No stores assigned',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            else
              ..._jobInformation.storesManaged.map((store) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Icon(Icons.store, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(store),
                      ],
                    ),
                  ),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompensationCard() {
    final totalCompensation = _compensation.baseSalary +
        _compensation.storesAllowance +
        _compensation.performanceBonus +
        _compensation.inventoryAccuracyBonus;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Compensation', Icons.attach_money),
            const SizedBox(height: 16),

            // Total Compensation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Annual Compensation',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'KES ${totalCompensation.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCompensationRow('Base Salary', _compensation.baseSalary),
            _buildCompensationRow('Stores Allowance', _compensation.storesAllowance),
            _buildCompensationRow('Performance Bonus', _compensation.performanceBonus),
            _buildCompensationRow('Inventory Accuracy Bonus', _compensation.inventoryAccuracyBonus),

            const SizedBox(height: 8),
            _buildInfoRow('Compensation Review Date',
                _compensation.compensationReviewDate.toIso8601String().split('T')[0]),

            // Benefits
            if (_compensation.benefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Benefits:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ..._compensation.benefits.map((benefit) =>
                  _buildBenefitItem(benefit),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousRolesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Previous Stores Roles', Icons.history),
            const SizedBox(height: 16),

            if (_employmentDetails.previousStoresRoles.isEmpty)
              const Center(
                child: Text(
                  'No previous roles recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._employmentDetails.previousStoresRoles.map((role) =>
                  _buildPreviousRoleItem(role),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousRoleItem(PreviousStoresRole role) {
    final duration = _calculateRoleDuration(role.startDate, role.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  role.role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(
                label: Text(duration),
                backgroundColor: Colors.blue[50],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            role.company,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${role.startDate.toIso8601String().split('T')[0]} - ${role.endDate.toIso8601String().split('T')[0]}',
            style: const TextStyle(color: Colors.grey),
          ),
          if (role.achievements.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Key Achievements:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ...role.achievements.map((achievement) =>
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                  child: Text('• $achievement'),
                ),
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(StoreBenefit benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.benefit,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  benefit.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            'KES ${benefit.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
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

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildCompensationRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateYearsOfExperience() {
    final now = DateTime.now();
    final difference = now.difference(_employmentDetails.hireDate);
    return difference.inDays / 365.25;
  }

  String _calculateRoleDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final years = (difference.inDays / 365.25).floor();
    final months = ((difference.inDays % 365.25) / 30.44).floor();

    if (years > 0 && months > 0) {
      return '$years yrs $months mos';
    } else if (years > 0) {
      return '$years yrs';
    } else {
      return '$months mos';
    }
  }

  // FIXED: Use enum toString() and format properly
  String _formatEmploymentType(EmploymentType type) {
    final stringValue = type.toString().split('.').last;
    return _formatEnumString(stringValue);
  }

  String _formatEmploymentStatus(EmploymentStatus status) {
    final stringValue = status.toString().split('.').last;
    return _formatEnumString(stringValue);
  }

  String _formatStoreManagerRole(StoreManagerRole role) {
    final stringValue = role.toString().split('.').last;
    return _formatEnumString(stringValue);
  }

  String _formatManagementLevel(StoreManagementLevel level) {
    final stringValue = level.toString().split('.').last;
    return _formatEnumString(stringValue);
  }

  String _formatEnumString(String enumString) {
    // Convert "SENIOR_MANAGEMENT" to "Senior Management"
    return enumString
        .toLowerCase()
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}