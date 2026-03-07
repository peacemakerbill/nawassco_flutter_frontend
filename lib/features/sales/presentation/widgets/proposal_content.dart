import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/customer.model.dart';
import '../../models/proposal.model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/proposal.provider.dart';
import 'sub_widgets/proposal/proposal_form.dart';
import 'sub_widgets/proposal/proposal_list.dart';

class ProposalContent extends ConsumerStatefulWidget {
  const ProposalContent({super.key});

  @override
  ConsumerState<ProposalContent> createState() => _ProposalContentState();
}

class _ProposalContentState extends ConsumerState<ProposalContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proposalProvider.notifier).refreshData();
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final customerState = ref.read(customerProvider);
      if (customerState.customers.isEmpty) {
        await ref.read(customerProvider.notifier).loadCustomers(refresh: true);
      }
      if (mounted) {
        // Remove duplicate customers by ID
        final seenIds = <String>{};
        final uniqueCustomers = ref.read(customerProvider).customers.where((customer) {
          if (customer.id.isEmpty) return false;
          if (seenIds.contains(customer.id)) return false;
          seenIds.add(customer.id);
          return true;
        }).toList();

        setState(() {
          _customers = uniqueCustomers;
        });
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
  }
  // Show proposal form as a dialog with animation
  void _showProposalForm(BuildContext context, Proposal? proposal) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: proposal == null ? 'New Proposal' : 'Edit Proposal',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: ProposalForm(
                  initialProposal: proposal,
                  customers: _customers,
                  onSuccess: () {
                    Navigator.pop(context);
                    ref.read(proposalProvider.notifier).refreshData();
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with Tabs
          Material(
            elevation: 2,
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Proposal Management',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF1A237E)),
                        onPressed: () => ref.read(proposalProvider.notifier).refreshData(),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF2196F3),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF2196F3),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Draft'),
                      Tab(text: 'Submitted'),
                      Tab(text: 'Under Review'),
                      Tab(text: 'Approved'),
                      Tab(text: 'Signed'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Proposals
                ProposalList(
                  filters: const ProposalFilters(),
                  customers: _customers,
                ),

                // Draft Proposals
                ProposalList(
                  filters: const ProposalFilters(status: ProposalStatus.draft),
                  customers: _customers,
                ),

                // Submitted Proposals
                ProposalList(
                  filters: const ProposalFilters(status: ProposalStatus.submitted),
                  customers: _customers,
                ),

                // Under Review Proposals
                ProposalList(
                  filters: const ProposalFilters(status: ProposalStatus.under_review),
                  customers: _customers,
                ),

                // Approved Proposals
                ProposalList(
                  filters: const ProposalFilters(approvalStatus: ApprovalStatus.approved),
                  customers: _customers,
                ),

                // Signed Proposals
                ProposalList(
                  filters: const ProposalFilters(status: ProposalStatus.signed),
                  customers: _customers,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: FloatingActionButton(
          onPressed: () {
            _showProposalForm(context, null);
          },
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}