import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/accountant.model.dart';
import 'document_viewer_dialog.dart';

class AccountantDetailsDialog extends ConsumerWidget {
  final Accountant accountant;

  const AccountantDetailsDialog({super.key, required this.accountant});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _viewDocument(String documentUrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(documentUrl: documentUrl),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: accountant.profilePictureUrl != null
                        ? NetworkImage(accountant.profilePictureUrl!)
                        : null,
                    child: accountant.profilePictureUrl == null
                        ? Icon(Icons.person_rounded, color: theme.colorScheme.onSurface)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountant.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (accountant.jobTitle != null)
                          Text(
                            accountant.jobTitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    _buildStatusBadge(accountant, theme),
                    const SizedBox(height: 20),

                    // Personal Information
                    _buildSection(
                      context: context,
                      title: 'Personal Information',
                      icon: Icons.person_rounded,
                      children: [
                        _buildDetailItem('Email', accountant.email, Icons.email_rounded, theme),
                        _buildDetailItem('Phone', accountant.phoneNumber, Icons.phone_rounded, theme),
                        _buildDetailItem('Employee Number', accountant.employeeNumber, Icons.badge_rounded, theme),
                        _buildDetailItem('Date of Birth', _formatDate(accountant.dateOfBirth), Icons.cake_rounded, theme),
                        _buildDetailItem('Gender', accountant.gender, Icons.transgender_rounded, theme),
                        _buildDetailItem('Address', accountant.address, Icons.home_rounded, theme),
                        _buildDetailItem('National ID', accountant.nationalId, Icons.assignment_ind_rounded, theme),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Employment Information
                    _buildSection(
                      context: context,
                      title: 'Employment Information',
                      icon: Icons.work_rounded,
                      children: [
                        _buildDetailItem('Department', accountant.department, Icons.business_rounded, theme),
                        _buildDetailItem('Employment Type', accountant.employmentType, Icons.assignment_rounded, theme),
                        _buildDetailItem('Employment Status', accountant.employmentStatus, Icons.work_outline_rounded, theme),
                        _buildDetailItem('Hire Date', _formatDate(accountant.hireDate), Icons.calendar_today_rounded, theme),
                        _buildDetailItem('Years of Service', '${accountant.yearsOfService} years', Icons.timeline_rounded, theme),
                        _buildDetailItem('Work Location', accountant.workLocation, Icons.location_on_rounded, theme),
                        _buildDetailItem('Cost Center', accountant.costCenter, Icons.account_balance_rounded, theme),
                        if (accountant.supervisorId != null)
                          _buildDetailItem('Supervisor ID', accountant.supervisorId, Icons.supervisor_account_rounded, theme),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Financial Information
                    if (accountant.bankName != null || accountant.salary != null)
                      _buildSection(
                        context: context,
                        title: 'Financial Information',
                        icon: Icons.account_balance_wallet_rounded,
                        children: [
                          if (accountant.salary != null)
                            _buildDetailItem('Salary', '\$${accountant.salary!.toStringAsFixed(2)}', Icons.attach_money_rounded, theme),
                          _buildDetailItem('Bank Name', accountant.bankName, Icons.account_balance_rounded, theme),
                          _buildDetailItem('Account Number', accountant.bankAccountNumber, Icons.credit_card_rounded, theme),
                          _buildDetailItem('Tax Number', accountant.taxNumber, Icons.receipt_rounded, theme),
                          _buildDetailItem('Social Security', accountant.socialSecurityNumber, Icons.security_rounded, theme),
                        ],
                      ),

                    if (accountant.bankName != null || accountant.salary != null)
                      const SizedBox(height: 20),

                    // Emergency Contact
                    if (accountant.emergencyContactName != null)
                      _buildSection(
                        context: context,
                        title: 'Emergency Contact',
                        icon: Icons.emergency_rounded,
                        children: [
                          _buildDetailItem('Contact Name', accountant.emergencyContactName, Icons.person_rounded, theme),
                          _buildDetailItem('Contact Phone', accountant.emergencyContactPhone, Icons.phone_rounded, theme),
                          _buildDetailItem('Relationship', accountant.emergencyContactRelationship, Icons.people_rounded, theme),
                        ],
                      ),

                    if (accountant.emergencyContactName != null)
                      const SizedBox(height: 20),

                    // System Access
                    if (accountant.systemAccess != null && accountant.systemAccess!.isNotEmpty)
                      _buildSystemAccessSection(accountant.systemAccess!, theme),

                    if (accountant.systemAccess != null && accountant.systemAccess!.isNotEmpty)
                      const SizedBox(height: 20),

                    // Qualifications
                    if (accountant.accountingQualifications != null && accountant.accountingQualifications!.isNotEmpty)
                      _buildQualificationsSection(accountant.accountingQualifications!, theme, context),

                    if (accountant.accountingQualifications != null && accountant.accountingQualifications!.isNotEmpty)
                      const SizedBox(height: 20),

                    // Documents
                    if (accountant.documents != null && accountant.documents!.isNotEmpty)
                      _buildDocumentsSection(accountant.documents!, theme, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Accountant accountant, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accountant.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accountant.isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            accountant.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: accountant.isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            accountant.isActive ? 'Active Employee' : 'Inactive Employee',
            style: TextStyle(
              color: accountant.isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not specified',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemAccessSection(List<dynamic> systemAccess, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security_rounded, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'System Access',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: systemAccess.map((access) {
            final accessMap = access as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.computer_rounded, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    accessMap['systemName'] ?? 'Unknown System',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQualificationsSection(List<dynamic> qualifications, ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Qualifications & Certifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...qualifications.map((qualification) {
          final qual = qualification as Map<String, dynamic>;
          return _buildQualificationItem(qual, theme, context);
        }).toList(),
      ],
    );
  }

  Widget _buildQualificationItem(Map<String, dynamic> qualification, ThemeData theme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 20),
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
                  const SizedBox(height: 2),
                  Text(
                    qualification['issuingOrganization'],
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                if (qualification['issueDate'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Issued: ${_formatDate(DateTime.tryParse(qualification['issueDate']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (qualification['documentUrl'] != null)
            IconButton(
              onPressed: () => _viewDocument(qualification['documentUrl'], context),
              icon: Icon(Icons.visibility_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'View Document',
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(List<dynamic> documents, ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_rounded, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...documents.map((document) {
          final doc = document as Map<String, dynamic>;
          return _buildDocumentItem(doc, theme, context);
        }).toList(),
      ],
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document, ThemeData theme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(_getDocumentIcon(document['type']), color: theme.colorScheme.primary, size: 20),
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
                if (document['uploadDate'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded: ${_formatDate(DateTime.tryParse(document['uploadDate']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
                if (document['status'] != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(document['status'], theme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      document['status'].toString().toUpperCase(),
                      style: TextStyle(
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
          if (document['documentUrl'] != null) ...[
            IconButton(
              onPressed: () => _viewDocument(document['documentUrl'], context),
              icon: Icon(Icons.visibility_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'View Document',
            ),
            IconButton(
              onPressed: () => _launchUrl(document['documentUrl']),
              icon: Icon(Icons.download_rounded, size: 18, color: theme.colorScheme.primary),
              tooltip: 'Download Document',
            ),
          ],
        ],
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
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getStatusColor(String? status, ThemeData theme) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}