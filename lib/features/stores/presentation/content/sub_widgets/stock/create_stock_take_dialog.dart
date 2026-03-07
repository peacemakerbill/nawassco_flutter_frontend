import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../providers/stock_take_provider.dart';

class CreateStockTakeDialog extends ConsumerStatefulWidget {
  final VoidCallback? onStockTakeCreated;

  const CreateStockTakeDialog({super.key, this.onStockTakeCreated});

  @override
  ConsumerState<CreateStockTakeDialog> createState() =>
      _CreateStockTakeDialogState();
}

class _CreateStockTakeDialogState extends ConsumerState<CreateStockTakeDialog> {
  final _formKey = GlobalKey<FormState>();

  String _stockTakeType = 'cycle_count';
  DateTime _stockTakeDate = DateTime.now();
  String _warehouse = '';
  final List<String> _selectedZones = [];
  final List<TeamMemberForm> _teamMembers = [];
  String _notes = '';

  final _warehouseController = TextEditingController();
  final _zoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addDefaultTeamMember();
  }

  void _addDefaultTeamMember() {
    final authState = ref.read(authProvider);
    _teamMembers.add(TeamMemberForm(
      memberId: authState.user?['_id'] ?? '',
      role: 'supervisor',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Create Stock Take',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),

                      // Warehouse and Zones
                      _buildLocationSection(),
                      const SizedBox(height: 24),

                      // Counting Team
                      _buildTeamSection(authState),
                      const SizedBox(height: 24),

                      // Notes
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                        ),
                        child: const Text('Create Stock Take'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stockTakeType,
                    decoration: const InputDecoration(
                      labelText: 'Stock Take Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'cycle_count', child: Text('Cycle Count')),
                      DropdownMenuItem(
                          value: 'spot_check', child: Text('Spot Check')),
                      DropdownMenuItem(
                          value: 'full_count', child: Text('Full Count')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly Count')),
                      DropdownMenuItem(
                          value: 'quarterly', child: Text('Quarterly Count')),
                      DropdownMenuItem(
                          value: 'annual', child: Text('Annual Count')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _stockTakeType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputDatePickerFormField(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDate: _stockTakeDate,
                    fieldLabelText: 'Stock Take Date',
                    onDateSubmitted: (date) {
                      setState(() {
                        _stockTakeDate = date;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _warehouseController,
              decoration: const InputDecoration(
                labelText: 'Warehouse',
                border: OutlineInputBorder(),
                hintText: 'Enter warehouse name or code',
              ),
              onChanged: (value) {
                setState(() {
                  _warehouse = value;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a warehouse';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zoneController,
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      border: OutlineInputBorder(),
                      hintText: 'Enter zone name',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addZone,
                  child: const Text('Add Zone'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedZones.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedZones
                    .map((zone) => Chip(
                          label: Text(zone),
                          onDeleted: () => _removeZone(zone),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(AuthState authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Counting Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addTeamMember,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Member'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_teamMembers.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.people, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No team members added',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ..._teamMembers.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _TeamMemberRow(
                member: member,
                index: index,
                onRemove: _teamMembers.length > 1
                    ? () => _removeTeamMember(index)
                    : null,
                onUpdate: (updatedMember) {
                  setState(() {
                    _teamMembers[index] = updatedMember;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Any additional information about this stock take...',
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addZone() {
    final zone = _zoneController.text.trim();
    if (zone.isNotEmpty && !_selectedZones.contains(zone)) {
      setState(() {
        _selectedZones.add(zone);
        _zoneController.clear();
      });
    }
  }

  void _removeZone(String zone) {
    setState(() {
      _selectedZones.remove(zone);
    });
  }

  void _addTeamMember() {
    setState(() {
      _teamMembers.add(TeamMemberForm(role: 'counter'));
    });
  }

  void _removeTeamMember(int index) {
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedZones.isNotEmpty) {
      final stockTakeData = {
        'stockTakeType': _stockTakeType,
        'stockTakeDate': _stockTakeDate.toIso8601String(),
        'warehouse': _warehouse,
        'zones': _selectedZones,
        'countingTeam': _teamMembers.map((member) => member.toJson()).toList(),
        if (_notes.isNotEmpty) 'notes': _notes,
      };

      final authState = ref.read(authProvider);
      await ref.read(stockTakeProvider.notifier).createStockTake(
            stockTakeData,
            authState.user?['_id'] ?? '',
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onStockTakeCreated?.call();
      }
    }
  }
}

class TeamMemberForm {
  String memberId;
  String role;
  List<String> assignedZones;

  TeamMemberForm({
    required this.role,
    this.memberId = '',
    this.assignedZones = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'member': memberId,
      'role': role,
      'assignedZones': assignedZones,
    };
  }
}

class _TeamMemberRow extends StatefulWidget {
  final TeamMemberForm member;
  final int index;
  final VoidCallback? onRemove;
  final ValueChanged<TeamMemberForm> onUpdate;

  const _TeamMemberRow({
    required this.member,
    required this.index,
    this.onRemove,
    required this.onUpdate,
  });

  @override
  State<_TeamMemberRow> createState() => _TeamMemberRowState();
}

class _TeamMemberRowState extends State<_TeamMemberRow> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: widget.member.role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'supervisor', child: Text('Supervisor')),
                      DropdownMenuItem(
                          value: 'counter', child: Text('Counter')),
                      DropdownMenuItem(
                          value: 'verifier', child: Text('Verifier')),
                      DropdownMenuItem(
                          value: 'data_entry', child: Text('Data Entry')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        widget.member.role = value!;
                      });
                      widget.onUpdate(widget.member);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (widget.onRemove != null)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: widget.onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
