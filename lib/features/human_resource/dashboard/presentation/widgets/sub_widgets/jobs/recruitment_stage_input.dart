import 'package:flutter/material.dart';
import '../../../../../models/job_model.dart';

class RecruitmentStageInput extends StatefulWidget {
  final List<RecruitmentStage> initialStages;
  final ValueChanged<List<RecruitmentStage>> onChanged;

  const RecruitmentStageInput({
    super.key,
    required this.initialStages,
    required this.onChanged,
  });

  @override
  State<RecruitmentStageInput> createState() => _RecruitmentStageInputState();
}

class _RecruitmentStageInputState extends State<RecruitmentStageInput> {
  final List<RecruitmentStage> _stages = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isMandatory = true;

  @override
  void initState() {
    super.initState();
    // Sort stages by stage number
    _stages.addAll(widget.initialStages);
    _stages.sort((a, b) => a.stageNumber.compareTo(b.stageNumber));
  }

  void _addStage() {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final duration = int.tryParse(_durationController.text) ?? 0;

    if (name.isNotEmpty && description.isNotEmpty && duration > 0) {
      final stage = RecruitmentStage(
        stageNumber: _stages.length + 1,
        name: name,
        description: description,
        estimatedDuration: duration,
        isMandatory: _isMandatory,
      );

      setState(() {
        _stages.add(stage);
        _clearForm();
        widget.onChanged(_stages);
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _durationController.clear();
    _isMandatory = true;
  }

  void _removeStage(int index) {
    setState(() {
      _stages.removeAt(index);
      // Re-number stages
      for (int i = 0; i < _stages.length; i++) {
        _stages[i] = _stages[i].copyWith(stageNumber: i + 1);
      }
      widget.onChanged(_stages);
    });
  }

  void _moveStageUp(int index) {
    if (index > 0) {
      setState(() {
        final temp = _stages[index];
        _stages[index] = _stages[index - 1].copyWith(stageNumber: index + 1);
        _stages[index - 1] = temp.copyWith(stageNumber: index);
        widget.onChanged(_stages);
      });
    }
  }

  void _moveStageDown(int index) {
    if (index < _stages.length - 1) {
      setState(() {
        final temp = _stages[index];
        _stages[index] = _stages[index + 1].copyWith(stageNumber: index + 1);
        _stages[index + 1] = temp.copyWith(stageNumber: index + 2);
        widget.onChanged(_stages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Stage Name*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.stacked_line_chart),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Duration (days)*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Mandatory Stage'),
                        value: _isMandatory,
                        onChanged: (value) {
                          setState(() {
                            _isMandatory = value ?? true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addStage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Add Recruitment Stage'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stages List
        if (_stages.isEmpty)
          const Center(
            child: Text(
              'No recruitment stages added yet',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else
          ..._stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    stage.stageNumber.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(stage.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stage.description),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${stage.estimatedDuration} days',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        if (!stage.isMandatory)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Text(
                              'Optional',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      onPressed: () => _moveStageUp(index),
                      tooltip: 'Move Up',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      onPressed: () => _moveStageDown(index),
                      tooltip: 'Move Down',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeStage(index),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}