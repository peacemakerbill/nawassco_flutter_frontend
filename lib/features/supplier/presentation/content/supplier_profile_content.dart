import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import '../../providers/supplier_profile_provider.dart';
import 'sub_widgets/contacts_management_widget.dart';
import 'sub_widgets/documents_widget.dart';
import 'sub_widgets/evaluation_history_widget.dart';
import 'sub_widgets/profile_edit_widget.dart';
import 'sub_widgets/profile_overview_widget.dart';

class SupplierProfileContent extends ConsumerStatefulWidget {
  const SupplierProfileContent({super.key});

  @override
  ConsumerState<SupplierProfileContent> createState() => _SupplierProfileContentState();
}

class _SupplierProfileContentState extends ConsumerState<SupplierProfileContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSupplierProfile();
  }

  void _loadSupplierProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final email = authState.user?['email'];
      if (email != null) {
        ref.read(supplierProfileProvider.notifier).getSupplierProfileByEmail(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(supplierProfileProvider);
    final authState = ref.read(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(profileState, authState),

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
                Tab(text: 'Overview'),
                Tab(text: 'Edit Profile'),
                Tab(text: 'Contacts'),
                Tab(text: 'Evaluations'),
                Tab(text: 'Documents'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                ProfileOverviewWidget(
                  supplier: profileState.supplier,
                  contacts: profileState.contacts,
                  evaluations: profileState.evaluations,
                  isLoading: profileState.isLoading,
                  error: profileState.error,
                  onRefresh: _loadSupplierProfile,
                ),

                // Edit Profile Tab
                ProfileEditWidget(
                  supplier: profileState.supplier,
                  isUpdating: profileState.isUpdating,
                  onUpdate: (data) async {
                    final success = await ref.read(supplierProfileProvider.notifier).updateSupplierProfile(data);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                      _tabController.animateTo(0);
                    }
                  },
                ),

                // Contacts Tab
                ContactsManagementWidget(
                  supplier: profileState.supplier,
                  contacts: profileState.contacts,
                  isUpdating: profileState.isUpdating,
                  onUpdateContact: (contactId, data) async {
                    final success = await ref.read(supplierProfileProvider.notifier).updateContact(contactId, data);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact updated successfully')),
                      );
                    }
                  },
                  onAddContact: (data) async {
                    final success = await ref.read(supplierProfileProvider.notifier).addContact(data);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact added successfully')),
                      );
                    }
                  },
                  onSetPrimary: (contactId) async {
                    final success = await ref.read(supplierProfileProvider.notifier).setPrimaryContact(contactId);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Primary contact updated')),
                      );
                    }
                  },
                  onDeleteContact: (contactId) async {
                    final success = await ref.read(supplierProfileProvider.notifier).deleteContact(contactId);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact deleted successfully')),
                      );
                    }
                  },
                ),

                // Evaluations Tab
                EvaluationHistoryWidget(
                  evaluations: profileState.evaluations,
                  isLoading: profileState.isLoading,
                ),

                // Documents Tab
                DocumentsWidget(
                  supplier: profileState.supplier,
                  onUpload: () {
                    // Handle document upload
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(SupplierProfileState profileState, AuthState authState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0066A1),
            const Color(0xFF004d80),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      profileState.supplier?.companyName.substring(0, 2).toUpperCase() ?? 'SP',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066A1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileState.supplier?.companyName ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (profileState.supplier?.tradingName != null)
                          Text(
                            profileState.supplier!.tradingName!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          profileState.supplier?.supplierNumber ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(profileState.supplier?.status ?? 'pending'),
                ],
              ),
              const SizedBox(height: 16),
              if (profileState.supplier != null) ...[
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.email, profileState.supplier!.contactDetails['primaryEmail']),
                    _buildInfoChip(Icons.phone, profileState.supplier!.contactDetails['primaryPhone']),
                    _buildInfoChip(Icons.work, _formatEnum(profileState.supplier!.supplierTier)),
                    _buildInfoChip(Icons.assessment, 'Score: ${profileState.supplier!.performanceMetrics['overallScore']?.toStringAsFixed(1) ?? 'N/A'}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'approved': Colors.green,
      'pending': Colors.orange,
      'draft': Colors.grey,
      'blacklisted': Colors.red,
    };

    final color = statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      backgroundColor: Colors.white.withOpacity(0.2),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatEnum(String value) {
    return value.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}