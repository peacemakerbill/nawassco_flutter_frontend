import 'package:flutter/material.dart';

import '../../../../models/proposal.model.dart';

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback onTap;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onTap,
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

  IconData _getStatusIcon(ProposalStatus status) {
    return switch (status) {
      ProposalStatus.draft => Icons.edit_outlined,
      ProposalStatus.submitted => Icons.send_outlined,
      ProposalStatus.under_review => Icons.visibility_outlined,
      ProposalStatus.revised => Icons.update_outlined,
      ProposalStatus.negotiation => Icons.handshake_outlined,
      ProposalStatus.accepted => Icons.check_circle_outline,
      ProposalStatus.rejected => Icons.cancel_outlined,
      ProposalStatus.expired => Icons.timer_off_outlined,
      ProposalStatus.signed => Icons.assignment_turned_in_outlined,
      ProposalStatus.converted_to_contract => Icons.description_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with proposal number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proposal.proposalNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(proposal.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(proposal.status),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(proposal.status),
                          size: 14,
                          color: _getStatusColor(proposal.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          proposal.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(proposal.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Customer and amount
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      proposal.customerName ?? 'Unknown Customer',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    proposal.formattedTotal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date and approval status
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${proposal.proposalDate.day}/${proposal.proposalDate.month}/${proposal.proposalDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getApprovalColor(proposal.approvalStatus)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      proposal.approvalStatus.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getApprovalColor(proposal.approvalStatus),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Executive summary preview
              if (proposal.executiveSummary.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 16),
                    Text(
                      proposal.executiveSummary.length > 100
                          ? '${proposal.executiveSummary.substring(0, 100)}...'
                          : proposal.executiveSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}