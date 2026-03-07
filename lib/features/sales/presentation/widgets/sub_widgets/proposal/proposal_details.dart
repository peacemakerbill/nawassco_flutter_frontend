import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/customer.model.dart';
import '../../../../models/proposal.model.dart';

class ProposalDetails extends StatelessWidget {
  final Proposal proposal;
  final List<Customer> customers;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const ProposalDetails({
    super.key,
    required this.proposal,
    required this.customers,
    required this.onEdit,
    required this.onClose,
  });

  Color _getStatusColor(ProposalStatus status) {
    return switch (status) {
      ProposalStatus.draft => const Color(0xFF9E9E9E),
      ProposalStatus.submitted => const Color(0xFF2196F3),
      ProposalStatus.under_review => const Color(0xFFFF9800),
      ProposalStatus.revised => const Color(0xFF9C27B0),
      ProposalStatus.negotiation => const Color(0xFF3F51B5),
      ProposalStatus.accepted => const Color(0xFF4CAF50),
      ProposalStatus.rejected => const Color(0xFFF44336),
      ProposalStatus.expired => const Color(0xFF607D8B),
      ProposalStatus.signed => const Color(0xFF009688),
      ProposalStatus.converted_to_contract => const Color(0xFF795548),
    };
  }

  Color _getApprovalColor(ApprovalStatus status) {
    return switch (status) {
      ApprovalStatus.pending => const Color(0xFFFF9800),
      ApprovalStatus.approved => const Color(0xFF4CAF50),
      ApprovalStatus.rejected => const Color(0xFFF44336),
      ApprovalStatus.requires_revision => const Color(0xFF2196F3),
    };
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getCustomerName() {
    final customer = customers.firstWhere(
          (c) => c.id == proposal.customer,
      orElse: () => Customer(
        id: '',
        customerNumber: '',
        customerType: CustomerType.residential,
        firstName: 'Unknown',
        lastName: 'Customer',
        email: '',
        phone: '',
        customerSince: DateTime.now(),
        billingInformation: BillingInformation(
          paymentMethod: PaymentMethod.bank_transfer,
        ),
        paymentTerms: const PaymentTerms(),
        connectionDetails: ConnectionDetails(
          connectionDate: DateTime.now(),
          connectionType: ConnectionType.new_connection,
        ),
        customerSegment: CustomerSegment.standard,
        status: CustomerStatus.prospect,
        salesSource: SalesSource.walk_in,
        communicationPreferences: const CommunicationPreferences(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return customer.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(proposal.proposalNumber),
        actions: [
          if (proposal.canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit Proposal',
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Close',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildOverviewSection(context),
              const SizedBox(height: 24),
              _buildContentSection(context),
              const SizedBox(height: 24),
              _buildFinancialSection(context),
              const SizedBox(height: 24),
              _buildItemsSection(context),
              const SizedBox(height: 24),
              _buildPaymentScheduleSection(context),
              const SizedBox(height: 24),
              _buildTimelineSection(context),
              const SizedBox(height: 24),
              _buildReviewSection(context),
              const SizedBox(height: 24),
              _buildSignatureSection(context),
              const SizedBox(height: 24),
              _buildMetadataSection(context),
              const SizedBox(height: 32),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(proposal.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _getStatusColor(proposal.status),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: _getStatusColor(proposal.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.proposalNumber,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCustomerName(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(proposal.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(proposal.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        proposal.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(proposal.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getApprovalColor(proposal.approvalStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getApprovalColor(proposal.approvalStatus),
                        ),
                      ),
                      child: Text(
                        proposal.approvalStatus.displayName,
                        style: TextStyle(
                          color: _getApprovalColor(proposal.approvalStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  'Version ${proposal.version}',
                  theme.primaryColor,
                ),
                _buildChip(
                  proposal.pricingModel.displayName,
                  Colors.deepPurple,
                ),
                if (proposal.validityDate != null)
                  _buildChip(
                    'Valid until ${_formatDate(proposal.validityDate)}',
                    Colors.green,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isVerySmall = constraints.maxWidth < 400;
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isVerySmall ? 1.3 : 1.8,
                  children: [
                    _buildStatCard(
                      context,
                      'Total Amount',
                      'KES ${proposal.totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money_outlined,
                      Colors.green,
                      isSmallScreen: isVerySmall,
                    ),
                    _buildStatCard(
                      context,
                      'Subtotal',
                      'KES ${proposal.subtotal.toStringAsFixed(2)}',
                      Icons.receipt_outlined,
                      Colors.blue,
                      isSmallScreen: isVerySmall,
                    ),
                    _buildStatCard(
                      context,
                      'Items',
                      '${proposal.items.length}',
                      Icons.list_outlined,
                      Colors.orange,
                      isSmallScreen: isVerySmall,
                    ),
                    _buildStatCard(
                      context,
                      'Tax Amount',
                      'KES ${proposal.taxAmount.toStringAsFixed(2)}',
                      Icons.percent_outlined,
                      Colors.purple,
                      isSmallScreen: isVerySmall,
                    ),
                    _buildStatCard(
                      context,
                      'Discount',
                      'KES ${proposal.discountAmount.toStringAsFixed(2)}',
                      Icons.discount_outlined,
                      Colors.red,
                      isSmallScreen: isVerySmall,
                    ),
                    _buildStatCard(
                      context,
                      'Proposal Date',
                      _formatDate(proposal.proposalDate),
                      Icons.calendar_today_outlined,
                      Colors.teal,
                      isSmallScreen: isVerySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposal Content',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              context,
              'Executive Summary',
              proposal.executiveSummary,
              Icons.summarize_outlined,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              'Scope of Work',
              proposal.scopeOfWork,
              Icons.work_outline_outlined,
            ),
            if (proposal.technicalApproach.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                'Technical Approach',
                proposal.technicalApproach,
                Icons.engineering_outlined,
              ),
            ],
            if (proposal.methodology.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                'Methodology',
                proposal.methodology,
                Icons.science_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialRow('Subtotal', proposal.subtotal),
            _buildFinancialRow('Tax Amount', proposal.taxAmount),
            _buildFinancialRow('Discount', proposal.discountAmount),
            const Divider(height: 24),
            _buildFinancialRow('Total Amount', proposal.totalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    final theme = Theme.of(context);
    if (proposal.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${proposal.items.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...proposal.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(context, index, item);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScheduleSection(BuildContext context) {
    final theme = Theme.of(context);
    if (proposal.paymentSchedule?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...proposal.paymentSchedule!.map((milestone) {
              return _buildMilestoneCard(context, milestone);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    final theme = Theme.of(context);
    if (proposal.timeline == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Timeline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 3;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    if (proposal.timeline!.startDate != null)
                      _buildInfoTile(
                        context,
                        'Start Date',
                        _formatDate(proposal.timeline!.startDate),
                        Icons.play_arrow_outlined,
                      ),
                    if (proposal.timeline!.endDate != null)
                      _buildInfoTile(
                        context,
                        'End Date',
                        _formatDate(proposal.timeline!.endDate),
                        Icons.flag_outlined,
                      ),
                    if (proposal.timeline!.totalDuration != null)
                      _buildInfoTile(
                        context,
                        'Total Duration',
                        '${proposal.timeline!.totalDuration} days',
                        Icons.timer_outlined,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review & Approval',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 3;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildInfoTile(
                      context,
                      'Review Status',
                      proposal.reviewStatus.displayName,
                      Icons.reviews_outlined,
                    ),
                    if (proposal.reviewDate != null)
                      _buildInfoTile(
                        context,
                        'Review Date',
                        _formatDate(proposal.reviewDate),
                        Icons.calendar_view_day_outlined,
                      ),
                    if (proposal.approvalDate != null)
                      _buildInfoTile(
                        context,
                        'Approval Date',
                        _formatDate(proposal.approvalDate),
                        Icons.check_circle_outlined,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection(BuildContext context) {
    final theme = Theme.of(context);
    if (proposal.signatureDate == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signature Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 3;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildInfoTile(
                      context,
                      'Signature Date',
                      _formatDate(proposal.signatureDate),
                      Icons.edit_outlined,
                    ),
                    if (proposal.contractStartDate != null)
                      _buildInfoTile(
                        context,
                        'Contract Start',
                        _formatDate(proposal.contractStartDate),
                        Icons.play_circle_outlined,
                      ),
                    if (proposal.contractEndDate != null)
                      _buildInfoTile(
                        context,
                        'Contract End',
                        _formatDate(proposal.contractEndDate),
                        Icons.stop_circle_outlined,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metadata',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildInfoTile(
                      context,
                      'Created',
                      _formatDate(proposal.createdAt),
                      Icons.add_circle_outlined,
                    ),
                    _buildInfoTile(
                      context,
                      'Last Updated',
                      _formatDate(proposal.updatedAt),
                      Icons.update_outlined,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Proposal'),
                  onPressed: proposal.canEdit ? onEdit : null,
                ),
                ActionChip(
                  avatar: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Download PDF'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Duplicate'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: proposal.canEdit ? onEdit : null,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Proposal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color, {
        bool isSmallScreen = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: isSmallScreen
          ? const EdgeInsets.all(12)
          : const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: isSmallScreen ? 20 : 24,
              ),
              const Spacer(),
              if (!isSmallScreen && value.length > 15)
                Tooltip(
                  message: value,
                  child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 11 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isSmallScreen ? 14 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.grey[800] : Colors.grey[600],
              ),
            ),
          ),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF2196F3) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, int index, ProposalItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.description ?? 'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                'KES ${(item.totalPrice ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Qty: ${item.quantity}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(
                'Unit: KES ${(item.unitPrice ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              if (item.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.category!.displayName,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, PaymentMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${milestone.milestoneNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name ?? 'Milestone ${milestone.milestoneNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (milestone.description != null)
                  Text(
                    milestone.description!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${(milestone.amount ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              if (milestone.percentage != null)
                Text(
                  '${milestone.percentage}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}