import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/store_manager_admin_provider.dart';
import 'sub_widgets/profile/store_manager_details.dart';
import 'sub_widgets/profile/store_manager_form.dart';
import 'sub_widgets/profile/store_manager_list.dart';

class StoreManagerManagementContent extends ConsumerStatefulWidget {
  const StoreManagerManagementContent({super.key});

  @override
  ConsumerState<StoreManagerManagementContent> createState() => _StoreManagerManagementContentState();
}

class _StoreManagerManagementContentState extends ConsumerState<StoreManagerManagementContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedView = 'list'; // 'list', 'create', 'details', 'edit'

  @override
  void initState() {
    super.initState();
    _loadStoreManagers();
  }

  void _loadStoreManagers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeManagerAdminProvider.notifier).getStoreManagers();
    });
  }

  void _navigateToView(String view, {String? storeManagerId}) {
    setState(() {
      _selectedView = view;
    });

    if (storeManagerId != null && (view == 'details' || view == 'edit')) {
      ref.read(storeManagerAdminProvider.notifier).getStoreManagerById(storeManagerId);
    } else if (view == 'create') {
      ref.read(storeManagerAdminProvider.notifier).clearSelectedStoreManager();
    }
  }

  void _handleSearch(String value) {
    ref.read(storeManagerAdminProvider.notifier).getStoreManagers(
      search: value.isEmpty ? null : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeManagerState = ref.watch(storeManagerAdminProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _selectedView == 'list' ? _buildListAppBar() : _buildDetailAppBar(),
      body: _buildCurrentView(),
      floatingActionButton: _selectedView == 'list' ? _buildFloatingActionButton() : null,
    );
  }

  AppBar _buildListAppBar() {
    return AppBar(
      title: const Text(
        'Store Managers',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E3A8A),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadStoreManagers,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  AppBar _buildDetailAppBar() {
    final storeManagerState = ref.watch(storeManagerAdminProvider);
    final storeManager = storeManagerState.selectedStoreManager;

    return AppBar(
      title: Text(
        _selectedView == 'create'
            ? 'Create Store Manager'
            : _selectedView == 'edit'
            ? 'Edit Store Manager'
            : storeManager != null
            ? '${storeManager.personalDetails.firstName} ${storeManager.personalDetails.lastName}'
            : 'Store Manager Details',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E3A8A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _navigateToView('list'),
      ),
      actions: _buildDetailAppBarActions(),
    );
  }

  List<Widget> _buildDetailAppBarActions() {
    if (_selectedView == 'details') {
      return [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _navigateToView('edit'),
          tooltip: 'Edit',
        ),
        const SizedBox(width: 8),
      ];
    }
    return [];
  }

  Widget _buildCurrentView() {
    switch (_selectedView) {
      case 'create':
        return StoreManagerForm(
          mode: 'create',
          onSave: () => _navigateToView('list'),
          onCancel: () => _navigateToView('list'),
        );
      case 'edit':
        return StoreManagerForm(
          mode: 'edit',
          onSave: () => _navigateToView('details'),
          onCancel: () => _navigateToView('details'),
        );
      case 'details':
        return const StoreManagerDetails();
      default:
        return StoreManagerList(
          searchController: _searchController,
          onSearch: _handleSearch,
          onViewDetails: (id) => _navigateToView('details', storeManagerId: id),
          onEdit: (id) => _navigateToView('edit', storeManagerId: id),
        );
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _navigateToView('create'),
      backgroundColor: const Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}