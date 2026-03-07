import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/journal_entry_model.dart';
import '../../../../providers/journal_entry_provider.dart';
import 'journal_entry_details_widget.dart';
import 'journal_entry_filter_widget.dart';
import 'journal_entry_card_widget.dart';

class JournalEntryListWidget extends ConsumerStatefulWidget {
  const JournalEntryListWidget({super.key});

  @override
  ConsumerState<JournalEntryListWidget> createState() =>
      _JournalEntryListWidgetState();
}

class _JournalEntryListWidgetState
    extends ConsumerState<JournalEntryListWidget> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journalEntryProvider.notifier).fetchJournalEntries();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    final state = ref.read(journalEntryProvider);
    if (state.currentPage < state.totalPages && !state.isLoading) {
      ref.read(journalEntryProvider.notifier).fetchJournalEntries(
        page: state.currentPage + 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalEntryProvider);

    return Column(
      children: [
        // Filters
        const JournalEntryFilterWidget(),

        // Content
        Expanded(
          child: state.isLoading && state.journalEntries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.journalEntries.isEmpty
              ? _buildEmptyState()
              : _buildJournalEntryList(state),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Journal Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first journal entry to get started',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntryList(JournalEntryState state) {
    return Column(
      children: [
        // Summary Bar
        _buildSummaryBar(state),

        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(journalEntryProvider.notifier)
                  .fetchJournalEntries();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.journalEntries.length + 1,
              itemBuilder: (context, index) {
                if (index == state.journalEntries.length) {
                  return state.currentPage < state.totalPages
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const SizedBox();
                }

                final entry = state.journalEntries[index];
                return JournalEntryCardWidget(
                  journalEntry: entry,
                  onTap: () => _showJournalEntryDetails(entry),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar(JournalEntryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            '${state.totalCount} entries',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  void _showJournalEntryDetails(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JournalEntryDetailsWidget(journalEntry: entry),
    );
  }
}