import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/lead_models.dart';
import '../../../../models/sales_representative_model.dart';
import '../../../../providers/lead_provider.dart';
import '../../../../providers/sales_rep_provider.dart';
import 'lead_form_widget.dart'; // Import the form widget

class LeadDetailWidget extends ConsumerWidget {
  final Lead lead;
  final bool isDialog; // Add this parameter to control if it's shown as dialog

  const LeadDetailWidget({
    super.key,
    required this.lead,
    this.isDialog = false, // Default to false for backward compatibility
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(leadProvider.notifier);
    final salesReps = ref.read(salesRepProvider).salesReps;
    final assignedRep = salesReps.firstWhere(
          (rep) => rep.id == lead.assignedTo,
      orElse: () => SalesRepresentative.empty(),
    );

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Content widget that can be used in both dialog and full screen
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Lead Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.contactDetails.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lead.leadNumber,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatusBadge(lead.status, theme),
                                const SizedBox(width: 8),
                                _buildPriorityBadge(lead.priority, theme),
                                const Spacer(),
                                Text(
                                  'KES ${lead.estimatedValue.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Call functionality
                            if (isDialog && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Email functionality
                            if (isDialog && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.email, size: 16),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Close detail dialog and open edit form as dialog
                            if (isDialog && Navigator.canPop(context)) {
                              Navigator.pop(context); // Close detail dialog
                              // Show edit form as a dialog
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Dialog(
                                  insetPadding: const EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                      maxHeight: 700,
                                    ),
                                    child: LeadFormWidget(lead: lead),
                                  ),
                                ),
                              );
                            } else {
                              // If not dialog, use provider navigation
                              notifier.showLeadForm(lead: lead);
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contact Information Card
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_mail,
            children: [
              _buildDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: lead.contactDetails.email,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: lead.contactDetails.phone,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Address',
                value: lead.contactDetails.address,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.location_city,
                label: 'Location',
                value: lead.contactDetails.location,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.mail,
                label: 'Contact Method',
                value: lead.contactDetails.communicationPreference.displayName,
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lead Information Card
          _buildSectionCard(
            title: 'Lead Information',
            icon: Icons.info,
            children: [
              _buildDetailRow(
                icon: Icons.source,
                label: 'Source',
                value: lead.source.displayName,
                theme: theme,
              ),
              if (lead.campaign != null)
                _buildDetailRow(
                  icon: Icons.campaign,
                  label: 'Campaign',
                  value: lead.campaign!,
                  theme: theme,
                ),
              if (lead.referralSource != null)
                _buildDetailRow(
                  icon: Icons.group,
                  label: 'Referral Source',
                  value: lead.referralSource!,
                  theme: theme,
                ),
              _buildDetailRow(
                icon: Icons.category,
                label: 'Lead Type',
                value: lead.leadType.displayName,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Created',
                value:
                '${dateFormat.format(lead.createdAt)} at ${timeFormat.format(lead.createdAt)}',
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.update,
                label: 'Last Updated',
                value:
                '${dateFormat.format(lead.updatedAt)} at ${timeFormat.format(lead.updatedAt)}',
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Assignment & Qualification Card
          _buildSectionCard(
            title: 'Assignment & Qualification',
            icon: Icons.assignment,
            children: [
              if (lead.assignedTo != null && assignedRep.id.isNotEmpty)
                _buildDetailRow(
                  icon: Icons.person,
                  label: 'Assigned To',
                  value: assignedRep.fullName,
                  theme: theme,
                  isImportant: true,
                ),
              _buildDetailRow(
                icon: Icons.score,
                label: 'Qualification Score',
                value: '${lead.qualificationScore.toStringAsFixed(1)}%',
                theme: theme,
                isImportant: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qualification Criteria',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCriteriaChip(
                              'Budget Available',
                              lead.qualificationCriteria.budgetAvailable,
                              theme,
                            ),
                            _buildCriteriaChip(
                              'Decision Maker',
                              lead.qualificationCriteria.decisionMaker,
                              theme,
                            ),
                            _buildCriteriaChip(
                              'Timeframe',
                              lead.qualificationCriteria.timeframe,
                              theme,
                            ),
                            _buildCriteriaChip(
                              'Need Identified',
                              lead.qualificationCriteria.needIdentified,
                              theme,
                            ),
                            _buildCriteriaChip(
                              'Authority',
                              lead.qualificationCriteria.authority,
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Company Information Card (Added)
          if (lead.companyDetails != null)
            Column(
              children: [
                _buildSectionCard(
                  title: 'Company Information',
                  icon: Icons.business,
                  children: [
                    _buildDetailRow(
                      icon: Icons.business,
                      label: 'Company Name',
                      value: lead.companyDetails!.companyName,
                      theme: theme,
                    ),
                    if (lead.companyDetails!.industry.isNotEmpty)
                      _buildDetailRow(
                        icon: Icons.work,
                        label: 'Industry',
                        value: lead.companyDetails!.industry,
                        theme: theme,
                      ),
                    _buildDetailRow(
                      icon: Icons.people,
                      label: 'Company Size',
                      value: lead.companyDetails!.size.displayName,
                      theme: theme,
                    ),
                    if (lead.companyDetails!.annualRevenue > 0)
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Annual Revenue',
                        value:
                        'KES ${lead.companyDetails!.annualRevenue.toStringAsFixed(2)}',
                        theme: theme,
                      ),
                    if (lead.companyDetails!.website.isNotEmpty)
                      _buildDetailRow(
                        icon: Icons.web,
                        label: 'Website',
                        value: lead.companyDetails!.website,
                        theme: theme,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Service Requirements Card
          if (lead.serviceRequirements.isNotEmpty)
            _buildSectionCard(
              title: 'Service Requirements',
              icon: Icons.description,
              children: lead.serviceRequirements.map((req) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.serviceType.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      req.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: req.urgency.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Urgency: ${req.urgency.displayName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: req.urgency.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (req.specificNeeds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: req.specificNeeds.map((need) {
                          return Chip(
                            label: Text(need),
                            backgroundColor:
                            theme.colorScheme.secondary.withOpacity(0.1),
                            labelStyle: theme.textTheme.labelSmall,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),

          // Timeline Information Card (Added)
          _buildSectionCard(
            title: 'Timeline',
            icon: Icons.calendar_today,
            children: [
              _buildDetailRow(
                icon: Icons.schedule,
                label: 'Expected Timeframe',
                value: lead.timeline.expectedTimeframe,
                theme: theme,
              ),
              _buildDetailRow(
                icon: Icons.flag,
                label: 'Urgency',
                value: lead.timeline.urgency.displayName,
                theme: theme,
              ),
              if (lead.timeline.specificDate != null)
                _buildDetailRow(
                  icon: Icons.calendar_month,
                  label: 'Specific Date',
                  value: dateFormat.format(lead.timeline.specificDate!),
                  theme: theme,
                ),
              if (lead.budget != null && lead.budget! > 0)
                _buildDetailRow(
                  icon: Icons.account_balance_wallet,
                  label: 'Budget',
                  value: 'KES ${lead.budget!.toStringAsFixed(2)}',
                  theme: theme,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Follow-up History Card
          _buildSectionCard(
            title: 'Follow-up History',
            icon: Icons.history,
            children: lead.followUpHistory.isNotEmpty
                ? lead.followUpHistory.map((followUp) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormat.format(followUp.date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(followUp.method.displayName),
                        backgroundColor: _getMethodColor(followUp.method)
                            .withOpacity(0.1),
                        labelStyle: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followUp.summary,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Outcome: ${followUp.outcome.displayName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                            theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (followUp.nextSteps.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Next Steps: ${followUp.nextSteps}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                        if (followUp.nextFollowUpDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Next Follow-up: ${dateFormat.format(followUp.nextFollowUpDate!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList()
                : [
              Center(
                child: Text(
                  'No follow-up history',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),

          if (lead.nextFollowUp != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Follow-up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                        Text(
                          dateFormat.format(lead.nextFollowUp!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Schedule follow-up
                      if (isDialog && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Reschedule'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Add follow-up
                    if (isDialog && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Follow-up'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (lead.status != LeadStatus.converted) {
                      // Convert to customer
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Convert to Customer'),
                          content: const Text(
                            'This will create a new customer from this lead. Continue?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close confirmation
                                if (isDialog) {
                                  Navigator.pop(context); // Close detail dialog
                                }
                                await notifier.convertLead(lead.id, {
                                  'customerType': 'residential',
                                  'serviceType': 'water_supply',
                                });
                              },
                              child: const Text('Convert'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    lead.status == LeadStatus.converted
                        ? 'Converted'
                        : 'Convert to Customer',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lead.status == LeadStatus.converted
                        ? Colors.green
                        : const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );

    // Return different structure based on isDialog
    if (isDialog) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 700,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Lead Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                color: const Color(0xFF1E3A8A),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                  onPressed: () {
                    Navigator.pop(context); // Close detail dialog
                    // Show edit form as a dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        insetPadding: const EdgeInsets.all(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 800,
                            maxHeight: 700,
                          ),
                          child: LeadFormWidget(lead: lead),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF1E3A8A)),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ],
            ),
            body: content,
          ),
        ),
      );
    } else {
      // Full screen version (original behavior)
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Lead Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => notifier.showLeadList(),
            color: const Color(0xFF1E3A8A),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
              onPressed: () {
                // Show edit form as a dialog even from full screen
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 800,
                        maxHeight: 700,
                      ),
                      child: LeadFormWidget(lead: lead),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF1E3A8A)),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),
        body: content,
      );
    }
  }

  // Helper method to get color for contact method
  Color _getMethodColor(ContactMethod method) {
    return switch (method) {
      ContactMethod.email => Colors.blue,
      ContactMethod.phone => Colors.green,
      ContactMethod.sms => Colors.purple,
      ContactMethod.inPerson => Colors.orange,
      ContactMethod.videoCall => Colors.red,
    };
  }

  Widget _buildStatusBadge(LeadStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(PriorityLevel priority, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priority.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 12,
            color: priority.color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                    isImportant ? FontWeight.w600 : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaChip(String label, bool isMet, ThemeData theme) {
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isMet ? Colors.green : Colors.grey[600],
        ),
      ),
      backgroundColor:
      isMet ? Colors.green.withOpacity(0.1) : Colors.grey[100],
      side: BorderSide(
        color: isMet ? Colors.green.withOpacity(0.3) : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}