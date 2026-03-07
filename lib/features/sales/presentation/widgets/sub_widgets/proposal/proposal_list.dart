import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../models/proposal.model.dart';
import '../../../../providers/proposal.provider.dart';
import 'proposal_card.dart';
import 'proposal_details.dart';
import 'proposal_form.dart';

class ProposalList extends ConsumerStatefulWidget {
  final ProposalFilters filters;
  final List<Customer> customers;

  const ProposalList({
    super.key,
    required this.filters,
    required this.customers,
  });

  @override
  ConsumerState<ProposalList> createState() => _ProposalListState();
}

class _ProposalListState extends ConsumerState<ProposalList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoadingMore = false;
  String _searchQuery = '';
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Apply filters when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proposalProvider.notifier).updateFilters(widget.filters);
    });
  }

  @override
  void didUpdateWidget(ProposalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      _searchController.clear();
      _searchQuery = '';
      ref.read(proposalProvider.notifier).updateFilters(widget.filters);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() => _isLoadingMore = true);
    ref.read(proposalProvider.notifier).loadNextPage();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    });
  }

  String _getCustomerName(String customerId) {
    final customer = widget.customers.firstWhere(
          (c) => c.id == customerId,
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

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _searchTimer?.cancel();

    // Set a new timer for 300ms debounce
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery != value) {
        _searchQuery = value;
        _performSearch();
      }
    });
  }

  void _performSearch() {
    // Create new filters with search query
    final newFilters = widget.filters.copyWith(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    ref.read(proposalProvider.notifier).updateFilters(newFilters);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    ref.read(proposalProvider.notifier).updateFilters(widget.filters);
  }

  List<Proposal> _filterProposals(List<Proposal> proposals) {
    if (_searchQuery.isEmpty) return proposals;

    final query = _searchQuery.toLowerCase();
    return proposals.where((proposal) {
      return proposal.proposalNumber.toLowerCase().contains(query) ||
          (proposal.customerName ?? '').toLowerCase().contains(query) ||
          proposal.executiveSummary.toLowerCase().contains(query) ||
          proposal.scopeOfWork.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalProvider);
    final filteredProposals = _filterProposals(state.proposals);

    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),

        // Proposal List
        Expanded(
          child: _buildProposalList(state, filteredProposals),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search proposals by number, customer, or content...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                onPressed: _clearSearch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalList(ProposalState state, List<Proposal> filteredProposals) {
    if (state.isLoading && state.proposals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF2196F3)),
        ),
      );
    }

    if (filteredProposals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No matching proposals' : 'No proposals found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : widget.filters.status != null
                  ? 'No ${widget.filters.status!.displayName.toLowerCase()} proposals'
                  : 'Create your first proposal to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(proposalProvider.notifier).refreshData();
      },
      color: const Color(0xFF2196F3),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: filteredProposals.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredProposals.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoadingMore
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF2196F3)),
                )
                    : const SizedBox(),
              ),
            );
          }

          final proposal = filteredProposals[index];
          final customerName = proposal.customerName ?? _getCustomerName(proposal.customer);

          return ProposalCard(
            proposal: proposal.copyWith(customerName: customerName),
            onTap: () => _showProposalDetails(proposal),
          );
        },
      ),
    );
  }

  // Show proposal details as a dialog with animation
  void _showProposalDetails(Proposal proposal) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Proposal Details',
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
                child: ProposalDetails(
                  proposal: proposal,
                  customers: widget.customers,
                  onEdit: () {
                    Navigator.pop(context);
                    _showProposalForm(proposal);
                  },
                  onClose: () => Navigator.pop(context),
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

  // Show proposal form as a dialog with animation
  void _showProposalForm(Proposal proposal) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Edit Proposal',
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
                  customers: widget.customers,
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
}