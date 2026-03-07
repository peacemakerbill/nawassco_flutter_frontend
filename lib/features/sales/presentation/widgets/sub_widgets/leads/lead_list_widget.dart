import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/lead_models.dart';
import '../../../../providers/lead_provider.dart';
import 'lead_card_widget.dart';
import 'lead_detail_widget.dart';
import 'lead_filters_widget.dart';
import 'lead_form_widget.dart';
import 'lead_stats_widget.dart';

class LeadListWidget extends ConsumerWidget {
  const LeadListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leadProvider);
    final notifier = ref.read(leadProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;

    // If showing details or stats, show those instead
    if (state.showDetails && state.selectedLead != null) {
      return LeadDetailWidget(lead: state.selectedLead!);
    }

    if (state.showStats) {
      return const LeadStatsWidget();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar Section
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              floating: true,
              pinned: false,
              snap: false,
              collapsedHeight: isSmallScreen ? 70 : 80,
              expandedHeight: isSmallScreen ? 120 : 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                ),
                titlePadding: EdgeInsets.only(
                  left: isSmallScreen ? 12 : 16,
                  bottom: isSmallScreen ? 10 : 12,
                  right: 16,
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isSalesRepView ? 'My Leads' : 'Leads Management',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalItems} leads • ${state.leads.length} showing',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              actions: [
                // Filter Button
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LeadFiltersWidget(),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_alt,
                      color: Color(0xFF1E3A8A),
                      size: 20,
                    ),
                  ),
                  tooltip: 'Filter leads',
                ),
                // Stats Button
                IconButton(
                  onPressed: () => notifier.showLeadStats(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  tooltip: 'View stats',
                ),
                // Add Lead Button - Responsive version
                if (!isSmallScreen)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Dialog(
                            insetPadding:
                                EdgeInsets.all(isSmallScreen ? 8 : 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isSmallScreen
                                    ? screenWidth - 16
                                    : isMediumScreen
                                        ? 600
                                        : 800,
                                maxHeight: isSmallScreen ? 600 : 700,
                              ),
                              child: const LeadFormWidget(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Lead'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Dialog(
                          insetPadding: const EdgeInsets.all(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth - 16,
                              maxHeight: 600,
                            ),
                            child: const LeadFormWidget(),
                          ),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Add lead',
                  ),
              ],
            ),

            // Search Bar Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: TextField(
                  onChanged: (value) => notifier.searchLeads(value),
                  decoration: InputDecoration(
                    hintText:
                        'Search leads by name, email, phone, or lead number...',
                    hintStyle: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => notifier.clearFilters(),
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ),

            // Status Filter Chips Section
            SliverToBoxAdapter(
              child: SizedBox(
                height: isSmallScreen ? 50 : 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  children: [
                    _buildStatusChip(
                        'All', null, notifier, state, isSmallScreen),
                    ...LeadStatus.values.map((status) {
                      return _buildStatusChip(
                        status.displayName,
                        status.name,
                        notifier,
                        state,
                        isSmallScreen,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // MAIN CONTENT SECTION - Fixed to handle empty state properly
            if (state.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              )
            else if (state.leads.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group,
                            size: isSmallScreen ? 80 : 120,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          Text(
                            'No leads found',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 24,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isSmallScreen ? 300 : 400,
                            ),
                            child: Text(
                              state.filters.isEmpty
                                  ? 'Add your first lead to get started with lead management'
                                  : 'No leads match your current filters. Try adjusting your search criteria.',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (state.filters.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.only(top: isSmallScreen ? 20 : 32),
                              child: ElevatedButton(
                                onPressed: () => notifier.clearFilters(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 24 : 32,
                                    vertical: isSmallScreen ? 12 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Clear Filters',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding:
                                  EdgeInsets.only(top: isSmallScreen ? 20 : 32),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Dialog(
                                      insetPadding: EdgeInsets.all(
                                          isSmallScreen ? 8 : 16),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: isSmallScreen
                                              ? screenWidth - 16
                                              : isMediumScreen
                                                  ? 600
                                                  : 800,
                                          maxHeight: isSmallScreen ? 600 : 700,
                                        ),
                                        child: const LeadFormWidget(),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 24 : 32,
                                    vertical: isSmallScreen ? 12 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Add Your First Lead',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lead = state.leads[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmallScreen ? 12 : 16,
                        index == 0 ? 8 : 4,
                        isSmallScreen ? 12 : 16,
                        4,
                      ),
                      child: LeadCardWidget(
                        lead: lead,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => LeadDetailWidget(
                              lead: lead,
                              isDialog: true,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: state.leads.length,
                ),
              ),

            // Pagination Section (only shown when there are leads)
            if (state.leads.isNotEmpty && state.totalPages > 1)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: state.currentPage > 1
                                ? () => notifier.fetchLeads(
                                    page: state.currentPage - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          ...List.generate(
                            state.totalPages,
                            (index) {
                              final page = index + 1;
                              // Show limited pages on small screens
                              if (isSmallScreen &&
                                  (page < state.currentPage - 1 ||
                                      page > state.currentPage + 1) &&
                                  page != 1 &&
                                  page != state.totalPages) {
                                if (page == state.currentPage - 2 ||
                                    page == state.currentPage + 2) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      '...',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      notifier.fetchLeads(page: page),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.currentPage == page
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.white,
                                    foregroundColor: state.currentPage == page
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: isSmallScreen ? 6 : 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation:
                                        state.currentPage == page ? 2 : 0,
                                  ),
                                  child: Text(page.toString()),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: state.currentPage < state.totalPages
                                ? () => notifier.fetchLeads(
                                    page: state.currentPage + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      // Floating Action Button for small screens
      floatingActionButton: isSmallScreen && state.leads.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth - 16,
                        maxHeight: 600,
                      ),
                      child: const LeadFormWidget(),
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStatusChip(
    String label,
    String? value,
    LeadProvider notifier,
    LeadListState state,
    bool isSmallScreen,
  ) {
    final isActive = value == null
        ? !state.filters.containsKey('status')
        : state.filters['status'] == value;

    return Padding(
      padding: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
        ),
        selected: isActive,
        onSelected: (selected) {
          if (value == null) {
            notifier.clearFilters();
          } else {
            notifier.filterLeads({'status': value});
          }
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF1E3A8A).withOpacity(0.1),
        labelStyle: TextStyle(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade600,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: isSmallScreen ? 12 : 14,
        ),
        side: BorderSide(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        checkmarkColor: const Color(0xFF1E3A8A),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 4 : 8,
        ),
      ),
    );
  }
}
