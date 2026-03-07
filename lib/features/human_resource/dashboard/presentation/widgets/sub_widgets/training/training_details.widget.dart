import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';
import 'certificate_upload.widget.dart';

class TrainingDetails extends ConsumerStatefulWidget {
  final Training training;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onManageParticipants;
  final VoidCallback? onUploadMaterials;
  final VoidCallback? onEvaluate;
  final bool showManagementActions;

  const TrainingDetails({
    super.key,
    required this.training,
    required this.onBack,
    this.onEdit,
    this.onManageParticipants,
    this.onUploadMaterials,
    this.onEvaluate,
    this.showManagementActions = false,
  });

  @override
  ConsumerState<TrainingDetails> createState() => _TrainingDetailsState();
}

class _TrainingDetailsState extends ConsumerState<TrainingDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.showManagementActions ? 5 : 4;
    _tabController = TabController(length: tabCount, vsync: this);

    // Refresh training data when details are opened
    _refreshTraining();
  }

  Future<void> _refreshTraining() async {
    setState(() => _isLoading = true);
    await ref.read(trainingProvider.notifier).getTrainingById(widget.training.id);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updatedTraining = ref.watch(trainingProvider).selectedTraining ?? widget.training;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 200,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              actions: [
                if (widget.onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit Training',
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshTraining,
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareTraining,
                  tooltip: 'Share',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  updatedTraining.trainingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: _buildHeroBackground(updatedTraining),
              ),
            ),

            // Header Info
            SliverToBoxAdapter(
              child: _buildHeaderInfo(updatedTraining),
            ),

            // Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabController: _tabController,
                showManagementActions: widget.showManagementActions,
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          controller: _tabController,
          children: _buildTabViews(updatedTraining),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(updatedTraining),
    );
  }

  Widget _buildHeroBackground(Training training) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            training.statusColor.withValues(alpha: 0.8),
            training.statusColor.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Overlay pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/patterns/pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    training.trainingCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  training.formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(Training training) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                icon: Icons.people,
                value: '${training.totalParticipants}',
                label: 'Participants',
                color: Colors.blue,
              ),
              _buildHeaderStat(
                icon: Icons.event_seat,
                value: '${training.availableSlots}',
                label: 'Available',
                color: training.availableSlots > 0 ? Colors.green : Colors.red,
              ),
              _buildHeaderStat(
                icon: Icons.schedule,
                value: training.durationText,
                label: 'Duration',
                color: Colors.orange,
              ),
              _buildHeaderStat(
                icon: Icons.attach_money,
                value: '${training.currency} ${training.cost.toStringAsFixed(0)}',
                label: 'Cost',
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registration Progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${training.totalParticipants}/${training.maxParticipants}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: training.progressPercentage / 100,
                backgroundColor: Colors.grey.shade200,
                color: _getProgressColor(training),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    training.availableSlots > 0
                        ? '${training.availableSlots} slots available'
                        : 'Fully booked',
                    style: TextStyle(
                      fontSize: 12,
                      color: training.availableSlots > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (training.registrationDeadline.isAfter(DateTime.now()))
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Closes ${DateFormat('dd MMM yyyy').format(training.registrationDeadline)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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

  List<Widget> _buildTabViews(Training training) {
    final tabs = [
      // Overview Tab
      _buildOverviewTab(training),

      // Schedule Tab
      _buildScheduleTab(training),

      // Participants Tab
      _buildParticipantsTab(training),

      // Materials Tab
      _buildMaterialsTab(training),
    ];

    // Add Evaluation tab for management view
    if (widget.showManagementActions) {
      tabs.add(_buildEvaluationTab(training));
    }

    return tabs;
  }

  Widget _buildOverviewTab(Training training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSection(
            title: 'Description',
            icon: Icons.description,
            child: Text(
              training.description,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),

          const SizedBox(height: 24),

          // Training Details
          _buildSection(
            title: 'Training Details',
            icon: Icons.info,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Training Type',
                  value: training.typeText,
                ),
                _buildDetailRow(
                  icon: Icons.group_work,
                  label: 'Category',
                  value: training.categoryText,
                ),
                _buildDetailRow(
                  icon: Icons.school,
                  label: 'Level',
                  value: training.levelText,
                ),
                _buildDetailRow(
                  icon: Icons.schedule,
                  label: 'Duration',
                  value: training.durationText,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Provider & Trainer
          _buildSection(
            title: 'Provider & Trainer',
            icon: Icons.business_center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.business,
                  label: 'Training Provider',
                  value: training.provider,
                ),
                _buildDetailRow(
                  icon: Icons.person,
                  label: 'Trainer',
                  value: training.trainer,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cost Information
          if (training.cost > 0)
            _buildSection(
              title: 'Cost Information',
              icon: Icons.attach_money,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.money,
                    label: 'Training Cost',
                    value: '${training.currency} ${training.cost.toStringAsFixed(2)}',
                  ),
                  if (training.cost > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Note: Cost may be covered by department budget. Please check with your manager.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(Training training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Dates
          _buildSection(
            title: 'Training Schedule',
            icon: Icons.calendar_today,
            child: Column(
              children: [
                _buildScheduleCard(
                  icon: Icons.event,
                  title: 'Training Period',
                  dates: '${DateFormat('dd MMM yyyy').format(training.startDate)} - ${DateFormat('dd MMM yyyy').format(training.endDate)}',
                  description: 'Full training duration',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildScheduleCard(
                  icon: Icons.event_busy,
                  title: 'Registration Deadline',
                  dates: DateFormat('dd MMM yyyy').format(training.registrationDeadline),
                  description: 'Last day to register',
                  color: training.registrationDeadline.isAfter(DateTime.now()) ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Venue Information
          _buildSection(
            title: 'Venue Details',
            icon: Icons.location_on,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.place, color: Colors.red),
                  title: const Text('Training Location'),
                  subtitle: Text(
                    training.venue,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _openMap(training.venue),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Daily Schedule (placeholder)
          _buildSection(
            title: 'Daily Schedule',
            icon: Icons.schedule,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Detailed daily schedule will be provided closer to the training date.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Request schedule
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Request Detailed Schedule'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab(Training training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Participants Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Participants Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${training.totalParticipants}/${training.maxParticipants}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: training.availableSlots > 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: [
                      _buildParticipantStat(
                        label: 'Registered',
                        value: training.participants
                            .where((p) => p.status == ParticipantStatus.registered)
                            .length
                            .toString(),
                        color: Colors.blue,
                      ),
                      _buildParticipantStat(
                        label: 'Attended',
                        value: training.participants
                            .where((p) => p.status == ParticipantStatus.attended)
                            .length
                            .toString(),
                        color: Colors.orange,
                      ),
                      _buildParticipantStat(
                        label: 'Completed',
                        value: training.participants
                            .where((p) => p.status == ParticipantStatus.completed)
                            .length
                            .toString(),
                        color: Colors.green,
                      ),
                      _buildParticipantStat(
                        label: 'Certificates',
                        value: training.participants
                            .where((p) => p.certificateUrl != null)
                            .length
                            .toString(),
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Manage Participants button (for managers)
          if (widget.onManageParticipants != null)
            ElevatedButton.icon(
              onPressed: widget.onManageParticipants,
              icon: const Icon(Icons.manage_accounts),
              label: const Text('Manage Participants'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

          const SizedBox(height: 16),

          // Participants List
          _buildSection(
            title: 'Participant List',
            icon: Icons.people,
            child: training.participants.isEmpty
                ? const Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No participants registered yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : Column(
              children: training.participants.take(10).map((participant) {
                return _buildParticipantListItem(participant);
              }).toList(),
            ),
          ),

          if (training.participants.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton.icon(
                  onPressed: widget.onManageParticipants,
                  icon: const Icon(Icons.more_horiz),
                  label: Text('View all ${training.participants.length} participants'),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(Training training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button for managers
          if (widget.onUploadMaterials != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: widget.onUploadMaterials,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Training Materials'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

          // Materials List
          if (training.materials.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No materials uploaded yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (widget.onUploadMaterials != null)
                    const Text(
                      'Upload presentations, documents, or other training materials',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            )
          else
            Column(
              children: [
                Text(
                  '${training.materials.length} material(s) available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...training.materials.map((material) {
                  return _buildMaterialCard(material);
                }).toList(),
              ],
            ),

          const SizedBox(height: 32),

          // Quick links section
          if (training.materials.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.download, size: 18),
                          label: const Text('Download All'),
                          onPressed: _downloadAllMaterials,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.print, size: 18),
                          label: const Text('Print Materials'),
                          onPressed: _printMaterials,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.share, size: 18),
                          label: const Text('Share Materials'),
                          onPressed: _shareMaterials,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluationTab(Training training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Rating
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          training.averageRating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getRatingColor(training.averageRating),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < training.averageRating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${training.averageRating.toStringAsFixed(1)} out of 5.0',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Evaluation Criteria
          if (training.evaluationCriteria.isNotEmpty)
            _buildSection(
              title: 'Evaluation Results',
              icon: Icons.assessment,
              child: Column(
                children: training.evaluationCriteria.map((criterion) {
                  return _buildCriterionCard(criterion);
                }).toList(),
              ),
            ),

          // Evaluate button
          if (widget.onEvaluate != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton.icon(
                onPressed: widget.onEvaluate,
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text('Evaluate Training'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
              ),
            ),

          if (training.evaluationCriteria.isEmpty && widget.onEvaluate == null)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.assessment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No evaluation data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(Training training) {
    if (widget.showManagementActions) {
      return FloatingActionButton.extended(
        onPressed: _showManagementOptions,
        icon: const Icon(Icons.more_vert),
        label: const Text('Manage'),
        backgroundColor: Colors.orange,
      );
    } else if (training.isOpenForRegistration && !training.isRegistered) {
      return FloatingActionButton.extended(
        onPressed: () => _registerForTraining(training),
        icon: const Icon(Icons.app_registration),
        label: const Text('Register Now'),
        backgroundColor: Colors.green,
      );
    } else if (training.isRegistered) {
      return FloatingActionButton.extended(
        onPressed: () => _showRegistrationDetails(),
        icon: const Icon(Icons.check_circle),
        label: const Text('Registered'),
        backgroundColor: Colors.blue,
      );
    }
    return const SizedBox.shrink();
  }

  // ========== HELPER WIDGETS ==========

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required IconData icon,
    required String title,
    required String dates,
    required String description,
    required Color color,
  }) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    dates,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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

  Widget _buildParticipantListItem(TrainingParticipant participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: participant.statusColor.withValues(alpha: 0.2),
          child: Text(
            participant.employeeName[0],
            style: TextStyle(
              color: participant.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(participant.employeeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(participant.department),
            Text(
              participant.statusText,
              style: TextStyle(
                fontSize: 12,
                color: participant.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: participant.certificateUrl != null
            ? const Icon(Icons.verified, color: Colors.green)
            : null,
      ),
    );
  }

  Widget _buildMaterialCard(TrainingMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(material.fileIcon, color: Colors.blue),
        ),
        title: Text(material.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${material.fileType} • ${DateFormat('dd MMM yyyy').format(material.uploadDate)}'),
            Text('Uploaded by: ${material.uploadedBy}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () => _downloadMaterial(material),
          tooltip: 'Download',
        ),
        onTap: () => _previewMaterial(material),
      ),
    );
  }

  Widget _buildCriterionCard(EvaluationCriterion criterion) {
    final score = criterion.averageScore;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  criterion.criterion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              color: _getScoreColor(score),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight: ${(criterion.weight * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _getScoreDescription(score),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== ACTION METHODS ==========

  void _showManagementOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Training'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.green),
                title: const Text('Manage Participants'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onManageParticipants?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.purple),
                title: const Text('Upload Materials'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onUploadMaterials?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in, color: Colors.orange),
                title: const Text('Upload Certificates'),
                onTap: _uploadCertificates,
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: Colors.teal),
                title: const Text('Evaluate Training'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEvaluate?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Training'),
                onTap: _confirmDelete,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerForTraining(Training training) async {
    final success = await ref.read(trainingProvider.notifier).registerForTraining(training.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for "${training.trainingTitle}"'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshTraining();
    }
  }

  void _showRegistrationDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registration Confirmed'),
          content: const Text(
            'You are successfully registered for this training. '
                'You will receive email notifications about any updates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to my trainings
              },
              child: const Text('View My Trainings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMap(String venue) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(venue)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _downloadMaterial(TrainingMaterial material) async {
    final url = Uri.parse(material.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _previewMaterial(TrainingMaterial material) async {
    // Implement material preview
  }

  void _downloadAllMaterials() {
    // Implement batch download
  }

  void _printMaterials() {
    // Implement print functionality
  }

  void _shareMaterials() {
    // Implement share functionality
  }

  void _uploadCertificates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: CertificateUpload(training: widget.training),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Training'),
          content: const Text('Are you sure you want to delete this training? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Call delete function from provider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Training deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
                widget.onBack();
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

  void _shareTraining() {
    // Implement share training functionality
  }

  // ========== HELPER METHODS ==========

  Color _getProgressColor(Training training) {
    if (training.availableSlots > training.maxParticipants * 0.5) {
      return Colors.green;
    } else if (training.availableSlots > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    return 'Needs Improvement';
  }
}

// Custom SliverPersistentHeaderDelegate for tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final bool showManagementActions;

  _TabBarDelegate({
    required this.tabController,
    required this.showManagementActions,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: [
          const Tab(text: 'Overview'),
          const Tab(text: 'Schedule'),
          const Tab(text: 'Participants'),
          const Tab(text: 'Materials'),
          if (showManagementActions) const Tab(text: 'Evaluation'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}