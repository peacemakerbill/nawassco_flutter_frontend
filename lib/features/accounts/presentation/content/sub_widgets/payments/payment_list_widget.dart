import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';
import 'payment_details_widget.dart';
import 'payment_form_widget.dart';

class PaymentListWidget extends ConsumerStatefulWidget {
  const PaymentListWidget({super.key});

  @override
  ConsumerState<PaymentListWidget> createState() => _PaymentListWidgetState();
}

class _PaymentListWidgetState extends ConsumerState<PaymentListWidget> {
  bool _initialized = false;
  final TextEditingController _searchController = TextEditingController();
  List<Payment> _filteredPayments = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load data once when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        ref.read(paymentProvider.notifier).fetchPayments();
      }
    });

    // Listen to search controller changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _applySearchFilter(List<Payment> payments) {
    if (_searchQuery.isEmpty) {
      _filteredPayments = List.from(payments);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredPayments = payments.where((payment) {
        return payment.paymentNumber.toLowerCase().contains(query) ||
            (payment.payeeName?.toLowerCase().contains(query) ?? false) ||
            (payment.companyBankName?.toLowerCase().contains(query) ?? false) ||
            payment.statusDisplay.toLowerCase().contains(query) ||
            payment.amount.toString().contains(query) ||
            _formatDate(payment.paymentDate).toLowerCase().contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final theme = Theme.of(context);

    // Apply search filter whenever payments change
    if (_filteredPayments.isEmpty || _searchQuery.isNotEmpty) {
      _applySearchFilter(paymentState.payments);
    } else if (_searchQuery.isEmpty) {
      _filteredPayments = List.from(paymentState.payments);
    }

    // Simple loading and error states
    if (paymentState.isLoading && paymentState.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentState.error != null && paymentState.payments.isEmpty) {
      return _buildErrorState(paymentState.error!, ref);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          _searchController.clear();
          return ref.read(paymentProvider.notifier).fetchPayments(page: 1);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: const Text('Payments'),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(paymentProvider.notifier).fetchPayments(page: 1);
                  },
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, color: theme.hintColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search payments...',
                            hintStyle: TextStyle(color: theme.hintColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (_) {
                            // Filtering happens automatically via the listener
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: theme.hintColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          tooltip: 'Clear search',
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Results Info
            if (_searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Search Results (${_filteredPayments.length})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: Text(
                          'Clear Search',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick Stats
            SliverToBoxAdapter(child: _buildQuickStats(paymentState, theme)),

            // Title with count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Payments (${paymentState.totalCount})',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Filtered: ${_filteredPayments.length}'),
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: theme.primaryColor),
                      ),
                  ],
                ),
              ),
            ),

            // Payments List
            if (_filteredPayments.isEmpty)
              SliverFillRemaining(child: _buildSearchEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final payment = _filteredPayments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPaymentCard(context, payment, ref, theme),
                      );
                    },
                    childCount: _filteredPayments.length,
                  ),
                ),
              ),

            // Pagination (only show when not searching)
            if (paymentState.totalPages > 1 && _searchQuery.isEmpty)
              SliverToBoxAdapter(child: _buildPagination(paymentState, ref)),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // Floating Action Button for Create Payment
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePaymentDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create New Payment',
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'Create your first payment to get started'
                  : 'No payments match your search for "$_searchQuery"',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Failed to load payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(paymentProvider.notifier).fetchPayments(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No payments yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first payment to get started',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(PaymentState state, ThemeData theme) {
    final displayedPayments = _searchQuery.isEmpty ? state.payments : _filteredPayments;
    final totalAmount = displayedPayments.fold<double>(0.0, (sum, p) => sum + p.amount);
    final processedCount = displayedPayments.where((p) => p.status == PaymentStatus.processed).length;
    final draftCount = displayedPayments.where((p) => p.status == PaymentStatus.draft).length;
    final approvedCount = displayedPayments.where((p) => p.status == PaymentStatus.approved).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 700;
          final bool isMobile = constraints.maxWidth < 500;

          if (isMobile) {
            return Column(
              children: [
                _buildStatItem('Total Amount', 'KES ${totalAmount.toStringAsFixed(2)}', Icons.account_balance_wallet, theme.primaryColor),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatItem('Processed', processedCount.toString(), Icons.check_circle, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatItem('Draft', draftCount.toString(), Icons.edit_note, Colors.orange)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatItem('Approved', approvedCount.toString(), Icons.verified, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatItem('Total', displayedPayments.length.toString(), Icons.format_list_numbered, Colors.purple)),
                  ],
                ),
              ],
            );
          }

          return isWide
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Total Amount', 'KES ${totalAmount.toStringAsFixed(2)}', Icons.account_balance_wallet, theme.primaryColor),
              _buildStatItem('Processed', processedCount.toString(), Icons.check_circle, Colors.green),
              _buildStatItem('Draft', draftCount.toString(), Icons.edit_note, Colors.orange),
              _buildStatItem('Approved', approvedCount.toString(), Icons.verified, Colors.blue),
              _buildStatItem('Total Payments', displayedPayments.length.toString(), Icons.format_list_numbered, Colors.purple),
            ],
          )
              : Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildStatItem('Total Amount', 'KES ${totalAmount.toStringAsFixed(2)}', Icons.account_balance_wallet, theme.primaryColor),
              _buildStatItem('Processed', processedCount.toString(), Icons.check_circle, Colors.green),
              _buildStatItem('Draft', draftCount.toString(), Icons.edit_note, Colors.orange),
              _buildStatItem('Approved', approvedCount.toString(), Icons.verified, Colors.blue),
              _buildStatItem('Total', displayedPayments.length.toString(), Icons.format_list_numbered, Colors.purple),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      constraints: const BoxConstraints(minWidth: 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment, WidgetRef ref, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPaymentDetails(context, payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status bar
                  Container(
                    width: 6,
                    height: 80,
                    decoration: BoxDecoration(color: payment.statusColor, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.paymentNumber,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    payment.payeeName ?? 'Unknown Payee',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(payment.statusDisplay, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: payment.statusColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isWide)
                          Row(
                            children: [
                              _infoChip(Icons.calendar_today, _formatDate(payment.paymentDate)),
                              const SizedBox(width: 12),
                              _infoChip(Icons.account_balance, payment.companyBankName ?? 'N/A'),
                              const SizedBox(width: 12),
                              _infoChip(Icons.payments, payment.paymentMethod.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${_formatDate(payment.paymentDate)}', style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text('Bank: ${payment.companyBankName ?? 'N/A'}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'KES ${payment.amount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (action) => _handlePaymentAction(action, payment, context, ref),
                              itemBuilder: (context) => _buildPopupMenuItems(payment),
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(Payment payment) {
    final actions = <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(value: 'view', child: ListTile(leading: Icon(Icons.visibility), title: Text('View Details'))),
    ];

    if (payment.canEdit) {
      actions.add(const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))));
    }
    if (payment.canApprove) {
      actions.add(const PopupMenuItem<String>(value: 'approve', child: ListTile(leading: Icon(Icons.verified), title: Text('Approve'))));
    }
    if (payment.canProcess) {
      actions.add(const PopupMenuItem<String>(value: 'process', child: ListTile(leading: Icon(Icons.play_arrow), title: Text('Process'))));
    }
    if (payment.canCancel) {
      actions.add(const PopupMenuItem<String>(value: 'cancel', child: ListTile(leading: Icon(Icons.cancel, color: Colors.red), title: Text('Cancel', style: TextStyle(color: Colors.red)))));
    }

    actions.add(const PopupMenuDivider());

    if (payment.status == PaymentStatus.draft) {
      actions.add(const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))));
    }

    return actions;
  }

  void _handlePaymentAction(String action, Payment payment, BuildContext context, WidgetRef ref) {
    final notifier = ref.read(paymentProvider.notifier);

    switch (action) {
      case 'view':
        _showPaymentDetails(context, payment);
        break;
      case 'edit':
        _showEditPaymentDialog(context, payment);
        break;
      case 'approve':
        _approvePayment(payment, notifier, context);
        break;
      case 'process':
        _processPayment(payment, notifier, context);
        break;
      case 'cancel':
        _cancelPayment(payment, notifier, context);
        break;
      case 'delete':
        _deletePayment(payment, notifier, context);
        break;
    }
  }

  void _showPaymentDetails(BuildContext context, Payment payment) {
    showDialog(context: context, builder: (_) => PaymentDetailsWidget(payment: payment));
  }

  void _showEditPaymentDialog(BuildContext context, Payment payment) {
    showDialog(context: context, builder: (_) => PaymentFormWidget(payment: payment));
  }

  void _showCreatePaymentDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const PaymentFormWidget());
  }

  Future<void> _approvePayment(Payment payment, PaymentProvider notifier, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Payment'),
        content: Text('Approve ${payment.paymentNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await notifier.approvePayment(payment.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment ${payment.paymentNumber} approved'), backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _processPayment(Payment payment, PaymentProvider notifier, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Process Payment'),
        content: Text('Process ${payment.paymentNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Process')),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await notifier.processPayment(payment.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment ${payment.paymentNumber} processed'), backgroundColor: Colors.blue));
      }
    }
  }

  Future<void> _cancelPayment(Payment payment, PaymentProvider notifier, BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Cancel ${payment.paymentNumber}?'),
          const SizedBox(height: 16),
          TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await notifier.cancelPayment(payment.id, reason: reasonController.text);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment cancelled'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deletePayment(Payment payment, PaymentProvider notifier, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await notifier.deletePayment(payment.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment deleted'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildPagination(PaymentState state, WidgetRef ref) {
    final notifier = ref.read(paymentProvider.notifier);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1 ? () => notifier.fetchPayments(page: state.currentPage - 1) : null,
            tooltip: 'Previous Page',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: Text('Page ${state.currentPage} of ${state.totalPages}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages ? () => notifier.fetchPayments(page: state.currentPage + 1) : null,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}