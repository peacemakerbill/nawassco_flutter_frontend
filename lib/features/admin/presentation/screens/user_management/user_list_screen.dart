import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/user_management/user_card.dart';
import '../../widgets/user_management/user_search_filter.dart';
import '../../constants/admin_colors.dart';
import 'user_detail_screen.dart';
import 'user_update_screen.dart';
import 'user_form_screen.dart';

// State provider for managing user list state
final userListStateProvider = StateNotifierProvider<UserListStateNotifier, UserListState>((ref) {
  return UserListStateNotifier(ref);
});

class UserListState {
  final List<dynamic> users;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final Set<String> selectedUsers;
  final String searchQuery;
  final String selectedFilter;

  UserListState({
    this.users = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedUsers = const {},
    this.searchQuery = '',
    this.selectedFilter = 'all',
  });

  UserListState copyWith({
    List<dynamic>? users,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    Set<String>? selectedUsers,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return UserListState(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class UserListStateNotifier extends StateNotifier<UserListState> {
  final Ref ref;

  UserListStateNotifier(this.ref) : super(UserListState());

  Future<void> loadUsers({bool loadMore = false}) async {
    if (!loadMore) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
      );
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final page = loadMore ? state.currentPage + 1 : 1;
      print('Loading users - page: $page, search: "${state.searchQuery}", filter: "${state.selectedFilter}"');

      final users = await ref.read(adminProvider).getUsers(
        page: page,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        filter: state.selectedFilter == 'all' ? null : state.selectedFilter,
      );

      print('Users loaded successfully: ${users.length} users');
      if (users.isNotEmpty) {
        print('First user sample: ${users.first}');
      }

      state = state.copyWith(
        users: loadMore ? [...state.users, ...users] : users,
        currentPage: page,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      print('Error loading users: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      selectedUsers: {},
    );
    loadUsers();
  }

  void setFilter(String filter) {
    state = state.copyWith(
      selectedFilter: filter,
      selectedUsers: {},
    );
    loadUsers();
  }

  void toggleUserSelection(String userId) {
    final newSelection = Set<String>.from(state.selectedUsers);
    if (newSelection.contains(userId)) {
      newSelection.remove(userId);
    } else {
      newSelection.add(userId);
    }
    state = state.copyWith(selectedUsers: newSelection);
  }

  void selectAllUsers() {
    final allUserIds = state.users.map((user) {
      final userId = user['_id'] ?? user['id'];
      return userId.toString();
    }).where((id) => id != null).toSet();

    state = state.copyWith(
      selectedUsers: state.selectedUsers.length == allUserIds.length ? {} : allUserIds,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedUsers: {});
  }

  void removeUser(String userId) {
    final newUsers = state.users.where((user) {
      final id = user['_id'] ?? user['id'];
      return id.toString() != userId;
    }).toList();
    state = state.copyWith(users: newUsers);
  }

  void updateUser(String userId, Map<String, dynamic> updatedData) {
    final newUsers = state.users.map((user) {
      final id = user['_id'] ?? user['id'];
      if (id.toString() == userId) {
        return {...user, ...updatedData};
      }
      return user;
    }).toList();
    state = state.copyWith(users: newUsers);
  }
}

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _bulkActionsScrollController = ScrollController();

  final Map<String, String> _filters = {
    'all': 'All Users',
    'isActive:true': 'Active',
    'isActive:false': 'Inactive',
    'isEmailVerified:true': 'Verified',
    'isEmailVerified:false': 'Unverified',
    'isArchived:true': 'Archived',
    'roles:Admin': 'Admins',
    'roles:SalesAgent': 'Sales Agents',
    'roles:Accounts': 'Accounts',
    'roles:Manager': 'Managers',
    'roles:HR': 'HR',
    'roles:Procurement': 'Procurement',
    'roles:Supplier': 'Suppliers',
    'roles:Technician': 'Technicians',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Initializing UserListScreen...');
      ref.read(userListStateProvider.notifier).loadUsers();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadMoreUsers() async {
    await ref.read(userListStateProvider.notifier).loadUsers(loadMore: true);
  }

  void _handleUserAction(String userId, String action) async {
    print('User Action: $action for user: $userId');

    final admin = ref.read(adminProvider);
    final notifier = ref.read(userListStateProvider.notifier);

    try {
      switch (action) {
        case 'view':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(id: userId),
            ),
          );
          break;
        case 'edit':
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserUpdateScreen(id: userId),
            ),
          );
          // Refresh after update
          if (result == true) {
            notifier.loadUsers();
          }
          break;
        case 'delete':
          _showDeleteDialog(userId, admin, notifier);
          break;
        case 'archive':
          await admin.toggleArchive(userId, true);
          notifier.loadUsers();
          _showSuccess('User archived successfully');
          break;
        case 'unarchive':
          await admin.toggleArchive(userId, false);
          notifier.loadUsers();
          _showSuccess('User unarchived successfully');
          break;
        case 'activate':
          await admin.toggleActive(userId, true);
          notifier.loadUsers();
          _showSuccess('User activated successfully');
          break;
        case 'deactivate':
          await admin.toggleActive(userId, false);
          notifier.loadUsers();
          _showSuccess('User deactivated successfully');
          break;
        case 'verify':
          await admin.verifyEmail(userId);
          notifier.loadUsers();
          _showSuccess('Email verified successfully');
          break;
        case 'unverify':
          await admin.unverifyEmail(userId);
          notifier.loadUsers();
          _showSuccess('Email unverified successfully');
          break;
      }
    } catch (e) {
      _showError('Failed to $action user: $e');
    }
  }

  List<BulkAction> _getAvailableBulkActions(UserListState state) {
    if (state.selectedUsers.isEmpty) return [];

    final selectedUsers = state.users.where((user) {
      final userId = user['_id'] ?? user['id'];
      return state.selectedUsers.contains(userId.toString());
    }).toList();

    if (selectedUsers.isEmpty) return [];

    // Check states for all selected users
    final allActive = selectedUsers.every((user) => user['isActive'] == true);
    final allInactive = selectedUsers.every((user) => user['isActive'] == false);
    final allArchived = selectedUsers.every((user) => user['isArchived'] == true);
    final allUnarchived = selectedUsers.every((user) => user['isArchived'] == false);
    final allVerified = selectedUsers.every((user) => user['isEmailVerified'] == true);
    final allUnverified = selectedUsers.every((user) => user['isEmailVerified'] == false);

    final actions = <BulkAction>[];

    // Active/Inactive actions
    if (allInactive || (!allActive && !allInactive)) {
      actions.add(BulkAction('activate', 'Activate', Icons.play_arrow));
    }
    if (allActive || (!allActive && !allInactive)) {
      actions.add(BulkAction('deactivate', 'Deactivate', Icons.pause));
    }

    // Archive/Unarchive actions
    if (allUnarchived || (!allArchived && !allUnarchived)) {
      actions.add(BulkAction('archive', 'Archive', Icons.archive));
    }
    if (allArchived || (!allArchived && !allUnarchived)) {
      actions.add(BulkAction('unarchive', 'Unarchive', Icons.unarchive));
    }

    // Verify/Unverify actions
    if (allUnverified || (!allVerified && !allUnverified)) {
      actions.add(BulkAction('verify', 'Verify', Icons.verified));
    }
    if (allVerified || (!allVerified && !allUnverified)) {
      actions.add(BulkAction('unverify', 'Unverify', Icons.verified_outlined));
    }

    // Delete action (always available)
    actions.add(BulkAction('delete', 'Delete', Icons.delete));

    return actions;
  }

  void _handleBulkAction(String action) async {
    final state = ref.read(userListStateProvider);
    if (state.selectedUsers.isEmpty) {
      _showError('Please select at least one user');
      return;
    }

    // Confirm destructive actions
    if (action == 'delete') {
      _showBulkDeleteDialog(state.selectedUsers.length);
      return;
    }

    try {
      final admin = ref.read(adminProvider);
      await admin.bulkAction(state.selectedUsers.toList(), action);

      ref.read(userListStateProvider.notifier).clearSelection();
      ref.read(userListStateProvider.notifier).loadUsers();
      _showSuccess('${state.selectedUsers.length} users ${_getActionPastTense(action)} successfully');
    } catch (e) {
      _showError('Failed to perform bulk action: $e');
    }
  }

  String _getActionPastTense(String action) {
    switch (action) {
      case 'activate': return 'activated';
      case 'deactivate': return 'deactivated';
      case 'archive': return 'archived';
      case 'unarchive': return 'unarchived';
      case 'verify': return 'verified';
      case 'unverify': return 'unverified';
      case 'delete': return 'deleted';
      default: return action;
    }
  }

  void _showBulkDeleteDialog(int userCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text('Are you sure you want to delete $userCount users? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final state = ref.read(userListStateProvider);
                final admin = ref.read(adminProvider);

                await admin.bulkAction(state.selectedUsers.toList(), 'delete');

                if (mounted) {
                  Navigator.pop(context);
                  ref.read(userListStateProvider.notifier).clearSelection();
                  ref.read(userListStateProvider.notifier).loadUsers();
                  _showSuccess('$userCount users deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showError('Failed to delete users: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id, AdminProvider admin, UserListStateNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await admin.deleteUser(id);
                if (mounted) {
                  Navigator.pop(context);
                  notifier.removeUser(id);
                  _showSuccess('User deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showError('Failed to delete user: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.error,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListStateProvider);
    final notifier = ref.read(userListStateProvider.notifier);
    final availableBulkActions = _getAvailableBulkActions(state);

    print('Building UserListScreen - isLoading: ${state.isLoading}, error: ${state.error}, users: ${state.users.length}');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Search and Filters
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  border: Border(bottom: BorderSide(color: AdminColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Add Button
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'User Management',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isSmallScreen)
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const UserFormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(
                                  backgroundColor: AdminColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                ),
                                tooltip: 'Add User',
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const UserFormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add User'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Search and Filters
                    UserSearchFilter(
                      searchController: _searchController,
                      selectedFilter: state.selectedFilter,
                      filters: _filters,
                      onFilterChanged: (filter) => notifier.setFilter(filter),
                      onClearSearch: () {
                        _searchController.clear();
                        notifier.setSearchQuery('');
                      },
                      onSearchChanged: () {
                        notifier.setSearchQuery(_searchController.text);
                      },
                    ),
                  ],
                ),
              ),

              // Bulk Actions Bar
              if (state.selectedUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.05),
                    border: Border(bottom: BorderSide(color: AdminColors.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AdminColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${state.selectedUsers.length} selected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: _bulkActionsScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: availableBulkActions.map((action) {
                                  return ActionChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(action.icon, size: 16),
                                        const SizedBox(width: 4),
                                        Text(action.label),
                                      ],
                                    ),
                                    onPressed: () => _handleBulkAction(action.action),
                                    backgroundColor: _getActionColor(action.action),
                                    labelStyle: TextStyle(
                                      color: _getActionTextColor(action.action),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.clear_all, size: 20),
                                onPressed: notifier.clearSelection,
                                tooltip: 'Clear Selection',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Users List (Now scrolls with everything)
              Padding(
                padding: const EdgeInsets.all(16),
                child: state.isLoading && state.users.isEmpty
                    ? const Center(child: LoadingWidget())
                    : state.error != null && state.users.isEmpty
                    ? _buildErrorWidget(state.error!, notifier)
                    : state.users.isEmpty
                    ? _buildEmptyState()
                    : Column(
                  children: [
                    for (final user in state.users)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UserCard(
                          user: user,
                          isSelected: state.selectedUsers.contains(
                            (user['_id'] ?? user['id']).toString(),
                          ),
                          onSelect: () => notifier.toggleUserSelection(
                            (user['_id'] ?? user['id']).toString(),
                          ),
                          onAction: (action) => _handleUserAction(
                            (user['_id'] ?? user['id']).toString(),
                            action,
                          ),
                        ),
                      ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Color _getActionColor(String action) {
    switch (action) {
      case 'delete':
        return AdminColors.error.withOpacity(0.1);
      case 'deactivate':
      case 'archive':
        return AdminColors.warning.withOpacity(0.1);
      case 'activate':
      case 'unarchive':
      case 'verify':
        return AdminColors.success.withOpacity(0.1);
      case 'unverify':
        return AdminColors.info.withOpacity(0.1);
      default:
        return AdminColors.primary.withOpacity(0.1);
    }
  }

  Color _getActionTextColor(String action) {
    switch (action) {
      case 'delete':
        return AdminColors.error;
      case 'deactivate':
      case 'archive':
        return AdminColors.warning;
      case 'activate':
      case 'unarchive':
      case 'verify':
        return AdminColors.success;
      case 'unverify':
        return AdminColors.info;
      default:
        return AdminColors.primary;
    }
  }

  Widget _buildUserList(UserListState state, UserListStateNotifier notifier) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null && state.users.isEmpty) {
      return _buildErrorWidget(state.error!, notifier);
    }

    if (state.users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadUsers(),
      backgroundColor: AdminColors.surface,
      color: AdminColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AdminColors.primary),
              ),
            );
          }

          final user = state.users[index];
          final userId = user['_id'] ?? user['id'];
          final isSelected = state.selectedUsers.contains(userId.toString());

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UserCard(
              user: user,
              isSelected: isSelected,
              onSelect: () => notifier.toggleUserSelection(userId.toString()),
              onAction: (action) => _handleUserAction(userId.toString(), action),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: AdminColors.grey300),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty ? 'No users match your search' : 'No users found',
              style: TextStyle(color: AdminColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(userListStateProvider.notifier).setSearchQuery('');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, UserListStateNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AdminColors.errorGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load users',
              style: TextStyle(
                color: AdminColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.loadUsers(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _bulkActionsScrollController.dispose();
    super.dispose();
  }
}

class BulkAction {
  final String action;
  final String label;
  final IconData icon;

  BulkAction(this.action, this.label, this.icon);
}