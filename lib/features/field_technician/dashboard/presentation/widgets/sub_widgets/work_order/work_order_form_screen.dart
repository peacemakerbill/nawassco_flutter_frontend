import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/work_order_provider.dart';

class WorkOrderFormScreen extends ConsumerStatefulWidget {
  final String? workOrderId;
  final Function() onBack;
  final Function() onSave;

  const WorkOrderFormScreen({
    super.key,
    this.workOrderId,
    required this.onBack,
    required this.onSave,
  });

  @override
  ConsumerState<WorkOrderFormScreen> createState() =>
      _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends ConsumerState<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zoneController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _accessInstructionsController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _estimatedCostController = TextEditingController();

  WorkOrderType _selectedType = WorkOrderType.repair;
  WorkOrderPriority _selectedPriority = WorkOrderPriority.medium;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = false;
  bool _isEditing = false;
  WorkOrder? _existingWorkOrder;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.workOrderId != null;
    if (_isEditing) {
      _loadWorkOrder();
    }
  }

  void _loadWorkOrder() {
    final workOrderState = ref.read(workOrderProvider);
    final workOrder = workOrderState.selectedWorkOrder;

    if (workOrder != null && workOrder.id == widget.workOrderId) {
      _populateForm(workOrder);
    } else {
      ref
          .read(workOrderProvider.notifier)
          .getWorkOrderById(widget.workOrderId!)
          .then((_) {
        final updatedState = ref.read(workOrderProvider);
        if (updatedState.selectedWorkOrder != null) {
          _populateForm(updatedState.selectedWorkOrder!);
        }
      });
    }
  }

  void _populateForm(WorkOrder workOrder) {
    setState(() {
      _existingWorkOrder = workOrder;
      _titleController.text = workOrder.title;
      _descriptionController.text = workOrder.description;
      _selectedType = workOrder.type;
      _selectedPriority = workOrder.priority;
      _customerIdController.text = workOrder.customerId;
      _customerNameController.text = workOrder.customerName;
      _addressController.text = workOrder.location.address;
      _cityController.text = workOrder.location.city;
      _zoneController.text = workOrder.location.zone;
      _landmarkController.text = workOrder.location.landmark ?? '';
      _accessInstructionsController.text =
          workOrder.location.accessInstructions ?? '';
      _estimatedDurationController.text =
          workOrder.estimatedDuration.toString();
      _estimatedCostController.text = workOrder.estimatedCost.toString();
      _selectedDate = workOrder.scheduledDate;
      _selectedTime = TimeOfDay.fromDateTime(workOrder.scheduledDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_isEditing ? 'Edit Work Order' : 'Create Work Order'),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteWorkOrder,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Work Order Title *',
                                border: OutlineInputBorder(),
                                hintText:
                                    'e.g., Water Leak Repair at Main Street',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description *',
                                border: OutlineInputBorder(),
                                hintText:
                                    'Describe the work to be performed...',
                              ),
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<WorkOrderType>(
                                    value: _selectedType,
                                    decoration: const InputDecoration(
                                      labelText: 'Work Order Type *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: WorkOrderType.values.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type.displayName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<
                                      WorkOrderPriority>(
                                    value: _selectedPriority,
                                    decoration: const InputDecoration(
                                      labelText: 'Priority *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: WorkOrderPriority.values
                                        .map((priority) {
                                      return DropdownMenuItem(
                                        value: priority,
                                        child: Text(priority.displayName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedPriority = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customerIdController,
                              decoration: const InputDecoration(
                                labelText: 'Customer ID *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter customer ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter customer name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter city';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _zoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Zone *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter zone';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _landmarkController,
                              decoration: const InputDecoration(
                                labelText: 'Landmark (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _accessInstructionsController,
                              decoration: const InputDecoration(
                                labelText: 'Access Instructions (optional)',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., Gate code, floor number, etc.',
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scheduling',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _selectDate,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.calendar_today),
                                        const SizedBox(width: 8),
                                        Text(_formatDate(_selectedDate)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _selectTime,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.access_time),
                                        const SizedBox(width: 8),
                                        Text(_formatTime(_selectedTime)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _estimatedDurationController,
                              decoration: const InputDecoration(
                                labelText: 'Estimated Duration (minutes) *',
                                border: OutlineInputBorder(),
                                suffixText: 'minutes',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter estimated duration';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _estimatedCostController,
                              decoration: const InputDecoration(
                                labelText: 'Estimated Cost *',
                                border: OutlineInputBorder(),
                                prefixText: 'KES ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter estimated cost';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Note: Actual costs will be calculated based on labor and materials used during the work.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Update Work Order'
                                    : 'Create Work Order',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final scheduledDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final workOrderData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'workOrderType': _selectedType.apiValue,
          'priority': _selectedPriority.apiValue,
          'customer': _customerIdController.text,
          'customerName': _customerNameController.text,
          'location': {
            'address': _addressController.text,
            'city': _cityController.text,
            'zone': _zoneController.text,
            'landmark': _landmarkController.text.isNotEmpty
                ? _landmarkController.text
                : null,
            'accessInstructions': _accessInstructionsController.text.isNotEmpty
                ? _accessInstructionsController.text
                : null,
          },
          'coordinates': {
            'latitude': -1.2921,
            'longitude': 36.8219,
          },
          'estimatedDuration': int.parse(_estimatedDurationController.text),
          'scheduledDate': scheduledDateTime.toIso8601String(),
          'estimatedCost': double.parse(_estimatedCostController.text),
          'createdBy': 'current_user_id',
        };

        final success = _isEditing
            ? await ref.read(workOrderProvider.notifier).updateWorkOrder(
                  widget.workOrderId!,
                  workOrderData,
                )
            : await ref.read(workOrderProvider.notifier).createWorkOrder(
                  WorkOrder.fromJson(workOrderData),
                );

        if (success) {
          widget.onSave();
        }
      } catch (e) {
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _deleteWorkOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Work Order'),
        content: const Text(
            'Are you sure you want to delete this work order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(workOrderProvider.notifier)
        .deleteWorkOrder(widget.workOrderId!);

    if (success) {
      widget.onBack();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customerIdController.dispose();
    _customerNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zoneController.dispose();
    _landmarkController.dispose();
    _accessInstructionsController.dispose();
    _estimatedDurationController.dispose();
    _estimatedCostController.dispose();
    super.dispose();
  }
}
