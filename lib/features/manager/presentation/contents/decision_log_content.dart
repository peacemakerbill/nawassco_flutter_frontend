import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/decision_log_model.dart';
import '../../providers/decision_log_provider.dart';
import 'sub_widgets/decision_logs/decision_log_detail.dart';
import 'sub_widgets/decision_logs/decision_log_form.dart';
import 'sub_widgets/decision_logs/decision_log_list.dart';

class DecisionLogContent extends ConsumerStatefulWidget {
  const DecisionLogContent({super.key});

  @override
  ConsumerState<DecisionLogContent> createState() => _DecisionLogContentState();
}

class _DecisionLogContentState extends ConsumerState<DecisionLogContent> {
  final _scrollController = ScrollController();
  ViewMode _viewMode = ViewMode.list;
  DecisionLog? _editingLog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(decisionLogProvider.notifier).fetchDecisionLogs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCreateNew() {
    setState(() {
      _editingLog = null;
      _viewMode = ViewMode.create;
    });
  }

  void _handleEdit(DecisionLog log) {
    setState(() {
      _editingLog = log;
      _viewMode = ViewMode.edit;
    });
  }

  void _handleViewDetail(DecisionLog log) {
    ref.read(decisionLogProvider.notifier).fetchDecisionLogById(log.id!);
    setState(() {
      _editingLog = null;
      _viewMode = ViewMode.detail;
    });
  }

  void _handleBackToList() {
    setState(() {
      _editingLog = null;
      _viewMode = ViewMode.list;
    });
    ref.read(decisionLogProvider.notifier).clearSelection();
  }

  void _handleSaveComplete() {
    _handleBackToList();
    ref.read(decisionLogProvider.notifier).fetchDecisionLogs();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decisionLogProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildContent(state),
      floatingActionButton: _viewMode == ViewMode.list
          ? FloatingActionButton.extended(
              onPressed: _handleCreateNew,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Decision Log'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildContent(DecisionLogState state) {
    switch (_viewMode) {
      case ViewMode.list:
        return DecisionLogList(
          state: state,
          onViewDetail: _handleViewDetail,
          onEdit: _handleEdit,
          onCreateNew: _handleCreateNew,
          onRefresh: () =>
              ref.read(decisionLogProvider.notifier).fetchDecisionLogs(),
        );
      case ViewMode.detail:
        return DecisionLogDetail(
          decisionLog: state.selectedLog,
          isLoading: state.isLoading,
          onBack: _handleBackToList,
          onEdit: () => _handleEdit(state.selectedLog!),
          onStatusUpdate: (status) {
            if (state.selectedLog?.id != null) {
              ref.read(decisionLogProvider.notifier).updateDecisionStatus(
                    state.selectedLog!.id!,
                    status,
                  );
            }
          },
        );
      case ViewMode.create:
      case ViewMode.edit:
        return DecisionLogForm(
          decisionLog: _editingLog,
          isEditing: _viewMode == ViewMode.edit,
          onSave: (log) async {
            final success = _viewMode == ViewMode.create
                ? await ref
                    .read(decisionLogProvider.notifier)
                    .createDecisionLog(log)
                : await ref
                    .read(decisionLogProvider.notifier)
                    .updateDecisionLog(log.id!, log);

            if (success && mounted) {
              _handleSaveComplete();
            }
          },
          onCancel: _handleBackToList,
          isLoading: state.isSaving,
        );
    }
  }
}

enum ViewMode { list, detail, create, edit }
