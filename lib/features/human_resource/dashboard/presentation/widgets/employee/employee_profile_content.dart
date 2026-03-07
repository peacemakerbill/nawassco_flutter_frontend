import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../models/employee_model.dart';
import '../../../../providers/employee_provider.dart';
import '../sub_widgets/employee/create_employee_profile_screen.dart';
import '../sub_widgets/employee/document_card.dart';
import '../sub_widgets/employee/employment_history_card.dart';
import '../sub_widgets/employee/profile_section_card.dart';
import '../sub_widgets/employee/qualification_card.dart';
import '../sub_widgets/employee/skill_chip.dart';

class EmployeeProfileContent extends ConsumerStatefulWidget {
  const EmployeeProfileContent({super.key});

  @override
  ConsumerState<EmployeeProfileContent> createState() => _EmployeeProfileContentState();
}

class _EmployeeProfileContentState extends ConsumerState<EmployeeProfileContent> {
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  late Map<String, dynamic> _editData;

  @override
  void initState() {
    super.initState();
    _editData = {};
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      // In a real app, you would upload this image
      // For now, we'll just update the local state
      setState(() {
        _editData['profilePictureUrl'] = picked.path;
      });
    }
  }

  void _startEditing(Employee employee) {
    setState(() {
      _isEditing = true;
      _editData = {
        'personalDetails': {
          'firstName': employee.personalDetails.firstName,
          'lastName': employee.personalDetails.lastName,
          'middleName': employee.personalDetails.middleName,
          'gender': employee.personalDetails.gender,
          'maritalStatus': employee.personalDetails.maritalStatus,
        },
        'contactInformation': {
          'personalEmail': employee.personalEmail,
          'workEmail': employee.workEmail,
          'personalPhone': employee.personalPhone,
          'workPhone': employee.workPhone,
        },
      };
    });
  }

  Future<void> _saveChanges() async {
    final provider = ref.read(employeeProvider.notifier);
    final currentEmployee = ref.read(employeeProvider).currentEmployee;

    if (currentEmployee != null) {
      final success = await provider.updateEmployee(currentEmployee.id, _editData);

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _editData = {};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editData = {};
    });
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Employee Profile Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You need to create your employee profile to access all features',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create profile
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateEmployeeProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Create Employee Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final currentEmployee = employeeState.currentEmployee;

    if (employeeState.isLoading && currentEmployee == null) {
      return _buildLoadingState();
    }

    if (currentEmployee == null) {
      return _buildEmptyState();
    }

    return _buildProfileContent(currentEmployee, employeeState);
  }

  Widget _buildProfileContent(Employee employee, EmployeeState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(employeeProvider.notifier).loadEmployees();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Profile Card
            _buildHeroCard(employee, theme),

            const SizedBox(height: 20),

            // Employment Info Card
            ProfileSectionCard(
              title: 'Employment Information',
              icon: Icons.business_center,
              children: _buildEmploymentInfo(employee),
            ),

            const SizedBox(height: 20),

            // Personal Information Card
            ProfileSectionCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: _buildPersonalInfo(employee),
              showEditButton: !_isEditing,
              onEdit: () => _startEditing(employee),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 16),
              _buildEditForm(),
            ],

            const SizedBox(height: 20),

            // Contact Information Card
            ProfileSectionCard(
              title: 'Contact Information',
              icon: Icons.contact_mail,
              children: _buildContactInfo(employee),
            ),

            const SizedBox(height: 20),

            // Skills & Qualifications Section
            if (employee.skills.isNotEmpty || employee.qualifications.isNotEmpty)
              Column(
                children: [
                  ProfileSectionCard(
                    title: 'Skills & Qualifications',
                    icon: Icons.school,
                    children: [
                      if (employee.skills.isNotEmpty) ...[
                        _buildSkillsSection(employee),
                        const SizedBox(height: 16),
                      ],
                      if (employee.qualifications.isNotEmpty)
                        _buildQualificationsSection(employee),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Documents Section
            if (employee.documents.isNotEmpty)
              Column(
                children: [
                  ProfileSectionCard(
                    title: 'Documents',
                    icon: Icons.folder,
                    children: _buildDocumentsSection(employee),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Employment History
            if (employee.employmentHistory.isNotEmpty)
              Column(
                children: [
                  ProfileSectionCard(
                    title: 'Employment History',
                    icon: Icons.history,
                    children: _buildEmploymentHistory(employee),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Promotion History
            if (employee.promotionHistory.isNotEmpty)
              ProfileSectionCard(
                title: 'Promotion History',
                icon: Icons.trending_up,
                children: _buildPromotionHistory(employee),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Employee employee, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture and Basic Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: theme.colorScheme.surface,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        // In real app, you would use NetworkImage
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.jobTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              employee.department,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(employee.employmentStatus).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getStatusColor(employee.employmentStatus)),
                            ),
                            child: Text(
                              employee.employmentStatus.toString().split('.').last.replaceAll('_', ' '),
                              style: TextStyle(
                                color: _getStatusColor(employee.employmentStatus),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Stats Row
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Employee ID', employee.employeeNumber, Icons.badge),
                  _buildStatItem('Years of Service', '${employee.yearsOfService}', Icons.calendar_today),
                  _buildStatItem('Age', '${employee.age}', Icons.cake),
                  _buildStatItem('Net Salary', '${employee.salaryCurrency} ${employee.netSalary.toStringAsFixed(2)}', Icons.monetization_on),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEmploymentInfo(Employee employee) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return [
      _buildInfoRow('Employee Number', employee.employeeNumber),
      _buildInfoRow('Hire Date', dateFormat.format(employee.hireDate)),
      _buildInfoRow('Employment Type', employee.employmentType.toString().split('.').last),
      _buildInfoRow('Employment Category', employee.employmentCategory.toString().split('.').last),
      _buildInfoRow('Job Grade', employee.jobGrade),
      _buildInfoRow('Basic Salary', '${employee.salaryCurrency} ${employee.basicSalary.toStringAsFixed(2)}'),
    ];
  }

  List<Widget> _buildPersonalInfo(Employee employee) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return [
      _buildInfoRow('First Name', employee.personalDetails.firstName),
      if (employee.personalDetails.middleName != null)
        _buildInfoRow('Middle Name', employee.personalDetails.middleName!),
      _buildInfoRow('Last Name', employee.personalDetails.lastName),
      _buildInfoRow('Date of Birth', dateFormat.format(employee.personalDetails.dateOfBirth)),
      _buildInfoRow('Gender', employee.personalDetails.gender.toString().split('.').last),
      _buildInfoRow('Marital Status', employee.personalDetails.maritalStatus.toString().split('.').last),
      _buildInfoRow('Nationality', employee.personalDetails.nationality),
      _buildInfoRow('National ID', employee.personalDetails.nationalId),
      _buildInfoRow('Tax Number', employee.personalDetails.taxNumber),
      if (employee.personalDetails.passportNumber != null)
        _buildInfoRow('Passport Number', employee.personalDetails.passportNumber!),
      _buildInfoRow('Social Security', employee.personalDetails.socialSecurityNumber),
    ];
  }

  List<Widget> _buildContactInfo(Employee employee) {
    return [
      _buildInfoRow('Personal Email', employee.personalEmail, icon: Icons.email),
      _buildInfoRow('Work Email', employee.workEmail, icon: Icons.work),
      _buildInfoRow('Personal Phone', employee.personalPhone, icon: Icons.phone),
      if (employee.workPhone != null)
        _buildInfoRow('Work Phone', employee.workPhone!, icon: Icons.phone_android),
    ];
  }

  Widget _buildSkillsSection(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: employee.skills.map((skill) {
            return SkillChip(skill: skill);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQualificationsSection(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qualifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...employee.qualifications.map((qualification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QualificationCard(qualification: qualification),
          );
        }).toList(),
      ],
    );
  }

  List<Widget> _buildDocumentsSection(Employee employee) {
    return [
      ...employee.documents.map((document) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DocumentCard(document: document),
        );
      }).toList(),
    ];
  }

  List<Widget> _buildEmploymentHistory(Employee employee) {
    return [
      ...employee.employmentHistory.map((history) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EmploymentHistoryCard(history: history),
        );
      }).toList(),
    ];
  }

  List<Widget> _buildPromotionHistory(Employee employee) {
    final dateFormat = DateFormat('MMM yyyy');
    return [
      ...employee.promotionHistory.map((promotion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(promotion.promotionDate),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Promotion',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.previousPosition,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From: ${promotion.salaryBefore.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.newPosition,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'To: ${promotion.salaryAfter.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (promotion.reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${promotion.reason}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Add form fields here based on _editData
          // For brevity, I'll add a simple example
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
            initialValue: _editData['personalDetails']?['firstName'],
            onChanged: (value) {
              setState(() {
                _editData['personalDetails']['firstName'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEditing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.active:
        return Colors.green;
      case EmploymentStatus.on_leave:
        return Colors.orange;
      case EmploymentStatus.suspended:
        return Colors.red;
      case EmploymentStatus.terminated:
        return Colors.grey;
      case EmploymentStatus.retired:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}