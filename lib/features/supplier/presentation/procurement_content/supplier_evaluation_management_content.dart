import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/supplier_evaluation_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_evaluation_provider.dart';
import '../../providers/supplier_provider.dart';
import 'sub_widgets/evaluation_form_widget.dart';
import 'sub_widgets/evaluation_list_widget.dart';

class SupplierEvaluationManagementContent extends ConsumerStatefulWidget {
  const SupplierEvaluationManagementContent({super.key});

  @override
  ConsumerState<SupplierEvaluationManagementContent> createState() => _SupplierEvaluationManagementContentState();
}

class _SupplierEvaluationManagementContentState extends ConsumerState<SupplierEvaluationManagementContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data when component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierProvider.notifier).getAllSuppliers();
      ref.read(supplierEvaluationProvider.notifier).getAllEvaluations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final evaluationState = ref.watch(supplierEvaluationProvider);
    final supplierState = ref.watch(supplierProvider);

    return Column(
      children: [
        // Header with supplier filter
        _buildHeader(supplierState.suppliers),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0066A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0066A1),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'All Evaluations'),
              Tab(text: 'New Evaluation'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Evaluations Tab
              EvaluationListWidget(
                evaluations: _selectedSupplierId != null
                    ? evaluationState.evaluations.where((e) => e.supplierId == _selectedSupplierId).toList()
                    : evaluationState.evaluations,
                isLoading: evaluationState.isLoading,
                error: evaluationState.error,
                onRefresh: () => ref.read(supplierEvaluationProvider.notifier).getAllEvaluations(),
                onView: (evaluation) => _showEvaluationDetails(evaluation),
                onSubmit: (evaluation) => _submitEvaluation(evaluation),
                onApprove: (evaluation) => _approveEvaluation(evaluation),
                onReject: (evaluation) => _rejectEvaluation(evaluation),
                onUpdateAction: (evaluationId, actionId, status) => _updateFollowUpAction(evaluationId, actionId, status),
              ),

              // New Evaluation Tab
              EvaluationFormWidget(
                suppliers: supplierState.suppliers,
                selectedSupplierId: _selectedSupplierId,
                onSubmit: (data) async {
                  final success = await ref.read(supplierEvaluationProvider.notifier).createEvaluation(data);
                  if (success && mounted) {
                    _tabController.animateTo(0); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evaluation created successfully')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Supplier> suppliers) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Color(0xFF0066A1), size: 24),
                SizedBox(width: 12),
                Text(
                  'Supplier Evaluation Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage supplier performance evaluations, approvals, and follow-up actions.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedSupplierId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Supplier',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Suppliers')),
                      ...suppliers.map((supplier) => DropdownMenuItem(
                        value: supplier.id,
                        child: Text(supplier.companyName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplierId = value;
                      });
                      if (value != null) {
                        ref.read(supplierEvaluationProvider.notifier).getEvaluationsBySupplier(value);
                      } else {
                        ref.read(supplierEvaluationProvider.notifier).getAllEvaluations();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(supplierEvaluationProvider.notifier).getAllEvaluations();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066A1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEvaluationDetails(SupplierEvaluation evaluation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evaluation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Evaluation Number: ${evaluation.evaluationNumber}'),
              Text('Total Score: ${evaluation.totalScore}'),
              Text('Grade: ${evaluation.grade}'),
              Text('Status: ${evaluation.status}'),
              const SizedBox(height: 16),
              if (evaluation.strengths.isNotEmpty) ...[
                const Text('Strengths:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...evaluation.strengths.map((strength) => Text('• $strength')),
                const SizedBox(height: 8),
              ],
              if (evaluation.weaknesses.isNotEmpty) ...[
                const Text('Weaknesses:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...evaluation.weaknesses.map((weakness) => Text('• $weakness')),
                const SizedBox(height: 8),
              ],
              if (evaluation.recommendations.isNotEmpty) ...[
                const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...evaluation.recommendations.map((recommendation) => Text('• $recommendation')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _submitEvaluation(SupplierEvaluation evaluation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Evaluation'),
        content: const Text('Submit this evaluation for review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierEvaluationProvider.notifier).submitEvaluation(evaluation.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evaluation submitted for review')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _approveEvaluation(SupplierEvaluation evaluation) {
    final commentsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Evaluation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Approve this evaluation?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Approval Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierEvaluationProvider.notifier).approveEvaluation(
                evaluation.id,
                comments: commentsController.text.isNotEmpty ? commentsController.text : null,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evaluation approved')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectEvaluation(SupplierEvaluation evaluation) {
    final commentsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Evaluation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reject this evaluation?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Rejection Comments *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide rejection comments')),
                );
                return;
              }

              Navigator.pop(context);
              final success = await ref.read(supplierEvaluationProvider.notifier).rejectEvaluation(
                evaluation.id,
                comments: commentsController.text,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evaluation rejected')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _updateFollowUpAction(String evaluationId, String actionId, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Action Status'),
        content: const Text('Update follow-up action status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(supplierEvaluationProvider.notifier).updateFollowUpAction(
                evaluationId,
                actionId,
                status,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action status updated')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}