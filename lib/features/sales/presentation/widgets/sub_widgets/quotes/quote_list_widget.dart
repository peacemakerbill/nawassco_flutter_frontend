import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/quote.model.dart';
import '../../../../providers/quote_provider.dart';
import 'quote_detail_widget.dart';
import 'quote_form_widget.dart';

class QuoteListWidget extends ConsumerStatefulWidget {
  const QuoteListWidget({super.key});

  @override
  ConsumerState<QuoteListWidget> createState() => _QuoteListWidgetState();
}

class _QuoteListWidgetState extends ConsumerState<QuoteListWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  QuoteStatus? _selectedStatus;
  ApprovalStatus? _selectedApprovalStatus;
  String? _selectedCustomerId;
  String? _selectedOpportunityId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(quoteProvider.notifier).loadNextPage();
    }
  }

  void _applyFilters() {
    final filters = QuoteFilters(
      status: _selectedStatus,
      approvalStatus: _selectedApprovalStatus,
      customer: _selectedCustomerId,
      opportunity: _selectedOpportunityId,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
    ref.read(quoteProvider.notifier).updateFilters(filters);
    setState(() {
      _showFilters = false;
    });
  }

  void _clearFilters() {
    _selectedStatus = null;
    _selectedApprovalStatus = null;
    _selectedCustomerId = null;
    _selectedOpportunityId = null;
    _searchController.clear();
    ref.read(quoteProvider.notifier).clearFilters();
    setState(() {
      _showFilters = false;
    });
  }

  void _showQuoteDetailsDialog(
      BuildContext context, WidgetRef ref, Quote quote) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: QuoteDetailWidget(quote: quote),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);

    return Column(
      children: [
        // Compact Filter Section
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search quotes, customers, opportunities...',
                          prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                            icon: const Icon(Icons.clear, size: 20),
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) _applyFilters();
                        },
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                        color: const Color(0xFF1E3A8A),
                      ),
                      tooltip: 'Toggle Filters',
                    ),
                    IconButton(
                      onPressed: _applyFilters,
                      icon:
                      const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                      tooltip: 'Search',
                    ),
                  ],
                ),

                // Collapsible Filters
                if (_showFilters) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<QuoteStatus?>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Status'),
                            ),
                            ...QuoteStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: status.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(status.displayName),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<ApprovalStatus?>(
                          value: _selectedApprovalStatus,
                          decoration: InputDecoration(
                            labelText: 'Approval',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Approval'),
                            ),
                            ...ApprovalStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: status.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(status.displayName),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedApprovalStatus = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed:
                        quoteState.filters.hasFilters ? _clearFilters : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Quote List
        Expanded(
          child: quoteState.isLoading && quoteState.quotes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : quoteState.quotes.isEmpty
              ? _buildEmptyState(ref)
              : RefreshIndicator(
            onRefresh: () async {
              ref.read(quoteProvider.notifier).refreshData();
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: quoteState.quotes.length + 1,
              itemBuilder: (context, index) {
                if (index == quoteState.quotes.length) {
                  return quoteState.isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : const SizedBox.shrink();
                }
                final quote = quoteState.quotes[index];
                return _buildQuoteCard(quote);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);
    final filters = quoteState.filters;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No quotes found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                filters.hasFilters
                    ? 'Try adjusting your filters'
                    : 'Create your first quote to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _showQuoteFormDialog(context, ref, null);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Quote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          _showQuoteDetailsDialog(context, ref, quote);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quote.customerDisplayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (quote.customerEmail != null &&
                            quote.customerEmail!.isNotEmpty)
                          Text(
                            quote.customerEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (quote.opportunityNumber != null &&
                            quote.opportunityNumber!.isNotEmpty)
                          Text(
                            'Opportunity: ${quote.opportunityNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: quote.status.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: quote.status.color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          quote.status.displayName,
                          style: TextStyle(
                            color: quote.status.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: quote.approvalStatus.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: quote.approvalStatus.color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          quote.approvalStatus.displayName,
                          style: TextStyle(
                            color: quote.approvalStatus.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // User Info Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            quote.createdByDisplayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${quote.quoteDate.day}/${quote.quoteDate.month}/${quote.quoteDate.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Details Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDetailItem(
                      Icons.timer,
                      'Expiry',
                      '${quote.expiryDate.day}/${quote.expiryDate.month}/${quote.expiryDate.year}',
                      color: quote.expiryColor,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailItem(
                      Icons.attach_money,
                      'Total',
                      quote.formattedTotal,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailItem(
                      Icons.description,
                      'Items',
                      '${quote.items.length}',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailItem(
                      Icons.schedule,
                      'Validity',
                      '${quote.validityPeriod} days',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showQuoteDetailsDialog(context, ref, quote);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (quote.canBeSent)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showSendConfirmation(quote);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Send'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, {Color? color}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color ?? Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  void _showSendConfirmation(Quote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Quote'),
        content: const Text(
          'Are you sure you want to send this quote to the customer? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(quoteProvider.notifier).sendQuote(quote.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Quote'),
          ),
        ],
      ),
    );
  }

  void _showQuoteFormDialog(BuildContext context, WidgetRef ref, Quote? quote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: QuoteFormWidget(initialQuote: quote),
        ),
      ),
    );
  }
}