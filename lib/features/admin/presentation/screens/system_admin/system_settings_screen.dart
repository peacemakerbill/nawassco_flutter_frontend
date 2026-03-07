import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/admin_colors.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            border: Border(bottom: BorderSide(color: AdminColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Settings',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage system configuration and user roles',
                style: TextStyle(
                  color: AdminColors.textSecondary,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: AdminColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AdminColors.primary,
            unselectedLabelColor: AdminColors.textSecondary,
            indicatorColor: AdminColors.primary,
            isScrollable: MediaQuery.of(context).size.width < 600,
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'User Roles'),
              Tab(text: 'Billing Settings'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              GeneralSettingsTab(),
              UserRolesTab(),
              BillingSettingsTab(),
              NotificationSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final padding = isLargeScreen ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Configuration',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      _SettingRow(
                        title: 'System Maintenance',
                        subtitle: 'Enable system maintenance mode',
                        widget: Switch(value: false, onChanged: (value) {}),
                      ),
                      _SettingRow(
                        title: 'Auto Backup',
                        subtitle: 'Automatically backup system data daily',
                        widget: Switch(value: true, onChanged: (value) {}),
                      ),
                      _SettingRow(
                        title: 'Data Retention',
                        subtitle: 'Keep user data for 7 years',
                        widget: Switch(value: true, onChanged: (value) {}),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isLargeScreen ? 20 : 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Tariff Settings',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _TariffRow('Residential', 'KES 45/m³'),
                      _TariffRow('Commercial', 'KES 60/m³'),
                      _TariffRow('Industrial', 'KES 75/m³'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserRolesTab extends StatelessWidget {
  const UserRolesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'name': 'Administrator', 'users': 3, 'permissions': 'Full system access'},
      {'name': 'Manager', 'users': 5, 'permissions': 'User and controller management'},
      {'name': 'Operator', 'users': 12, 'permissions': 'Service requests and operations'},
      {'name': 'Viewer', 'users': 8, 'permissions': 'Read-only access'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final padding = isLargeScreen ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLargeScreen
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User Roles & Permissions',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Add New Role'),
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Roles & Permissions',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Add New Role'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      ...roles.map((role) => _RoleCard(role: role, isLargeScreen: isLargeScreen)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BillingSettingsTab extends StatelessWidget {
  const BillingSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 24 : 16,
            vertical: constraints.maxWidth > 600 ? 24 : 16,
          ),
          child: const Center(
            child: Text('Billing Settings Content'),
          ),
        );
      },
    );
  }
}

class NotificationSettingsTab extends StatelessWidget {
  const NotificationSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 24 : 16,
            vertical: constraints.maxWidth > 600 ? 24 : 16,
          ),
          child: const Center(
            child: Text('Notification Settings Content'),
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget widget;

  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: AdminColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          widget,
        ],
      ),
    );
  }
}

class _TariffRow extends StatelessWidget {
  final String type;
  final String rate;

  const _TariffRow(this.type, this.rate);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              type,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              rate,
              style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Map<String, dynamic> role;
  final bool isLargeScreen;

  const _RoleCard({required this.role, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['name'],
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role['permissions'],
                    style: TextStyle(
                      color: AdminColors.textSecondary,
                      fontSize: isLargeScreen ? 12 : 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AdminColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${role['users']} users',
                style: TextStyle(
                  color: AdminColors.primary,
                  fontSize: isLargeScreen ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.edit, size: isLargeScreen ? 18 : 16),
              onPressed: () {},
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}