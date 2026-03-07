import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tender_application_model.dart';
import '../../../../providers/tender_application_provider.dart';


class TenderApplicationDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const TenderApplicationDetailScreen({super.key, required this.applicationId});

  @override
  ConsumerState<TenderApplicationDetailScreen> createState() => _TenderApplicationDetailScreenState();
}

class _TenderApplicationDetailScreenState extends ConsumerState<TenderApplicationDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tenderApplicationProvider.notifier).getApplicationById(widget.applicationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(tenderApplicationProvider);
    final application = applicationState.selectedApplication;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(tenderApplicationProvider.notifier).getApplicationById(widget.applicationId);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleAction(value, application!);
            },
            itemBuilder: (context) => _buildActionMenu(application),
          ),
        ],
      ),
      body: applicationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : application == null
          ? const Center(child: Text('Application not found'))
          : Column(
        children: [
          // Header Section
          _buildHeaderSection(application),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: _buildTabContent(application),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(TenderApplication application) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  application.applicationNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.applicationStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(application.applicationStatus)),
                ),
                child: Text(
                  application.applicationStatus.name.replaceAll('_', ' '),
                  style: TextStyle(
                    color: _getStatusColor(application.applicationStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            application.companyProfile.companyName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          if (application.totalBidAmount != null) ...[
            const SizedBox(height: 4),
            Text(
              'KES ${application.totalBidAmount!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('Overview', 0),
            _buildTab('Financial', 1),
            _buildTab('Technical', 2),
            _buildTab('Documents', 3),
            _buildTab('Evaluation', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _selectedTab == index ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: _selectedTab == index ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(TenderApplication application) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(application);
      case 1:
        return _buildFinancialTab(application);
      case 2:
        return _buildTechnicalTab(application);
      case 3:
        return _buildDocumentsTab(application);
      case 4:
        return _buildEvaluationTab(application);
      default:
        return _buildOverviewTab(application);
    }
  }

  Widget _buildOverviewTab(TenderApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Company Information',
            Icons.business,
            [
              _buildInfoRow('Company Name', application.companyProfile.companyName),
              _buildInfoRow('Registration', application.companyProfile.registrationNumber),
              _buildInfoRow('Year Established', application.companyProfile.yearEstablished.toString()),
              _buildInfoRow('Physical Address', application.companyProfile.physicalAddress),
              _buildInfoRow('Postal Address', application.companyProfile.postalAddress),
              _buildInfoRow('Contact Person', application.companyProfile.contactPerson),
              _buildInfoRow('Contact Email', application.companyProfile.contactEmail),
              _buildInfoRow('Contact Phone', application.companyProfile.contactPhone),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Application Details',
            Icons.assignment,
            [
              _buildInfoRow('Submission Method', application.submissionMethod.name.replaceAll('_', ' ')),
              _buildInfoRow('Submission Date', application.submissionDate != null
                  ? _formatDetailedDate(application.submissionDate!)
                  : 'Not submitted'
              ),
              _buildInfoRow('Bid Validity', application.bidValidityPeriod != null
                  ? '${application.bidValidityPeriod} days'
                  : 'Not specified'
              ),
              _buildInfoRow('Currency', application.currency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab(TenderApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (application.totalBidAmount != null)
            _buildSectionCard(
              'Financial Summary',
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.green),
                    title: const Text('Total Bid Amount'),
                    trailing: Text(
                      'KES ${application.totalBidAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (application.bidAmountBreakdown.isNotEmpty)
            _buildSectionCard(
              'Bid Amount Breakdown',
              Column(
                children: application.bidAmountBreakdown.map((item) => _buildBreakdownItem(item)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (application.bidSecurity != null)
            _buildSectionCard(
              'Bid Security',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Type', application.bidSecurity!.type.name.replaceAll('_', ' ')),
                  _buildInfoRow('Amount', 'KES ${application.bidSecurity!.amount.toStringAsFixed(0)}'),
                  _buildInfoRow('Issuer', application.bidSecurity!.issuer),
                  _buildInfoRow('Reference', application.bidSecurity!.referenceNumber),
                  _buildInfoRow('Issue Date', _formatDate(application.bidSecurity!.issueDate)),
                  _buildInfoRow('Expiry Date', _formatDate(application.bidSecurity!.expiryDate)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTechnicalTab(TenderApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (application.technicalProposal != null)
            _buildSectionCard(
              'Technical Proposal',
              Text(
                application.technicalProposal!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          const SizedBox(height: 16),
          if (application.methodology != null)
            _buildSectionCard(
              'Methodology',
              Text(
                application.methodology!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          const SizedBox(height: 16),
          if (application.workPlan.isNotEmpty)
            _buildSectionCard(
              'Work Plan',
              Column(
                children: application.workPlan.map((item) => _buildWorkPlanItem(item)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (application.keyPersonnel.isNotEmpty)
            _buildSectionCard(
              'Key Personnel',
              Column(
                children: application.keyPersonnel.map((person) => _buildPersonnelItem(person)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(TenderApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (application.technicalDocuments.isNotEmpty)
            _buildSectionCard(
              'Technical Documents',
              Column(
                children: application.technicalDocuments.map((doc) => _buildDocumentItem(doc)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (application.financialDocuments.isNotEmpty)
            _buildSectionCard(
              'Financial Documents',
              Column(
                children: application.financialDocuments.map((doc) => _buildFinancialDocumentItem(doc)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (application.taxCompliance != null)
            _buildSectionCard(
              'Tax Compliance',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('PIN Certificate', application.taxCompliance!.pinCertificate),
                  _buildInfoRow('Tax Compliance', application.taxCompliance!.taxComplianceUrl),
                  _buildInfoRow('Validity Period', application.taxCompliance!.validityPeriod),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluationTab(TenderApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (application.technicalScore != null || application.financialScore != null)
            _buildSectionCard(
              'Evaluation Scores',
              Column(
                children: [
                  if (application.technicalScore != null)
                    _buildScoreItem('Technical Score', application.technicalScore!),
                  if (application.financialScore != null)
                    _buildScoreItem('Financial Score', application.financialScore!),
                  if (application.totalScore != null)
                    _buildScoreItem('Total Score', application.totalScore!, isTotal: true),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (application.evaluationRemarks != null)
            _buildSectionCard(
              'Evaluation Remarks',
              Text(application.evaluationRemarks!),
            ),
          const SizedBox(height: 16),
          if (application.evaluatedBy != null)
            _buildSectionCard(
              'Evaluation Details',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Evaluated By', application.evaluatedBy!),
                  if (application.evaluationDate != null)
                    _buildInfoRow('Evaluation Date', _formatDetailedDate(application.evaluationDate!)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(BidAmountBreakdown item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.item,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.quantity} ${item.unit}'),
                Text('KES ${item.unitPrice.toStringAsFixed(2)}/unit'),
                Text(
                  'KES ${item.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkPlanItem(WorkPlanItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.activity,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Duration: ${item.duration} days'),
                const SizedBox(width: 16),
                Text('Responsible: ${item.responsible}'),
              ],
            ),
            const SizedBox(height: 4),
            Text('${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelItem(KeyPersonnel person) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${person.position} - ${person.role}'),
            const SizedBox(height: 4),
            Text('${person.experience} years experience'),
            const SizedBox(height: 4),
            Text('Qualifications: ${person.qualifications}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(TechnicalDocument doc) {
    return ListTile(
      leading: const Icon(Icons.description, color: Colors.blue),
      title: Text(doc.documentName),
      subtitle: Text('${(doc.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // Handle document download
        },
      ),
    );
  }

  Widget _buildFinancialDocumentItem(FinancialDocument doc) {
    return ListTile(
      leading: const Icon(Icons.receipt, color: Colors.green),
      title: Text(doc.documentName),
      subtitle: Text(doc.documentType),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // Handle document download
        },
      ),
    );
  }

  Widget _buildScoreItem(String label, double score, {bool isTotal = false}) {
    return ListTile(
      leading: Icon(
        isTotal ? Icons.star : Icons.assessment,
        color: isTotal ? Colors.amber : Colors.blue,
      ),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isTotal ? Colors.amber[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isTotal ? Colors.amber : Colors.blue),
        ),
        child: Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            color: isTotal ? Colors.amber[800] : Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildActionMenu(TenderApplication? application) {
    final actions = <PopupMenuEntry<String>>[];

    if (application != null) {
      if (application.applicationStatus == ApplicationStatus.DRAFT) {
        actions.add(const PopupMenuItem<String>(
          value: 'submit',
          child: Text('Submit Application'),
        ));
      }

      if (application.applicationStatus == ApplicationStatus.SUBMITTED ||
          application.applicationStatus == ApplicationStatus.UNDER_REVIEW) {
        actions.add(const PopupMenuItem<String>(
          value: 'withdraw',
          child: Text('Withdraw Application'),
        ));
      }

      if (application.applicationStatus == ApplicationStatus.PENDING_CLARIFICATION) {
        actions.add(const PopupMenuItem<String>(
          value: 'clarify',
          child: Text('Provide Clarification'),
        ));
      }

      // For procurement staff
      if (application.applicationStatus == ApplicationStatus.SUBMITTED) {
        actions.add(const PopupMenuDivider());
        actions.add(const PopupMenuItem<String>(
          value: 'evaluate',
          child: Text('Evaluate Application'),
        ));
      }

      if (application.applicationStatus == ApplicationStatus.QUALIFIED) {
        actions.add(const PopupMenuItem<String>(
          value: 'award',
          child: Text('Award Contract'),
        ));
      }
    }

    return actions;
  }

  void _handleAction(String action, TenderApplication application) {
    switch (action) {
      case 'submit':
        _submitApplication();
        break;
      case 'withdraw':
        _withdrawApplication();
        break;
      case 'evaluate':
        _showEvaluationDialog(application);
        break;
      case 'award':
        _awardContract(application);
        break;
    }
  }

  Future<void> _submitApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Application'),
        content: const Text('Are you sure you want to submit this application? Once submitted, you cannot make changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(tenderApplicationProvider.notifier).submitApplication(
        widget.applicationId,
        DateTime.now(),
      );

      if (success && mounted) {
        // Refresh the application
        ref.read(tenderApplicationProvider.notifier).getApplicationById(widget.applicationId);
      }
    }
  }

  Future<void> _withdrawApplication() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for withdrawal:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      final success = await ref.read(tenderApplicationProvider.notifier).withdrawApplication(
        widget.applicationId,
        reasonController.text,
      );

      if (success && mounted) {
        ref.read(tenderApplicationProvider.notifier).getApplicationById(widget.applicationId);
      }
    }
  }

  void _showEvaluationDialog(TenderApplication application) {
    // Implementation for evaluation dialog
  }

  void _awardContract(TenderApplication application) {
    // Implementation for awarding contract
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.DRAFT:
        return Colors.grey;
      case ApplicationStatus.SUBMITTED:
        return Colors.blue;
      case ApplicationStatus.UNDER_REVIEW:
        return Colors.orange;
      case ApplicationStatus.TECHNICAL_EVALUATION:
        return Colors.deepOrange;
      case ApplicationStatus.FINANCIAL_EVALUATION:
        return Colors.purple;
      case ApplicationStatus.QUALIFIED:
        return Colors.green;
      case ApplicationStatus.DISQUALIFIED:
        return Colors.red;
      case ApplicationStatus.AWARDED:
        return Colors.teal;
      case ApplicationStatus.REJECTED:
        return Colors.red;
      case ApplicationStatus.WITHDRAWN:
        return Colors.brown;
      case ApplicationStatus.PENDING_CLARIFICATION:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}