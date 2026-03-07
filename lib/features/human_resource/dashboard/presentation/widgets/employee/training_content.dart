import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/training.model.dart';
import '../../../../providers/training.provider.dart';
import '../sub_widgets/training/training_calendar.widget.dart';
import '../sub_widgets/training/training_details.widget.dart';
import '../sub_widgets/training/training_list.widget.dart';
import '../sub_widgets/training/training_stats.widget.dart';

class TrainingContent extends ConsumerStatefulWidget {
  const TrainingContent({super.key});

  @override
  ConsumerState<TrainingContent> createState() => _TrainingContentState();
}

class _TrainingContentState extends ConsumerState<TrainingContent> {
  Training? _selectedTraining;
  bool _showCalendar = false;
  bool _showStats = false;
  bool _showMyTrainings = false;

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
    });
  }

  void _handleBack() {
    setState(() {
      _selectedTraining = null;
    });
  }

  void _toggleCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
      _selectedTraining = null;
      _showStats = false;
    });
  }

  void _toggleStats() {
    setState(() {
      _showStats = !_showStats;
      _selectedTraining = null;
      _showCalendar = false;
    });
  }

  void _toggleMyTrainings() {
    setState(() {
      _showMyTrainings = !_showMyTrainings;
      if (_showMyTrainings) {
        // Load only registered trainings
        final myTrainings = ref.read(trainingProvider).myTrainings;
        if (myTrainings.isEmpty) {
          // Show message if no trainings
        }
      }
    });
  }

  void _registerForTraining(Training training) {
    ref.read(trainingProvider.notifier).registerForTraining(training.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registered for "${training.trainingTitle}"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);
    final authState = ref.watch(authProvider);
    final canManage = authState.isAdmin || authState.isHR || authState.isManager;

    final displayedTrainings = _showMyTrainings
        ? state.trainings.where((t) => t.isRegistered).toList()
        : state.trainings;

    // Show training details if selected
    if (_selectedTraining != null) {
      return TrainingDetails(
        training: _selectedTraining!,
        onBack: _handleBack,
        onEdit: canManage ? () {
          // Navigate to edit (would be handled by parent)
        } : null,
        onManageParticipants: canManage ? () {
          // Show participant management
        } : null,
        onUploadMaterials: canManage ? () {
          // Show material upload
        } : null,
        onEvaluate: canManage ? () {
          // Show evaluation form
        } : null,
      );
    }

    // Show calendar view
    if (_showCalendar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Training Calendar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: TrainingCalendar(
          onTrainingSelect: _handleTrainingSelect,
        ),
      );
    }

    // Show statistics
    if (_showStats) {
      return TrainingStats(onBack: _handleBack);
    }

    // Main content with available trainings
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _toggleCalendar,
            tooltip: 'Calendar View',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _toggleStats,
            tooltip: 'View Statistics',
          ),
          IconButton(
            icon: Icon(_showMyTrainings ? Icons.list : Icons.bookmark),
            onPressed: _toggleMyTrainings,
            tooltip: _showMyTrainings ? 'Show All Trainings' : 'Show My Trainings',
          ),
        ],
      ),
      body: TrainingList(
        trainings: displayedTrainings,
        isLoading: state.isLoading,
        error: state.error,
        onRefresh: _loadInitialData,
        onTrainingSelect: _handleTrainingSelect,
        onTrainingEdit: canManage ? (training) {
          // Would navigate to edit in management content
        } : null,
        onTrainingDelete: canManage ? (training) {
          // Would show delete confirmation
        } : null,
        onLoadMore: () {
          ref.read(trainingProvider.notifier).loadTrainings(loadMore: true);
        },
        hasMore: state.hasMore,
      ),
      floatingActionButton: _showMyTrainings
          ? null
          : FloatingActionButton.extended(
        onPressed: () {
          // Show filter dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Quick Filter'),
                content: const Text('Filter trainings by status, category, or type'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Show filter panel
                    },
                    child: const Text('Show Filters'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.filter_alt),
        label: const Text('Filter'),
      ),
    );
  }
}