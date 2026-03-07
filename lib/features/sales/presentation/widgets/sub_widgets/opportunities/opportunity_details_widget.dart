import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../../models/opportunity.model.dart';
import '../../../../providers/opportunity_provider.dart';
import 'opportunity_form_widget.dart';

class OpportunityDetailsWidget extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  const OpportunityDetailsWidget({super.key, required this.opportunity});

  @override
  ConsumerState<OpportunityDetailsWidget> createState() => _OpportunityDetailsWidgetState();
}

class _OpportunityDetailsWidgetState extends ConsumerState<OpportunityDetailsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final double _chartHeight = 200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final opportunity = widget.opportunity;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(children: [
          _buildHeader(theme, opportunity),
          const SizedBox(height: 16),
          _buildTabs(isSmallScreen),
          Expanded(child: _buildTabContent(opportunity, isSmallScreen)),
        ]),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Opportunity opportunity) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: isSmallScreen ? _buildMobileHeader(theme, opportunity) : _buildDesktopHeader(theme, opportunity),
    );
  }

  Widget _buildDesktopHeader(ThemeData theme, Opportunity opportunity) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back), color: const Color(0xFF1E3A8A)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(opportunity.opportunityNumber, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
            const SizedBox(height: 4),
            Text(opportunity.description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _buildStageBadge(opportunity.salesStage),
            const SizedBox(height: 8),
            _buildTypeBadge(opportunity.opportunityType),
          ]),
        ]),
        const SizedBox(height: 16),
        _buildQuickStatsRow(opportunity),
      ])),
      const SizedBox(width: 20),
      Column(children: [
        ElevatedButton.icon(
          onPressed: () => _showEditDialog(opportunity),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        ),
        const SizedBox(height: 8),
        _buildMoreMenu(opportunity),
      ]),
    ]);
  }

  Widget _buildMobileHeader(ThemeData theme, Opportunity opportunity) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back), color: const Color(0xFF1E3A8A)),
        Expanded(child: Text(opportunity.opportunityNumber, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)))),
        ElevatedButton(
          onPressed: () => _showEditDialog(opportunity),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
          child: const Icon(Icons.edit, size: 16),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _confirmDelete(opportunity),
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          tooltip: 'Delete Opportunity',
        ),
      ]),
      const SizedBox(height: 8),
      Text(opportunity.description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 12),
      Row(children: [_buildStageBadge(opportunity.salesStage), const SizedBox(width: 8), _buildTypeBadge(opportunity.opportunityType)]),
      const SizedBox(height: 12),
      _buildMobileQuickStats(opportunity),
    ]);
  }

  Widget _buildStageBadge(SalesStage stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: stage.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: stage.color.withValues(alpha: 0.3))),
      child: Row(children: [Icon(stage.icon, size: 16, color: stage.color), const SizedBox(width: 8), Text(stage.displayName, style: TextStyle(color: stage.color, fontWeight: FontWeight.bold, fontSize: 14))]),
    );
  }

  Widget _buildTypeBadge(OpportunityType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: type.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Text(type.displayName, style: TextStyle(color: type.color, fontWeight: FontWeight.w500, fontSize: 12)),
    );
  }

  Widget _buildQuickStatsRow(Opportunity opportunity) {
    return Row(children: [
      _buildQuickStatItem(Icons.attach_money, opportunity.valueFormatted, 'Estimated Value', Colors.green),
      const SizedBox(width: 24),
      _buildQuickStatItem(Icons.trending_up, opportunity.revenueFormatted, 'Expected Revenue', Colors.orange),
      const SizedBox(width: 24),
      _buildQuickStatItem(Icons.timeline, '${opportunity.daysInPipeline} days', 'Pipeline Age', Colors.blue),
      const SizedBox(width: 24),
      _buildQuickStatItem(Icons.star, '${opportunity.probability}%', 'Probability', opportunity.probabilityColor),
    ]);
  }

  Widget _buildMobileQuickStats(Opportunity opportunity) {
    return Wrap(spacing: 12, runSpacing: 8, children: [
      _buildMobileQuickStatItem(Icons.attach_money, opportunity.valueFormatted, 'Value'),
      _buildMobileQuickStatItem(Icons.timeline, '${opportunity.daysInPipeline}d', 'Age'),
      _buildMobileQuickStatItem(Icons.star, '${opportunity.probability}%', 'Probability'),
    ]);
  }

  Widget _buildQuickStatItem(IconData icon, String value, String label, Color color) {
    return Row(children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    ]);
  }

  Widget _buildMobileQuickStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Column(children: [
        Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildMoreMenu(Opportunity opportunity) {
    return PopupMenuButton<String>(
      icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)), child: const Icon(Icons.more_vert, size: 20)),
      itemBuilder: (context) => [
        if (!opportunity.isClosed) const PopupMenuItem(value: 'update_stage', child: Row(children: [Icon(Icons.trending_up, color: Colors.green, size: 20), SizedBox(width: 8), Text('Update Stage')])),
        const PopupMenuItem(value: 'add_competitor', child: Row(children: [Icon(Icons.group, color: Colors.blue, size: 20), SizedBox(width: 8), Text('Add Competitor')])),
        const PopupMenuItem(value: 'add_decision_maker', child: Row(children: [Icon(Icons.person_add, color: Colors.purple, size: 20), SizedBox(width: 8), Text('Add Decision Maker')])),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete Opportunity')])),
      ],
      onSelected: (value) => _handleMenuAction(value, opportunity),
    );
  }

  void _handleMenuAction(String value, Opportunity opportunity) {
    switch (value) {
      case 'update_stage': _showUpdateStageDialog(opportunity); break;
      case 'add_competitor': _showAddCompetitorDialog(opportunity); break;
      case 'add_decision_maker': _showAddDecisionMakerDialog(opportunity); break;
      case 'delete': _confirmDelete(opportunity); break;
    }
  }

  Widget _buildTabs(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: !isSmallScreen,
        labelColor: const Color(0xFF1E3A8A),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF1E3A8A),
        indicatorWeight: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 12 : 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        tabs: const [Tab(text: 'Overview'), Tab(text: 'Financials'), Tab(text: 'Competition'), Tab(text: 'Decision Makers'), Tab(text: 'Timeline')],
      ),
    );
  }

  Widget _buildTabContent(Opportunity opportunity, bool isSmallScreen) {
    return TabBarView(controller: _tabController, children: [
      _OverviewTab(opportunity: opportunity, isSmallScreen: isSmallScreen),
      _FinancialsTab(opportunity: opportunity, isSmallScreen: isSmallScreen, chartHeight: _chartHeight),
      _CompetitionTab(opportunity: opportunity, isSmallScreen: isSmallScreen, onAddCompetitor: () => _showAddCompetitorDialog(opportunity)),
      _DecisionMakersTab(opportunity: opportunity, isSmallScreen: isSmallScreen, onAddDecisionMaker: () => _showAddDecisionMakerDialog(opportunity)),
      _TimelineTab(opportunity: opportunity, isSmallScreen: isSmallScreen),
    ]);
  }

  void _showEditDialog(Opportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: OpportunityFormWidget(opportunity: opportunity),
        );
      },
    );
  }

  void _showUpdateStageDialog(Opportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) {
        SalesStage? selectedStage = opportunity.salesStage;
        return AlertDialog(
          title: const Text('Update Sales Stage'),
          content: SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true, children: SalesStage.values.map((stage) {
            return ListTile(
              leading: Icon(stage.icon, color: stage.color),
              title: Text(stage.displayName),
              subtitle: Text(stage.isClosed ? 'Closes the opportunity' : 'Move to next stage', style: const TextStyle(fontSize: 12)),
              tileColor: selectedStage == stage ? stage.color.withValues(alpha: 0.1) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateStage(opportunity, stage);
              },
            );
          }).toList())),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }

  Future<void> _updateStage(Opportunity opportunity, SalesStage newStage) async {
    final provider = ref.read(opportunityProvider.notifier);
    await provider.updateStage(opportunity.id, newStage);
  }

  void _showAddCompetitorDialog(Opportunity opportunity) {
    final nameController = TextEditingController();
    final strengthController = TextEditingController();
    final weaknessController = TextEditingController();
    final advantageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Competitor'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Competitor Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: strengthController, decoration: const InputDecoration(labelText: 'Strengths', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 12),
            TextField(controller: weaknessController, decoration: const InputDecoration(labelText: 'Weaknesses', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 12),
            TextField(controller: advantageController, decoration: const InputDecoration(labelText: 'Our Advantage', border: OutlineInputBorder()), maxLines: 2),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                _addCompetitor(opportunity, nameController.text, strengthController.text, weaknessController.text, advantageController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCompetitor(Opportunity opportunity, String name, String strength, String weakness, String advantage) async {
    final provider = ref.read(opportunityProvider.notifier);
    await provider.addCompetitor(opportunity.id, {
      'name': name,
      'strength': strength,
      'weakness': weakness,
      'ourAdvantage': advantage
    });
  }

  void _showAddDecisionMakerDialog(Opportunity opportunity) {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final contactController = TextEditingController();
    InfluenceLevel? selectedInfluence;
    Attitude? selectedAttitude;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Decision Maker'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title/Position', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<InfluenceLevel>(
                value: selectedInfluence,
                decoration: const InputDecoration(labelText: 'Influence Level', border: OutlineInputBorder()),
                hint: const Text('Select influence level', style: TextStyle(color: Colors.grey)),
                items: InfluenceLevel.values.map((level) => DropdownMenuItem<InfluenceLevel>(
                  value: level,
                  child: Text(level.displayName),
                )).toList(),
                onChanged: (value) => setState(() => selectedInfluence = value),
                validator: (value) => value == null ? 'Please select influence level' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Attitude>(
                value: selectedAttitude,
                decoration: const InputDecoration(labelText: 'Attitude', border: OutlineInputBorder()),
                hint: const Text('Select attitude', style: TextStyle(color: Colors.grey)),
                items: Attitude.values.map((attitude) => DropdownMenuItem<Attitude>(
                  value: attitude,
                  child: Text(attitude.displayName),
                )).toList(),
                onChanged: (value) => setState(() => selectedAttitude = value),
                validator: (value) => value == null ? 'Please select attitude' : null,
              ),
              const SizedBox(height: 12),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Information', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    titleController.text.isNotEmpty &&
                    selectedInfluence != null &&
                    selectedAttitude != null) {
                  Navigator.pop(context);
                  _addDecisionMaker(opportunity, nameController.text, titleController.text, selectedInfluence!, selectedAttitude!, contactController.text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDecisionMaker(Opportunity opportunity, String name, String title, InfluenceLevel influence, Attitude attitude, String contactInfo) async {
    final provider = ref.read(opportunityProvider.notifier);
    await provider.addDecisionMaker(opportunity.id, {
      'name': name,
      'title': title,
      'influence': influence.name,
      'attitude': attitude.name,
      'contactInfo': contactInfo
    });
  }

  void _confirmDelete(Opportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Opportunity'),
        content: Text('Are you sure you want to delete opportunity ${opportunity.opportunityNumber}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteOpportunity(opportunity);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete')
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOpportunity(Opportunity opportunity) async {
    final provider = ref.read(opportunityProvider.notifier);
    final success = await provider.deleteOpportunity(opportunity.id);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}

// Tab Widgets
class _OverviewTab extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _OverviewTab({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _StageProgressionCard(opportunity: opportunity, isSmallScreen: isSmallScreen),
        const SizedBox(height: 16),
        _KeyInfoGrid(opportunity: opportunity, isSmallScreen: isSmallScreen),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _LeadInfoCard(opportunity: opportunity)),
          if (!isSmallScreen) const SizedBox(width: 16),
          if (!isSmallScreen) Expanded(child: _CustomerInfoCard(opportunity: opportunity)),
        ]),
        if (isSmallScreen) ...[const SizedBox(height: 16), _CustomerInfoCard(opportunity: opportunity)],
        const SizedBox(height: 16),
        _NextStepCard(opportunity: opportunity),
        if (opportunity.customRequirements.isNotEmpty) ...[const SizedBox(height: 16), _CustomRequirementsCard(opportunity: opportunity)],
        if (opportunity.keyFactors.isNotEmpty) ...[const SizedBox(height: 16), _KeyFactorsCard(opportunity: opportunity)],
        if (opportunity.lessonsLearned.isNotEmpty) ...[const SizedBox(height: 16), _LessonsLearnedCard(opportunity: opportunity)],
      ]),
    );
  }
}

class _StageProgressionCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _StageProgressionCard({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final stages = SalesStage.values;
    final currentIndex = stages.indexWhere((stage) => stage == opportunity.salesStage);

    return _InfoCard(
      icon: Icons.timeline,
      title: 'Stage Progression',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: isSmallScreen ? 120 : 80, child: ListView.builder(scrollDirection: isSmallScreen ? Axis.vertical : Axis.horizontal, itemCount: stages.length, itemBuilder: (context, index) {
          final stage = stages[index];
          final isCurrent = index == currentIndex;
          final isCompleted = index <= currentIndex;
          return isSmallScreen ? _buildVerticalStageItem(stage, isCurrent, isCompleted) : _buildHorizontalStageItem(stage, index, isCurrent, isCompleted);
        })),
        const SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Probability: ${opportunity.probability}%', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            Text(opportunity.probability >= 80 ? 'High Confidence' : opportunity.probability >= 50 ? 'Medium Confidence' : 'Low Confidence', style: TextStyle(color: opportunity.probabilityColor, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: opportunity.probability / 100, backgroundColor: Colors.grey[200], color: opportunity.probabilityColor, minHeight: 10, borderRadius: BorderRadius.circular(5)),
        ]),
      ]),
    );
  }

  Widget _buildHorizontalStageItem(SalesStage stage, int index, bool isCurrent, bool isCompleted) {
    return Row(children: [
      if (index > 0) Container(width: 50, height: 2, color: isCompleted ? stage.color : Colors.grey[300]),
      Column(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: isCurrent ? stage.color.withValues(alpha: 0.2) : isCompleted ? stage.color : Colors.grey[200], shape: BoxShape.circle, border: Border.all(color: isCurrent ? stage.color : Colors.transparent, width: 2)),
            child: Icon(stage.icon, size: 18, color: isCurrent ? stage.color : isCompleted ? Colors.white : Colors.grey[400])),
        const SizedBox(height: 8),
        SizedBox(width: 80, child: Text(stage.displayName, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? stage.color : Colors.grey[600]), maxLines: 2)),
      ]),
    ]);
  }

  Widget _buildVerticalStageItem(SalesStage stage, bool isCurrent, bool isCompleted) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: isCurrent ? stage.color.withValues(alpha: 0.2) : isCompleted ? stage.color : Colors.grey[200], shape: BoxShape.circle, border: Border.all(color: isCurrent ? stage.color : Colors.transparent, width: 2)),
          child: Icon(stage.icon, size: 18, color: isCurrent ? stage.color : isCompleted ? Colors.white : Colors.grey[400])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(stage.displayName, style: TextStyle(fontSize: 14, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? stage.color : Colors.grey[700])),
        if (isCurrent) Text('Current Stage', style: TextStyle(fontSize: 12, color: stage.color, fontWeight: FontWeight.w500)),
      ])),
    ]));
  }
}

class _KeyInfoGrid extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _KeyInfoGrid({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final gridData = [
      _GridItem(Icons.person, 'Assigned To', opportunity.assignedToName, Colors.blue),
      _GridItem(Icons.date_range, 'Created Date', DateFormat('dd MMM yyyy').format(opportunity.createdAt), Colors.green),
      _GridItem(Icons.update, 'Last Updated', DateFormat('dd MMM yyyy').format(opportunity.updatedAt), Colors.orange),
      _GridItem(Icons.calendar_today, 'Next Step Date', opportunity.nextStepDate != null ? DateFormat('dd MMM yyyy').format(opportunity.nextStepDate!) : 'Not set', Colors.purple),
      _GridItem(Icons.check_circle, 'Status', opportunity.isClosed ? 'Closed' : 'Active', opportunity.isClosed ? Colors.red : Colors.green),
      _GridItem(Icons.bar_chart, 'Pipeline Duration', '${opportunity.daysInPipeline} days', Colors.teal),
    ];

    return _InfoCard(title: 'Key Information', child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 2 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isSmallScreen ? 1.5 : 2
      ),
      itemCount: gridData.length,
      itemBuilder: (context, index) => _buildInfoGridItem(gridData[index]),
    ));
  }

  Widget _buildInfoGridItem(_GridItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: item.color.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Icon(item.icon, size: 16, color: item.color), const SizedBox(width: 8), Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey))]),
        const SizedBox(height: 8),
        Text(item.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item.color)),
      ]),
    );
  }
}

class _LeadInfoCard extends StatelessWidget {
  final Opportunity opportunity;
  const _LeadInfoCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final lead = opportunity.lead;
    final contact = lead?['contactDetails'] ?? {};

    return _InfoCard(icon: Icons.person_outline, title: 'Lead Information', iconColor: Colors.blue[700]!, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (lead != null) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ContactInfoItem('Name', '${contact['firstName'] ?? ''} ${contact['lastName'] ?? ''}'.trim()),
        _ContactInfoItem('Email', contact['email'] ?? 'Not available'),
        _ContactInfoItem('Phone', contact['phone'] ?? 'Not available'),
        _ContactInfoItem('Location', '${contact['city'] ?? ''}, ${contact['country'] ?? ''}'),
        if (lead['leadNumber'] != null) _ContactInfoItem('Lead Number', lead['leadNumber']),
      ]) else const Text('Lead information not available', style: TextStyle(color: Colors.grey)),
    ]));
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final Opportunity opportunity;
  const _CustomerInfoCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final customer = opportunity.customer;

    return _InfoCard(icon: Icons.business, title: 'Customer Information', iconColor: Colors.green[700]!, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (customer != null) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (customer['companyName'] != null) _ContactInfoItem('Company', customer['companyName']),
        _ContactInfoItem('Name', '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim()),
        _ContactInfoItem('Email', customer['email'] ?? 'Not available'),
        _ContactInfoItem('Phone', customer['phone'] ?? 'Not available'),
        if (customer['customerNumber'] != null) _ContactInfoItem('Customer Number', customer['customerNumber']),
        if (customer['customerType'] != null) _ContactInfoItem('Customer Type', customer['customerType'].toString().replaceAll('_', ' ').toUpperCase()),
      ]) else const Text('No customer assigned', style: TextStyle(color: Colors.grey)),
    ]));
  }
}

class _ContactInfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _ContactInfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : 'Not available',
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final Opportunity opportunity;
  const _NextStepCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.next_week, title: 'Next Step', iconColor: Colors.purple[700]!, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple[100]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(opportunity.nextStep, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.purple[800])),
        if (opportunity.nextStepDate != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.purple[600]),
            const SizedBox(width: 8),
            Text(DateFormat('EEEE, dd MMMM yyyy').format(opportunity.nextStepDate!), style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Text(_getDaysUntilNextStep(opportunity.nextStepDate!), style: TextStyle(color: _getNextStepColor(opportunity.nextStepDate!), fontWeight: FontWeight.bold)),
          ]),
        ],
      ]),
    ));
  }

  String _getDaysUntilNextStep(DateTime nextStepDate) {
    final difference = nextStepDate.difference(DateTime.now());
    final days = difference.inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days > 1) return 'In $days days';
    if (days == -1) return 'Yesterday';
    return '${days.abs()} days ago';
  }

  Color _getNextStepColor(DateTime nextStepDate) {
    final days = nextStepDate.difference(DateTime.now()).inDays;
    if (days < 0) return Colors.red;
    if (days == 0) return Colors.orange;
    if (days <= 2) return Colors.yellow[700]!;
    return Colors.green;
  }
}

class _CustomRequirementsCard extends StatelessWidget {
  final Opportunity opportunity;
  const _CustomRequirementsCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.checklist, title: 'Custom Requirements', iconColor: Colors.orange[700]!, child: Wrap(spacing: 8, runSpacing: 8, children: opportunity.customRequirements.map((req) {
      return Chip(label: Text(req), backgroundColor: Colors.orange[50], side: BorderSide(color: Colors.orange[100]!), labelStyle: TextStyle(color: Colors.orange[800]));
    }).toList()));
  }
}

class _KeyFactorsCard extends StatelessWidget {
  final Opportunity opportunity;
  const _KeyFactorsCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.flag, title: 'Key Factors', iconColor: Colors.teal[700]!, child: Wrap(spacing: 8, runSpacing: 8, children: opportunity.keyFactors.map((factor) {
      return Chip(label: Text(factor), backgroundColor: Colors.teal[50], side: BorderSide(color: Colors.teal[100]!), labelStyle: TextStyle(color: Colors.teal[800]), avatar: const Icon(Icons.star, size: 16));
    }).toList()));
  }
}

class _LessonsLearnedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _LessonsLearnedCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final title = opportunity.salesStage.isWon ? 'Win Factors' : 'Lessons Learned';

    return _InfoCard(icon: Icons.school, title: title, iconColor: Colors.red[700]!, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: opportunity.lessonsLearned.map((lesson) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.check_circle, size: 16, color: opportunity.salesStage.isWon ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Expanded(child: Text(lesson, style: TextStyle(color: Colors.grey[700]))),
      ]))).toList()),
      if (opportunity.winLossReason != null && opportunity.winLossReason!.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: opportunity.salesStage.isWon ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: opportunity.salesStage.isWon ? Colors.green[100]! : Colors.red[100]!)),
            child: Text(opportunity.winLossReason!, style: TextStyle(color: opportunity.salesStage.isWon ? Colors.green[800] : Colors.red[800]))),
      ],
    ]));
  }
}

class _FinancialsTab extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  final double chartHeight;
  const _FinancialsTab({required this.opportunity, required this.isSmallScreen, required this.chartHeight});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: EdgeInsets.all(isSmallScreen ? 12 : 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FinancialSummaryCard(opportunity: opportunity, isSmallScreen: isSmallScreen),
      if (opportunity.proposedServices.isNotEmpty) ...[const SizedBox(height: 16), _ProposedServicesCard(opportunity: opportunity)],
      const SizedBox(height: 16),
      _RevenueChartCard(opportunity: opportunity, isSmallScreen: isSmallScreen, chartHeight: chartHeight),
      const SizedBox(height: 16),
      _FinancialMetricsCard(opportunity: opportunity, isSmallScreen: isSmallScreen),
    ]));
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _FinancialSummaryCard({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
        icon: Icons.attach_money,
        title: 'Financial Summary',
        iconColor: Colors.green[700]!,
        child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isVerySmall = width < 400;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isVerySmall ? 1 : (isSmallScreen ? 2 : 2),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isVerySmall ? 2.5 : (isSmallScreen ? 2.8 : 3),
                ),
                itemCount: 4,
                itemBuilder: (context, index) => switch (index) {
                  0 => _buildFinancialMetric('Estimated Value', opportunity.valueFormatted, Icons.assessment, Colors.blue),
                  1 => _buildFinancialMetric('Expected Revenue', opportunity.revenueFormatted, Icons.trending_up, Colors.green),
                  2 => _buildFinancialMetric('Probability', '${opportunity.probability}%', Icons.star, opportunity.probabilityColor),
                  3 => _buildFinancialMetric('Pipeline Value', 'KES ${opportunity.expectedRevenue.toStringAsFixed(2)}', Icons.show_chart, Colors.orange),
                  _ => const SizedBox(),
                },
              );
            }
        )
    );
  }

  Widget _buildFinancialMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                          maxLines: 1,
                        ),
                      ),
                    ]
                )
            ),
          ]
      ),
    );
  }
}

class _ProposedServicesCard extends StatelessWidget {
  final Opportunity opportunity;
  const _ProposedServicesCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final services = opportunity.proposedServices;
    final totalValue = services.fold(0.0, (sum, service) => sum + service.totalPrice);

    return _InfoCard(
        icon: Icons.list_alt,
        title: 'Proposed Services',
        iconColor: Colors.purple[700]!,
        child: Column(children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(16)),
              child: Text(
                  'KES ${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.bold)
              )
          ),
          const SizedBox(height: 16),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) => _buildServiceItem(services[index])
          ),
        ])
    );
  }

  Widget _buildServiceItem(ProposedService service) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.build, color: Colors.blue[700], size: 20)
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceType.displayName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                        service.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis
                    ),
                  ]
              )
          ),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                      'KES ${service.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                    '${service.quantity} × KES ${service.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)
                ),
              ]
          ),
        ])
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  final double chartHeight;
  const _RevenueChartCard({required this.opportunity, required this.isSmallScreen, required this.chartHeight});

  @override
  Widget build(BuildContext context) {
    final stages = SalesStage.values;
    final data = stages.map((stage) => _ChartData(stage.displayName, stage == opportunity.salesStage ? opportunity.expectedRevenue : 0, stage.color)).toList();

    return _InfoCard(title: 'Revenue Projection by Stage', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: chartHeight, child: SfCartesianChart(
        margin: EdgeInsets.zero,
        primaryXAxis: CategoryAxis(labelStyle: const TextStyle(fontSize: 10), labelRotation: isSmallScreen ? 45 : 0),
        primaryYAxis: NumericAxis(labelStyle: const TextStyle(fontSize: 10), numberFormat: NumberFormat.compactCurrency(symbol: 'KES ')),
        series: <ColumnSeries<_ChartData, String>>[
          ColumnSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            pointColorMapper: (_ChartData data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 10), labelAlignment: ChartDataLabelAlignment.top),
          ),
        ],
      )),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Row(children: [
        Icon(Icons.info, color: Colors.blue[700], size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('Expected revenue shown for current stage. Revenue changes as opportunity progresses through stages.', style: TextStyle(fontSize: 12, color: Colors.blue[800]))),
      ])),
    ]));
  }
}

class _FinancialMetricsCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _FinancialMetricsCard({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
        title: 'Financial Metrics',
        child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isVerySmall = width < 400;
              final isMedium = width >= 400 && width < 600;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isVerySmall ? 2 : (isMedium ? 3 : (isSmallScreen ? 4 : 4)),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isVerySmall ? 1.2 : (isMedium ? 1.4 : 1.5),
                ),
                itemCount: 8,
                itemBuilder: (context, index) => _buildMetricItem(index, opportunity),
              );
            }
        )
    );
  }

  Widget _buildMetricItem(int index, Opportunity opportunity) {
    final item = switch (index) {
      0 => _MetricItem('ROI Potential', '${(opportunity.expectedRevenue / (opportunity.estimatedValue * 0.3)).toStringAsFixed(1)}x', Icons.auto_graph, Colors.green),
      1 => _MetricItem('Margin', '${((opportunity.expectedRevenue - (opportunity.estimatedValue * 0.4)) / opportunity.expectedRevenue * 100).toStringAsFixed(1)}%', Icons.percent, Colors.blue),
      2 => _MetricItem('Risk Level', opportunity.probability >= 80 ? 'Low' : opportunity.probability >= 50 ? 'Medium' : 'High', Icons.warning, opportunity.probability >= 80 ? Colors.green : opportunity.probability >= 50 ? Colors.orange : Colors.red),
      3 => _MetricItem('Deal Size', opportunity.estimatedValue > 100000 ? 'Large' : opportunity.estimatedValue > 50000 ? 'Medium' : 'Small', Icons.scale, opportunity.estimatedValue > 100000 ? Colors.purple : opportunity.estimatedValue > 50000 ? Colors.blue : Colors.green),
      4 => _MetricItem('Time to Close', '${opportunity.daysInPipeline} days', Icons.timer, Colors.orange),
      5 => _MetricItem('Win Probability', '${opportunity.probability}%', Icons.emoji_events, opportunity.probabilityColor),
      6 => _MetricItem('Value per Day', 'KES ${(opportunity.expectedRevenue / opportunity.daysInPipeline).toStringAsFixed(2)}', Icons.timeline, Colors.teal),
      7 => _MetricItem('Conversion Score', '${((opportunity.probability * opportunity.daysInPipeline) / 100).toStringAsFixed(1)}', Icons.score, Colors.indigo),
      _ => _MetricItem('', '', Icons.circle, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: item.color.withValues(alpha: 0.3))
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 18, color: item.color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.color),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ]
      ),
    );
  }
}

class _CompetitionTab extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  final VoidCallback onAddCompetitor;
  const _CompetitionTab({required this.opportunity, required this.isSmallScreen, required this.onAddCompetitor});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: EdgeInsets.all(isSmallScreen ? 12 : 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompetitiveAdvantageCard(opportunity: opportunity),
      const SizedBox(height: 16),
      _CompetitorsCard(opportunity: opportunity, onAddCompetitor: onAddCompetitor),
    ]));
  }
}

class _CompetitiveAdvantageCard extends StatelessWidget {
  final Opportunity opportunity;
  const _CompetitiveAdvantageCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.emoji_events, title: 'Competitive Advantage', iconColor: Colors.green[700]!, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[100]!)),
      child: Text(opportunity.competitiveAdvantage ?? 'No competitive advantage specified', style: TextStyle(color: Colors.green[800], fontSize: opportunity.competitiveAdvantage == null ? 14 : 16, fontStyle: opportunity.competitiveAdvantage == null ? FontStyle.italic : FontStyle.normal)),
    ));
  }
}

class _CompetitorsCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onAddCompetitor;
  const _CompetitorsCard({required this.opportunity, required this.onAddCompetitor});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.group, title: 'Competitors', iconColor: Colors.red[700]!, child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)), child: Text('${opportunity.competitors.length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))),
      const SizedBox(height: 16),
      if (opportunity.competitors.isEmpty) Container(padding: const EdgeInsets.all(40), child: Column(children: [
        Icon(Icons.group_off, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text('No competitors identified', style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Add competitors to track competition in this opportunity', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ])) else ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: opportunity.competitors.length, separatorBuilder: (context, index) => const SizedBox(height: 16), itemBuilder: (context, index) => _CompetitorCard(competitor: opportunity.competitors[index], index: index + 1)),
      const SizedBox(height: 16),
      Center(child: ElevatedButton.icon(onPressed: onAddCompetitor, icon: const Icon(Icons.add, size: 16), label: const Text('Add Competitor'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white))),
    ]));
  }
}

class _CompetitorCard extends StatelessWidget {
  final Competitor competitor;
  final int index;
  const _CompetitorCard({required this.competitor, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[100]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)), child: Center(child: Text(index.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                competitor.name ?? 'Unnamed Competitor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[800]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isVerySmall = width < 300;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isVerySmall ? 1 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isVerySmall ? 4 : 3,
                  ),
                  itemCount: 3,
                  itemBuilder: (context, index) => switch (index) {
                    0 => _buildCompetitorDetail('Strengths', competitor.strength, Icons.add_circle, Colors.green),
                    1 => _buildCompetitorDetail('Weaknesses', competitor.weakness, Icons.remove_circle, Colors.red),
                    2 => _buildCompetitorDetail('Our Advantage', competitor.ourAdvantage, Icons.emoji_events, Colors.blue),
                    _ => const SizedBox(),
                  },
                );
              }
          ),
        ])
    );
  }

  Widget _buildCompetitorDetail(String label, String? value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        ]),
        const SizedBox(height: 4),
        Expanded(
          child: Text(
              value ?? 'Not specified',
              style: TextStyle(fontSize: 9, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis
          ),
        ),
      ]),
    );
  }
}

class _DecisionMakersTab extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  final VoidCallback onAddDecisionMaker;
  const _DecisionMakersTab({required this.opportunity, required this.isSmallScreen, required this.onAddDecisionMaker});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: EdgeInsets.all(isSmallScreen ? 12 : 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _DecisionProcessCard(opportunity: opportunity, isSmallScreen: isSmallScreen),
      const SizedBox(height: 16),
      _DecisionMakersCard(opportunity: opportunity, onAddDecisionMaker: onAddDecisionMaker),
    ]));
  }
}

class _DecisionProcessCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _DecisionProcessCard({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final process = opportunity.decisionProcess;
    final items = [
      _ProcessDetail('Process', process.process ?? 'Not specified', Icons.timeline, Colors.blue),
      _ProcessDetail('Timeline', process.timeline ?? 'Not specified', Icons.schedule, Colors.green),
      _ProcessDetail('Approval Levels', '${process.approvalLevels} levels', Icons.layers, Colors.orange),
      _ProcessDetail('Approval Required', process.approvalRequired ? 'Yes' : 'No', Icons.check_circle, process.approvalRequired ? Colors.green : Colors.grey),
    ];

    return _InfoCard(
        icon: Icons.gavel,
        title: 'Decision Process',
        iconColor: Colors.purple[700]!,
        child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isVerySmall = width < 400;

              return Column(children: [
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isVerySmall ? 1 : (isSmallScreen ? 2 : 2),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isVerySmall ? 2.5 : (isSmallScreen ? 2.8 : 3),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildProcessDetail(items[index])
                ),
                if (process.decisionDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple[100]!)),
                      child: Row(children: [
                        Icon(Icons.calendar_today, color: Colors.purple[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Decision Date',
                                    style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    DateFormat('EEEE, dd MMMM yyyy').format(process.decisionDate!),
                                    style: const TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ]
                            )
                        ),
                      ])
                  ),
                ],
              ]);
            }
        )
    );
  }

  Widget _buildProcessDetail(_ProcessDetail detail) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: detail.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: detail.color.withValues(alpha: 0.3))
        ),
        child: Row(children: [
          Icon(detail.icon, size: 20, color: detail.color),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detail.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        detail.value,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: detail.color),
                        maxLines: 1,
                      ),
                    ),
                  ]
              )
          ),
        ])
    );
  }
}

class _DecisionMakersCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onAddDecisionMaker;
  const _DecisionMakersCard({required this.opportunity, required this.onAddDecisionMaker});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: Icons.people, title: 'Decision Makers', iconColor: Colors.indigo[700]!, child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(12)), child: Text('${opportunity.decisionMakers.length}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12))),
      const SizedBox(height: 16),
      if (opportunity.decisionMakers.isEmpty) Container(padding: const EdgeInsets.all(40), child: Column(children: [
        Icon(Icons.person_off, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text('No decision makers identified', style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Add decision makers to track influence and attitude', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ])) else ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: opportunity.decisionMakers.length, separatorBuilder: (context, index) => const SizedBox(height: 16), itemBuilder: (context, index) => _DecisionMakerCard(maker: opportunity.decisionMakers[index], index: index + 1)),
      const SizedBox(height: 16),
      Center(child: ElevatedButton.icon(onPressed: onAddDecisionMaker, icon: const Icon(Icons.person_add, size: 16), label: const Text('Add Decision Maker'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white))),
    ]));
  }
}

class _DecisionMakerCard extends StatelessWidget {
  final DecisionMaker maker;
  final int index;
  const _DecisionMakerCard({required this.maker, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo[100]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(index.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maker.name ?? 'Unnamed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maker.title ?? 'No title',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ]
                )
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: maker.attitude.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: maker.attitude.color.withValues(alpha: 0.3))),
                  child: Text(
                    maker.attitude.displayName,
                    style: TextStyle(color: maker.attitude.color, fontSize: 10, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
              ),
              const SizedBox(height: 4),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey[100]!)),
                  child: Text(
                    maker.influence.displayName,
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
              ),
            ]),
          ]),
          const SizedBox(height: 12),
          Divider(color: Colors.indigo[100]),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.contact_phone, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                  maker.contactInfo ?? 'No contact info',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
            ),
          ]),
        ])
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _TimelineTab({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final events = [
      _TimelineEvent('Opportunity Created', opportunity.createdAt, Icons.add_circle, Colors.green, 'Opportunity ${opportunity.opportunityNumber} was created'),
      if (opportunity.nextStepDate != null) _TimelineEvent('Next Step Scheduled', opportunity.nextStepDate!, Icons.schedule, Colors.blue, 'Next step: ${opportunity.nextStep}'),
      if (opportunity.closeDate != null) _TimelineEvent('Opportunity ${opportunity.salesStage.isWon ? 'Won' : 'Lost'}', opportunity.closeDate!, opportunity.salesStage.isWon ? Icons.emoji_events : Icons.cancel, opportunity.salesStage.isWon ? Colors.green : Colors.red, opportunity.winLossReason ?? 'Opportunity closed'),
      _TimelineEvent('Last Updated', opportunity.updatedAt, Icons.update, Colors.orange, 'Last updated on ${DateFormat('dd MMM yyyy').format(opportunity.updatedAt)}'),
    ];

    return SingleChildScrollView(padding: EdgeInsets.all(isSmallScreen ? 12 : 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TimelineCard(events: events),
      const SizedBox(height: 16),
      _ActivitySummaryCard(opportunity: opportunity, isSmallScreen: isSmallScreen),
    ]));
  }
}

class _TimelineCard extends StatelessWidget {
  final List<_TimelineEvent> events;
  const _TimelineCard({required this.events});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(title: 'Opportunity Timeline', child: events.isEmpty ? Container(padding: const EdgeInsets.all(40), child: Column(children: [
      Icon(Icons.timeline, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 16),
      const Text('No timeline events', style: TextStyle(color: Colors.grey, fontSize: 16)),
    ])) : Column(children: events.map((event) => _buildTimelineEvent(event)).toList()));
  }

  Widget _buildTimelineEvent(_TimelineEvent event) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: event.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: event.color)), child: Icon(event.icon, color: event.color, size: 20)),
        Container(width: 2, height: 20, color: Colors.grey[300]),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: event.color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            DateFormat('dd MMM yyyy').format(event.date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ]),
        const SizedBox(height: 8),
        Text(event.description, style: TextStyle(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis, maxLines: 2),
        const SizedBox(height: 4),
        Text(DateFormat('h:mm a').format(event.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]))),
    ]));
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isSmallScreen;
  const _ActivitySummaryCard({required this.opportunity, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final daysInPipeline = opportunity.daysInPipeline;
    final stageDuration = daysInPipeline / SalesStage.values.length;

    return _InfoCard(
        title: 'Activity Summary',
        child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isVerySmall = width < 400;
              final isMedium = width >= 400 && width < 600;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isVerySmall ? 1 : (isMedium ? 2 : (isSmallScreen ? 2 : 2)),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isVerySmall ? 2.5 : (isMedium ? 2.8 : 3),
                ),
                itemCount: 4,
                itemBuilder: (context, index) => switch (index) {
                  0 => _buildActivityMetric('Days in Pipeline', '$daysInPipeline days', Icons.timelapse, Colors.blue),
                  1 => _buildActivityMetric('Stage Duration', '${stageDuration.toStringAsFixed(1)} days', Icons.speed, Colors.green),
                  2 => _buildActivityMetric('Update Frequency', '${(daysInPipeline / 3).toStringAsFixed(1)} days', Icons.update, Colors.orange),
                  3 => _buildActivityMetric('Pipeline Velocity', '${(opportunity.estimatedValue / daysInPipeline).toStringAsFixed(2)}/day', Icons.trending_up, Colors.purple),
                  _ => const SizedBox(),
                },
              );
            }
        )
    );
  }

  Widget _buildActivityMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                          maxLines: 1,
                        ),
                      ),
                    ]
                )
            ),
          ]
      ),
    );
  }
}

// Helper Widgets and Classes
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  const _InfoCard({required this.title, this.icon, this.iconColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 20),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _GridItem(this.icon, this.label, this.value, this.color);
}

class _ChartData {
  final String x;
  final double y;
  final Color color;
  const _ChartData(this.x, this.y, this.color);
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricItem(this.label, this.value, this.icon, this.color);
}

class _ProcessDetail {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ProcessDetail(this.label, this.value, this.icon, this.color);
}

class _TimelineEvent {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String description;
  const _TimelineEvent(this.title, this.date, this.icon, this.color, this.description);
}