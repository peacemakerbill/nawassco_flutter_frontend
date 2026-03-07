import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/opportunity_provider.dart';
import 'sub_widgets/opportunities/opportunity_details_widget.dart';
import 'sub_widgets/opportunities/opportunity_form_widget.dart';
import 'sub_widgets/opportunities/opportunity_list_widget.dart';

class SalesOpportunitiesContent extends ConsumerWidget {
  const SalesOpportunitiesContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(opportunityProvider);
    final provider = ref.read(opportunityProvider.notifier);

    // Ensure we're in sales rep view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isSalesRepView) {
        provider.toggleSalesRepView();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_ind,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Opportunities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      'Assigned sales opportunities',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Opportunity List
          Expanded(
            child: OpportunityListWidget(
              isSalesRepView: true,
              onAddNew: () {
                showDialog(
                  context: context,
                  builder: (context) => const Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(20),
                    child: OpportunityFormWidget(),
                  ),
                );
              },
              onViewDetails: (opportunity) {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(20),
                    child: OpportunityDetailsWidget(opportunity: opportunity),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}