import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/store_settings_model.dart';
import '../../providers/store_settings_provider.dart';
import 'sub_widgets/settings/setting_category_card.dart';
import 'sub_widgets/settings/setting_dropdown_card.dart';
import 'sub_widgets/settings/setting_number_card.dart';
import 'sub_widgets/settings/setting_toggle_card.dart';

class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFFE3F2FD),
      end: const Color(0xFF1976D2),
    ).animate(_animationController);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await ref.read(storeSettingsProvider.notifier).getStoreSettings();
      await ref.read(storeSettingsProvider.notifier).getSystemStatistics();
      _animationController.forward();
    } catch (e) {
      // Error handled by provider
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    ref.invalidate(storeSettingsProvider);
    await _loadInitialData();
    setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeSettingsProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Store Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
          if (state.settings != null)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: _showResetConfirmation,
              tooltip: 'Reset to Defaults',
            ),
        ],
      ),
      body: state.isLoading && state.settings == null
          ? _buildShimmerLoader(isLargeScreen)
          : state.error != null && state.settings == null
          ? _buildErrorState(state.error!, _refreshData)
          : _buildSettingsContent(state, theme, isLargeScreen),
    );
  }

  Widget _buildSettingsContent(StoreSettingsState state, ThemeData theme, bool isLargeScreen) {
    final settings = state.settings!;
    final statistics = state.systemStatistics;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
        child: Column(
          children: [
            _buildHeroSection(settings, statistics, theme, isLargeScreen),
            const SizedBox(height: 24),
            _buildBasicSettings(settings, theme),
            const SizedBox(height: 20),
            _buildInventorySettings(settings, theme),
            const SizedBox(height: 20),
            _buildWarehouseSettings(settings, theme),
            const SizedBox(height: 20),
            _buildSecuritySettings(settings, theme),
            const SizedBox(height: 20),
            _buildSystemSettings(settings, theme),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(StoreSettings settings, Map<String, dynamic>? statistics, ThemeData theme, bool isLargeScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
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
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.companyName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Store Configuration & Preferences',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (statistics != null) _buildStatisticsGrid(statistics, theme),
            const SizedBox(height: 16),
            Text(
              'Last Updated: ${_formatDate(settings.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> statistics, ThemeData theme) {
    final features = statistics['features'] ?? {};
    final thresholds = statistics['thresholds'] ?? {};

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatItem('Batch Tracking', features['batchTracking'] ?? false, theme),
        _buildStatItem('Serial Tracking', features['serialTracking'] ?? false, theme),
        _buildStatItem('Low Stock Alert', '${thresholds['lowStock'] ?? 0} units', theme),
        _buildStatItem('Max Variance', '${thresholds['maxVariance'] ?? 0}%', theme),
      ],
    );
  }

  Widget _buildStatItem(String label, dynamic value, ThemeData theme) {
    final isBool = value is bool;
    final isActive = isBool ? value : true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isBool ? (value ? Icons.check_circle_rounded : Icons.remove_circle_rounded) : Icons.info_rounded,
            color: isBool ? (value ? Colors.green : Colors.orange) : Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBool ? (value ? 'Enabled' : 'Disabled') : value.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSettings(StoreSettings settings, ThemeData theme) {
    return SettingCategoryCard(
      title: 'Basic Settings',
      icon: Icons.business_rounded,
      theme: theme,
      child: Column(
        children: [
          SettingDropdownCard(
            title: 'Company Name',
            value: settings.companyName,
            onChanged: (value) => _updateSetting('companyName', value),
            theme: theme,
            isText: true,
          ),
          SettingDropdownCard(
            title: 'Currency',
            value: settings.currency,
            options: const ['KES', 'USD', 'EUR', 'GBP'],
            onChanged: (value) => _updateSetting('currency', value),
            theme: theme,
          ),
          SettingDropdownCard(
            title: 'Timezone',
            value: settings.timezone,
            options: const ['Africa/Nairobi', 'UTC', 'America/New_York', 'Europe/London'],
            onChanged: (value) => _updateSetting('timezone', value),
            theme: theme,
          ),
          SettingDropdownCard(
            title: 'Date Format',
            value: settings.dateFormat,
            options: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
            onChanged: (value) => _updateSetting('dateFormat', value),
            theme: theme,
          ),
          SettingDropdownCard(
            title: 'Language',
            value: settings.language,
            options: const ['en', 'sw', 'fr', 'es'],
            onChanged: (value) => _updateSetting('language', value),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySettings(StoreSettings settings, ThemeData theme) {
    return SettingCategoryCard(
      title: 'Inventory Management',
      icon: Icons.inventory_2_rounded,
      theme: theme,
      child: Column(
        children: [
          SettingToggleCard(
            title: 'Batch Tracking',
            value: settings.inventory.enableBatchTracking,
            onChanged: (value) => _updateSetting('inventory.enableBatchTracking', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Serial Number Tracking',
            value: settings.inventory.enableSerialNumberTracking,
            onChanged: (value) => _updateSetting('inventory.enableSerialNumberTracking', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Expiry Management',
            value: settings.inventory.enableExpiryManagement,
            onChanged: (value) => _updateSetting('inventory.enableExpiryManagement', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Auto Reorder',
            value: settings.inventory.autoReorder,
            onChanged: (value) => _updateSetting('inventory.autoReorder', value),
            theme: theme,
          ),
          SettingNumberCard(
            title: 'Low Stock Threshold',
            value: settings.inventory.lowStockThreshold.toDouble(),
            onChanged: (value) => _updateSetting('inventory.lowStockThreshold', value.toInt()),
            theme: theme,
            suffix: 'units',
          ),
          SettingNumberCard(
            title: 'Critical Stock Threshold',
            value: settings.inventory.criticalStockThreshold.toDouble(),
            onChanged: (value) => _updateSetting('inventory.criticalStockThreshold', value.toInt()),
            theme: theme,
            suffix: 'units',
          ),
          SettingNumberCard(
            title: 'Reorder Point',
            value: settings.inventory.reorderPoint.toDouble(),
            onChanged: (value) => _updateSetting('inventory.reorderPoint', value.toInt()),
            theme: theme,
            suffix: 'units',
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSettings(StoreSettings settings, ThemeData theme) {
    return SettingCategoryCard(
      title: 'Warehouse & Stock',
      icon: Icons.warehouse_rounded,
      theme: theme,
      child: Column(
        children: [
          SettingToggleCard(
            title: 'Zone Management',
            value: settings.warehouse.enableZoneManagement,
            onChanged: (value) => _updateSetting('warehouse.enableZoneManagement', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Bin Locations',
            value: settings.warehouse.enableBinLocations,
            onChanged: (value) => _updateSetting('warehouse.enableBinLocations', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Temperature Control',
            value: settings.warehouse.enableTemperatureControl,
            onChanged: (value) => _updateSetting('warehouse.enableTemperatureControl', value),
            theme: theme,
          ),
          SettingNumberCard(
            title: 'Max Utilization',
            value: settings.warehouse.maxUtilizationPercentage.toDouble(),
            onChanged: (value) => _updateSetting('warehouse.maxUtilizationPercentage', value.toInt()),
            theme: theme,
            suffix: '%',
            max: 100,
          ),
          SettingToggleCard(
            title: 'Cycle Counting',
            value: settings.stockTake.enableCycleCounting,
            onChanged: (value) => _updateSetting('stockTake.enableCycleCounting', value),
            theme: theme,
          ),
          SettingNumberCard(
            title: 'Max Variance %',
            value: settings.stockTake.maxVariancePercentage,
            onChanged: (value) => _updateSetting('stockTake.maxVariancePercentage', value),
            theme: theme,
            suffix: '%',
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(StoreSettings settings, ThemeData theme) {
    return SettingCategoryCard(
      title: 'Security & Access',
      icon: Icons.security_rounded,
      theme: theme,
      child: Column(
        children: [
          SettingToggleCard(
            title: 'Two-Factor Authentication',
            value: settings.security.twoFactorAuth,
            onChanged: (value) => _updateSetting('security.twoFactorAuth', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Password Expiry',
            value: settings.security.passwordExpiry,
            onChanged: (value) => _updateSetting('security.passwordExpiry', value),
            theme: theme,
          ),
          SettingNumberCard(
            title: 'Session Timeout',
            value: settings.security.sessionTimeout.toDouble(),
            onChanged: (value) => _updateSetting('security.sessionTimeout', value.toInt()),
            theme: theme,
            suffix: 'mins',
          ),
          SettingNumberCard(
            title: 'Password Expiry Days',
            value: settings.security.passwordExpiryDays.toDouble(),
            onChanged: (value) => _updateSetting('security.passwordExpiryDays', value.toInt()),
            theme: theme,
            suffix: 'days',
          ),
          SettingToggleCard(
            title: 'IP Whitelisting',
            value: settings.security.ipWhitelisting,
            onChanged: (value) => _updateSetting('security.ipWhitelisting', value),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(StoreSettings settings, ThemeData theme) {
    return SettingCategoryCard(
      title: 'System & Maintenance',
      icon: Icons.settings_suggest_rounded,
      theme: theme,
      child: Column(
        children: [
          SettingToggleCard(
            title: 'Auto Backup',
            value: settings.system.enableAutoBackup,
            onChanged: (value) => _updateSetting('system.enableAutoBackup', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Audit Log',
            value: settings.system.enableAuditLog,
            onChanged: (value) => _updateSetting('system.enableAuditLog', value),
            theme: theme,
          ),
          SettingToggleCard(
            title: 'Maintenance Mode',
            value: settings.system.maintenanceMode,
            onChanged: (value) => _updateSetting('system.maintenanceMode', value),
            theme: theme,
          ),
          SettingNumberCard(
            title: 'Backup Frequency',
            value: settings.system.backupFrequency.toDouble(),
            onChanged: (value) => _updateSetting('system.backupFrequency', value.toInt()),
            theme: theme,
            suffix: 'days',
          ),
          SettingDropdownCard(
            title: 'Backup Location',
            value: settings.system.backupLocation,
            options: const ['local', 'cloud', 'both'],
            onChanged: (value) => _updateSetting('system.backupLocation', value),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _updateSetting(String path, dynamic value) async {
    try {
      await ref.read(storeSettingsProvider.notifier).updateSetting(path, value);
      _showSuccessSnackbar('Setting updated successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to update setting: $e');
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    try {
      await ref.read(storeSettingsProvider.notifier).resetToDefaults();
      _showSuccessSnackbar('Settings reset to defaults successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to reset settings: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildShimmerLoader(bool isLargeScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
        child: Column(
          children: [
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
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
            Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}