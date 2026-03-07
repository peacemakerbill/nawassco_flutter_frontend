import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../../core/utils/toast_utils.dart';
import '../../../../../../models/performance/performance_appraisal.model.dart';
import '../../../../../../providers/performance/performance_provider.dart';

class CreateAppraisalForm extends ConsumerStatefulWidget {
  final VoidCallback onCancel;
  final Function(PerformanceAppraisal) onSuccess;

  const CreateAppraisalForm({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  ConsumerState<CreateAppraisalForm> createState() => _CreateAppraisalFormState();
}

class _CreateAppraisalFormState extends ConsumerState<CreateAppraisalForm> {
  final _formKey = GlobalKey<FormState>();
  final _employeeController = TextEditingController();
  final _reviewerController = TextEditingController();
  final _hrReviewerController = TextEditingController();
  final _periodController = TextEditingController();
  final _appraisalDateController = TextEditingController();
  final _nextAppraisalDateController = TextEditingController();

  String? _selectedEmployeeId;
  String? _selectedReviewerId;
  String? _selectedHrReviewerId;
  DateTime? _appraisalDate;
  DateTime? _nextAppraisalDate;

  final List<Map<String, dynamic>> _keyPerformanceAreas = [];
  final List<Map<String, dynamic>> _competencies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(performanceProvider.notifier).fetchEmployeeList();
    });
  }

  @override
  void dispose() {
    _employeeController.dispose();
    _reviewerController.dispose();
    _hrReviewerController.dispose();
    _periodController.dispose();
    _appraisalDateController.dispose();
    _nextAppraisalDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performanceState = ref.watch(performanceProvider);
    final employeeList = performanceState.employeeList ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        title: const Text('Create Performance Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Card(
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Employee *',
                          border: OutlineInputBorder(),
                        ),
                        items: employeeList.map<DropdownMenuItem<String>>((employee) {
                          final name = '${employee['firstName']} ${employee['lastName']}';
                          return DropdownMenuItem<String>(
                            value: employee['_id'] as String,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployeeId = value;
                            final employee = employeeList.firstWhere(
                                  (e) => e['_id'] == value,
                              orElse: () => {},
                            );
                            if (employee.isNotEmpty) {
                              _employeeController.text = '${employee['firstName']} ${employee['lastName']}';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an employee';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _periodController,
                        decoration: const InputDecoration(
                          labelText: 'Appraisal Period *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Q4 2024, Annual 2024',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter appraisal period';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _appraisalDateController,
                              decoration: const InputDecoration(
                                labelText: 'Appraisal Date *',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select appraisal date';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nextAppraisalDateController,
                              decoration: const InputDecoration(
                                labelText: 'Next Appraisal Date *',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, false),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select next appraisal date';
                                }
                                return null;
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

              // Reviewers
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviewers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Primary Reviewer *',
                          border: OutlineInputBorder(),
                        ),
                        items: employeeList.map<DropdownMenuItem<String>>((employee) {
                          final name = '${employee['firstName']} ${employee['lastName']}';
                          return DropdownMenuItem<String>(
                            value: employee['_id'] as String,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReviewerId = value;
                            final employee = employeeList.firstWhere(
                                  (e) => e['_id'] == value,
                              orElse: () => {},
                            );
                            if (employee.isNotEmpty) {
                              _reviewerController.text = '${employee['firstName']} ${employee['lastName']}';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a reviewer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'HR Reviewer *',
                          border: OutlineInputBorder(),
                        ),
                        items: employeeList.map<DropdownMenuItem<String>>((employee) {
                          final name = '${employee['firstName']} ${employee['lastName']}';
                          return DropdownMenuItem<String>(
                            value: employee['_id'] as String,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedHrReviewerId = value;
                            final employee = employeeList.firstWhere(
                                  (e) => e['_id'] == value,
                              orElse: () => {},
                            );
                            if (employee.isNotEmpty) {
                              _hrReviewerController.text = '${employee['firstName']} ${employee['lastName']}';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select HR reviewer';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Key Performance Areas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Key Performance Areas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: _addKPA,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._keyPerformanceAreas.asMap().entries.map((entry) {
                        final index = entry.key;
                        final kpa = entry.value;
                        return _buildKPAItem(index, kpa);
                      }).toList(),
                      if (_keyPerformanceAreas.isEmpty)
                        const Center(
                          child: Text(
                            'No key performance areas added',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Competencies
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Competencies',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: _addCompetency,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._competencies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final competency = entry.value;
                        return _buildCompetencyItem(index, competency);
                      }).toList(),
                      if (_competencies.isEmpty)
                        const Center(
                          child: Text(
                            'No competencies added',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Create Performance Review',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isAppraisalDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isAppraisalDate) {
          _appraisalDate = picked;
          _appraisalDateController.text = _formatDate(picked);
        } else {
          _nextAppraisalDate = picked;
          _nextAppraisalDateController.text = _formatDate(picked);
        }
      });
    }
  }

  void _addKPA() {
    setState(() {
      _keyPerformanceAreas.add({
        'area': '',
        'weight': 0.0,
        'target': '',
        'achievement': '',
        'rating': 0.0,
        'comments': '',
      });
    });
  }

  void _addCompetency() {
    setState(() {
      _competencies.add({
        'competency': '',
        'description': '',
        'rating': 0.0,
        'examples': [],
      });
    });
  }

  Widget _buildKPAItem(int index, Map<String, dynamic> kpa) {
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
                  'KPA ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _keyPerformanceAreas.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: kpa['area'],
              decoration: const InputDecoration(
                labelText: 'Performance Area',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _keyPerformanceAreas[index]['area'] = value;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: kpa['weight'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Weight (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _keyPerformanceAreas[index]['weight'] = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: kpa['rating'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Rating (1-5)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _keyPerformanceAreas[index]['rating'] = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: kpa['target'],
              decoration: const InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _keyPerformanceAreas[index]['target'] = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: kpa['achievement'],
              decoration: const InputDecoration(
                labelText: 'Achievement',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _keyPerformanceAreas[index]['achievement'] = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: kpa['comments'],
              decoration: const InputDecoration(
                labelText: 'Comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _keyPerformanceAreas[index]['comments'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetencyItem(int index, Map<String, dynamic> competency) {
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
                  'Competency ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _competencies.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: competency['competency'],
              decoration: const InputDecoration(
                labelText: 'Competency Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _competencies[index]['competency'] = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: competency['description'],
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _competencies[index]['description'] = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: competency['rating'].toString(),
              decoration: const InputDecoration(
                labelText: 'Rating (1-5)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _competencies[index]['rating'] = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEmployeeId == null ||
          _selectedReviewerId == null ||
          _selectedHrReviewerId == null ||
          _appraisalDate == null ||
          _nextAppraisalDate == null) {
        ToastUtils.showErrorToast('Please fill all required fields');
        return;
      }

      // Generate appraisal number
      final appraisalNumber = 'PA-${DateTime.now().millisecondsSinceEpoch}';

      final data = {
        'appraisalNumber': appraisalNumber,
        'employee': _selectedEmployeeId,
        'appraisalPeriod': _periodController.text.trim(),
        'appraisalDate': _appraisalDate!.toIso8601String(),
        'nextAppraisalDate': _nextAppraisalDate!.toIso8601String(),
        'reviewer': _selectedReviewerId,
        'hrReviewer': _selectedHrReviewerId,
        'keyPerformanceAreas': _keyPerformanceAreas,
        'competencies': _competencies,
        'overallRating': 0.0,
        'performanceLevel': 'meets_expectations',
        'potentialLevel': 'steady_performer',
        'strengths': [],
        'developmentAreas': [],
        'reviewerComments': '',
        'status': 'draft',
      };

      try {
        final appraisal = await ref.read(performanceProvider.notifier).createAppraisal(data);
        if (appraisal != null) {
          widget.onSuccess(appraisal);
        }
      } catch (e) {
        ToastUtils.showErrorToast('Failed to create review: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}