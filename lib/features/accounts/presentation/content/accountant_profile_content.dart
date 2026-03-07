import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../models/accountant.model.dart';
import '../../providers/accountant_providers.dart';
import 'sub_widgets/accountant/accountant_edit_dialog.dart';
import 'sub_widgets/accountant/accountant_form_dialog.dart';
import 'sub_widgets/accountant/document_viewer_dialog.dart';
import 'sub_widgets/accountant/qualification_form_dialog.dart';

class AccountantProfileContent extends ConsumerStatefulWidget {
  const AccountantProfileContent({super.key});

  @override
  ConsumerState<AccountantProfileContent> createState() => _AccountantProfileContentState();
}

class _AccountantProfileContentState extends ConsumerState<AccountantProfileContent> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRefreshing = false;

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    ref.read(accountantProfileProvider.notifier).refresh();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  Future<void> _updateProfilePicture() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        await ref.read(accountantProfileProvider.notifier).uploadProfilePicture(
          bytes,
          pickedFile.name,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditDialog(String section, Accountant accountant) {
    showDialog(
      context: context,
      builder: (context) => AccountantEditDialog(
        accountant: accountant,
        section: section,
      ),
    );
  }

  void _addQualification() {
    showDialog(
      context: context,
      builder: (context) => const QualificationFormDialog(),
    );
  }

  void _viewDocument(String documentUrl) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(documentUrl: documentUrl),
    );
  }

  Future<void> _downloadDocument(String documentUrl) async {
    final uri = Uri.parse(documentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot download document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewQualificationDocument(Map<String, dynamic> qualification) {
    final documentUrl = qualification['documentUrl'];
    if (documentUrl != null && documentUrl is String) {
      _viewDocument(documentUrl);
    }
  }

  void _downloadQualificationDocument(Map<String, dynamic> qualification) {
    final documentUrl = qualification['documentUrl'];
    if (documentUrl != null && documentUrl is String) {
      _downloadDocument(documentUrl);
    }
  }

  void _viewEmployeeDocument(Map<String, dynamic> document) {
    final documentUrl = document['documentUrl'];
    if (documentUrl != null && documentUrl is String) {
      _viewDocument(documentUrl);
    }
  }

  void _downloadEmployeeDocument(Map<String, dynamic> document) {
    final documentUrl = document['documentUrl'];
    if (documentUrl != null && documentUrl is String) {
      _downloadDocument(documentUrl);
    }
  }

// Update the _createProfileFromAuth method:
  Future<void> _createProfileFromAuth() async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create a pre-filled Accountant object from auth data
      final prefilledAccountant = Accountant(
        firstName: user['firstName']?.toString().trim() ?? '',
        lastName: user['lastName']?.toString().trim() ?? '',
        email: user['email']?.toString().trim() ?? '',
        phoneNumber: user['phoneNumber']?.toString().trim() ?? user['phone']?.toString().trim() ?? '',
        employeeNumber: null, // Will be auto-generated
        jobTitle: 'accountant',
        department: 'Accounts',
        employmentType: 'full_time',
        employmentStatus: 'active',
        dateOfBirth: null, // User must select
        gender: user['gender']?.toString(),
        address: user['address']?.toString(),
        profilePictureUrl: null,
        hireDate: null, // User must select
        isActive: true,
        nationalId: user['nationalId']?.toString() ?? '',
        workLocation: 'Head Office',
        costCenter: 'FIN-001',
        bankName: null,
        bankAccountNumber: null,
        taxNumber: null,
        socialSecurityNumber: null,
        emergencyContactName: null,
        emergencyContactPhone: null,
        emergencyContactRelationship: null,
        softwareProficiencies: null,
        specializedAreas: null,
        approvalLimits: null,
        workSchedule: null,
        isAuthorizedSignatory: false,
      );

      // Show the form dialog with prefilled data - let user fill in the rest
      _showCreateProfileDialog(prefilledAccountant);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

// And update the AccountantFormDialog call in _showCreateProfileDialog:
  void _showCreateProfileDialog(Accountant? prefilledAccountant) {
    showDialog(
      context: context,
      builder: (context) => AccountantFormDialog(
        accountant: prefilledAccountant,
        isCreateProfile: true,
      ),
    ).then((_) {
      // Refresh profile after dialog closes
      _refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(accountantProfileProvider);
    final theme = Theme.of(context);

    return profileAsync.when(
      data: (accountant) {
        if (accountant == null) {
          return _buildCreateProfileState(theme);
        }
        return _buildProfileContent(accountant, theme);
      },
      loading: () => _buildShimmerLoader(),
      error: (error, stack) => _buildErrorState(error.toString(), _refreshProfile),
    );
  }

  // Build create profile state
  Widget _buildCreateProfileState(ThemeData theme) {
    final authState = ref.read(authProvider);
    final user = authState.user;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'No Accountant Profile Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You need to create an accountant profile to access all features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            // DEBUG INFO
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Debug Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Logged in as: ${user?['email'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Auth state: ${authState.isAuthenticated ? 'Authenticated' : 'Not authenticated'}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'User roles: ${authState.activeRoles.join(', ')}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _createProfileFromAuth,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Accountant Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // DEBUG BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    if (user?['email'] != null) {
                      final exists = await ref.read(accountantProfileProvider.notifier).checkProfileExists(user?['email']);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile exists: $exists'),
                            backgroundColor: exists ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text('Check Profile Exists'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(accountantProfileProvider.notifier).refreshProfile();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Force Refresh'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _refreshProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Accountant accountant, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(accountant, theme),
            const SizedBox(height: 20),

            // Quick Actions Card
            _buildQuickActionsCard(theme, accountant),
            const SizedBox(height: 20),

            // Personal Information Card
            _buildEditableInfoCard(
              title: 'Personal Information',
              icon: Icons.person_rounded,
              accountant: accountant,
              section: 'personal',
              theme: theme,
              children: [
                _buildEditableInfoItem('First Name', accountant.firstName, Icons.person_rounded, theme),
                _buildEditableInfoItem('Last Name', accountant.lastName, Icons.person_outline_rounded, theme),
                _buildEditableInfoItem('Email', accountant.email, Icons.email_rounded, theme),
                _buildEditableInfoItem('Phone', accountant.phoneNumber, Icons.phone_rounded, theme),
                _buildEditableInfoItem('Date of Birth', _formatDate(accountant.dateOfBirth), Icons.cake_rounded, theme),
                _buildEditableInfoItem('Gender', accountant.gender, Icons.transgender_rounded, theme),
                _buildEditableInfoItem('Address', accountant.address, Icons.home_rounded, theme),
                _buildEditableInfoItem('National ID', accountant.nationalId, Icons.badge_rounded, theme),
              ],
            ),
            const SizedBox(height: 20),

            // Employment Information Card
            _buildEditableInfoCard(
              title: 'Employment Information',
              icon: Icons.work_outline_rounded,
              accountant: accountant,
              section: 'employment',
              theme: theme,
              children: [
                _buildEditableInfoItem('Employee Number', accountant.employeeNumber, Icons.badge_rounded, theme),
                _buildEditableInfoItem('Job Title', accountant.jobTitle, Icons.work_rounded, theme),
                _buildEditableInfoItem('Department', accountant.department, Icons.business_rounded, theme),
                _buildEditableInfoItem('Employment Type', accountant.employmentType, Icons.assignment_rounded, theme),
                _buildEditableInfoItem('Hire Date', _formatDate(accountant.hireDate), Icons.calendar_today_rounded, theme),
                _buildEditableInfoItem('Years of Service', '${accountant.yearsOfService} years', Icons.timeline_rounded, theme),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Information Card
            if (accountant.bankName != null || accountant.bankAccountNumber != null)
              _buildEditableInfoCard(
                title: 'Financial Information',
                icon: Icons.account_balance_wallet_rounded,
                accountant: accountant,
                section: 'financial',
                theme: theme,
                children: [
                  if (accountant.salary != null) _buildEditableInfoItem('Salary', '\$${accountant.salary!.toStringAsFixed(2)}', Icons.attach_money_rounded, theme),
                  _buildEditableInfoItem('Bank Name', accountant.bankName, Icons.account_balance_rounded, theme),
                  _buildEditableInfoItem('Account Number', accountant.bankAccountNumber, Icons.credit_card_rounded, theme),
                  _buildEditableInfoItem('Tax Number', accountant.taxNumber, Icons.receipt_rounded, theme),
                  _buildEditableInfoItem('Social Security', accountant.socialSecurityNumber, Icons.security_rounded, theme),
                ],
              ),

            if (accountant.bankName != null || accountant.bankAccountNumber != null)
              const SizedBox(height: 20),

            // Emergency Contact Card
            if (accountant.emergencyContactName != null)
              _buildEditableInfoCard(
                title: 'Emergency Contact',
                icon: Icons.emergency_rounded,
                accountant: accountant,
                section: 'emergency',
                theme: theme,
                children: [
                  _buildEditableInfoItem('Contact Name', accountant.emergencyContactName, Icons.person_rounded, theme),
                  _buildEditableInfoItem('Contact Phone', accountant.emergencyContactPhone, Icons.phone_rounded, theme),
                  _buildEditableInfoItem('Relationship', accountant.emergencyContactRelationship, Icons.people_rounded, theme),
                ],
              ),

            if (accountant.emergencyContactName != null)
              const SizedBox(height: 20),

            // Qualifications Card
            _buildQualificationsCard(accountant, theme),

            // Documents Card
            if (accountant.documents != null && accountant.documents!.isNotEmpty)
              _buildDocumentsCard(accountant, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Accountant accountant, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: accountant.profilePictureUrl != null
                        ? NetworkImage(accountant.profilePictureUrl!)
                        : null,
                    child: accountant.profilePictureUrl == null
                        ? Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _updateProfilePicture,
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              accountant.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (accountant.jobTitle != null) ...[
              const SizedBox(height: 8),
              Text(
                accountant.jobTitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text(
                  accountant.email,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            if (accountant.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Text(
                    accountant.phoneNumber!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accountant.isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accountant.isActive ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                accountant.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: accountant.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(ThemeData theme, Accountant accountant) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  icon: Icons.person_rounded,
                  label: 'Edit Personal Info',
                  onTap: () => _showEditDialog('personal', accountant),
                  theme: theme,
                ),
                _buildQuickActionButton(
                  icon: Icons.work_rounded,
                  label: 'Edit Employment',
                  onTap: () => _showEditDialog('employment', accountant),
                  theme: theme,
                ),
                _buildQuickActionButton(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Edit Financial',
                  onTap: () => _showEditDialog('financial', accountant),
                  theme: theme,
                ),
                _buildQuickActionButton(
                  icon: Icons.emergency_rounded,
                  label: 'Edit Emergency Contact',
                  onTap: () => _showEditDialog('emergency', accountant),
                  theme: theme,
                ),
                _buildQuickActionButton(
                  icon: Icons.school_rounded,
                  label: 'Add Qualification',
                  onTap: _addQualification,
                  theme: theme,
                ),
                _buildQuickActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh Profile',
                  onTap: _refreshProfile,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard({
    required String title,
    required IconData icon,
    required Accountant accountant,
    required String section,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showEditDialog(section, accountant),
                  icon: Icon(Icons.edit_rounded, size: 18),
                  tooltip: 'Edit $title',
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

  Widget _buildEditableInfoItem(String label, String? value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not set',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationsCard(Accountant accountant, ThemeData theme) {
    final qualifications = accountant.accountingQualifications ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Qualifications & Certifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addQualification,
                  icon: Icon(Icons.add_rounded, size: 18),
                  tooltip: 'Add Qualification',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (qualifications.isEmpty)
              _buildEmptyQualificationState(theme)
            else
              ...qualifications.map((qualification) {
                final qual = qualification as Map<String, dynamic>;
                return _buildQualificationItem(qual, theme);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQualificationState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'No qualifications added yet',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first qualification to get started',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addQualification,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Qualification'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationItem(Map<String, dynamic> qualification, ThemeData theme) {
    final hasDocument = qualification['documentUrl'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qualification['name'] ?? 'Unnamed Qualification',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (qualification['issuingOrganization'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    qualification['issuingOrganization'],
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (qualification['issueDate'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Issued: ${_formatDate(DateTime.tryParse(qualification['issueDate']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                if (qualification['expiryDate'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${_formatDate(DateTime.tryParse(qualification['expiryDate']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasDocument) ...[
            IconButton(
              onPressed: () => _viewQualificationDocument(qualification),
              icon: Icon(Icons.visibility_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'View Document',
            ),
            IconButton(
              onPressed: () => _downloadQualificationDocument(qualification),
              icon: Icon(Icons.download_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'Download Document',
            ),
          ] else ...[
            Icon(
              Icons.no_accounts_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(Accountant accountant, ThemeData theme) {
    final documents = accountant.documents ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Badge(
                  backgroundColor: theme.colorScheme.primary,
                  label: Text(documents.length.toString()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...documents.map((document) {
              final doc = document as Map<String, dynamic>;
              return _buildDocumentItem(doc, theme);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document, ThemeData theme) {
    final hasDocument = document['documentUrl'] != null;
    final status = document['status']?.toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            _getDocumentIcon(document['type']),
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document['name'] ?? 'Unnamed Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (document['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    document['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (document['uploadDate'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded: ${_formatDate(DateTime.tryParse(document['uploadDate']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                if (status != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status, theme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasDocument) ...[
            IconButton(
              onPressed: () => _viewEmployeeDocument(document),
              icon: Icon(Icons.visibility_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'View Document',
            ),
            IconButton(
              onPressed: () => _downloadEmployeeDocument(document),
              icon: Icon(Icons.download_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'Download Document',
            ),
          ] else ...[
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'word':
        return Icons.description_rounded;
      case 'excel':
        return Icons.table_chart_rounded;
      case 'certificate':
        return Icons.verified_rounded;
      case 'license':
        return Icons.card_membership_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'verified':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }
}