import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/accountant.model.dart';
import '../../providers/accountant_providers.dart';
import 'sub_widgets/accountant/accountant_details_dialog.dart';
import 'sub_widgets/accountant/accountant_form_dialog.dart';
import 'sub_widgets/accountant/document_viewer_dialog.dart';

class AccountantsManagementContent extends ConsumerStatefulWidget {
  const AccountantsManagementContent({super.key});

  @override
  ConsumerState<AccountantsManagementContent> createState() =>
      _AccountantsManagementContentState();
}

class _AccountantsManagementContentState
    extends ConsumerState<AccountantsManagementContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  AccountantFilters _tempFilters = AccountantFilters();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final filters =
        ref.read(accountantsManagementProvider.notifier).filters.copyWith(
              search: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
            );
    ref.read(accountantsManagementProvider.notifier).setFilters(filters);
  }

  void _applyFilters() {
    ref.read(accountantsManagementProvider.notifier).setFilters(_tempFilters);
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    _tempFilters = AccountantFilters();
    _searchController.clear();
    ref.read(accountantsManagementProvider.notifier).clearFilters();
    setState(() => _showFilters = false);
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    ref.read(accountantsManagementProvider.notifier).refresh();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  void _showAccountantForm({Accountant? accountant}) {
    showDialog(
      context: context,
      builder: (context) => AccountantFormDialog(accountant: accountant),
    );
  }

  void _showAccountantDetails(Accountant accountant) {
    showDialog(
      context: context,
      builder: (context) => AccountantDetailsDialog(accountant: accountant),
    );
  }

  void _viewDocument(String documentUrl) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(documentUrl: documentUrl),
    );
  }

  void _deleteAccountant(Accountant accountant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Accountant'),
        content: Text(
            'Are you sure you want to delete ${accountant.fullName}? This will deactivate their account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(accountantsManagementProvider.notifier)
                    .deleteAccountant(accountant.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${accountant.fullName} deactivated successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to deactivate accountant: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child:
                const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _restoreAccountant(Accountant accountant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Accountant'),
        content: Text(
            'Are you sure you want to restore ${accountant.fullName}? This will activate their account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(accountantsManagementProvider.notifier)
                    .restoreAccountant(accountant.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${accountant.fullName} activated successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to activate accountant: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child:
                const Text('Activate', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountantsAsync = ref.watch(accountantsManagementProvider);
    final management = ref.read(accountantsManagementProvider.notifier);
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Column(
      children: [
        // Header with Search and Actions
        _buildHeader(theme, management, isLargeScreen),

        // Filters Panel
        if (_showFilters) _buildFiltersPanel(theme),

        // Statistics Cards
        if (accountantsAsync.hasValue && accountantsAsync.value!.isNotEmpty)
          _buildStatisticsCards(accountantsAsync.value!, theme),

        // Content
        Expanded(
          child: accountantsAsync.when(
            data: (accountants) => _buildAccountantsList(
                accountants, theme, management, isLargeScreen),
            loading: () => _buildShimmerLoader(),
            error: (error, stack) =>
                _buildErrorState(error.toString(), _refreshData),
          ),
        ),

        // Pagination
        if (accountantsAsync.hasValue && accountantsAsync.value!.isNotEmpty)
          _buildPagination(management, theme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AccountantsManagementProvider management,
      bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Title
              Icon(Icons.people_alt_rounded,
                  color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Accountants Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),

              // Actions
              if (isLargeScreen) ...[
                // Search Field (only on large screens)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.search_rounded,
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search accountants...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Filter Button
              IconButton(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: _showFilters
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                tooltip: 'Filters',
              ),

              // Add Button
              IconButton(
                onPressed: () => _showAccountantForm(),
                icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
                tooltip: 'Add Accountant',
              ),

              // Refresh Button
              IconButton(
                onPressed: _isRefreshing ? null : _refreshData,
                icon: _isRefreshing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(Icons.refresh_rounded,
                        color: theme.colorScheme.primary),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Search Field for mobile
          if (!isLargeScreen) ...[
            const SizedBox(height: 12),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search accountants...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Filters',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Job Title Filter
              _buildFilterDropdown(
                label: 'Job Title',
                value: _tempFilters.jobTitle,
                items: [
                  'Chief Accountant',
                  'Senior Accountant',
                  'Accountant',
                  'Junior Accountant',
                  'Accounting Clerk'
                ],
                onChanged: (value) => setState(() =>
                    _tempFilters = _tempFilters.copyWith(jobTitle: value)),
                theme: theme,
              ),

              // Department Filter
              _buildFilterDropdown(
                label: 'Department',
                value: _tempFilters.department,
                items: [
                  'Finance',
                  'Accounting',
                  'Management',
                  'HR',
                  'Operations'
                ],
                onChanged: (value) => setState(() =>
                    _tempFilters = _tempFilters.copyWith(department: value)),
                theme: theme,
              ),

              // Employment Status Filter
              _buildFilterDropdown(
                label: 'Status',
                value: _tempFilters.employmentStatus,
                items: ['ACTIVE', 'TERMINATED', 'SUSPENDED', 'ON_LEAVE'],
                onChanged: (value) => setState(() => _tempFilters =
                    _tempFilters.copyWith(employmentStatus: value)),
                theme: theme,
              ),

              // Active Status Filter
              _buildFilterDropdown(
                label: 'Active',
                value: _tempFilters.isActive?.toString(),
                items: ['true', 'false'],
                onChanged: (value) => setState(() => _tempFilters =
                    _tempFilters.copyWith(isActive: value == 'true')),
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(List<Accountant> accountants, ThemeData theme) {
    final activeCount = accountants.where((a) => a.isActive).length;
    final inactiveCount = accountants.length - activeCount;
    final departments =
        accountants.map((a) => a.department).whereType<String>().toSet();
    final avgServiceYears =
        accountants.fold(0.0, (sum, a) => sum + a.yearsOfService) /
            accountants.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatCard(
            title: 'Total Accountants',
            value: accountants.length.toString(),
            icon: Icons.people_rounded,
            color: Colors.blue,
            theme: theme,
          ),
          _buildStatCard(
            title: 'Active',
            value: activeCount.toString(),
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            theme: theme,
          ),
          _buildStatCard(
            title: 'Inactive',
            value: inactiveCount.toString(),
            icon: Icons.cancel_rounded,
            color: Colors.orange,
            theme: theme,
          ),
          _buildStatCard(
            title: 'Departments',
            value: departments.length.toString(),
            icon: Icons.business_rounded,
            color: Colors.purple,
            theme: theme,
          ),
          _buildStatCard(
            title: 'Avg Service',
            value: '${avgServiceYears.toStringAsFixed(1)} yrs',
            icon: Icons.timeline_rounded,
            color: Colors.teal,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountantsList(List<Accountant> accountants, ThemeData theme,
      AccountantsManagementProvider management, bool isLargeScreen) {
    if (accountants.isEmpty) {
      return _buildEmptyState(theme, management);
    }

    return isLargeScreen
        ? _buildDesktopGridView(accountants, theme, management)
        : _buildMobileListView(accountants, theme, management);
  }

  Widget _buildDesktopGridView(List<Accountant> accountants, ThemeData theme,
      AccountantsManagementProvider management) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: accountants.length,
      itemBuilder: (context, index) {
        final accountant = accountants[index];
        return _buildDesktopAccountantCard(accountant, theme, management);
      },
    );
  }

  Widget _buildMobileListView(List<Accountant> accountants, ThemeData theme,
      AccountantsManagementProvider management) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accountants.length,
      itemBuilder: (context, index) {
        final accountant = accountants[index];
        return _buildMobileAccountantCard(accountant, theme, management);
      },
    );
  }

  Widget _buildDesktopAccountantCard(Accountant accountant, ThemeData theme,
      AccountantsManagementProvider management) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showAccountantDetails(accountant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar and Basic Info
              CircleAvatar(
                radius: 30,
                backgroundImage: accountant.profilePictureUrl != null
                    ? NetworkImage(accountant.profilePictureUrl!)
                    : null,
                child: accountant.profilePictureUrl == null
                    ? Icon(Icons.person_rounded,
                        size: 24, color: theme.colorScheme.onSurface)
                    : null,
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountant.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountant.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (accountant.jobTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        accountant.jobTitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (accountant.department != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        accountant.department!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accountant.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accountant.isActive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      accountant.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: accountant.isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showAccountantDetails(accountant),
                        icon: Icon(Icons.visibility_rounded, size: 18),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        onPressed: () =>
                            _showAccountantForm(accountant: accountant),
                        icon: Icon(Icons.edit_rounded, size: 18),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: accountant.isActive
                            ? () => _deleteAccountant(accountant)
                            : () => _restoreAccountant(accountant),
                        icon: Icon(
                          accountant.isActive
                              ? Icons.person_remove_rounded
                              : Icons.person_add_rounded,
                          size: 18,
                          color: accountant.isActive
                              ? Colors.orange
                              : Colors.green,
                        ),
                        tooltip:
                            accountant.isActive ? 'Deactivate' : 'Activate',
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

  Widget _buildMobileAccountantCard(Accountant accountant, ThemeData theme,
      AccountantsManagementProvider management) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAccountantDetails(accountant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: accountant.profilePictureUrl != null
                        ? NetworkImage(accountant.profilePictureUrl!)
                        : null,
                    child: accountant.profilePictureUrl == null
                        ? Icon(Icons.person_rounded,
                            color: theme.colorScheme.onSurface)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountant.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          accountant.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accountant.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accountant.isActive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      accountant.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: accountant.isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details
              if (accountant.jobTitle != null ||
                  accountant.department != null) ...[
                Row(
                  children: [
                    if (accountant.jobTitle != null) ...[
                      Icon(Icons.work_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        accountant.jobTitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (accountant.department != null)
                        const SizedBox(width: 12),
                    ],
                    if (accountant.department != null) ...[
                      Icon(Icons.business_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        accountant.department!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showAccountantDetails(accountant),
                      icon: Icon(Icons.visibility_rounded, size: 16),
                      label: const Text('Details'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () =>
                          _showAccountantForm(accountant: accountant),
                      icon: Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: accountant.isActive
                          ? () => _deleteAccountant(accountant)
                          : () => _restoreAccountant(accountant),
                      icon: Icon(
                        accountant.isActive
                            ? Icons.person_remove_rounded
                            : Icons.person_add_rounded,
                        size: 16,
                      ),
                      label:
                          Text(accountant.isActive ? 'Deactivate' : 'Activate'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            accountant.isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(
      AccountantsManagementProvider management, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed:
                management.hasPreviousPage ? management.previousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),

          // Page Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              'Page ${management.currentPage} of ${management.totalPages}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Next Button
          IconButton(
            onPressed: management.hasNextPage ? management.nextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All $label',
                        style: TextStyle(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  ),
                  ...items.map((item) =>
                      DropdownMenuItem(value: item, child: Text(item))),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, AccountantsManagementProvider management) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              management.filters.hasFilters
                  ? 'No accountants found'
                  : 'No accountants yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              management.filters.hasFilters
                  ? 'Try adjusting your filters to see more results'
                  : 'Add your first accountant to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            if (management.filters.hasFilters)
              ElevatedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _showAccountantForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add First Accountant'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 16,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8)),
                      Container(
                          height: 12,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 4)),
                      Container(height: 12, color: Colors.white, width: 100),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load accountants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
