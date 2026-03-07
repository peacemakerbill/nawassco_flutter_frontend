import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../providers/admin_provider.dart';
import '../../constants/admin_colors.dart';
import '../../widgets/user_management/user_account_status.dart';
import '../../widgets/user_management/user_additional_info.dart';
import '../../widgets/user_management/user_profile_header.dart';
import '../../widgets/user_management/user_quick_actions.dart';

class UserDetailScreen extends ConsumerWidget {
  final String id;
  const UserDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(futureUserProvider(id));

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.transparent,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/admin/users/$id/edit'),
            tooltip: 'Edit User',
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => _buildErrorWidget(context, error.toString(), ref),
        data: (user) => _buildSuccessContent(user, id, ref),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                'Failed to load user details',
                style: TextStyle(
                  color: AdminColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AdminColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(futureUserProvider(id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(Map<String, dynamic> user, String id, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserProfileHeader(user: user, id: id),
          const SizedBox(height: 16),
          UserQuickActions(user: user, id: id, ref: ref),
          const SizedBox(height: 16),
          UserAccountStatus(user: user, id: id, ref: ref),
          const SizedBox(height: 16),
          UserAdditionalInfo(user: user),
          const SizedBox(height: 16), // Extra bottom padding
        ],
      ),
    );
  }
}

// Add this provider for better state management
final futureUserProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) {
  return ref.read(adminProvider).getUser(id);
});