import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/field_team.dart';
import '../../../providers/field_team_provider.dart';
import '../sub_widgets/field_team/field_team_card.dart';
import '../sub_widgets/field_team/field_team_details.dart';
import '../sub_widgets/field_team/field_team_form.dart';

class FieldTeamContent extends ConsumerStatefulWidget {
  const FieldTeamContent({super.key});

  @override
  ConsumerState<FieldTeamContent> createState() => _FieldTeamContentState();
}

class _FieldTeamContentState extends ConsumerState<FieldTeamContent> {
  final _searchController = TextEditingController();
  FieldTeamView _currentView = FieldTeamView.list;
  FieldTeam? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldTeamProvider.notifier).loadFieldTeams();
    });
  }

  void _showTeamDetails(FieldTeam team) {
    setState(() {
      _selectedTeam = team;
      _currentView = FieldTeamView.details;
    });
  }

  void _showCreateForm() {
    setState(() {
      _selectedTeam = null;
      _currentView = FieldTeamView.create;
    });
  }

  void _showEditForm(FieldTeam team) {
    setState(() {
      _selectedTeam = team;
      _currentView = FieldTeamView.edit;
    });
  }

  void _backToList() {
    setState(() {
      _selectedTeam = null;
      _currentView = FieldTeamView.list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldTeamProvider);
    final notifier = ref.read(fieldTeamProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(state, notifier),

          // Content based on current view
          Expanded(
            child: _buildCurrentView(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FieldTeamState state, FieldTeamProvider notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentView != FieldTeamView.list) ...[
                IconButton(
                  onPressed: _backToList,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to list',
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.groups, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Text(
                _getHeaderTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              if (_currentView == FieldTeamView.list) ...[
                _buildSearchField(notifier),
                const SizedBox(width: 12),
                _buildFilterButton(state, notifier),
                const SizedBox(width: 12),
                _buildAddButton(),
              ],
            ],
          ),
          if (_currentView == FieldTeamView.list) ...[
            const SizedBox(height: 12),
            _buildQuickStats(state),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(FieldTeamProvider notifier) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _searchController,
        onChanged: notifier.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search teams...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterButton(FieldTeamState state, FieldTeamProvider notifier) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
      onSelected: (value) {
        _handleFilterSelection(value, state, notifier);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'clear', child: Text('Clear Filters')),
        const PopupMenuDivider(),
        ...state.availableDepartments
            .map((dept) => PopupMenuItem(
                value: 'dept:$dept', child: Text('Department: $dept')))
            .toList(),
        const PopupMenuDivider(),
        ...state.availableWorkZones
            .map((zone) => PopupMenuItem(
                value: 'zone:$zone', child: Text('Work Zone: $zone')))
            .toList(),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'active:true', child: Text('Active Only')),
        const PopupMenuItem(
            value: 'active:false', child: Text('Inactive Only')),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _showCreateForm,
      icon: const Icon(Icons.add),
      label: const Text('New Team'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildQuickStats(FieldTeamState state) {
    final totalTeams = state.teams.length;
    final activeTeams = state.teams.where((team) => team.isActive).length;
    final totalMembers =
        state.teams.fold(0, (sum, team) => sum + team.totalMembers);
    final avgWorkload = state.teams.isEmpty
        ? 0
        : state.teams
                .map((team) => team.currentWorkload)
                .reduce((a, b) => a + b) /
            state.teams.length;

    return Row(
      children: [
        _buildStatCard(
            'Total Teams', totalTeams.toString(), Icons.groups, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Active Teams', activeTeams.toString(),
            Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Total Members', totalMembers.toString(), Icons.people,
            Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard('Avg Workload', '${avgWorkload.toStringAsFixed(1)}%',
            Icons.work, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildCurrentView(FieldTeamState state, FieldTeamProvider notifier) {
    switch (_currentView) {
      case FieldTeamView.list:
        return _buildTeamList(state, notifier);
      case FieldTeamView.details:
        return FieldTeamDetailsWidget(
          team: _selectedTeam!,
          onEdit: () => _showEditForm(_selectedTeam!),
          onBack: _backToList,
        );
      case FieldTeamView.create:
        return FieldTeamFormWidget(
          onSave: (teamData) async {
            final success = await notifier.createFieldTeam(teamData);
            if (success) {
              _backToList();
            }
          },
          onCancel: _backToList,
        );
      case FieldTeamView.edit:
        return FieldTeamFormWidget(
          team: _selectedTeam,
          onSave: (teamData) async {
            final success =
                await notifier.updateFieldTeam(_selectedTeam!.id, teamData);
            if (success) {
              _backToList();
            }
          },
          onCancel: _backToList,
        );
    }
  }

  Widget _buildTeamList(FieldTeamState state, FieldTeamProvider notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeams,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final teams = state.filteredTeams;

    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No field teams found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Create your first field team to get started',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (state.searchQuery.isEmpty)
              ElevatedButton(
                onPressed: _showCreateForm,
                child: const Text('Create Team'),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return FieldTeamCard(
            team: team,
            onTap: () => _showTeamDetails(team),
            onEdit: () => _showEditForm(team),
          );
        },
      ),
    );
  }

  void _handleFilterSelection(
      String value, FieldTeamState state, FieldTeamProvider notifier) {
    switch (value) {
      case 'clear':
        notifier.clearFilters();
        break;
      case 'active:true':
        notifier.setActiveFilter(true);
        break;
      case 'active:false':
        notifier.setActiveFilter(false);
        break;
      default:
        if (value.startsWith('dept:')) {
          final dept = value.substring(5);
          notifier.setDepartmentFilter(dept);
        } else if (value.startsWith('zone:')) {
          final zone = value.substring(5);
          notifier.setWorkZoneFilter(zone);
        }
    }
  }

  String _getHeaderTitle() {
    switch (_currentView) {
      case FieldTeamView.list:
        return 'Field Teams';
      case FieldTeamView.details:
        return 'Team Details';
      case FieldTeamView.create:
        return 'Create New Team';
      case FieldTeamView.edit:
        return 'Edit Team';
    }
  }
}

enum FieldTeamView {
  list,
  details,
  create,
  edit,
}
