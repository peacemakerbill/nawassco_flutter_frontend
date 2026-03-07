import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/training.model.dart';
import '../../../../providers/training.provider.dart';
import '../sub_widgets/training/evaluation_form.widget.dart';
import '../sub_widgets/training/material_upload.widget.dart';
import '../sub_widgets/training/participant_manager.widget.dart';
import '../sub_widgets/training/training_details.widget.dart';
import '../sub_widgets/training/training_form.widget.dart';
import '../sub_widgets/training/training_list.widget.dart';
import '../sub_widgets/training/training_stats.widget.dart';

class TrainingManagementContent extends ConsumerStatefulWidget {
  const TrainingManagementContent({super.key});

  @override
  ConsumerState<TrainingManagementContent> createState() => _TrainingManagementContentState();
}

class _TrainingManagementContentState extends ConsumerState<TrainingManagementContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Training? _selectedTraining;
  bool _showForm = false;
  bool _showStats = false;
  bool _showFilter = false;
  Training? _editingTraining;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await ref.read(trainingProvider.notifier).loadTrainings();
  }

  void _handleTrainingSelect(Training training) {
    setState(() {
      _selectedTraining = training;
      _showForm = false;
      _showStats = false;
    });
  }

  void _handleCreateNew() {
    setState(() {
      _showForm = true;
      _selectedTraining = null;
      _showStats = false;
      _editingTraining = null;
    });
  }

  void _handleEditTraining(Training training) {
    setState(() {
      _editingTraining = training;
      _showForm = true;
      _selectedTraining = null;
      _showStats = false;
    });
  }

  void _handleFormComplete() {
    setState(() {
      _showForm = false;
      _editingTraining = null;
    });
    _loadInitialData();
  }

  void _handleBack() {
    setState(() {
      _selectedTraining = null;
      _showForm = false;
      _showStats = false;
    });
  }

  void _toggleStats() {
    setState(() {
      _showStats = !_showStats;
      _selectedTraining = null;
      _showForm = false;
    });
  }

  void _toggleFilter() {
    setState(() {
      _showFilter = !_showFilter;
    });
  }

  void _showParticipantManagement(Training training) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: ParticipantManager(training: training),
        );
      },
    );
  }

  void _showMaterialUpload(Training training) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: MaterialUpload(training: training),
        );
      },
    );
  }

  void _showEvaluation(Training training) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: EvaluationForm(training: training),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);
    final authState = ref.watch(authProvider);
    final canManage = authState.isAdmin || authState.isHR || authState.isManager;

    if (!canManage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to manage trainings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show training details if selected
    if (_selectedTraining != null) {
      return TrainingDetails(
        training: _selectedTraining!,
        onBack: _handleBack,
        onEdit: () => _handleEditTraining(_selectedTraining!),
        onManageParticipants: () => _showParticipantManagement(_selectedTraining!),
        onUploadMaterials: () => _showMaterialUpload(_selectedTraining!),
        onEvaluate: () => _showEvaluation(_selectedTraining!),
      );
    }

    // Show training form
    if (_showForm) {
      return TrainingForm(
        training: _editingTraining,
        onSuccess: _handleFormComplete,
        onCancel: _handleBack,
      );
    }

    // Show statistics
    if (_showStats) {
      return TrainingStats(onBack: _handleBack);
    }

    // Main management dashboard
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Training Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _toggleStats,
            tooltip: 'View Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _toggleFilter,
            tooltip: 'Filter Trainings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick stats bar
          if (!_showFilter) _buildQuickStats(state),

          // Filter panel
          if (_showFilter) _buildFilterPanel(),

          // Training list
          Expanded(
            child: TrainingList(
              trainings: state.trainings,
              isLoading: state.isLoading,
              error: state.error,
              onRefresh: _loadInitialData,
              onTrainingSelect: _handleTrainingSelect,
              onTrainingEdit: _handleEditTraining,
              onTrainingDelete: (training) {
                _confirmDeleteTraining(training);
              },
              onLoadMore: () {
                ref.read(trainingProvider.notifier).loadTrainings(loadMore: true);
              },
              hasMore: state.hasMore,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreateNew,
        icon: const Icon(Icons.add),
        label: const Text('New Training'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildQuickStats(TrainingState state) {
    final stats = state.statistics;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.school,
            value: stats.totalTrainings.toString(),
            label: 'Total',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.calendar_today,
            value: stats.upcomingTrainings.toString(),
            label: 'Upcoming',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: stats.completedTrainings.toString(),
            label: 'Completed',
            color: Colors.purple,
          ),
          _buildStatItem(
            icon: Icons.people,
            value: stats.departmentStats
                .fold<int>(0, (sum, dept) => sum + dept.participantCount)
                .toString(),
            label: 'Participants',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    final state = ref.watch(trainingProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleFilter,
                tooltip: 'Close filters',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Open for Registration'),
                selected: state.selectedStatus == TrainingStatus.open_for_registration,
                onSelected: (selected) {
                  ref.read(trainingProvider.notifier).filterTrainings(
                    status: selected ? TrainingStatus.open_for_registration : null,
                  );
                },
              ),
              FilterChip(
                label: const Text('In Progress'),
                selected: state.selectedStatus == TrainingStatus.in_progress,
                onSelected: (selected) {
                  ref.read(trainingProvider.notifier).filterTrainings(
                    status: selected ? TrainingStatus.in_progress : null,
                  );
                },
              ),
              FilterChip(
                label: const Text('Completed'),
                selected: state.selectedStatus == TrainingStatus.completed,
                onSelected: (selected) {
                  ref.read(trainingProvider.notifier).filterTrainings(
                    status: selected ? TrainingStatus.completed : null,
                  );
                },
              ),
              FilterChip(
                label: const Text('Technical Skills'),
                selected: state.selectedCategory == TrainingCategory.technical_skills,
                onSelected: (selected) {
                  ref.read(trainingProvider.notifier).filterTrainings(
                    category: selected ? TrainingCategory.technical_skills : null,
                  );
                },
              ),
              FilterChip(
                label: const Text('Management'),
                selected: state.selectedCategory == TrainingCategory.management,
                onSelected: (selected) {
                  ref.read(trainingProvider.notifier).filterTrainings(
                    category: selected ? TrainingCategory.management : null,
                  );
                },
              ),
              FilterChip(
                label: const Text('Clear All'),
                backgroundColor: Colors.grey.shade100,
                onSelected: (_) {
                  ref.read(trainingProvider.notifier).clearFilters();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTraining(Training training) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Training'),
          content: Text(
            'Are you sure you want to delete "${training.trainingTitle}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(trainingProvider.notifier).deleteTraining(training.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Training "${training.trainingTitle}" deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}