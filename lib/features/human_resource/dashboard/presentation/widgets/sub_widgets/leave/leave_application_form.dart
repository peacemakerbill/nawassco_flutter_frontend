import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/leave/leave_application.dart';
import '../../../../../providers/employee_provider.dart';
import '../../../../../providers/leave_provider.dart';

class LeaveApplicationForm extends ConsumerStatefulWidget {
  final LeaveApplication? initialData;
  final VoidCallback? onSuccess;

  const LeaveApplicationForm({
    super.key,
    this.initialData,
    this.onSuccess,
  });

  @override
  ConsumerState<LeaveApplicationForm> createState() =>
      _LeaveApplicationFormState();
}

class _LeaveApplicationFormState extends ConsumerState<LeaveApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  late LeaveType _selectedLeaveType;
  late DateTime _startDate;
  late DateTime _endDate;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _handoverNotesController =
      TextEditingController();
  String? _selectedHandoverTo;
  final List<String> _urgentTasks = [];
  final TextEditingController _urgentTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLeaveType =
        widget.initialData?.leaveType ?? LeaveType.annual_leave;
    _startDate = widget.initialData?.startDate ?? DateTime.now();
    _endDate = widget.initialData?.endDate ??
        DateTime.now().add(
          const Duration(days: 1),
        );
    _reasonController.text = widget.initialData?.reason ?? '';
    _emergencyContactController.text =
        widget.initialData?.emergencyContact ?? '';
    _handoverNotesController.text = widget.initialData?.handoverNotes ?? '';
    _selectedHandoverTo = widget.initialData?.handoverToId;
    _urgentTasks.addAll(widget.initialData?.urgentTasks ?? []);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _emergencyContactController.dispose();
    _handoverNotesController.dispose();
    _urgentTaskController.dispose();
    super.dispose();
  }

  int _calculateTotalDays() {
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final employeeId = ref.read(employeeProvider).currentEmployee?.id;
      if (employeeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your employee profile first'),
          ),
        );
        return;
      }

      final leaveData = {
        'employee': employeeId,
        'leaveType': describeEnum(_selectedLeaveType),
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'reason': _reasonController.text.trim(),
        if (_emergencyContactController.text.isNotEmpty)
          'emergencyContact': _emergencyContactController.text.trim(),
        if (_handoverNotesController.text.isNotEmpty)
          'handoverNotes': _handoverNotesController.text.trim(),
        if (_selectedHandoverTo != null) 'handoverTo': _selectedHandoverTo,
        if (_urgentTasks.isNotEmpty) 'urgentTasks': _urgentTasks,
      };

      final success =
          await ref.read(leaveProvider.notifier).applyForLeave(leaveData);

      if (success && widget.onSuccess != null) {
        widget.onSuccess!();
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addUrgentTask() {
    final task = _urgentTaskController.text.trim();
    if (task.isNotEmpty && !_urgentTasks.contains(task)) {
      setState(() {
        _urgentTasks.add(task);
        _urgentTaskController.clear();
      });
    }
  }

  void _removeUrgentTask(String task) {
    setState(() {
      _urgentTasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveBalance = ref.watch(leaveProvider).leaveBalance;
    final availableBalance = leaveBalance?.getBalanceForType(
          describeEnum(_selectedLeaveType),
        ) ??
        0;
    final totalDays = _calculateTotalDays();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Type Selection
            const Text(
              'Leave Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LeaveType.values.map((type) {
                final isSelected = _selectedLeaveType == type;
                final balance = leaveBalance?.getBalanceForType(
                      describeEnum(type),
                    ) ??
                    0;

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 18,
                        color: isSelected ? Colors.white : type.color,
                      ),
                      const SizedBox(width: 6),
                      Text(type.displayName),
                      const SizedBox(width: 4),
                      Text(
                        '($balance)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLeaveType = type;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: type.color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? type.color : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Date Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy').format(_startDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy').format(_endDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total Days & Balance Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalDays ${totalDays == 1 ? 'day' : 'days'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      Text(
                        'Total Leave Days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$availableBalance days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: availableBalance >= totalDays
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (totalDays > availableBalance) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange[800],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Insufficient balance. You need ${totalDays - availableBalance} more days.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Leave *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason for leave';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Emergency Contact
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact (Optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Handover Notes
            TextFormField(
              controller: _handoverNotesController,
              decoration: const InputDecoration(
                labelText: 'Work Handover Notes (Optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Urgent Tasks
            const Text(
              'Urgent Tasks to Handover (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _urgentTaskController,
                    decoration: InputDecoration(
                      hintText: 'Add an urgent task',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addUrgentTask,
                      ),
                    ),
                    onFieldSubmitted: (_) => _addUrgentTask(),
                  ),
                ),
              ],
            ),

            if (_urgentTasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _urgentTasks.map((task) {
                  return Chip(
                    label: Text(task),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeUrgentTask(task),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Leave Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
