import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../models/employee_model.dart';
import 'document_card.dart';
import 'employment_history_card.dart';
import 'profile_section_card.dart';
import 'qualification_card.dart';
import 'skill_chip.dart';


class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Employee employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/pattern.png'),
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Profile Info
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.surface,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            employee.jobTitle,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  employee.department,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(employee.employmentStatus).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _getStatusColor(employee.employmentStatus)),
                                ),
                                child: Text(
                                  employee.employmentStatus.toString().split('.').last.replaceAll('_', ' '),
                                  style: TextStyle(
                                    color: _getStatusColor(employee.employmentStatus),
                                    fontSize: 14,
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
              ),
            ),
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Quick Stats
                    _buildQuickStats(employee, theme),
                    const SizedBox(height: 20),

                    // Employment Information
                    ProfileSectionCard(
                      title: 'Employment Information',
                      icon: Icons.business_center,
                      children: _buildEmploymentInfo(employee),
                    ),
                    const SizedBox(height: 20),

                    // Personal Information
                    ProfileSectionCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      children: _buildPersonalInfo(employee),
                    ),
                    const SizedBox(height: 20),

                    // Contact Information
                    ProfileSectionCard(
                      title: 'Contact Information',
                      icon: Icons.contact_mail,
                      children: _buildContactInfo(employee),
                    ),
                    const SizedBox(height: 20),

                    // Skills & Qualifications
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

                    // Documents
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
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Employee employee, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('ID', employee.employeeNumber, Icons.badge, theme),
          _buildStatItem('Service', '${employee.yearsOfService} yrs', Icons.calendar_today, theme),
          _buildStatItem('Age', '${employee.age}', Icons.cake, theme),
          _buildStatItem('Salary', '${employee.salaryCurrency} ${employee.netSalary.toStringAsFixed(0)}', Icons.monetization_on, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
      _buildInfoRow('Employment Status', employee.employmentStatus.toString().split('.').last.replaceAll('_', ' ')),
      _buildInfoRow('Employment Category', employee.employmentCategory.toString().split('.').last),
      _buildInfoRow('Department', employee.department),
      _buildInfoRow('Job Title', employee.jobTitle),
      _buildInfoRow('Job Grade', employee.jobGrade),
      _buildInfoRow('Basic Salary', '${employee.salaryCurrency} ${employee.basicSalary.toStringAsFixed(2)}'),
      _buildInfoRow('Net Salary', '${employee.salaryCurrency} ${employee.netSalary.toStringAsFixed(2)}'),
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
      if (employee.personalDetails.passportNumber != null)
        _buildInfoRow('Passport Number', employee.personalDetails.passportNumber!),
      _buildInfoRow('Tax Number', employee.personalDetails.taxNumber),
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
      }),
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