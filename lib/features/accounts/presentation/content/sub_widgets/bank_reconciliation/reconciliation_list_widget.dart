import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/bank_reconciliation_model.dart';
import '../../../../providers/bank_reconciliation_provider.dart';
import 'reconciliation_form_widget.dart';

class ReconciliationListWidget extends ConsumerStatefulWidget {
  const ReconciliationListWidget({super.key});

  @override
  ConsumerState<ReconciliationListWidget> createState() =>
      _ReconciliationListWidgetState();
}

class _ReconciliationListWidgetState
    extends ConsumerState<ReconciliationListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(bankReconciliationProvider);
    final notifier = ref.read(bankReconciliationProvider.notifier);

    if (state.currentPage < state.totalPages) {
      setState(() {
        _isLoadingMore = true;
      });

      final newFilters = state.filters.copyWith(page: state.currentPage + 1);
      notifier.fetchReconciliations(filters: newFilters).then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankReconciliationProvider);
    final notifier = ref.read(bankReconciliationProvider.notifier);

    return Padding(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 8 : 16,
      ),
      child: Column(
        children: [
          // Filters
          _buildFilters(state, notifier, context),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: _buildReconciliationList(state, notifier, context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildBankAccountFilter(state, notifier),
                      const SizedBox(height: 12),
                      _buildStatusFilter(state, notifier),
                      const SizedBox(height: 12),
                      _buildDateFilters(state, notifier, context),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBankAccountFilter(state, notifier)),
                    SizedBox(width: MediaQuery.of(context).size.width < 900 ? 8 : 12),
                    Expanded(child: _buildStatusFilter(state, notifier)),
                    SizedBox(width: MediaQuery.of(context).size.width < 900 ? 8 : 12),
                    Expanded(
                      child: _buildDateFilters(state, notifier, context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by reconciliation number...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: Color(0xFF0D47A1), width: 2),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                      final newFilters = state.filters.copyWith();
                      notifier.updateFilters(newFilters);
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width < 600 ? 8 : 12,
                ),
                ElevatedButton.icon(
                  onPressed: () => notifier.refresh(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: EdgeInsets.symmetric(
                      horizontal:
                      MediaQuery.of(context).size.width < 600 ? 12 : 16,
                      vertical: MediaQuery.of(context).size.width < 600 ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountFilter(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Account',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          value: state.filters.bankAccount,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All Accounts',
                style: TextStyle(fontSize: 13),
              ),
            ),
            ...state.bankAccounts.map((account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      account.accountName,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (account.bankAccountNumber != null)
                      Text(
                        account.bankAccountNumber!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            final newFilters = state.filters.copyWith(bankAccount: value);
            notifier.updateFilters(newFilters);
          },
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          value: state.filters.status,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All Statuses',
                style: TextStyle(fontSize: 13),
              ),
            ),
            ...ReconciliationStatus.values.map((status) {
              return DropdownMenuItem<String>(
                value: status.name,
                child: Text(
                  _getStatusDisplayText(status),
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }),
          ],
          onChanged: (value) {
            final newFilters = state.filters.copyWith(status: value);
            notifier.updateFilters(newFilters);
          },
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildDateFilters(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 400;

            if (isMobile) {
              return Column(
                children: [
                  _buildDateField(
                    'From',
                    state.filters.startDate,
                    true,
                    state,
                    notifier,
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildDateField(
                    'To',
                    state.filters.endDate,
                    false,
                    state,
                    notifier,
                    context,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'From',
                    state.filters.startDate,
                    true,
                    state,
                    notifier,
                    context,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateField(
                    'To',
                    state.filters.endDate,
                    false,
                    state,
                    notifier,
                    context,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label,
      String? dateValue,
      bool isStartDate,
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      readOnly: true,
      controller: TextEditingController(
        text: dateValue != null
            ? _formatDate(DateTime.parse(dateValue))
            : '',
      ),
      onTap: () => _selectDate(isStartDate, state, notifier, context),
    );
  }

  Widget _buildReconciliationList(
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) {
    if (state.isLoading && state.reconciliations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.reconciliations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: MediaQuery.of(context).size.width < 600 ? 48 : 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No reconciliations found',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first bank reconciliation to get started',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (state.bankAccounts.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.clearSelectedReconciliation();
                    _showCreateDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Reconciliation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 600 ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reconciliations',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }

                return const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Account / Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Statement Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Statement Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Book Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Difference',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: 60), // Actions column
                  ],
                );
              },
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
              state.reconciliations.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.reconciliations.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  );
                }

                final reconciliation = state.reconciliations[index];
                return _buildReconciliationItem(
                  reconciliation,
                  notifier,
                  context,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationItem(
      BankReconciliation reconciliation,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: InkWell(
              onTap: () => notifier.fetchReconciliationById(reconciliation.id!),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reconciliation.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reconciliation.reconciliationNumber,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                            reconciliation.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reconciliation.statusDisplayText,
                            style: TextStyle(
                              color: reconciliation.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statement: ${_formatCurrency(reconciliation.statementBalance)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Book: ${_formatCurrency(reconciliation.bookBalance)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(reconciliation.statementDate),
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(reconciliation.difference),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: reconciliation.difference.abs() > 0.01
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => notifier.fetchReconciliationById(reconciliation.id!),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 768 ? 12 : 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reconciliation.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reconciliation.reconciliationNumber,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(reconciliation.statementDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatCurrency(reconciliation.statementBalance),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatCurrency(reconciliation.bookBalance),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatCurrency(reconciliation.difference),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: reconciliation.difference.abs() > 0.01
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: reconciliation.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reconciliation.statusDisplayText,
                          style: TextStyle(
                            color: reconciliation.statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.visibility,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            onPressed: () =>
                                notifier.fetchReconciliationById(reconciliation.id!),
                            tooltip: 'View Details',
                            splashRadius: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          if (reconciliation.canEdit)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              onPressed: () =>
                                  _showEditDialog(context, reconciliation),
                              tooltip: 'Edit',
                              splashRadius: 16,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  String _getStatusDisplayText(ReconciliationStatus status) {
    switch (status) {
      case ReconciliationStatus.draft:
        return 'Draft';
      case ReconciliationStatus.in_progress:
        return 'In Progress';
      case ReconciliationStatus.completed:
        return 'Completed';
      case ReconciliationStatus.adjusted:
        return 'Adjusted';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  Future<void> _selectDate(
      bool isStartDate,
      BankReconciliationState state,
      BankReconciliationProvider notifier,
      BuildContext context,
      ) async {
    final initialDate = isStartDate && state.filters.startDate != null
        ? DateTime.parse(state.filters.startDate!)
        : (!isStartDate && state.filters.endDate != null
        ? DateTime.parse(state.filters.endDate!)
        : DateTime.now());

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final newFilters = isStartDate
          ? state.filters.copyWith(
          startDate: selectedDate.toIso8601String().split('T')[0])
          : state.filters.copyWith(
          endDate: selectedDate.toIso8601String().split('T')[0]);
      notifier.updateFilters(newFilters);
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width * 0.95
                : 800,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: const ReconciliationFormWidget(),
        ),
      ),
    ).then((_) {
      // Refresh list after dialog closes
      ref.read(bankReconciliationProvider.notifier).fetchReconciliations();
    });
  }

  void _showEditDialog(
      BuildContext context,
      BankReconciliation reconciliation,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width * 0.95
                : 800,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: ReconciliationFormWidget(reconciliation: reconciliation),
        ),
      ),
    ).then((_) {
      // Refresh list after dialog closes
      ref.read(bankReconciliationProvider.notifier).fetchReconciliations();
    });
  }
}