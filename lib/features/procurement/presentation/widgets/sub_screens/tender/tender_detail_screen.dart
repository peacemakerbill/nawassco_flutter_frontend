import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tender_application_model.dart';
import '../../../../domain/models/tender_model.dart' hide ClarificationStatus;
import '../../../../providers/tender_provider.dart';

class TenderDetailScreen extends ConsumerStatefulWidget {
  final String tenderId;

  const TenderDetailScreen({super.key, required this.tenderId});

  @override
  ConsumerState<TenderDetailScreen> createState() => _TenderDetailScreenState();
}

class _TenderDetailScreenState extends ConsumerState<TenderDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tenderProvider.notifier).getTenderById(widget.tenderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenderState = ref.watch(tenderProvider);
    final tender = tenderState.selectedTender;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tender Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(tenderProvider.notifier).getTenderById(widget.tenderId);
            },
          ),
        ],
      ),
      body: tenderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tender == null
          ? const Center(child: Text('Tender not found'))
          : Column(
        children: [
          // Header Section
          _buildHeaderSection(tender),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: _buildTabContent(tender),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Tender tender) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tender.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(tender.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(tender.status)),
                ),
                child: Text(
                  tender.status.name.replaceAll('_', ' '),
                  style: TextStyle(
                    color: _getStatusColor(tender.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tender.tenderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tender.description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Requirements', 1),
          _buildTab('Timeline', 2),
          _buildTab('Documents', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
              color: _selectedTab == index ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Tender tender) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(tender);
      case 1:
        return _buildRequirementsTab(tender);
      case 2:
        return _buildTimelineTab(tender);
      case 3:
        return _buildDocumentsTab(tender);
      default:
        return _buildOverviewTab(tender);
    }
  }

  Widget _buildOverviewTab(Tender tender) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Basic Information',
            Icons.info,
            [
              _buildInfoRow('Tender Number', tender.tenderNumber),
              _buildInfoRow('Reference', tender.referenceNumber ?? 'N/A'),
              _buildInfoRow('Category', tender.category.name.replaceAll('_', ' ')),
              _buildInfoRow('Type', tender.tenderType.name),
              _buildInfoRow('Procurement Method', tender.procurementMethod.name.replaceAll('_', ' ')),
              _buildInfoRow('Department', tender.department),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Financial Information',
            Icons.attach_money,
            [
              _buildInfoRow('Estimated Budget', 'KES ${tender.estimatedBudget.toStringAsFixed(0)}'),
              _buildInfoRow('Tender Fee', 'KES ${tender.tenderFee.toStringAsFixed(0)}'),
              _buildInfoRow('Bid Security', 'KES ${tender.bidSecurityAmount.toStringAsFixed(0)}'),
              _buildInfoRow('Currency', tender.currency),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Contact Information',
            Icons.contact_mail,
            [
              _buildInfoRow('Contact Person', tender.contactPerson),
              _buildInfoRow('Email', tender.contactEmail),
              _buildInfoRow('Phone', tender.contactPhone),
              _buildInfoRow('Department', tender.contactDepartment),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Bidding Information',
            Icons.assignment,
            [
              _buildInfoRow('Bid Opening Venue', tender.bidOpeningVenue),
              _buildInfoRow('Submission Method', tender.bidSubmissionMethod.name.replaceAll('_', ' ')),
              _buildInfoRow('Bid Validity Period', '${tender.bidValidityPeriod} days'),
              _buildInfoRow('Contract Duration', '${tender.contractDuration} months'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab(Tender tender) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tender.eligibilityCriteria.isNotEmpty)
            _buildSectionCard(
              'Eligibility Criteria',
              Column(
                children: tender.eligibilityCriteria.map((criterion) => _buildCriterionItem(criterion)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.technicalRequirements.isNotEmpty)
            _buildSectionCard(
              'Technical Requirements',
              Column(
                children: tender.technicalRequirements.map((req) => _buildRequirementItem(req)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.financialRequirements.isNotEmpty)
            _buildSectionCard(
              'Financial Requirements',
              Column(
                children: tender.financialRequirements.map((req) => _buildFinancialRequirementItem(req)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.experienceRequirements.isNotEmpty)
            _buildSectionCard(
              'Experience Requirements',
              Column(
                children: tender.experienceRequirements.map((req) => _buildExperienceRequirementItem(req)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.evaluationCriteria.isNotEmpty)
            _buildSectionCard(
              'Evaluation Criteria',
              Column(
                children: tender.evaluationCriteria.map((criterion) => _buildEvaluationCriterion(criterion)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(Tender tender) {
    final timelineEvents = <Widget>[
      if (tender.publishedDate != null)
        _buildTimelineEvent('Published', tender.publishedDate!, Icons.publish),
      if (tender.advertisementDate != null)
        _buildTimelineEvent('Advertisement', tender.advertisementDate!, Icons.campaign),
      _buildTimelineEvent('Closing', tender.closingDate, Icons.event_busy),
      _buildTimelineEvent('Opening', tender.openingDate, Icons.event_available),
      if (tender.preBidMeetingDate != null)
        _buildTimelineEvent('Pre-Bid Meeting', tender.preBidMeetingDate!, Icons.groups),
      if (tender.siteVisitDate != null)
        _buildTimelineEvent('Site Visit', tender.siteVisitDate!, Icons.location_on),
      if (tender.clarificationDeadline != null)
        _buildTimelineEvent('Clarification Deadline', tender.clarificationDeadline!, Icons.help_outline),
      if (tender.evaluationStartDate != null)
        _buildTimelineEvent('Evaluation Start', tender.evaluationStartDate!, Icons.assessment),
      if (tender.evaluationEndDate != null)
        _buildTimelineEvent('Evaluation End', tender.evaluationEndDate!, Icons.assignment_turned_in),
      if (tender.awardDate != null)
        _buildTimelineEvent('Awarded', tender.awardDate!, Icons.emoji_events),
      if (tender.contractSigningDate != null)
        _buildTimelineEvent('Contract Signing', tender.contractSigningDate!, Icons.assignment),
      if (tender.completionDate != null)
        _buildTimelineEvent('Completed', tender.completionDate!, Icons.check_circle),
    ];

    // Add created/updated dates for context
    timelineEvents.addAll([
      _buildTimelineEvent('Created', tender.createdAt, Icons.create, isSystem: true),
      _buildTimelineEvent('Last Updated', tender.updatedAt, Icons.update, isSystem: true),
    ]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: timelineEvents.isEmpty
          ? const Center(
        child: Text(
          'No timeline events available',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : Column(
        children: timelineEvents,
      ),
    );
  }

  Widget _buildDocumentsTab(Tender tender) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tender.biddingDocuments.isNotEmpty)
            _buildSectionCard(
              'Bidding Documents',
              Column(
                children: tender.biddingDocuments.map((doc) => _buildDocumentItem(doc)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.technicalSpecifications.isNotEmpty)
            _buildSectionCard(
              'Technical Specifications',
              Column(
                children: tender.technicalSpecifications.map((doc) => _buildDocumentItem(doc)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.drawings.isNotEmpty)
            _buildSectionCard(
              'Drawings',
              Column(
                children: tender.drawings.map((doc) => _buildDocumentItem(doc)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.amendments.isNotEmpty)
            _buildSectionCard(
              'Amendments',
              Column(
                children: tender.amendments.map((amendment) => _buildAmendmentItem(amendment)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (tender.clarifications.isNotEmpty)
            _buildSectionCard(
              'Clarifications',
              Column(
                children: tender.clarifications.map((clarification) => _buildClarificationItem(clarification)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widgets for building content
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

  Widget _buildCriterionItem(EligibilityCriterion criterion) {
    return ListTile(
      leading: Icon(
        criterion.isMandatory ? Icons.check_circle : Icons.radio_button_unchecked,
        color: criterion.isMandatory ? Colors.green : Colors.grey,
      ),
      title: Text(criterion.criterion),
      subtitle: Text(criterion.description),
      dense: true,
    );
  }

  Widget _buildRequirementItem(TechnicalRequirement requirement) {
    return ListTile(
      leading: Icon(
        requirement.isMandatory ? Icons.check_circle : Icons.radio_button_unchecked,
        color: requirement.isMandatory ? Colors.green : Colors.grey,
      ),
      title: Text(requirement.requirement),
      subtitle: Text(requirement.description),
      dense: true,
    );
  }

  Widget _buildFinancialRequirementItem(FinancialRequirement requirement) {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: Colors.green),
      title: Text(requirement.requirement),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(requirement.description),
          if (requirement.minimumValue != null)
            Text(
              'Minimum: KES ${requirement.minimumValue!.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
      dense: true,
    );
  }

  Widget _buildExperienceRequirementItem(ExperienceRequirement requirement) {
    return ListTile(
      leading: const Icon(Icons.work_history, color: Colors.orange),
      title: Text(requirement.type),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(requirement.description),
          Text('Minimum ${requirement.minimumYears} years experience'),
          Text('${requirement.similarProjectsRequired} similar projects required'),
          if (requirement.annualTurnover != null)
            Text(
              'Annual turnover: KES ${requirement.annualTurnover!.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
      dense: true,
    );
  }

  Widget _buildEvaluationCriterion(EvaluationCriterion criterion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    criterion.criterion,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Chip(
                  label: Text('${criterion.weight}%'),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              criterion.description,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (criterion.subCriteria != null && criterion.subCriteria!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Sub-criteria:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              ...criterion.subCriteria!.map((sub) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    Text('• ${sub.subCriterion}'),
                    const Spacer(),
                    Text('${sub.weight}%'),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(String title, DateTime date, IconData icon, {bool isSystem = false}) {
    final now = DateTime.now();
    final isPast = date.isBefore(now);
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    Color getStatusColor() {
      if (isSystem) return Colors.grey;
      if (isToday) return Colors.blue;
      return isPast ? Colors.green : Colors.orange;
    }

    String getStatusText() {
      if (isSystem) return 'System';
      if (isToday) return 'Today';
      return isPast ? 'Completed' : 'Upcoming';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      color: isSystem ? Colors.grey[50] : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: getStatusColor(), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSystem ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDetailedDate(date)),
            const SizedBox(height: 2),
            Text(
              getStatusText(),
              style: TextStyle(
                color: getStatusColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatDate(date),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String documentUrl) {
    final fileName = documentUrl.split('/').last;
    return ListTile(
      leading: const Icon(Icons.description, color: Colors.blue),
      title: Text(fileName),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // Handle document download
          _showDownloadDialog(fileName);
        },
      ),
    );
  }

  Widget _buildAmendmentItem(TenderAmendment amendment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amendment.amendmentNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_formatDate(amendment.amendmentDate)),
              ],
            ),
            const SizedBox(height: 8),
            Text(amendment.description),
            if (amendment.changes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Changes:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...amendment.changes.map((change) => Text('• $change')).toList(),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Issued by: ${amendment.issuedBy}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClarificationItem(TenderClarification clarification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    clarification.question,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getClarificationStatusColor(clarification.status as ClarificationStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    clarification.status.name,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (clarification.answer != null) ...[
              Text(
                'Answer: ${clarification.answer}',
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.person, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Asked by: ${clarification.questionBy}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  _formatDate(clarification.questionDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadDialog(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Document'),
        content: Text('Would you like to download "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement download logic here
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TenderStatus status) {
    switch (status) {
      case TenderStatus.DRAFT:
        return Colors.grey;
      case TenderStatus.UNDER_REVIEW:
        return Colors.orange;
      case TenderStatus.APPROVED:
        return Colors.blue;
      case TenderStatus.PUBLISHED:
        return Colors.green;
      case TenderStatus.ACTIVE:
        return Colors.lightGreen;
      case TenderStatus.CLOSED:
        return Colors.purple;
      case TenderStatus.AWARDED:
        return Colors.teal;
      case TenderStatus.COMPLETED:
        return Colors.indigo;
      case TenderStatus.CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getClarificationStatusColor(ClarificationStatus status) {
    switch (status) {
      case ClarificationStatus.PENDING:
        return Colors.orange;
      case ClarificationStatus.ANSWERED:
        return Colors.green;
      case ClarificationStatus.REJECTED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}