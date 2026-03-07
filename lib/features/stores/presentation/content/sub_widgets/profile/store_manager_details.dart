import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/store_manager_model.dart';
import '../../../../providers/store_manager_admin_provider.dart';

class StoreManagerDetails extends ConsumerWidget {
  const StoreManagerDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeManagerState = ref.watch(storeManagerAdminProvider);
    final storeManager = storeManagerState.selectedStoreManager;

    if (storeManagerState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (storeManager == null) {
      return const Center(child: Text('Store manager not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(storeManager),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(context, storeManager, ref),
          const SizedBox(height: 16),

          // Personal Information
          _buildPersonalInfoCard(storeManager),
          const SizedBox(height: 16),

          // Contact Information
          _buildContactInfoCard(storeManager),
          const SizedBox(height: 16),

          // Employment Information
          _buildEmploymentInfoCard(storeManager),
          const SizedBox(height: 16),

          // Job Information
          _buildJobInfoCard(storeManager),
          const SizedBox(height: 16),

          // Compensation
          _buildCompensationCard(storeManager),
          const SizedBox(height: 16),

          // Performance
          _buildPerformanceCard(storeManager),
          const SizedBox(height: 16),

          // Inventory Authority
          _buildInventoryAuthorityCard(storeManager),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(StoreManager storeManager) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[100]!, width: 3),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 20),

            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${storeManager.personalDetails.firstName} ${storeManager.personalDetails.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeManager.jobInformation.jobTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('Employee #: ${storeManager.employeeNumber}'),
                      _buildInfoChip('Department: ${storeManager.department}'),
                      _buildStatusChip(storeManager.isActive),
                      _buildRoleChip(storeManager.storeManagerRole),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, StoreManager storeManager, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updatePerformance(context, storeManager, ref),
                icon: const Icon(Icons.assessment, size: 18),
                label: const Text('Update Performance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addObjective(context, storeManager, ref),
                icon: const Icon(Icons.flag, size: 18),
                label: const Text('Add Objective'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _toggleActiveStatus(storeManager, ref),
                icon: Icon(
                  storeManager.isActive ? Icons.pause : Icons.play_arrow,
                  size: 18,
                ),
                label: Text(storeManager.isActive ? 'Deactivate' : 'Activate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: storeManager.isActive ? Colors.orange[50] : Colors.green[50],
                  foregroundColor: storeManager.isActive ? Colors.orange[700] : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Personal Information',
      Icons.person,
      [
        _buildInfoRow('First Name', storeManager.personalDetails.firstName),
        _buildInfoRow('Last Name', storeManager.personalDetails.lastName),
        _buildInfoRow('Date of Birth',
            storeManager.personalDetails.dateOfBirth.toIso8601String().split('T')[0]),
        _buildInfoRow('Gender', _formatGender(storeManager.personalDetails.gender)),
        _buildInfoRow('National ID', storeManager.personalDetails.nationalId),
      ],
    );
  }

  Widget _buildContactInfoCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Contact Information',
      Icons.contact_mail,
      [
        _buildInfoRow('Work Email', storeManager.contactInformation.workEmail),
        _buildInfoRow('Personal Email', storeManager.contactInformation.personalEmail),
        _buildInfoRow('Work Phone', storeManager.contactInformation.workPhone),
        _buildInfoRow('Personal Phone', storeManager.contactInformation.personalPhone),
        _buildInfoRow('Office Location', storeManager.contactInformation.officeLocation),
      ],
    );
  }

  Widget _buildEmploymentInfoCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Employment Information',
      Icons.work,
      [
        _buildInfoRow('Hire Date',
            storeManager.employmentDetails.hireDate.toIso8601String().split('T')[0]),
        _buildInfoRow('Employment Type',
            _formatEmploymentType(storeManager.employmentDetails.employmentType)),
        _buildInfoRow('Employment Status',
            _formatEmploymentStatus(storeManager.employmentDetails.employmentStatus)),
        _buildInfoRow('Stores Experience',
            '${storeManager.employmentDetails.storesExperience} years'),
      ],
    );
  }

  Widget _buildJobInfoCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Job Information',
      Icons.business_center,
      [
        _buildInfoRow('Job Title', storeManager.jobInformation.jobTitle),
        _buildInfoRow('Store Manager Role',
            storeManager.storeManagerRole.name.replaceAll('_', ' ')),
        _buildInfoRow('Management Level',
            storeManager.managementLevel.name.replaceAll('_', ' ')),
        _buildInfoRow('Department', storeManager.department),
        _buildInfoRow('Location', storeManager.jobInformation.location),
        _buildInfoRow('Cost Center', storeManager.jobInformation.costCenter),
        _buildInfoRow('Stores Managed',
            storeManager.jobInformation.storesManaged.join(', ')),
      ],
    );
  }

  Widget _buildCompensationCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Compensation',
      Icons.attach_money,
      [
        _buildInfoRow('Base Salary', 'KES ${storeManager.compensation.baseSalary.toStringAsFixed(2)}'),
        _buildInfoRow('Stores Allowance', 'KES ${storeManager.compensation.storesAllowance.toStringAsFixed(2)}'),
        _buildInfoRow('Performance Bonus', 'KES ${storeManager.compensation.performanceBonus.toStringAsFixed(2)}'),
        _buildInfoRow('Inventory Accuracy Bonus',
            'KES ${storeManager.compensation.inventoryAccuracyBonus.toStringAsFixed(2)}'),
        _buildInfoRow('Compensation Review Date',
            storeManager.compensation.compensationReviewDate.toIso8601String().split('T')[0]),
      ],
    );
  }

  Widget _buildPerformanceCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Performance',
      Icons.assessment,
      [
        _buildPerformanceRow('Inventory Accuracy',
            storeManager.performance.inventoryAccuracy),
        _buildPerformanceRow('Stock Turnover',
            storeManager.performance.stockTurnover),
        _buildPerformanceRow('Order Fulfillment',
            storeManager.performance.orderFulfillment),
        _buildPerformanceRow('Cost Savings',
            storeManager.performance.costSavings),
        _buildPerformanceRow('Team Performance',
            storeManager.performance.teamPerformance),
        _buildPerformanceRow('Safety Compliance',
            storeManager.performance.safetyCompliance),
        _buildPerformanceRow('Overall Rating',
            storeManager.performance.overallRating, isOverall: true),
      ],
    );
  }

  Widget _buildInventoryAuthorityCard(StoreManager storeManager) {
    return _buildInfoCard(
      'Inventory Authority',
      Icons.inventory,
      [
        _buildAuthorityRow('Inventory Management',
            storeManager.inventoryAuthority.inventoryManagement),
        _buildAuthorityRow('Stock Adjustments Limit',
            'KES ${storeManager.inventoryAuthority.stockAdjustments.toStringAsFixed(2)}'),
        _buildAuthorityRow('Write-off Authority',
            'KES ${storeManager.inventoryAuthority.writeOffAuthority.toStringAsFixed(2)}'),
        _buildAuthorityRow('Stock Transfer',
            storeManager.inventoryAuthority.stockTransfer),
        _buildAuthorityRow('Quality Hold',
            storeManager.inventoryAuthority.qualityHold),
        _buildAuthorityRow('Disposal Authority',
            storeManager.inventoryAuthority.disposalAuthority),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              value.isEmpty ? 'Not set' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, double value, {bool isOverall = false}) {
    Color color;
    if (value >= 80) {
      color = Colors.green;
    } else if (value >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isOverall ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (value is bool)
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: value ? Colors.green : Colors.red,
            )
          else
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive ? Colors.green[50] : Colors.red[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRoleChip(StoreManagerRole role) {
    return Chip(
      label: Text(
        role.name.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.purple[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _updatePerformance(BuildContext context, StoreManager storeManager, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => PerformanceUpdateDialog(
        storeManager: storeManager,
        onUpdate: (performanceData) {
          ref.read(storeManagerAdminProvider.notifier).updatePerformance(
            storeManager.id,
            performanceData,
          );
        },
      ),
    );
  }

  void _addObjective(BuildContext context, StoreManager storeManager, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddObjectiveDialog(
        onAdd: (objectiveData) {
          ref.read(storeManagerAdminProvider.notifier).addStoreObjective(
            storeManager.id,
            objectiveData,
          );
        },
      ),
    );
  }

  void _toggleActiveStatus(StoreManager storeManager, WidgetRef ref) {
    ref.read(storeManagerAdminProvider.notifier).toggleActiveStatus(
      storeManager.id,
      !storeManager.isActive,
    );
  }

  String _formatGender(Gender gender) {
    return gender.name[0] + gender.name.substring(1).toLowerCase();
  }

  String _formatEmploymentType(EmploymentType type) {
    return type.name.replaceAll('_', ' ');
  }

  String _formatEmploymentStatus(EmploymentStatus status) {
    return status.name.replaceAll('_', ' ');
  }
}

// Additional Dialog Components
class PerformanceUpdateDialog extends StatefulWidget {
  final StoreManager storeManager;
  final Function(Map<String, dynamic>) onUpdate;

  const PerformanceUpdateDialog({
    super.key,
    required this.storeManager,
    required this.onUpdate,
  });

  @override
  State<PerformanceUpdateDialog> createState() => _PerformanceUpdateDialogState();
}

class _PerformanceUpdateDialogState extends State<PerformanceUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryAccuracyController = TextEditingController();
  final _stockTurnoverController = TextEditingController();
  final _orderFulfillmentController = TextEditingController();
  final _costSavingsController = TextEditingController();
  final _teamPerformanceController = TextEditingController();
  final _safetyComplianceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  void _populateForm() {
    final performance = widget.storeManager.performance;
    _inventoryAccuracyController.text = performance.inventoryAccuracy.toString();
    _stockTurnoverController.text = performance.stockTurnover.toString();
    _orderFulfillmentController.text = performance.orderFulfillment.toString();
    _costSavingsController.text = performance.costSavings.toString();
    _teamPerformanceController.text = performance.teamPerformance.toString();
    _safetyComplianceController.text = performance.safetyCompliance.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Performance'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPerformanceField('Inventory Accuracy', _inventoryAccuracyController),
              _buildPerformanceField('Stock Turnover', _stockTurnoverController),
              _buildPerformanceField('Order Fulfillment', _orderFulfillmentController),
              _buildPerformanceField('Cost Savings', _costSavingsController),
              _buildPerformanceField('Team Performance', _teamPerformanceController),
              _buildPerformanceField('Safety Compliance', _safetyComplianceController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updatePerformance,
          child: const Text('Update'),
        ),
      ],
    );
  }

  Widget _buildPerformanceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label (%)',
          border: const OutlineInputBorder(),
          suffixText: '%',
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value?.isEmpty == true) return 'Required';
          final numValue = double.tryParse(value!);
          if (numValue == null || numValue < 0 || numValue > 100) {
            return 'Enter value between 0-100';
          }
          return null;
        },
      ),
    );
  }

  void _updatePerformance() {
    if (_formKey.currentState!.validate()) {
      final performanceData = {
        'inventoryAccuracy': double.parse(_inventoryAccuracyController.text),
        'stockTurnover': double.parse(_stockTurnoverController.text),
        'orderFulfillment': double.parse(_orderFulfillmentController.text),
        'costSavings': double.parse(_costSavingsController.text),
        'teamPerformance': double.parse(_teamPerformanceController.text),
        'safetyCompliance': double.parse(_safetyComplianceController.text),
      };

      widget.onUpdate(performanceData);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _inventoryAccuracyController.dispose();
    _stockTurnoverController.dispose();
    _orderFulfillmentController.dispose();
    _costSavingsController.dispose();
    _teamPerformanceController.dispose();
    _safetyComplianceController.dispose();
    super.dispose();
  }
}

class AddObjectiveDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddObjectiveDialog({super.key, required this.onAdd});

  @override
  State<AddObjectiveDialog> createState() => _AddObjectiveDialogState();
}

class _AddObjectiveDialogState extends State<AddObjectiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _objectiveController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Store Objective'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _objectiveController,
                decoration: const InputDecoration(
                  labelText: 'Objective *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (%) *',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Required';
                  final numValue = double.tryParse(value!);
                  if (numValue == null || numValue <= 0 || numValue > 100) {
                    return 'Enter value between 1-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date *',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDueDate(context),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addObjective,
          child: const Text('Add Objective'),
        ),
      ],
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _addObjective() {
    if (_formKey.currentState!.validate()) {
      final objectiveData = {
        'objective': _objectiveController.text,
        'description': _descriptionController.text,
        'weight': double.parse(_weightController.text),
        'dueDate': _dueDate?.toIso8601String(),
        'metrics': [],
      };

      widget.onAdd(objectiveData);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _objectiveController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }
}