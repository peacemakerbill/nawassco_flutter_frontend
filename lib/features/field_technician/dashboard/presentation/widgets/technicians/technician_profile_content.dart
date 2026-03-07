import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/field_technician.dart';
import '../../../providers/field_technician_provider.dart';
import '../sub_widgets/field_technician/edit_technician_dialog.dart';
import '../sub_widgets/field_technician/technician_performance_card.dart';
import '../sub_widgets/field_technician/technician_profile_header.dart';
import '../sub_widgets/field_technician/technician_quick_actions.dart';

class TechnicianProfileContent extends ConsumerStatefulWidget {
  const TechnicianProfileContent({super.key});

  @override
  ConsumerState<TechnicianProfileContent> createState() =>
      _TechnicianProfileContentState();
}

class _TechnicianProfileContentState
    extends ConsumerState<TechnicianProfileContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  void _loadProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldTechnicianProvider.notifier).loadCurrentTechnicianProfile();
    });
  }

  void _handleEditProfile() {
    final currentTechnician =
        ref.read(fieldTechnicianProvider).currentTechnician;
    if (currentTechnician != null) {
      showDialog(
        context: context,
        builder: (context) =>
            EditTechnicianDialog(technician: currentTechnician),
      );
    }
  }

  void _handleCreateProfile() {
    showDialog(
      context: context,
      builder: (context) => const EditTechnicianDialog(),
    );
  }

  void _handleRefreshProfile() {
    ref.read(fieldTechnicianProvider.notifier).loadCurrentTechnicianProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldTechnicianProvider);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: _buildSliverContent(state, theme, isMobile),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSliverContent(
      FieldTechnicianState state, ThemeData theme, bool isMobile) {
    return [
      _buildAppBar(state),
      if (state.isLoading) _buildLoadingState(),
      if (state.currentTechnician == null && !state.isLoading)
        _buildNoProfileState(theme),
      if (state.currentTechnician != null && !state.isLoading)
        ..._buildProfileContent(state, theme, isMobile),
    ];
  }

  SliverAppBar _buildAppBar(FieldTechnicianState state) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: const Text(
        'My Technician Profile',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: _handleRefreshProfile,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
        if (state.currentTechnician != null)
          IconButton(
            onPressed: _handleEditProfile,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Profile',
          ),
      ],
    );
  }

  SliverFillRemaining _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  SliverFillRemaining _buildNoProfileState(ThemeData theme) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No Technician Profile Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your field technician profile to start managing your work orders and performance.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleCreateProfile,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Create Technician Profile'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProfileContent(
      FieldTechnicianState state, ThemeData theme, bool isMobile) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TechnicianProfileHeader(technician: state.currentTechnician!),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TechnicianQuickActions(technician: state.currentTechnician!),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child:
              TechnicianPerformanceCard(technician: state.currentTechnician!),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _buildWorkInformationCard(
              state.currentTechnician!, theme, isMobile),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _buildSpecializationsAndTools(
              state.currentTechnician!, theme, isMobile),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
    ];
  }

  Widget _buildWorkInformationCard(
      FieldTechnician technician, ThemeData theme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Work Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWorkInfoGrid(technician, theme, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationsAndTools(
      FieldTechnician technician, ThemeData theme, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildSpecializationsCard(technician, theme),
        ),
        if (!isMobile) const SizedBox(width: 16),
        if (!isMobile)
          Expanded(
            child: _buildToolsCard(technician, theme),
          ),
      ],
    );
  }

  Widget _buildSpecializationsCard(
      FieldTechnician technician, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Specializations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (technician.specializedAreas.isEmpty)
              Text(
                'No specializations added',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: technician.specializedAreas.map((area) {
                  return Chip(
                    label: Text(area),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.orange),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsCard(FieldTechnician technician, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_rounded,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tools Assigned',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (technician.toolsAssigned.isEmpty)
              Text(
                'No tools assigned',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: technician.toolsAssigned.map((tool) {
                  return Chip(
                    label: Text(tool),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkInfoGrid(
      FieldTechnician technician, ThemeData theme, bool isMobile) {
    if (isMobile) {
      return Column(
        children: _buildWorkInfoItems(technician),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 4,
      children: _buildWorkInfoItems(technician),
    );
  }

  List<Widget> _buildWorkInfoItems(FieldTechnician technician) {
    return [
      _buildWorkInfoItem(
          'Employee ID', technician.employeeNumber, Icons.badge_rounded),
      _buildWorkInfoItem(
          'Department', technician.department, Icons.business_rounded),
      _buildWorkInfoItem(
          'Work Zone', technician.workZone, Icons.location_on_rounded),
      _buildWorkInfoItem(
          'Hire Date',
          '${technician.hireDate.day}/${technician.hireDate.month}/${technician.hireDate.year}',
          Icons.calendar_today_rounded),
      if (technician.vehicleAssigned != null)
        _buildWorkInfoItem('Vehicle', technician.vehicleAssigned!,
            Icons.directions_car_rounded),
    ];
  }

  Widget _buildWorkInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
