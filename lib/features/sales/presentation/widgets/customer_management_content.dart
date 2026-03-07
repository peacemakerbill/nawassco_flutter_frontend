import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nawassco/features/sales/presentation/widgets/sub_widgets/customer/customer_card.dart';

import '../../models/customer.model.dart';
import '../../providers/customer_provider.dart';
import 'sub_widgets/customer/customer_details.dart';
import 'sub_widgets/customer/customer_form.dart';
import 'sub_widgets/customer/customer_search.dart';
import 'sub_widgets/customer/customer_stats_card.dart';

class CustomerManagementContent extends ConsumerStatefulWidget {

  const CustomerManagementContent({super.key});

  @override
  ConsumerState<CustomerManagementContent> createState() =>
      _CustomerManagementContentState();
}

class _CustomerManagementContentState
    extends ConsumerState<CustomerManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_scrollListener);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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
    ref.read(customerProvider.notifier).loadNextPage();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    });
  }

  void _showCustomerForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CustomerForm(
          onSuccess: () {
            Navigator.pop(context);
            ref.read(customerProvider.notifier).refreshData();
          },
        ),
      ),
    );
  }

  void _showCustomerDetails(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CustomerDetails(
          customer: customer,
          onEdit: () {
            Navigator.pop(context);
            _showCustomerEditForm(customer);
          },
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showCustomerEditForm(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CustomerForm(
          initialCustomer: customer,
          onSuccess: () {
            Navigator.pop(context);
            ref.read(customerProvider.notifier).refreshData();
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
          'Are you sure you want to delete this customer? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(customerProvider.notifier)
                  .deleteCustomer(customer.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header with Tabs
          Material(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Customer Management',
                          style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref
                            .read(customerProvider.notifier)
                            .refreshData(),
                        tooltip: 'Refresh',
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showCustomerForm,
                        tooltip: 'Add Customer',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'All Customers'),
                      Tab(text: 'Active'),
                      Tab(text: 'Prospects'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dashboard Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CustomerStatsCard(),
                        const SizedBox(height: 16),
                        const CustomerSearch(),
                        const SizedBox(height: 16),
                        _buildRecentCustomers(context, state),
                      ],
                    ),
                  ),
                ),

                // All Customers Tab
                _buildCustomersList(state, isMobile),

                // Active Customers Tab
                _buildFilteredList(state, CustomerStatus.active, isMobile),

                // Prospects Tab
                _buildFilteredList(state, CustomerStatus.prospect, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(CustomerState state, bool isMobile) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCustomerForm,
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: CustomerSearch(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.read(customerProvider.notifier).refreshData();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: state.customers.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.customers.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox(),
                    ),
                  );
                }

                final customer = state.customers[index];
                final isSelected = state.selectedCustomer?.id == customer.id;

                return CustomerCard(
                  customer: customer,
                  isSelected: isSelected,
                  onTap: () => _showCustomerDetails(customer),
                  onEdit: () => _showCustomerEditForm(customer),
                  onDelete: () => _showDeleteDialog(customer),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredList(
      CustomerState state,
      CustomerStatus status,
      bool isMobile,
      ) {
    final filteredCustomers = state.customers
        .where((customer) => customer.status == status)
        .toList();

    if (state.isLoading && filteredCustomers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == CustomerStatus.active
                  ? Icons.check_circle_outline
                  : Icons.person_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              status == CustomerStatus.active
                  ? 'No active customers'
                  : 'No prospects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              status == CustomerStatus.active
                  ? 'All customers are marked as inactive or prospects'
                  : 'Convert leads to see them here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: CustomerSearch(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              final isSelected = state.selectedCustomer?.id == customer.id;

              return CustomerCard(
                customer: customer,
                isSelected: isSelected,
                onTap: () => _showCustomerDetails(customer),
                onEdit: () => _showCustomerEditForm(customer),
                onDelete: () => _showDeleteDialog(customer),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCustomers(BuildContext context, CustomerState state) {
    final recentCustomers = state.customers.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Customers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentCustomers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customers yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first customer to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showCustomerForm,
                        child: const Text('Add Customer'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentCustomers.map((customer) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCustomerColor(customer.customerType)
                      .withValues(alpha: 0.1),
                  child: Icon(
                    _getCustomerIcon(customer.customerType),
                    color: _getCustomerColor(customer.customerType),
                  ),
                ),
                title: Text(customer.displayName),
                subtitle: Text(customer.customerNumber),
                trailing: Chip(
                  label: Text(customer.status.displayName),
                  backgroundColor:
                  _getStatusColor(customer.status).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getStatusColor(customer.status),
                  ),
                ),
                onTap: () => _showCustomerDetails(customer),
              )),
          ],
        ),
      ),
    );
  }

  Color _getCustomerColor(CustomerType type) {
    return switch (type) {
      CustomerType.residential => const Color(0xFF2196F3),
      CustomerType.commercial => const Color(0xFF4CAF50),
      CustomerType.industrial => const Color(0xFFFF9800),
      CustomerType.institutional => const Color(0xFF9C27B0),
      CustomerType.government => const Color(0xFFF44336),
    };
  }

  IconData _getCustomerIcon(CustomerType type) {
    return switch (type) {
      CustomerType.residential => Icons.home_outlined,
      CustomerType.commercial => Icons.business_outlined,
      CustomerType.industrial => Icons.factory_outlined,
      CustomerType.institutional => Icons.school_outlined,
      CustomerType.government => Icons.account_balance_outlined,
    };
  }

  Color _getStatusColor(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.active => const Color(0xFF4CAF50),
      CustomerStatus.prospect => const Color(0xFF2196F3),
      CustomerStatus.inactive => const Color(0xFF9E9E9E),
      CustomerStatus.suspended => const Color(0xFFFF9800),
      CustomerStatus.blacklisted => const Color(0xFFF44336),
    };
  }
}