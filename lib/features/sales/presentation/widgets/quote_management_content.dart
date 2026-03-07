import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quote.model.dart';
import '../../providers/quote_provider.dart';
import 'sub_widgets/quotes/quote_form_widget.dart';
import 'sub_widgets/quotes/quote_list_widget.dart';
import 'sub_widgets/quotes/quote_stats_widget.dart';

class QuoteManagementContent extends ConsumerStatefulWidget {
  const QuoteManagementContent({super.key});

  @override
  ConsumerState<QuoteManagementContent> createState() =>
      _QuoteManagementContentState();
}

class _QuoteManagementContentState
    extends ConsumerState<QuoteManagementContent> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      ref.read(quoteProvider.notifier).refreshData();
      ref.read(quoteProvider.notifier).loadStats();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing quote data: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading quote management...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: !quoteState.showStats
          ? FloatingActionButton.extended(
        onPressed: () {
          _showQuoteFormDialog(context, ref, null);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Quote'),
        backgroundColor: const Color(0xFF1E3A8A),
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, quoteState),

            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(quoteState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuoteState quoteState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quotes Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quoteState.showStats) {
                        ref.read(quoteProvider.notifier).showQuoteList();
                      } else {
                        ref.read(quoteProvider.notifier).showQuoteStats();
                      }
                    },
                    icon: Icon(
                      quoteState.showStats ? Icons.list : Icons.bar_chart,
                      color: const Color(0xFF1E3A8A),
                    ),
                    tooltip: quoteState.showStats ? 'Show List' : 'View Stats',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!quoteState.showStats) _buildQuickStats(quoteState),
        ],
      ),
    );
  }

  Widget _buildQuickStats(QuoteState quoteState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            'Total Quotes',
            '${quoteState.totalItems}',
            Icons.description,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Pending Approval',
            '${quoteState.stats?.byApprovalStatus[ApprovalStatus.pending] ?? 0}',
            Icons.pending,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Value',
            quoteState.stats?.totalAmountFormatted ?? 'KES 0.00',
            Icons.attach_money,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(QuoteState quoteState) {
    if (quoteState.error != null && quoteState.error!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              quoteState.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(quoteProvider.notifier).refreshData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (quoteState.showStats) {
      return const QuoteStatsWidget();
    } else {
      return const QuoteListWidget();
    }
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