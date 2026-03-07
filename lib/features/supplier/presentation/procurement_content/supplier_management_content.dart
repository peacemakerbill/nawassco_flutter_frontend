import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import 'sub_widgets/supplier_details_widget.dart';
import 'sub_widgets/supplier_form_widget.dart';
import 'sub_widgets/supplier_list_widget.dart';


class SupplierManagementContent extends ConsumerStatefulWidget {
  const SupplierManagementContent({super.key});

  @override
  ConsumerState<SupplierManagementContent> createState() => _SupplierManagementContentState();
}

class _SupplierManagementContentState extends ConsumerState<SupplierManagementContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load suppliers when component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierProvider.notifier).getAllSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final supplierState = ref.watch(supplierProvider);

    return Column(
      children: [
        // Header with search and filters
        _buildHeader(),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0066A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0066A1),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'All Suppliers'),
              Tab(text: 'Add Supplier'),
              Tab(text: 'Supplier Details'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Suppliers Tab
              SupplierListWidget(
                suppliers: supplierState.suppliers,
                isLoading: supplierState.isLoading,
                error: supplierState.error,
                onRefresh: () => ref.read(supplierProvider.notifier).getAllSuppliers(),
                onEdit: (supplier) {
                  ref.read(supplierProvider.notifier).getSupplierById(supplier.id);
                  _tabController.animateTo(2); // Go to details tab
                },
                onView: (supplier) {
                  ref.read(supplierProvider.notifier).getSupplierById(supplier.id);
                  _tabController.animateTo(2); // Go to details tab
                },
                onApprove: (supplier) => _showApproveDialog(supplier),
                onBlacklist: (supplier) => _showBlacklistDialog(supplier),
              ),

              // Add Supplier Tab
              SupplierFormWidget(
                onSubmit: (data) async {
                  final success = await ref.read(supplierProvider.notifier).createSupplier(data);
                  if (success && mounted) {
                    _tabController.animateTo(0); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supplier created successfully')),
                    );
                  }
                },
              ),

              // Supplier Details Tab
              SupplierDetailsWidget(
                supplier: supplierState.selectedSupplier,
                isLoading: supplierState.isLoading,
                onUpdate: (data) async {
                  if (supplierState.selectedSupplier != null) {
                    final success = await ref.read(supplierProvider.notifier).updateSupplier(
                      supplierState.selectedSupplier!.id,
                      data,
                    );
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Supplier updated successfully')),
                      );
                    }
                  }
                },
                onDelete: () {
                  if (supplierState.selectedSupplier != null) {
                    _showDeleteDialog(supplierState.selectedSupplier!);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.business, color: Color(0xFF0066A1), size: 24),
                SizedBox(width: 12),
                Text(
                  'Supplier Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Manage supplier registrations, approvals, and performance tracking.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search suppliers...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                      ref.read(supplierProvider.notifier).getAllSuppliers(
                        queryParams: {'search': value},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(supplierProvider.notifier).getAllSuppliers();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066A1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Supplier'),
        content: Text('Are you sure you want to approve ${supplier.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierProvider.notifier).approveSupplier(supplier.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${supplier.companyName} approved successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showBlacklistDialog(Supplier supplier) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blacklist Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blacklist ${supplier.companyName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for blacklisting',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.pop(context);
              final success = await ref.read(supplierProvider.notifier).blacklistSupplier(
                supplier.id,
                {'blacklistReason': reasonController.text},
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${supplier.companyName} blacklisted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Blacklist'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete ${supplier.companyName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierProvider.notifier).deleteSupplier(supplier.id);
              if (success && mounted) {
                _tabController.animateTo(0); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${supplier.companyName} deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}