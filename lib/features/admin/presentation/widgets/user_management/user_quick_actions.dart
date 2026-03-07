import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/admin_provider.dart';
import '../../constants/admin_colors.dart';

class UserQuickActions extends ConsumerWidget {
  final Map<String, dynamic> user;
  final String id;
  final WidgetRef ref;

  const UserQuickActions({
    super.key,
    required this.user,
    required this.id,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = user['isActive'] ?? false;
    final isEmailVerified = user['isEmailVerified'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.cardShadow,
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildActionButtons(context, isActive, isEmailVerified),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.bolt, color: AdminColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Quick Actions',
          style: TextStyle(
            color: AdminColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isActive, bool isEmailVerified) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ActionButton(
          icon: Icons.verified_user,
          label: isEmailVerified ? 'Unverify' : 'Verify',
          color: isEmailVerified ? AdminColors.warning : AdminColors.success,
          onTap: () => _handleEmailVerification(context, isEmailVerified),
        ),
        _ActionButton(
          icon: isActive ? Icons.toggle_off : Icons.toggle_on,
          label: isActive ? 'Deactivate' : 'Activate',
          color: isActive ? AdminColors.error : AdminColors.success,
          onTap: () => _handleActivation(context, isActive),
        ),
        _ActionButton(
          icon: Icons.archive,
          label: user['isArchived'] ?? false ? 'Unarchive' : 'Archive',
          color: user['isArchived'] ?? false ? AdminColors.info : AdminColors.warning,
          onTap: () => _handleArchive(context),
        ),
        _ActionButton(
          icon: Icons.email,
          label: 'Send Email',
          color: AdminColors.info,
          onTap: () => _handleSendEmail(context),
        ),
      ],
    );
  }

  Future<void> _handleEmailVerification(BuildContext context, bool isEmailVerified) async {
    try {
      if (isEmailVerified) {
        await ref.read(adminProvider).unverifyEmail(id);
      } else {
        await ref.read(adminProvider).verifyEmail(id);
      }
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, isEmailVerified ? 'Email unverified' : 'Email verified');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update verification: $e');
    }
  }

  Future<void> _handleActivation(BuildContext context, bool isActive) async {
    try {
      await ref.read(adminProvider).toggleActive(id, !isActive);
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, isActive ? 'User deactivated' : 'User activated');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update status: $e');
    }
  }

  Future<void> _handleArchive(BuildContext context) async {
    try {
      final shouldArchive = !(user['isArchived'] ?? false);
      await ref.read(adminProvider).toggleArchive(id, shouldArchive);
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, shouldArchive ? 'User archived' : 'User unarchived');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update archive status: $e');
    }
  }

  void _handleSendEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Send email functionality coming soon'),
        backgroundColor: AdminColors.info,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.success,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.error,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}