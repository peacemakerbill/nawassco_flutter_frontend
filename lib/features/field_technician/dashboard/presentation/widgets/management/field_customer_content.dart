import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/utils/toast_utils.dart';
import '../../../models/field_customer.dart';
import '../../../providers/field_customer_provider.dart';
import '../sub_widgets/field_customer/create_customer_form.dart';
import '../sub_widgets/field_customer/customer_card.dart';
import '../sub_widgets/field_customer/customer_details.dart';
import '../sub_widgets/field_customer/edit_customer_form.dart';

class FieldCustomerContent extends ConsumerStatefulWidget {
  const FieldCustomerContent({super.key});

  @override
  ConsumerState<FieldCustomerContent> createState() => _FieldCustomerContentState();
}

class _FieldCustomerContentState extends ConsumerState<FieldCustomerContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldCustomerProvider);
    final provider = ref.read(fieldCustomerProvider.notifier);

    // Load customers on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.customers.isEmpty && !state.isLoading) {
        provider.getFieldCustomers();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Header with Tabs
            _buildTopHeader(context, ref, state),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  _buildOverviewTab(context, ref, state),

                  // All Customers Tab
                  _buildAllCustomersTab(context, ref, state),

                  // Active Customers Tab
                  _buildFilteredCustomersTab(
                    context,
                    ref,
                    state,
                    'Active Customers',
                        (customer) => customer.accountStatus == AccountStatus.active,
                  ),

                  // Suspended Customers Tab
                  _buildFilteredCustomersTab(
                    context,
                    ref,
                    state,
                    'Suspended Customers',
                        (customer) => customer.accountStatus == AccountStatus.suspended,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, WidgetRef ref, FieldCustomerState state) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Field Customers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (query) {
                      if (query.isEmpty) {
                        ref.read(fieldCustomerProvider.notifier).clearSearch();
                      } else {
                        ref.read(fieldCustomerProvider.notifier).searchFieldCustomers(query);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (state.isLoading)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.read(fieldCustomerProvider.notifier).refreshCustomers(),
                    tooltip: 'Refresh',
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => ref.read(fieldCustomerProvider.notifier).showCreateCustomerForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('New Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'All Customers',
                ),
                Tab(
                  icon: Icon(Icons.check_circle),
                  text: 'Active',
                ),
                Tab(
                  icon: Icon(Icons.pause_circle),
                  text: 'Suspended',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, WidgetRef ref, FieldCustomerState state) {
    final totalBalance = state.customers.fold<double>(0, (sum, c) => sum + c.currentBalance);
    final activeCount = state.customers.where((c) => c.accountStatus == AccountStatus.active).length;
    final suspendedCount = state.customers.where((c) => c.accountStatus == AccountStatus.suspended).length;
    final residentialCount = state.customers.where((c) => c.customerType == CustomerType.residential).length;
    final commercialCount = state.customers.where((c) => c.customerType == CustomerType.commercial).length;

    if (state.showCreateForm) {
      return CreateCustomerForm(
        onCancel: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
      );
    }

    if (state.showEditForm && state.selectedCustomer != null) {
      return EditCustomerForm(
        customer: state.selectedCustomer!,
        onCancel: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
      );
    }

    if (state.showDetails && state.selectedCustomer != null) {
      return CustomerDetailsWidget(
        customer: state.selectedCustomer!,
        onBack: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
        onEdit: () => ref.read(fieldCustomerProvider.notifier).showEditCustomerForm(state.selectedCustomer!),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Customers',
                state.customers.length.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'Active',
                activeCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Suspended',
                suspendedCount.toString(),
                Icons.pause_circle,
                Colors.orange,
              ),
              _buildStatCard(
                'Balance Due',
                'KSh ${totalBalance.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Customer Type Distribution
          const Text(
            'Customer Type Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildCustomerTypeCard(
                'Residential',
                residentialCount,
                state.customers.isEmpty ? 0 : (residentialCount / state.customers.length * 100).toDouble(),
                Colors.blue,
              ),
              _buildCustomerTypeCard(
                'Commercial',
                commercialCount,
                state.customers.isEmpty ? 0 : (commercialCount / state.customers.length * 100).toDouble(),
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4,
            children: [
              _buildQuickActionCard(
                context,
                ref,
                Icons.add,
                'New Customer',
                'Create a new field customer',
                Colors.blue,
                    () => ref.read(fieldCustomerProvider.notifier).showCreateCustomerForm(),
              ),
              _buildQuickActionCard(
                context,
                ref,
                Icons.download,
                'Export Data',
                'Export customer data to CSV',
                Colors.green,
                    () => _exportData(ref),
              ),
              _buildQuickActionCard(
                context,
                ref,
                Icons.filter_alt,
                'Filter Customers',
                'Apply advanced filters',
                Colors.orange,
                    () => _showFilterDialog(context, ref),
              ),
              _buildQuickActionCard(
                context,
                ref,
                Icons.analytics,
                'View Reports',
                'View customer analytics',
                Colors.purple,
                    () => _viewReports(context, ref),
              ),
            ],
          ),

          // Recent Customers Section
          if (state.customers.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                const Text(
                  'Recent Customers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _tabController.index = 1,
                  child: const Row(
                    children: [
                      Text('View All'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildRecentCustomersTable(context, ref, state),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllCustomersTab(BuildContext context, WidgetRef ref, FieldCustomerState state) {
    return _buildCustomersContent(context, ref, state, 'All Customers', null);
  }

  Widget _buildFilteredCustomersTab(
      BuildContext context,
      WidgetRef ref,
      FieldCustomerState state,
      String title,
      bool Function(FieldCustomer) filter,
      ) {
    final filteredCustomers = state.customers.where(filter).toList();
    return _buildCustomersContent(context, ref, state.copyWith(customers: filteredCustomers), title, filter);
  }

  Widget _buildCustomersContent(
      BuildContext context,
      WidgetRef ref,
      FieldCustomerState state,
      String title,
      bool Function(FieldCustomer)? filter,
      ) {
    if (state.showCreateForm) {
      return CreateCustomerForm(
        onCancel: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
      );
    }

    if (state.showEditForm && state.selectedCustomer != null) {
      return EditCustomerForm(
        customer: state.selectedCustomer!,
        onCancel: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
      );
    }

    if (state.showDetails && state.selectedCustomer != null) {
      return CustomerDetailsWidget(
        customer: state.selectedCustomer!,
        onBack: () => ref.read(fieldCustomerProvider.notifier).closeAllForms(),
        onEdit: () => ref.read(fieldCustomerProvider.notifier).showEditCustomerForm(state.selectedCustomer!),
      );
    }

    if (state.customers.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              filter == null ? 'No customers found' : 'No ${title.toLowerCase()} found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(fieldCustomerProvider.notifier).showCreateCustomerForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Create First Customer'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row for this tab
          _buildTabStatsOverview(context, ref, state, title),
          const SizedBox(height: 16),

          // Filter chips (only for All Customers tab)
          if (filter == null) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: state.filters.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(fieldCustomerProvider.notifier).clearFilters();
                      }
                    },
                    backgroundColor: state.filters.isEmpty ? Colors.blue[100] : null,
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: state.filters.isEmpty ? Colors.blue : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...CustomerType.values.map((type) {
                    final isSelected = state.filters['customerType'] == type.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(fieldCustomerProvider.notifier).setFilters({
                            'customerType': selected ? type.name : null,
                          });
                        },
                        backgroundColor: isSelected ? Colors.blue[100] : null,
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                    );
                  }),
                  ...AccountStatus.values.map((status) {
                    final isSelected = state.filters['accountStatus'] == status.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(fieldCustomerProvider.notifier).setFilters({
                            'accountStatus': selected ? status.name : null,
                          });
                        },
                        backgroundColor: isSelected ? Colors.blue[100] : null,
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Customers List/Grid
          Expanded(
            child: MediaQuery.of(context).size.width > 600
                ? _buildDataTableView(state, ref)
                : _buildCustomersList(state, ref),
          ),

          // Load more button
          if (state.hasMore && !state.isLoading) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => ref.read(fieldCustomerProvider.notifier).loadMoreCustomers(),
                child: const Text('Load More'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabStatsOverview(BuildContext context, WidgetRef ref, FieldCustomerState state, String title) {
    final totalBalance = state.customers.fold<double>(0, (sum, c) => sum + c.currentBalance);
    final activeCount = state.customers.where((c) => c.accountStatus == AccountStatus.active).length;
    final suspendedCount = state.customers.where((c) => c.accountStatus == AccountStatus.suspended).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatTile(
            title,
            '${state.customers.length} customers',
            Icons.people,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            'Total Balance Due',
            'KSh ${totalBalance.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.red,
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            'Active',
            '$activeCount',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            'Suspended',
            '$suspendedCount',
            Icons.pause_circle,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(FieldCustomerState state, WidgetRef ref) {
    return ListView.builder(
      itemCount: state.customers.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.customers.length) {
          if (state.hasMore && !state.isLoading) {
            ref.read(fieldCustomerProvider.notifier).loadMoreCustomers();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Container();
        }

        final customer = state.customers[index];
        return CustomerCard(
          customer: customer,
          onTap: () => ref.read(fieldCustomerProvider.notifier).showCustomerDetails(customer),
        );
      },
    );
  }

  Widget _buildDataTableView(FieldCustomerState state, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Customer #',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: state.customers.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.customers.length) {
                  if (state.hasMore && !state.isLoading) {
                    ref.read(fieldCustomerProvider.notifier).loadMoreCustomers();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Container();
                }

                final customer = state.customers[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => ref.read(fieldCustomerProvider.notifier).showCustomerDetails(customer),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              customer.customerNumber,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              customer.fullName,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.phoneNumber,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  customer.email,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              customer.customerType.displayName,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              customer.formattedBalance,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildStatusChip(customer.accountStatus),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, size: 18),
                                  onPressed: () => ref.read(fieldCustomerProvider.notifier).showCustomerDetails(customer),
                                  tooltip: 'View Details',
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => ref.read(fieldCustomerProvider.notifier).showEditCustomerForm(customer),
                                  tooltip: 'Edit',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTypeCard(String type, int count, double percentage, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count customers',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% of total',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context,
      WidgetRef ref,
      IconData icon,
      String title,
      String description,
      Color color,
      VoidCallback onPressed,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCustomersTable(BuildContext context, WidgetRef ref, FieldCustomerState state) {
    final recentCustomers = state.customers.take(5).toList();

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Balance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Rows
        ...recentCustomers.map((customer) {
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: InkWell(
              onTap: () => ref.read(fieldCustomerProvider.notifier).showCustomerDetails(customer),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            customer.customerNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        customer.customerType.displayName,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        customer.formattedBalance,
                        style: TextStyle(
                          color: customer.currentBalance > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildStatusChip(customer.accountStatus),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AccountStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _exportData(WidgetRef ref) {
    ToastUtils.showInfoToast('Export feature coming soon!');
  }

  void _viewReports(BuildContext context, WidgetRef ref) {
    ToastUtils.showInfoToast('Reports feature coming soon!');
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Status',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AccountStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.displayName),
                    selected: ref.read(fieldCustomerProvider).filters['accountStatus'] == status.name,
                    onSelected: (selected) {
                      // Update filters
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Type',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: CustomerType.values.map((type) {
                  return FilterChip(
                    label: Text(type.displayName),
                    selected: ref.read(fieldCustomerProvider).filters['customerType'] == type.name,
                    onSelected: (selected) {
                      // Update filters
                    },
                  );
                }).toList(),
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
              // Apply filters
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}