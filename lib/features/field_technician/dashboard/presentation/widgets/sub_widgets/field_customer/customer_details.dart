import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/utils/toast_utils.dart';
import '../../../../models/field_customer.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/field_customer_provider.dart';
import '../../../../providers/work_order_provider.dart';

class CustomerDetailsWidget extends ConsumerStatefulWidget {
  final FieldCustomer customer;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const CustomerDetailsWidget({
    super.key,
    required this.customer,
    required this.onBack,
    required this.onEdit,
  });

  @override
  ConsumerState<CustomerDetailsWidget> createState() =>
      _CustomerDetailsWidgetState();
}

class _CustomerDetailsWidgetState extends ConsumerState<CustomerDetailsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _paymentReferenceController = TextEditingController();
  final _suspendReasonController = TextEditingController();

  String? _selectedPaymentMethod;
  List<String> _paymentMethods = [
    'Cash',
    'MPesa',
    'Bank Transfer',
    'Credit Card',
    'Other'
  ];
  StreamSubscription? _workOrderSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load work orders for this customer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomerWorkOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentAmountController.dispose();
    _paymentMethodController.dispose();
    _paymentReferenceController.dispose();
    _suspendReasonController.dispose();
    _workOrderSubscription?.cancel();
    super.dispose();
  }

  void _loadCustomerWorkOrders() {
    // Filter work orders for this customer
    final provider = ref.read(workOrderProvider.notifier);
    provider.updateFilters({'customer': widget.customer.id});
  }

  @override
  Widget build(BuildContext context) {
    final workOrders =
        ref.watch(filteredWorkOrdersProvider({'customer': widget.customer.id}));
    final totalSpent =
        workOrders.fold<double>(0, (sum, wo) => sum + wo.actualCost);
    final completedOrders =
        workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(widget.customer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: widget.onEdit,
            tooltip: 'Edit Customer',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePopupAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print Details'),
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Info'),
                ),
              ),
              const PopupMenuItem(
                value: 'notification',
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  title: Text('Send Notification'),
                ),
              ),
              PopupMenuItem(
                value: 'suspend',
                child: ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title:
                      widget.customer.accountStatus == AccountStatus.suspended
                          ? const Text('Reactivate Account')
                          : const Text('Suspend Account'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Customer'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header
            _buildCustomerHeader(context, totalSpent),
            const SizedBox(height: 24),

            // Tabs
            Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Billing'),
                      Tab(text: 'Service'),
                      Tab(text: 'Work Orders'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(context, totalSpent, completedOrders,
                          workOrders.length),
                      _buildBillingTab(context),
                      _buildServiceTab(context),
                      _buildWorkOrdersTab(context, workOrders),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(BuildContext context, double totalSpent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.customer.firstName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.customer.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.customer.accountStatus.color
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: widget.customer.accountStatus.color),
                        ),
                        child: Text(
                          widget.customer.accountStatus.displayName,
                          style: TextStyle(
                            color: widget.customer.accountStatus.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer #: ${widget.customer.customerNumber}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Account #: ${widget.customer.accountNumber}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.phone, widget.customer.phoneNumber),
                      _buildInfoChip(Icons.email, widget.customer.email),
                      _buildInfoChip(Icons.location_on,
                          widget.customer.address.fullAddress),
                      _buildInfoChip(Icons.category,
                          widget.customer.customerType.displayName),
                      _buildInfoChip(Icons.settings,
                          widget.customer.connectionType.displayName),
                    ],
                  ),
                ],
              ),
            ),

            // Balance Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.customer.formattedBalance,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.customer.hasOutstandingBalance
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.customer.hasOutstandingBalance)
                    ElevatedButton.icon(
                      onPressed: () => _showRecordPaymentDialog(context),
                      icon: const Icon(Icons.payment),
                      label: const Text('Record Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, double totalSpent,
      int completedOrders, int totalOrders) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Account Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 8,
                    children: [
                      _buildInfoRow('Customer Type',
                          widget.customer.customerType.displayName),
                      _buildInfoRow('Connection Type',
                          widget.customer.connectionType.displayName),
                      _buildInfoRow('Meter Number',
                          widget.customer.meterNumber ?? 'Not assigned'),
                      _buildInfoRow('Preferred Language',
                          widget.customer.preferredLanguage.toUpperCase()),
                      _buildInfoRow('Account Created',
                          _formatDate(widget.customer.createdAt)),
                      _buildInfoRow('Last Updated',
                          _formatDate(widget.customer.updatedAt)),
                      _buildInfoRow('Service Requests',
                          '${widget.customer.serviceRequests.length}'),
                      _buildInfoRow('Work Orders', '$totalOrders'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Spent',
                'KSh ${totalSpent.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
              ),
              _buildStatCard(
                'Completed Orders',
                '$completedOrders',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Service Rating',
                widget.customer.serviceHistory.isNotEmpty
                    ? (widget.customer.serviceHistory.fold<double>(
                                0, (sum, s) => sum + (s.rating ?? 0)) /
                            widget.customer.serviceHistory.length)
                        .toStringAsFixed(1)
                    : 'N/A',
                Icons.star,
                Colors.amber,
              ),
              _buildStatCard(
                'Avg Monthly Bill',
                'KSh ${widget.customer.billing.averageMonthlyBill.toStringAsFixed(2)}',
                Icons.receipt,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Billing Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.currency(
                          locale: 'en_KE',
                          symbol: 'KES ',
                          decimalDigits: 0,
                        ),
                      ),
                      series: <ColumnSeries<Map<String, dynamic>, String>>[
                        ColumnSeries<Map<String, dynamic>, String>(
                          dataSource: _generateBillingData(),
                          xValueMapper: (data, _) => data['month'],
                          yValueMapper: (data, _) => data['amount'],
                          color: Colors.blue,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingTab(BuildContext context) {
    final sortedPayments = widget.customer.paymentHistory
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    final totalPaid = sortedPayments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return Column(
      children: [
        // Billing Information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billing Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 8,
                  children: [
                    _buildInfoRow(
                        'Current Balance', widget.customer.formattedBalance),
                    _buildInfoRow('Average Monthly Bill',
                        'KSh ${widget.customer.billing.averageMonthlyBill.toStringAsFixed(2)}'),
                    _buildInfoRow(
                        'Last Payment',
                        widget.customer.billing.lastPaymentDate != null
                            ? _formatDate(
                                widget.customer.billing.lastPaymentDate!)
                            : 'Never'),
                    _buildInfoRow('Last Payment Amount',
                        'KSh ${widget.customer.billing.lastPaymentAmount.toStringAsFixed(2)}'),
                    _buildInfoRow(
                        'Billing Cycle', widget.customer.billing.billingCycle),
                    _buildInfoRow(
                        'Total Paid', 'KSh ${totalPaid.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment History
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Payment History',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (sortedPayments.length > 5)
                      TextButton(
                        onPressed: () => _showAllPaymentsDialog(context),
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sortedPayments.isEmpty)
                  const Center(
                    child: Text(
                      'No payment history',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: sortedPayments.take(5).map((payment) {
                      return _buildPaymentListItem(payment);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTab(BuildContext context) {
    final sortedServices = widget.customer.serviceHistory
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    final totalRating = widget.customer.serviceHistory.isNotEmpty
        ? (widget.customer.serviceHistory
                .fold<double>(0, (sum, s) => sum + (s.rating ?? 0)) /
            widget.customer.serviceHistory.length)
        : 0;

    return Column(
      children: [
        // Service Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Services',
                      '${widget.customer.serviceHistory.length}',
                      Icons.history,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Avg. Rating',
                      totalRating > 0 ? totalRating.toStringAsFixed(1) : 'N/A',
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      'Last Service',
                      sortedServices.isNotEmpty
                          ? _formatDate(sortedServices.first.serviceDate)
                          : 'Never',
                      Icons.calendar_today,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Common Issue',
                      _getMostCommonServiceType(),
                      Icons.build,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recent Services
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Services',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddServiceDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Service'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sortedServices.isEmpty)
                  const Center(
                    child: Text(
                      'No service history',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: sortedServices.take(5).map((service) {
                      return _buildServiceListItem(service);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkOrdersTab(BuildContext context, List<WorkOrder> workOrders) {
    final sortedWorkOrders = workOrders
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    final completed =
        workOrders.where((wo) => wo.status == WorkOrderStatus.completed).length;
    final inProgress = workOrders
        .where((wo) => wo.status == WorkOrderStatus.inProgress)
        .length;
    final pending =
        workOrders.where((wo) => wo.status == WorkOrderStatus.pending).length;
    final totalCost =
        workOrders.fold<double>(0, (sum, wo) => sum + wo.actualCost);

    return Column(
      children: [
        // Work Order Stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Work Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total',
                      '${workOrders.length}',
                      Icons.work,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Completed',
                      '$completed',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'In Progress',
                      '$inProgress',
                      Icons.hourglass_bottom,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Pending',
                      '$pending',
                      Icons.pending,
                      Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                    'Total Cost', 'KSh ${totalCost.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildInfoRow('Avg Completion Time',
                    _calculateAvgCompletionTime(workOrders)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recent Work Orders
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Work Orders',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateWorkOrderDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Work Order'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sortedWorkOrders.isEmpty)
                  const Center(
                    child: Text(
                      'No work orders found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: sortedWorkOrders.take(5).map((workOrder) {
                      return _buildWorkOrderListItem(workOrder);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentListItem(PaymentRecord payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: payment.status.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.payment,
            color: payment.status.color,
          ),
        ),
        title: Text(
          'KSh ${payment.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${payment.method} • ${_formatDate(payment.paymentDate)} • ${payment.reference}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: payment.status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: payment.status.color.withOpacity(0.3)),
          ),
          child: Text(
            payment.status.displayName,
            style: TextStyle(
              color: payment.status.color,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceListItem(ServiceHistory service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.build, color: Colors.blue),
        ),
        title: Text(
          service.serviceType,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatDate(service.serviceDate)} • ${service.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: service.rating != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(service.rating!.toStringAsFixed(1)),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildWorkOrderListItem(WorkOrder workOrder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: workOrder.priority == WorkOrderPriority.high ||
                    workOrder.priority == WorkOrderPriority.urgent
                ? Colors.red.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.work,
            color: workOrder.priority == WorkOrderPriority.high ||
                    workOrder.priority == WorkOrderPriority.urgent
                ? Colors.red
                : Colors.blue,
          ),
        ),
        title: Text(
          workOrder.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${workOrder.workOrderNumber} • ${_formatDate(workOrder.scheduledDate)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: workOrder.status == WorkOrderStatus.completed
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            workOrder.status.displayName,
            style: TextStyle(
              color: workOrder.status == WorkOrderStatus.completed
                  ? Colors.green
                  : Colors.orange,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => _showWorkOrderDetails(context, workOrder),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Map<String, dynamic>> _generateBillingData() {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      months.add({
        'month': '${date.month}/${date.year}',
        'amount':
            widget.customer.billing.averageMonthlyBill * (0.8 + 0.4 * (i / 5)),
      });
    }

    return months;
  }

  String _getMostCommonServiceType() {
    if (widget.customer.serviceHistory.isEmpty) return 'None';

    final counts = <String, int>{};
    for (final service in widget.customer.serviceHistory) {
      counts[service.serviceType] = (counts[service.serviceType] ?? 0) + 1;
    }

    final mostCommon =
        counts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostCommon.key;
  }

  String _calculateAvgCompletionTime(List<WorkOrder> workOrders) {
    final completedOrders = workOrders
        .where((wo) =>
            wo.status == WorkOrderStatus.completed &&
            wo.actualStartDate != null &&
            wo.actualEndDate != null)
        .toList();

    if (completedOrders.isEmpty) return 'N/A';

    final totalMinutes = completedOrders.fold<double>(0, (sum, wo) {
      final duration = wo.actualEndDate!.difference(wo.actualStartDate!);
      return sum + duration.inMinutes.toDouble();
    });

    final avgMinutes = totalMinutes / completedOrders.length;

    if (avgMinutes < 60) {
      return '${avgMinutes.toInt()} minutes';
    } else {
      return '${(avgMinutes / 60).toStringAsFixed(1)} hours';
    }
  }

  // Dialog Methods
  Future<void> _showRecordPaymentDialog(BuildContext context) async {
    _selectedPaymentMethod = _paymentMethods.first;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _paymentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'KSh ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Payment method is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentReferenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number (Optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitPayment(context),
              child: const Text('Record Payment'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_paymentAmountController.text) ?? 0;
    final paymentRecord = PaymentRecord(
      paymentDate: DateTime.now(),
      amount: amount,
      method: _selectedPaymentMethod!,
      reference: _paymentReferenceController.text.isNotEmpty
          ? _paymentReferenceController.text
          : 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
      status: PaymentStatus.paid,
    );

    final success =
        await ref.read(fieldCustomerProvider.notifier).recordPayment(
              widget.customer.id,
              paymentRecord,
            );

    if (success) {
      Navigator.pop(context);
      _paymentAmountController.clear();
      _paymentMethodController.clear();
      _paymentReferenceController.clear();
    }
  }

  Future<void> _showAllPaymentsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('All Payments'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: widget.customer.paymentHistory.map((payment) {
                  return _buildPaymentListItem(payment);
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddServiceDialog(BuildContext context) async {
    final serviceTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    final ratingController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Service History'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: serviceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'e.g., Meter Installation, Leak Repair',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Service type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating (1-5, optional)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final rating = double.tryParse(value);
                      if (rating == null || rating < 1 || rating > 5) {
                        return 'Enter a rating between 1 and 5';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final service = ServiceHistory(
                  serviceDate: DateTime.now(),
                  serviceType: serviceTypeController.text,
                  description: descriptionController.text,
                  technicianId: 'current_user_id',
                  // Replace with actual technician ID
                  workOrderId: '',
                  rating: ratingController.text.isNotEmpty
                      ? double.tryParse(ratingController.text)
                      : null,
                );

                final success = await ref
                    .read(fieldCustomerProvider.notifier)
                    .addServiceHistory(
                      widget.customer.id,
                      service,
                    );

                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Service'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWorkOrderDetails(
      BuildContext context, WorkOrder workOrder) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(workOrder.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('Work Order #', workOrder.workOrderNumber),
                _buildInfoRow('Status', workOrder.status.displayName),
                _buildInfoRow('Priority', workOrder.priority.displayName),
                _buildInfoRow(
                    'Scheduled Date', _formatDate(workOrder.scheduledDate)),
                if (workOrder.actualStartDate != null)
                  _buildInfoRow(
                      'Actual Start', _formatDate(workOrder.actualStartDate!)),
                if (workOrder.actualEndDate != null)
                  _buildInfoRow(
                      'Actual End', _formatDate(workOrder.actualEndDate!)),
                _buildInfoRow('Estimated Cost',
                    'KSh ${workOrder.estimatedCost.toStringAsFixed(2)}'),
                _buildInfoRow('Actual Cost',
                    'KSh ${workOrder.actualCost.toStringAsFixed(2)}'),
                _buildInfoRow('Description', workOrder.description),
                const SizedBox(height: 16),
                if (workOrder.assignedTechnicianNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Technicians:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...workOrder.assignedTechnicianNames
                          .map((name) => Text('• $name')),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to full work order details
                Navigator.pop(context);
              },
              child: const Text('View Full Details'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateWorkOrderDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Work Order'),
          content: const Text(
              'This will create a new work order for this customer. Proceed to the work order creation form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to work order creation
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  void _handlePopupAction(String value, BuildContext context) {
    switch (value) {
      case 'print':
        _printCustomerDetails();
        break;
      case 'share':
        _shareCustomerInfo(context);
        break;
      case 'notification':
        _sendNotification(context);
        break;
      case 'suspend':
        if (widget.customer.accountStatus == AccountStatus.suspended) {
          _reactivateAccount(context);
        } else {
          _suspendAccount(context);
        }
        break;
      case 'delete':
        _deleteCustomer(context);
        break;
    }
  }

  void _printCustomerDetails() {
    // Implement print functionality
    ToastUtils.showInfoToast('Print functionality coming soon!');
  }

  void _shareCustomerInfo(BuildContext context) {
    // Implement share functionality
    final shareText = '''
Customer: ${widget.customer.fullName}
Account #: ${widget.customer.accountNumber}
Phone: ${widget.customer.phoneNumber}
Email: ${widget.customer.email}
Address: ${widget.customer.address.fullAddress}
Balance: ${widget.customer.formattedBalance}
''';

    // Show share dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Customer Info'),
        content: SelectableText(shareText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification(BuildContext context) async {
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Enter notification message...',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Message is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send notification logic
                Navigator.pop(context);
                ToastUtils.showSuccessToast('Notification sent!');
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _suspendAccount(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Suspend Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Please provide a reason for suspending this account:'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _suspendReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'e.g., Non-payment, security concern...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Reason is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_suspendReasonController.text.isEmpty) {
                  ToastUtils.showErrorToast('Please provide a reason');

                  return;
                }

                final success = await ref
                    .read(fieldCustomerProvider.notifier)
                    .updateAccountStatus(
                      widget.customer.id,
                      AccountStatus.suspended,
                      _suspendReasonController.text,
                    );

                if (success) {
                  Navigator.pop(context);
                  _suspendReasonController.clear();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Suspend Account'),
            ),
          ],
        );
      },
    );
  }

  void _reactivateAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate Account'),
        content: const Text(
            'Are you sure you want to reactivate this customer account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(fieldCustomerProvider.notifier)
                  .updateAccountStatus(
                    widget.customer.id,
                    AccountStatus.active,
                    'Account reactivated',
                  );

              if (success) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
            'Are you sure you want to delete this customer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(fieldCustomerProvider.notifier)
                  .deleteFieldCustomer(widget.customer.id);

              if (success) {
                Navigator.pop(context);
                widget.onBack();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
