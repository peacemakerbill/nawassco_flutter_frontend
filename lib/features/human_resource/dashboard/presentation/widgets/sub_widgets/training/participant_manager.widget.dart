import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../models/employee_model.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/employee_provider.dart';
import '../../../../../providers/training.provider.dart';

class ParticipantManager extends ConsumerStatefulWidget {
  final Training training;

  const ParticipantManager({super.key, required this.training});

  @override
  ConsumerState<ParticipantManager> createState() => _ParticipantManagerState();
}

class _ParticipantManagerState extends ConsumerState<ParticipantManager> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, ParticipantStatus> _statusUpdates = {};
  final Map<String, String> _feedbackUpdates = {};
  final Map<String, Map<String, double>> _scoreUpdates = {};
  bool _showAddParticipant = false;
  String? _selectedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final participants = widget.training.participants;
    final employees = ref.watch(employeeProvider).employees;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Participants'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _showAddParticipant = true),
              tooltip: 'Add Participant',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAllChanges,
              tooltip: 'Save Changes',
            ),
          ],
        ),
        body: Column(
          children: [
            // Summary stats
            _buildSummaryStats(),

            // Participants list
            Expanded(
              child: participants.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No participants registered',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return _buildParticipantCard(participant);
                },
              ),
            ),
          ],
        ),

        // Add participant dialog
        // if(_showAddParticipant) _buildAddParticipantDialog(employees),
    );
  }

  Widget _buildSummaryStats() {
    final participants = widget.training.participants;
    final completed = participants.where((p) => p.status == ParticipantStatus.completed).length;
    final attended = participants.where((p) => p.status == ParticipantStatus.attended).length;
    final registered = participants.where((p) => p.status == ParticipantStatus.registered).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', participants.length.toString(), Colors.blue),
          _buildStatItem('Registered', registered.toString(), Colors.blue),
          _buildStatItem('Attended', attended.toString(), Colors.orange),
          _buildStatItem('Completed', completed.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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

  Widget _buildParticipantCard(TrainingParticipant participant) {
    final currentStatus = _statusUpdates[participant.id] ?? participant.status;
    final currentFeedback = _feedbackUpdates[participant.id] ?? participant.feedback;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: participant.statusColor.withOpacity(0.2),
                  child: Text(
                    participant.employeeName[0],
                    style: TextStyle(
                      color: participant.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${participant.employeeNumber} • ${participant.department}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      if (participant.jobTitle != null)
                        Text(
                          participant.jobTitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<ParticipantStatus>(
                  onSelected: (status) {
                    setState(() {
                      _statusUpdates[participant.id] = status;
                    });
                  },
                  itemBuilder: (context) {
                    return ParticipantStatus.values.map((status) {
                      return PopupMenuItem<ParticipantStatus>(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getStatusText(currentStatus),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(currentStatus),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Registration date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Registered: ${DateFormat('dd MMM yyyy').format(participant.registrationDate)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Scores row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: participant.preTrainingScore?.toStringAsFixed(1) ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Pre-Training Score',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.score, size: 18),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final score = double.tryParse(value);
                      if (score != null) {
                        _scoreUpdates[participant.id] = {
                          ..._scoreUpdates[participant.id] ?? {},
                          'preTrainingScore': score,
                        };
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: participant.postTrainingScore?.toStringAsFixed(1) ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Post-Training Score',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.score, size: 18),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final score = double.tryParse(value);
                      if (score != null) {
                        _scoreUpdates[participant.id] = {
                          ..._scoreUpdates[participant.id] ?? {},
                          'postTrainingScore': score,
                        };
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Feedback
            TextFormField(
              initialValue: currentFeedback ?? '',
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment, size: 18),
              ),
              maxLines: 2,
              onChanged: (value) {
                _feedbackUpdates[participant.id] = value;
              },
            ),

            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                if (participant.certificateUrl == null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _uploadCertificate(participant),
                      icon: const Icon(Icons.assignment_turned_in, size: 18),
                      label: const Text('Upload Certificate'),
                    ),
                  ),
                if (participant.certificateUrl == null) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveParticipantChanges(participant),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Changes'),
                  ),
                ),
              ],
            ),

            // Certificate status
            if (participant.certificateUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Certificate issued',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // View certificate
                      },
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddParticipantDialog(List<Employee> employees) {
    final availableEmployees = employees.where((employee) {
      return !widget.training.participants.any((p) => p.employeeId == employee.id);
    }).toList();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Participant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEmployeeId,
              decoration: const InputDecoration(
                labelText: 'Select Employee',
                border: OutlineInputBorder(),
              ),
              items: availableEmployees.map((employee) {
                return DropdownMenuItem<String>(
                  value: employee.id,
                  child: Text('${employee.fullName} (${employee.id})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEmployeeId = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _showAddParticipant = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedEmployeeId != null ? _addParticipant : null,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addParticipant() async {
    if (_selectedEmployeeId == null) return;

    // final success = await ref.read(trainingProvider.notifier).registerParticipant(
    //   widget.training.id,
    //   _selectedEmployeeId!,
    // );
    //
    // if (success) {
    //   setState(() {
    //     _showAddParticipant = false;
    //     _selectedEmployeeId = null;
    //   });
    // }
  }

  Future<void> _saveParticipantChanges(TrainingParticipant participant) async {
    final status = _statusUpdates[participant.id];
    final feedback = _feedbackUpdates[participant.id];
    final scores = _scoreUpdates[participant.id];

    if (status == null && feedback == null && scores == null) return;

    final success = await ref.read(trainingProvider.notifier).updateParticipantStatus(
      widget.training.id,
      participant.employeeId,
      status?.toString().split('.').last ?? participant.status.toString().split('.').last,
      feedback: feedback,
      preScore: scores?['preTrainingScore'],
      postScore: scores?['postTrainingScore'],
    );

    if (success) {
      // Clear local updates
      _statusUpdates.remove(participant.id);
      _feedbackUpdates.remove(participant.id);
      _scoreUpdates.remove(participant.id);
    }
  }

  Future<void> _saveAllChanges() async {
    for (final participant in widget.training.participants) {
      await _saveParticipantChanges(participant);
    }
  }

  Future<void> _uploadCertificate(TrainingParticipant participant) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await ref.read(trainingProvider.notifier).uploadCertificate(
        widget.training.id,
        participant.employeeId,
        file,
      );
    }
  }

  String _getStatusText(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.registered: return 'Registered';
      case ParticipantStatus.attended: return 'Attended';
      case ParticipantStatus.completed: return 'Completed';
      case ParticipantStatus.no_show: return 'No Show';
      case ParticipantStatus.cancelled: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  Color _getStatusColor(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.registered: return Colors.blue;
      case ParticipantStatus.attended: return Colors.orange;
      case ParticipantStatus.completed: return Colors.green;
      case ParticipantStatus.no_show: return Colors.red;
      case ParticipantStatus.cancelled: return Colors.grey;
      default: return Colors.grey;
    }
  }
}