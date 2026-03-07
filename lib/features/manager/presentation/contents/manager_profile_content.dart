import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/manager_model.dart';
import '../../providers/manager_profile_provider.dart';
import 'sub_widgets/manager_profile/manager_details.dart';
import 'sub_widgets/manager_profile/manager_form.dart';

class ManagerProfileContent extends ConsumerStatefulWidget {
  const ManagerProfileContent({super.key});

  @override
  ConsumerState<ManagerProfileContent> createState() =>
      _ManagerProfileContentState();
}

class _ManagerProfileContentState extends ConsumerState<ManagerProfileContent> {
  ViewMode _viewMode = ViewMode.profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    ref.read(managerProfileProvider.notifier).loadMyManagerProfile();
  }

  void _showCreateForm() {
    setState(() {
      _viewMode = ViewMode.create;
    });
  }

  void _showEditForm() {
    setState(() {
      _viewMode = ViewMode.edit;
    });
  }

  void _backToProfile() {
    setState(() {
      _viewMode = ViewMode.profile;
    });
  }

  Future<void> _handleCreateProfile(Map<String, dynamic> data) async {
    final success = await ref
        .read(managerProfileProvider.notifier)
        .createManagerProfile(data);
    if (success) {
      _backToProfile();
    }
  }

  Future<void> _handleUpdateProfile(Map<String, dynamic> data) async {
    final manager = ref.read(managerProfileProvider).manager;
    if (manager != null) {
      final success =
          await ref.read(managerProfileProvider.notifier).updateMyProfile(data);
      if (success) {
        _backToProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerProfileProvider);
    final manager = state.manager;

    return Scaffold(
      body: _buildContent(state, manager),
    );
  }

  Widget _buildContent(ManagerProfileState state, ManagerModel? manager) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_viewMode) {
      case ViewMode.create:
        return ManagerForm(
          onSubmit: _handleCreateProfile,
          onCancel: () {
            if (state.hasProfile) {
              _backToProfile();
            } else {
              // Go back to empty state
              setState(() {
                _viewMode = ViewMode.profile;
              });
            }
          },
        );
      case ViewMode.edit:
        return manager == null
            ? _buildProfileEmpty()
            : ManagerForm(
                manager: manager,
                isEditing: true,
                onSubmit: _handleUpdateProfile,
                onCancel: _backToProfile,
              );
      default:
        if (!state.hasProfile || manager == null) {
          return _buildProfileEmpty();
        }
        return ManagerDetails(
          manager: manager,
          onEdit: _showEditForm,
          onBack: null,
        );
    }
  }

  Widget _buildProfileEmpty() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 60,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manager Profile Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t created your manager profile yet. '
              'Please create one to access manager features and settings.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                _buildFeatureItem(
                  icon: Icons.work_rounded,
                  title: 'Job Information',
                  description: 'Set your job title, department, and role',
                ),
                _buildFeatureItem(
                  icon: Icons.attach_money_rounded,
                  title: 'Compensation Details',
                  description: 'Enter your salary and benefits information',
                ),
                _buildFeatureItem(
                  icon: Icons.gavel_rounded,
                  title: 'Authority Settings',
                  description:
                      'Configure approval limits and signing authority',
                ),
                _buildFeatureItem(
                  icon: Icons.group_rounded,
                  title: 'Team Management',
                  description: 'Manage your direct reports and teams',
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showCreateForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Manager Profile',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

enum ViewMode {
  profile,
  create,
  edit,
}
