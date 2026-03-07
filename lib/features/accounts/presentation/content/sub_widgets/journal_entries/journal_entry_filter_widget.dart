import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/journal_entry_provider.dart';

class JournalEntryFilterWidget extends ConsumerStatefulWidget {
  const JournalEntryFilterWidget({super.key});

  @override
  ConsumerState<JournalEntryFilterWidget> createState() =>
      _JournalEntryFilterWidgetState();
}

class _JournalEntryFilterWidgetState
    extends ConsumerState<JournalEntryFilterWidget> {
  final _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _statusFilter;
  String? _sourceDocumentFilter;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    final state = ref.read(journalEntryProvider);
    _searchController.text = state.searchQuery;
    _startDate = state.startDate;
    _endDate = state.endDate;
    _statusFilter = state.statusFilter;
    _sourceDocumentFilter = state.sourceDocumentFilter;
  }

  void _applyFilters() {
    ref.read(journalEntryProvider.notifier).updateFilters(
      searchQuery: _searchController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      status: _statusFilter,
      sourceDocument: _sourceDocumentFilter,
    );
    ref.read(journalEntryProvider.notifier).fetchJournalEntries();
  }

  void _clearFilters() {
    _searchController.clear();
    _startDate = null;
    _endDate = null;
    _statusFilter = null;
    _sourceDocumentFilter = null;

    ref.read(journalEntryProvider.notifier).updateFilters(
      searchQuery: '',
      startDate: null,
      endDate: null,
      status: null,
      sourceDocument: null,
    );
    ref.read(journalEntryProvider.notifier).fetchJournalEntries();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Row
            _buildSearchRow(),
            const SizedBox(height: 16),
            // Filter Row
            _buildFilterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search entries...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        const SizedBox(width: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return Column(
                children: [
                  FilledButton(
                    onPressed: _applyFilters,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: const Icon(Icons.search, size: 20),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Icon(Icons.clear, size: 20),
                  ),
                ],
              );
            }
            return Row(
              children: [
                FilledButton(
                  onPressed: _applyFilters,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Column(
            children: [
              _buildDateFilter(true),
              const SizedBox(height: 12),
              _buildDateFilter(false),
              const SizedBox(height: 12),
              _buildStatusFilter(),
              const SizedBox(height: 12),
              _buildSourceDocumentFilter(),
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: constraints.maxWidth < 1000
                  ? (constraints.maxWidth - 72) / 4
                  : 200,
              child: _buildDateFilter(true),
            ),
            SizedBox(
              width: constraints.maxWidth < 1000
                  ? (constraints.maxWidth - 72) / 4
                  : 200,
              child: _buildDateFilter(false),
            ),
            SizedBox(
              width: constraints.maxWidth < 1000
                  ? (constraints.maxWidth - 72) / 4
                  : 200,
              child: _buildStatusFilter(),
            ),
            SizedBox(
              width: constraints.maxWidth < 1000
                  ? (constraints.maxWidth - 72) / 4
                  : 200,
              child: _buildSourceDocumentFilter(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateFilter(bool isStartDate) {
    final date = isStartDate ? _startDate : _endDate;
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: isStartDate ? 'From Date' : 'To Date',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Select date',
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: date != null
            ? IconButton(
          icon: const Icon(Icons.clear, size: 16),
          onPressed: () {
            setState(() {
              if (isStartDate) {
                _startDate = null;
              } else {
                _endDate = null;
              }
            });
            _applyFilters();
          },
        )
            : null,
      ),
      controller: TextEditingController(
        text: date != null
            ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
            : '',
      ),
      onTap: () => _selectDate(context, isStartDate),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _statusFilter,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Status')),
        DropdownMenuItem(value: 'draft', child: Text('Draft')),
        DropdownMenuItem(value: 'posted', child: Text('Posted')),
        DropdownMenuItem(value: 'approved', child: Text('Approved')),
        DropdownMenuItem(value: 'reversed', child: Text('Reversed')),
        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildSourceDocumentFilter() {
    return DropdownButtonFormField<String>(
      value: _sourceDocumentFilter,
      decoration: InputDecoration(
        labelText: 'Source Document',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Sources')),
        DropdownMenuItem(value: 'manual', child: Text('Manual')),
        DropdownMenuItem(value: 'invoice', child: Text('Invoice')),
        DropdownMenuItem(value: 'payment', child: Text('Payment')),
        DropdownMenuItem(value: 'receipt', child: Text('Receipt')),
        DropdownMenuItem(
            value: 'purchase_order', child: Text('Purchase Order')),
        DropdownMenuItem(value: 'sales_order', child: Text('Sales Order')),
        DropdownMenuItem(
            value: 'bank_reconciliation', child: Text('Bank Reconciliation')),
        DropdownMenuItem(value: 'adjustment', child: Text('Adjustment')),
      ],
      onChanged: (value) {
        setState(() {
          _sourceDocumentFilter = value;
        });
        _applyFilters();
      },
    );
  }
}