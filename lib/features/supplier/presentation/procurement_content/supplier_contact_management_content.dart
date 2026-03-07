import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/supplier_contact_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_contact_provider.dart';
import '../../providers/supplier_provider.dart';
import 'sub_widgets/contact_form_widget.dart';
import 'sub_widgets/contact_list_widget.dart';

class SUpplierContactManagementContent extends ConsumerStatefulWidget {
  const SUpplierContactManagementContent({super.key});

  @override
  ConsumerState<SUpplierContactManagementContent> createState() => _SupplierContactManagementContentState();
}

class _SupplierContactManagementContentState extends ConsumerState<SUpplierContactManagementContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data when component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierProvider.notifier).getAllSuppliers();
      ref.read(supplierContactProvider.notifier).getAllContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(supplierContactProvider);
    final supplierState = ref.watch(supplierProvider);

    return Column(
      children: [
        // Header with supplier filter
        _buildHeader(supplierState.suppliers),

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
              Tab(text: 'All Contacts'),
              Tab(text: 'Add Contact'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Contacts Tab
              ContactListWidget(
                contacts: _selectedSupplierId != null
                    ? contactState.contacts.where((c) => c.supplierId == _selectedSupplierId).toList()
                    : contactState.contacts,
                isLoading: contactState.isLoading,
                error: contactState.error,
                onRefresh: () => ref.read(supplierContactProvider.notifier).getAllContacts(),
                onEdit: (contact) {
                  // Switch to add tab with edit mode
                  _tabController.animateTo(1);
                },
                onDelete: (contact) => _showDeleteDialog(contact),
                onSetPrimary: (contact) => _setPrimaryContact(contact),
              ),

              // Add Contact Tab
              ContactFormWidget(
                suppliers: supplierState.suppliers,
                selectedSupplierId: _selectedSupplierId,
                onSubmit: (data) async {
                  final success = await ref.read(supplierContactProvider.notifier).createContact(data);
                  if (success && mounted) {
                    _tabController.animateTo(0); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact created successfully')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Supplier> suppliers) {
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
                Icon(Icons.contacts, color: Color(0xFF0066A1), size: 24),
                SizedBox(width: 12),
                Text(
                  'Contact Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage supplier contacts, communication preferences, and authorization.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedSupplierId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Supplier',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Suppliers')),
                      ...suppliers.map((supplier) => DropdownMenuItem(
                        value: supplier.id,
                        child: Text(supplier.companyName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplierId = value;
                      });
                      if (value != null) {
                        ref.read(supplierContactProvider.notifier).getContactsBySupplier(value);
                      } else {
                        ref.read(supplierContactProvider.notifier).getAllContacts();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(supplierContactProvider.notifier).getAllContacts();
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

  void _showDeleteDialog(SupplierContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.firstName} ${contact.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierContactProvider.notifier).deleteContact(contact.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${contact.firstName} ${contact.lastName} deleted successfully')),
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

  void _setPrimaryContact(SupplierContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Primary Contact'),
        content: Text('Set ${contact.firstName} ${contact.lastName} as primary contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierContactProvider.notifier).setPrimaryContact(contact.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${contact.firstName} ${contact.lastName} set as primary')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Primary'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}