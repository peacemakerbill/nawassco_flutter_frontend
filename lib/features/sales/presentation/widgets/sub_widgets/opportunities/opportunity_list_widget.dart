import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/opportunity.model.dart';
import '../../../../providers/opportunity_provider.dart';
import 'opportunity_details_widget.dart';
import 'opportunity_form_widget.dart';

class OpportunityListWidget extends ConsumerStatefulWidget {
  final bool isSalesRepView;
  final VoidCallback onAddNew;
  final Function(Opportunity) onViewDetails;

  const OpportunityListWidget({
    super.key,
    this.isSalesRepView = false,
    required this.onAddNew,
    required this.onViewDetails,
  });

  @override
  ConsumerState<OpportunityListWidget> createState() => _OpportunityListWidgetState();
}

class _OpportunityListWidgetState extends ConsumerState<OpportunityListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = ref.read(opportunityProvider.notifier);
    provider.loadOpportunities(refresh: true);
    provider.loadStats();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _loadMore() async {
    if (_isLoadingMore) return;
    final state = ref.read(opportunityProvider);
    if (state.currentPage >= state.totalPages || !state.hasMore) return;

    setState(() => _isLoadingMore = true);
    await ref.read(opportunityProvider.notifier).loadNextPage();
    setState(() => _isLoadingMore = false);
  }

  void _showFormDialog({Opportunity? opportunity}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: OpportunityFormWidget(opportunity: opportunity),
        );
      },
    );
  }

  void _showDetailsDialog(Opportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: OpportunityDetailsWidget(opportunity: opportunity),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opportunityProvider);
    final provider = ref.read(opportunityProvider.notifier);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Opportunity'),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          if (!isSmallScreen) _buildDesktopHeader(state, provider),
          if (isSmallScreen) _buildMobileHeader(state, provider),
          _buildSearchAndFilters(state, provider, isSmallScreen),
          Expanded(
            child: state.isLoading && state.opportunities.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.opportunities.isEmpty
                ? _buildEmptyState()
                : _buildOpportunitiesList(state, isSmallScreen),
          ),
          if (_isLoadingMore) const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
          if (state.error != null) _buildErrorState(state.error!),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(OpportunityState state, OpportunityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatsGrid(state)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isSalesRepView)
                ElevatedButton.icon(
                  onPressed: provider.toggleSalesRepView,
                  icon: Icon(state.isSalesRepView ? Icons.visibility : Icons.visibility_off, size: 18),
                  label: Text(state.isSalesRepView ? 'Show All' : 'Show Assigned', style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    elevation: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(OpportunityState state, OpportunityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMobileStats(state),
          const SizedBox(height: 16),
          Row(
            children: [
              const Spacer(),
              if (!widget.isSalesRepView)
                IconButton(
                  onPressed: provider.toggleSalesRepView,
                  icon: Icon(state.isSalesRepView ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF1E3A8A)),
                  tooltip: state.isSalesRepView ? 'Show All' : 'Show Assigned',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(OpportunityState state) {
    if (state.stats == null) return const SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final stats = state.stats!;
        return switch (index) {
          0 => _buildStatCard('Total Opportunities', '${stats.total}', Icons.business_center, Colors.blue),
          1 => _buildStatCard('Total Value', stats.totalValueFormatted, Icons.attach_money, Colors.green),
          2 => _buildStatCard('Expected Revenue', stats.expectedRevenueFormatted, Icons.trending_up, Colors.orange),
          3 => _buildStatCard('Win Rate', stats.winRateFormatted, Icons.star, Colors.purple),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildMobileStats(OpportunityState state) {
    if (state.stats == null) return const SizedBox();
    final stats = state.stats!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMobileStatItem('Total', '${stats.total}', Icons.business_center),
        _buildMobileStatItem('Value', stats.totalValueFormatted, Icons.attach_money),
        _buildMobileStatItem('Win Rate', stats.winRateFormatted, Icons.star),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSearchAndFilters(OpportunityState state, OpportunityProvider provider, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => Future.delayed(const Duration(milliseconds: 500), () {
                        provider.updateFilters(state.filters.copyWith(search: value));
                      }),
                      decoration: const InputDecoration(
                        hintText: 'Search opportunities...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (state.filters.hasFilters)
                    IconButton(
                      onPressed: provider.clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          if (!isSmallScreen) ...[const SizedBox(width: 12), _buildFilterButton(state, provider)],
        ],
      ),
    );
  }

  Widget _buildFilterButton(OpportunityState state, OpportunityProvider provider) {
    return PopupMenuButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: state.filters.hasFilters ? const Color(0xFF1E3A8A).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: state.filters.hasFilters ? const Color(0xFF1E3A8A) : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, color: state.filters.hasFilters ? const Color(0xFF1E3A8A) : Colors.grey[700], size: 20),
            if (state.filters.hasFilters)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(10)),
                child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(child: _buildStageFilter(state, provider)),
        PopupMenuItem(child: _buildTypeFilter(state, provider)),
      ],
    );
  }

  Widget _buildStageFilter(OpportunityState state, OpportunityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sales Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SalesStage.values.map((stage) {
            final isSelected = state.filters.stage == stage;
            return FilterChip(
              label: Text(stage.displayName),
              selected: isSelected,
              onSelected: (selected) {
                provider.updateFilters(state.filters.copyWith(stage: selected ? stage : null));
                Navigator.pop(context);
              },
              selectedColor: stage.color.withValues(alpha: 0.2),
              backgroundColor: Colors.grey[100],
              checkmarkColor: stage.color,
              labelStyle: TextStyle(color: isSelected ? stage.color : Colors.grey[800], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              avatar: Icon(stage.icon, size: 16, color: stage.color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeFilter(OpportunityState state, OpportunityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Opportunity Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: OpportunityType.values.map((type) {
            final isSelected = state.filters.type == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                provider.updateFilters(state.filters.copyWith(type: selected ? type : null));
                Navigator.pop(context);
              },
              selectedColor: type.color.withValues(alpha: 0.2),
              backgroundColor: Colors.grey[100],
              checkmarkColor: type.color,
              labelStyle: TextStyle(color: isSelected ? type.color : Colors.grey[800], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              avatar: Icon(type.icon, size: 16, color: type.color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text('No Opportunities Found', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.isSalesRepView ? 'You have no assigned opportunities yet' : 'Start by creating your first opportunity',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create First Opportunity'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => ref.read(opportunityProvider.notifier).clearError(),
              icon: const Icon(Icons.close, size: 18),
              color: Colors.red[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunitiesList(OpportunityState state, bool isSmallScreen) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.opportunities.length + 1,
      itemBuilder: (context, index) {
        if (index == state.opportunities.length) {
          if (state.hasMore && state.currentPage < state.totalPages) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox(height: 80);
        }
        return isSmallScreen
            ? _buildMobileOpportunityCard(state.opportunities[index])
            : _buildDesktopOpportunityCard(state.opportunities[index]);
      },
    );
  }

  Widget _buildDesktopOpportunityCard(Opportunity opportunity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsDialog(opportunity),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: opportunity.salesStage.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: opportunity.salesStage.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(opportunity.salesStage.icon, size: 14, color: opportunity.salesStage.color),
                          const SizedBox(width: 6),
                          Text(opportunity.salesStage.displayName,
                              style: TextStyle(color: opportunity.salesStage.color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: opportunity.opportunityType.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(opportunity.opportunityType.icon, size: 12, color: opportunity.opportunityType.color),
                          const SizedBox(width: 4),
                          Text(opportunity.opportunityType.displayName,
                              style: TextStyle(color: opportunity.opportunityType.color, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opportunity.opportunityNumber,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          const SizedBox(height: 8),
                          Text(
                            opportunity.description.length > 150 ? '${opportunity.description.substring(0, 150)}...' : opportunity.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoItem(Icons.person, opportunity.leadDisplayName),
                              const SizedBox(width: 16),
                              if (opportunity.customerId != null) _buildInfoItem(Icons.business, opportunity.customerDisplayName),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(opportunity.valueFormatted,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        const SizedBox(height: 4),
                        Text('Expected: ${opportunity.revenueFormatted}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Probability', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  Text(opportunity.probabilityText,
                                      style: TextStyle(color: opportunity.probabilityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: opportunity.probability / 100,
                                backgroundColor: Colors.grey[200],
                                color: opportunity.probabilityColor,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.timeline, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${opportunity.daysInPipeline} days in pipeline',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showDetailsDialog(opportunity),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!opportunity.isClosed)
                      ElevatedButton.icon(
                        onPressed: () => _showUpdateStageDialog(opportunity),
                        icon: const Icon(Icons.trending_up, size: 16),
                        label: const Text('Update Stage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileOpportunityCard(Opportunity opportunity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsDialog(opportunity),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: opportunity.salesStage.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: opportunity.salesStage.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(opportunity.salesStage.icon, size: 12, color: opportunity.salesStage.color),
                          const SizedBox(width: 4),
                          Text(opportunity.salesStage.displayName,
                              style: TextStyle(color: opportunity.salesStage.color, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: opportunity.opportunityType.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(opportunity.opportunityType.icon, size: 12, color: opportunity.opportunityType.color),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(opportunity.opportunityNumber,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 8),
                Text(
                  opportunity.description.length > 100 ? '${opportunity.description.substring(0, 100)}...' : opportunity.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(opportunity.leadDisplayName,
                          style: TextStyle(color: Colors.grey[700], fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunity.valueFormatted,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        Text(opportunity.probabilityText,
                            style: TextStyle(color: opportunity.probabilityColor, fontWeight: FontWeight.w500, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showDetailsDialog(opportunity),
                          icon: const Icon(Icons.visibility, size: 18),
                          color: const Color(0xFF1E3A8A),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (!opportunity.isClosed)
                          IconButton(
                            onPressed: () => _showUpdateStageDialog(opportunity),
                            icon: const Icon(Icons.trending_up, size: 18),
                            color: Colors.green,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  void _showUpdateStageDialog(Opportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) {
        SalesStage? selectedStage = opportunity.salesStage;
        return AlertDialog(
          title: const Text('Update Sales Stage'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: SalesStage.values.map((stage) {
                return ListTile(
                  leading: Icon(stage.icon, color: stage.color),
                  title: Text(stage.displayName),
                  tileColor: selectedStage == stage ? stage.color.withValues(alpha: 0.1) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    selectedStage = stage;
                    Navigator.pop(context);
                    _updateStage(opportunity, selectedStage!);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }

  void _updateStage(Opportunity opportunity, SalesStage newStage) async {
    try {
      await ref.read(opportunityProvider.notifier).updateStage(opportunity.id, newStage);
    } catch (e) {
      // Error is handled by the provider
    }
  }
}