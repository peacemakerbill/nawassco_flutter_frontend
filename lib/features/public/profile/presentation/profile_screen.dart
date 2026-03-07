import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/cloudinary_provider.dart';
import 'widgets/profile_completion_bar.dart';
import 'widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFFE3F2FD),
      end: const Color(0xFF1976D2),
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    ref.invalidate(profileProvider);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (picked == null) return;

    setState(() => _isLoading = true);

    try {
      final cloudinary = ref.read(cloudinaryProvider);
      final imageUrl = await cloudinary.uploadImageDirectly(picked);

      final profile = ref.read(profileProvider);
      await profile.updateProfile({'profilePictureUrl': imageUrl});

      _refreshProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(profileProvider: ref.read(profileProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;
    final isMediumScreen = screenSize.width > 480;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshProfile,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).logout(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(profileProvider).getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoader(isLargeScreen, isMediumScreen);
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return _buildErrorState(snapshot.error, _refreshProfile);
          }

          final user = snapshot.data!;
          final profilePic = user['profilePictureUrl'] as String?;

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
              child: Column(
                children: [
                  _buildHeroSection(user, profilePic, isLargeScreen, isMediumScreen, theme),
                  const SizedBox(height: 24),
                  _buildCompletionCard(user, theme),
                  const SizedBox(height: 20),
                  _buildPersonalInfoCard(user, context, theme),
                  const SizedBox(height: 20),
                  _buildActionCards(context, theme, isLargeScreen),
                  const SizedBox(height: 20),
                  _buildQuickActions(theme, isLargeScreen),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> user, String? profilePic, bool isLargeScreen, bool isMediumScreen, ThemeData theme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: UserAvatar(
                    imageUrl: profilePic,
                    radius: isLargeScreen ? 70 : (isMediumScreen ? 60 : 50),
                    onTap: _isLoading ? null : _updateProfilePicture,
                  ),
                ),
                if (!_isLoading)
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Icon(Icons.edit_rounded, color: Colors.white, size: isLargeScreen ? 20 : 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    '${user['firstName']} ${user['lastName']}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user['username'] != null && user['username'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '@${user['username']}',
                        style: TextStyle(fontSize: isLargeScreen ? 16 : 14, color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_rounded, color: Colors.white.withOpacity(0.8), size: isLargeScreen ? 18 : 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user['email'],
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isLargeScreen ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (user['phoneNumber'] != null && user['phoneNumber'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, color: Colors.white.withOpacity(0.8), size: isLargeScreen ? 16 : 14),
                          const SizedBox(width: 6),
                          Text(
                            user['phoneNumber'],
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isLargeScreen ? 14 : 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(Map<String, dynamic> user, ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Card(
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.cardColor, _colorAnimation.value!.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.analytics_rounded, color: theme.colorScheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Profile Completion',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProfileCompletionBar(percentage: user['profileCompletion'] ?? 0),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(user['profileCompletion'] ?? 0).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if ((user['profileCompletion'] ?? 0) < 100)
                          TextButton(
                            onPressed: () => context.go('/profile-edit'),
                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                            child: const Text('Complete Profile'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(Map<String, dynamic> user, BuildContext context, ThemeData theme) {
    final personalInfo = [
      _buildInfoItem('Location', user['location'], Icons.location_on_rounded, theme),
      _buildInfoItem('Address', user['address'], Icons.home_rounded, theme),
      _buildInfoItem('Gender', user['gender'], Icons.person_rounded, theme),
      if (user['dateOfBirth'] != null) _buildInfoItem('Birth Date', _formatDate(user['dateOfBirth']), Icons.cake_rounded, theme),
      _buildInfoItem('National ID', user['nationalId'], Icons.badge_rounded, theme),
      _buildInfoItem('Account Number', user['accountNumber'], Icons.credit_card_rounded, theme),
      _buildInfoItem('Meter Number', user['meterNumber'], Icons.speed_rounded, theme),
      _buildInfoItem('Service Zone', user['serviceZone'], Icons.place_rounded, theme),
      _buildInfoItem('Customer Type', user['customerType'], Icons.business_rounded, theme),
    ].where((item) => item != null).cast<Widget>().toList();

    if (personalInfo.isEmpty) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 6,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...personalInfo,
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildInfoItem(String label, String? value, IconData icon, ThemeData theme) {
    if (value == null || value.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, ThemeData theme, bool isLargeScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildActionCard(
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            icon: Icons.person_rounded,
            color: theme.colorScheme.primary,
            onTap: () => context.go('/profile-edit'),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            icon: Icons.lock_rounded,
            color: const Color(0xFFF57C00),
            onTap: () => _showChangePasswordDialog(context),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Settings',
            subtitle: 'App preferences and configuration',
            icon: Icons.settings_rounded,
            color: const Color(0xFF388E3C),
            onTap: () => context.go('/settings'),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isLargeScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionButton(icon: Icons.share_rounded, label: 'Share Profile', color: theme.colorScheme.primary, onTap: () => _showComingSoon(context, 'Share Profile'), theme: theme),
              _buildQuickActionButton(icon: Icons.qr_code_rounded, label: 'QR Code', color: const Color(0xFF7B1FA2), onTap: () => _showComingSoon(context, 'QR Code'), theme: theme),
              _buildQuickActionButton(icon: Icons.help_rounded, label: 'Support', color: const Color(0xFFF57C00), onTap: () => context.go('/support'), theme: theme),
              _buildQuickActionButton(icon: Icons.history_rounded, label: 'Activity', color: const Color(0xFF388E3C), onTap: () => context.go('/activity'), theme: theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(bool isLargeScreen, bool isMediumScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
        child: Column(
          children: [
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(error?.toString() ?? 'Unknown error occurred', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature functionality coming soon!'), backgroundColor: Theme.of(context).colorScheme.primary, behavior: SnackBarBehavior.floating),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final ProfileProvider profileProvider;
  const ChangePasswordDialog({super.key, required this.profileProvider});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.profileProvider.changePassword(_oldPasswordCtrl.text.trim(), _newPasswordCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Password changed successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPasswordField(controller: _oldPasswordCtrl, label: 'Current Password', obscureText: _obscureOldPassword, onToggleVisibility: () => setState(() => _obscureOldPassword = !_obscureOldPassword), theme: theme),
              const SizedBox(height: 16),
              _buildPasswordField(controller: _newPasswordCtrl, label: 'New Password', obscureText: _obscureNewPassword, onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword), theme: theme),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm New Password',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) => value != _newPasswordCtrl.text ? 'Passwords do not match' : null,
                theme: theme,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Text('Update'),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required ThemeData theme,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}