import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/store_manager_model.dart';
import '../../providers/store_manager_provider.dart';
import 'sub_widgets/profile/development_section.dart';
import 'sub_widgets/profile/employment_details_section.dart';
import 'sub_widgets/profile/inventory_authority_section.dart';
import 'sub_widgets/profile/objectives_section.dart';
import 'sub_widgets/profile/performance_section.dart';
import 'sub_widgets/profile/personal_info_section.dart';
import 'sub_widgets/profile/team_management_section.dart';


class StoreManagerProfileContent extends ConsumerStatefulWidget {
  const StoreManagerProfileContent({super.key});

  @override
  ConsumerState<StoreManagerProfileContent> createState() => _StoreManagerProfileContentState();
}

class _StoreManagerProfileContentState extends ConsumerState<StoreManagerProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadProfileData();
  }

  void _loadProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeManagerProvider.notifier).getStoreManagerProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeManagerState = ref.watch(storeManagerProvider);
    final storeManager = storeManagerState.storeManager;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Store Manager Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/store-manager'),
        ),
        actions: [
          if (storeManagerState.isUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProfileData,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: storeManagerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : storeManagerState.error != null
          ? _buildErrorState(storeManagerState.error!)
          : storeManager == null
          ? _buildEmptyState()
          : _buildProfileContent(storeManager),
    );
  }

  Widget _buildProfileContent(StoreManager storeManager) {
    return Column(
      children: [
        // Profile Header
        _buildProfileHeader(storeManager),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF1E3A8A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1E3A8A),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Personal Info'),
              Tab(text: 'Employment'),
              Tab(text: 'Inventory Authority'),
              Tab(text: 'Performance'),
              Tab(text: 'Objectives'),
              Tab(text: 'Team'),
              Tab(text: 'Development'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PersonalInfoSection(storeManager: storeManager),
              EmploymentDetailsSection(storeManager: storeManager),
              InventoryAuthoritySection(storeManager: storeManager),
              PerformanceSection(storeManager: storeManager),
              ObjectivesSection(storeManager: storeManager),
              TeamManagementSection(storeManager: storeManager),
              DevelopmentSection(storeManager: storeManager),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(StoreManager storeManager) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${storeManager.personalDetails.firstName} ${storeManager.personalDetails.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${storeManager.jobInformation.jobTitle} • ${storeManager.storeManagerRole.name.replaceAll('_', ' ')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildHeaderChip('Employee #: ${storeManager.employeeNumber}'),
                    _buildHeaderChip('Department: ${storeManager.department}'),
                    _buildHeaderChip('Level: ${storeManager.managementLevel.name.replaceAll('_', ' ')}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfileData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Profile Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Store manager profile not found or not set up',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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