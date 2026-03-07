import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/admin_provider.dart';
import '../../constants/admin_colors.dart';

class UserAccountStatus extends ConsumerWidget {
  final Map<String, dynamic> user;
  final String id;
  final WidgetRef ref;

  const UserAccountStatus({
    super.key,
    required this.user,
    required this.id,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildStatusSwitches(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.settings, color: AdminColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Account Status',
          style: TextStyle(
            color: AdminColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitches(BuildContext context) {
    return Column(
      children: [
        _StatusSwitch(
          title: 'Active Account',
          value: user['isActive'] ?? false,
          onChanged: (v) => _handleActiveStatusChange(context, v),
          activeColor: AdminColors.success,
        ),
        _StatusSwitch(
          title: 'Archived Account',
          value: user['isArchived'] ?? false,
          onChanged: (v) => _handleArchiveStatusChange(context, v),
          activeColor: AdminColors.primary,
        ),
        _StatusSwitch(
          title: 'Email Verified',
          value: user['isEmailVerified'] ?? false,
          onChanged: (v) => _handleEmailVerificationChange(context, v),
          activeColor: AdminColors.info,
        ),
      ],
    );
  }

  Future<void> _handleActiveStatusChange(BuildContext context, bool value) async {
    try {
      await ref.read(adminProvider).toggleActive(id, value);
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, value ? 'User activated' : 'User deactivated');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update status: $e');
    }
  }

  Future<void> _handleArchiveStatusChange(BuildContext context, bool value) async {
    try {
      await ref.read(adminProvider).toggleArchive(id, value);
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, value ? 'User archived' : 'User unarchived');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update archive status: $e');
    }
  }

  Future<void> _handleEmailVerificationChange(BuildContext context, bool value) async {
    try {
      if (value) {
        await ref.read(adminProvider).verifyEmail(id);
      } else {
        await ref.read(adminProvider).unverifyEmail(id);
      }
      ref.invalidate(adminProvider);
      _showSuccessSnackbar(context, value ? 'Email verified' : 'Email unverified');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to update verification: $e');
    }
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

class _StatusSwitch extends StatefulWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color activeColor;

  const _StatusSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<_StatusSwitch> createState() => _StatusSwitchState();
}

class _StatusSwitchState extends State<_StatusSwitch> {
  late bool _currentValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentValue ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: _currentValue ? widget.activeColor : AdminColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.activeColor,
                ),
              ),
            )
          else
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _currentValue,
                onChanged: (value) async {
                  setState(() {
                    _currentValue = value;
                    _isLoading = true;
                  });

                  try {
                    await widget.onChanged(value);
                  } catch (e) {
                    setState(() {
                      _currentValue = !value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: $e'),
                        backgroundColor: AdminColors.error,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                activeColor: widget.activeColor,
                activeTrackColor: widget.activeColor.withOpacity(0.3),
                inactiveThumbColor: AdminColors.grey400,
                inactiveTrackColor: AdminColors.grey200,
              ),
            ),
        ],
      ),
    );
  }
}