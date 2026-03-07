import 'package:flutter/material.dart';
import '../../../../models/decision_log_model.dart';
import 'decision_log_analysis.dart';

class DecisionLogDetail extends StatefulWidget {
  final DecisionLog? decisionLog;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final Function(DecisionStatus) onStatusUpdate;

  const DecisionLogDetail({
    super.key,
    required this.decisionLog,
    required this.isLoading,
    required this.onBack,
    required this.onEdit,
    required this.onStatusUpdate,
  });

  @override
  State<DecisionLogDetail> createState() => _DecisionLogDetailState();
}

class _DecisionLogDetailState extends State<DecisionLogDetail> {
  int _selectedTab = 0;
  final List<StepStatus> _stepStatusOptions = StepStatus.values;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || widget.decisionLog == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final log = widget.decisionLog!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.decisionId,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: widget.onEdit,
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats row
                _buildQuickStats(log),
                const SizedBox(height: 24),

                // Tab bar
                _buildTabBar(),
                const SizedBox(height: 24),

                // Tab content
                IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildOverviewTab(log),
                    _buildAnalysisTab(log),
                    _buildImplementationTab(log),
                    _buildOutcomesTab(log),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DecisionLog log) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(log.status.icon, color: log.status.color),
                          const SizedBox(width: 8),
                          Text(
                            log.status.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: log.status.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Decision date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decision Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(log.decisionDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Alternatives
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alternatives',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${log.alternatives.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Confidence
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${log.analysis.confidence.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(log.analysis.confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            if (log.implementationSteps.isNotEmpty)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _calculateProgress(log.implementationSteps),
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Implementation Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(_calculateProgress(log.implementationSteps) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabButton('Overview', 0, Icons.info_outline),
            _buildTabButton('Analysis', 1, Icons.analytics),
            _buildTabButton('Implementation', 2, Icons.engineering),
            _buildTabButton('Outcomes', 3, Icons.fact_check),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected ? Border.all(color: Colors.blue, width: 1.5) : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(DecisionLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Problem Statement
        _buildSection(
          title: 'Problem Statement',
          content: Text(log.problemStatement),
          icon: Icons.error_outline,
          color: Colors.red,
        ),
        const SizedBox(height: 20),

        // Context
        _buildSection(
          title: 'Context',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Background', log.context.background),
              _buildInfoRow('Trigger', log.context.trigger),
              _buildInfoRow('Scope', log.context.scope),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildUrgencyImpactChip('Urgency', log.context.urgency),
                  const SizedBox(width: 12),
                  _buildUrgencyImpactChip('Impact', log.context.impact),
                ],
              ),
            ],
          ),
          icon: Icons.lightbulb_outline,
          color: Colors.orange,
        ),
        const SizedBox(height: 20),

        // Decision
        _buildSection(
          title: 'Decision',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.decision,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Rationale', log.rationale),
            ],
          ),
          icon: Icons.gavel,
          color: Colors.green,
        ),
        const SizedBox(height: 20),

        // Objectives & Constraints
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSection(
                title: 'Objectives',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.objectives
                      .map((obj) => _buildBulletPoint(obj))
                      .toList(),
                ),
                icon: Icons.flag,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildSection(
                title: 'Constraints',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.constraints
                      .map((constraint) => _buildBulletPoint(constraint))
                      .toList(),
                ),
                icon: Icons.block,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisTab(DecisionLog log) {
    return DecisionLogAnalysis(
      analysis: log.analysis,
      alternatives: log.alternatives,
      criteria: log.criteria,
    );
  }

  Widget _buildImplementationTab(DecisionLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add step button
        ElevatedButton.icon(
          onPressed: () {
            // Show add step dialog
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Implementation Step'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Steps list
        if (log.implementationSteps.isEmpty)
          const Center(
            child: Column(
              children: [
                Icon(Icons.engineering, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No implementation steps added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ...log.implementationSteps.map((step) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.step,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: step.status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: step.status.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                step.status.icon,
                                size: 14,
                                color: step.status.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                step.status.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: step.status.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owner: ${step.ownerId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatDate(step.startDate)} - ${step.endDate != null ? _formatDate(step.endDate!) : 'Ongoing'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<StepStatus>(
                      value: step.status,
                      items: _stepStatusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, size: 16, color: status.color),
                              const SizedBox(width: 8),
                              Text(status.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        // Update step status
                      },
                      decoration: InputDecoration(
                        labelText: 'Update Status',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildOutcomesTab(DecisionLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expected outcomes
        _buildSection(
          title: 'Expected Outcomes',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: log.expectedOutcomes
                .map((outcome) => _buildBulletPoint(outcome))
                .toList(),
          ),
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        const SizedBox(height: 20),

        // Add actual outcome button
        ElevatedButton.icon(
          onPressed: () {
            // Show add outcome dialog
          },
          icon: const Icon(Icons.add_chart),
          label: const Text('Record Actual Outcome'),
        ),
        const SizedBox(height: 20),

        // Lessons learned
        if (log.lessonsLearned != null && log.lessonsLearned!.isNotEmpty)
          _buildSection(
            title: 'Lessons Learned',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: log.lessonsLearned!
                  .map((lesson) => _buildBulletPoint(lesson))
                  .toList(),
            ),
            icon: Icons.school,
            color: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyImpactChip(String type, dynamic level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: level.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$type: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            level.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  double _calculateProgress(List<ImplementationStep> steps) {
    if (steps.isEmpty) return 0;
    final completed =
        steps.where((s) => s.status == StepStatus.completed).length;
    return completed / steps.length;
  }
}
