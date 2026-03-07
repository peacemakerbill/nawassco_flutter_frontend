import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/budget_model.dart';
import '../../../../providers/budget_provider.dart';
import 'budget_item_form_widget.dart';

class BudgetFormWidget extends ConsumerStatefulWidget {
  final Budget? budget;

  const BudgetFormWidget({super.key, this.budget});

  @override
  ConsumerState<BudgetFormWidget> createState() => _BudgetFormWidgetState();
}

class _BudgetFormWidgetState extends ConsumerState<BudgetFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _budgetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fiscalYearController = TextEditingController();

  PeriodType _selectedPeriodType = PeriodType.annual;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 365));

  List<BudgetItem> _budgetItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _initializeFormWithBudget();
    } else {
      _fiscalYearController.text = DateTime.now().year.toString();
      _adjustDatesBasedOnPeriod();
    }
  }

  void _initializeFormWithBudget() {
    final budget = widget.budget!;
    _budgetNameController.text = budget.budgetName;
    _descriptionController.text = budget.description;
    _fiscalYearController.text = budget.fiscalYear;
    _selectedPeriodType = budget.periodType;
    _selectedStartDate = budget.startDate;
    _selectedEndDate = budget.endDate;
    _budgetItems = List.from(budget.items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Header
            _buildHeader(),
            // Form Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFormContent(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            widget.budget == null ? Icons.add : Icons.edit,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.budget == null ? 'Create New Budget' : 'Edit Budget',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Basic Information
                    _buildBasicInformationSection(isMobile),
                    const SizedBox(height: 24),

                    // Period Information
                    _buildPeriodInformationSection(isMobile),
                    const SizedBox(height: 24),

                    // Budget Items
                    _buildBudgetItemsSection(isMobile),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformationSection(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetNameController,
              decoration: InputDecoration(
                labelText: 'Budget Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget name';
                }
                if (value.length > 100) {
                  return 'Budget name cannot exceed 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                if (value.length > 500) {
                  return 'Description cannot exceed 500 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fiscalYearController,
              decoration: InputDecoration(
                labelText: 'Fiscal Year',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a fiscal year';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodInformationSection(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Period Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PeriodType>(
              decoration: InputDecoration(
                labelText: 'Period Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              value: _selectedPeriodType,
              items: PeriodType.values
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(_getPeriodTypeLabel(type)),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriodType = value;
                    _adjustDatesBasedOnPeriod();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (isMobile)
              Column(
                children: [
                  _buildDatePicker('Start Date', _selectedStartDate, (date) {
                    setState(() => _selectedStartDate = date);
                  }),
                  const SizedBox(height: 16),
                  _buildDatePicker('End Date', _selectedEndDate, (date) {
                    setState(() => _selectedEndDate = date);
                  }),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker('Start Date', _selectedStartDate, (date) {
                      setState(() => _selectedStartDate = date);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker('End Date', _selectedEndDate, (date) {
                      setState(() => _selectedEndDate = date);
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (_selectedEndDate.isBefore(_selectedStartDate))
              Text(
                'End date must be after start date',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate,
      ValueChanged<DateTime> onDateSelected) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(selectedDate, onDateSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Theme.of(context).hintColor),
                const SizedBox(width: 12),
                Text(
                  dateFormat.format(selectedDate),
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetItemsSection(bool isMobile) {
    final totalBudget =
    _budgetItems.fold(0.0, (sum, item) => sum + item.budgetAmount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Budget Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Total: KES ${totalBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_budgetItems.isNotEmpty) ...[
              _buildBudgetItemsList(isMobile),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: () => _addBudgetItem(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Budget Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: Size(isMobile ? double.infinity : 200, 48),
              ),
            ),
            if (_budgetItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No budget items added yet. Add at least one item to continue.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItemsList(bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _budgetItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _budgetItems[index];
        return _buildBudgetItemCard(item, index, isMobile);
      },
    );
  }

  Widget _buildBudgetItemCard(BudgetItem item, int index, bool isMobile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.accountName ?? 'Unknown Account',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.accountCode != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${item.accountCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                      if (item.accountType != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Type: ${item.accountType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KES ${item.budgetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.actualSpent > 0)
                      Text(
                        '${((item.actualSpent / item.budgetAmount) * 100).toStringAsFixed(1)}% spent',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.costCenter != null || item.projectCode != null || item.notes != null)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (item.costCenter != null)
                    _buildItemChip('Cost Center: ${item.costCenter}', isMobile),
                  if (item.projectCode != null)
                    _buildItemChip('Project: ${item.projectCode}', isMobile),
                  if (item.notes != null && item.notes!.length < 30)
                    _buildItemChip('Notes: ${item.notes}', isMobile),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                  onPressed: () => _editBudgetItem(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: isMobile ? 16 : 18, color: Theme.of(context).colorScheme.error),
                  onPressed: () => _removeBudgetItem(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemChip(String text, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 10 : 11,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: isMobile ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              ),
              child: Text(
                widget.budget == null ? 'CREATE BUDGET' : 'UPDATE BUDGET',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(
      DateTime selectedDate, ValueChanged<DateTime> onDateSelected) {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate != null) {
        onDateSelected(pickedDate);
      }
    });
  }

  String _getPeriodTypeLabel(PeriodType type) {
    switch (type) {
      case PeriodType.annual:
        return 'Annual';
      case PeriodType.quarterly:
        return 'Quarterly';
      case PeriodType.monthly:
        return 'Monthly';
    }
  }

  void _adjustDatesBasedOnPeriod() {
    final now = DateTime.now();
    final year = int.tryParse(_fiscalYearController.text) ?? now.year;

    switch (_selectedPeriodType) {
      case PeriodType.annual:
        setState(() {
          _selectedStartDate = DateTime(year, 1, 1);
          _selectedEndDate = DateTime(year, 12, 31);
        });
        break;
      case PeriodType.quarterly:
        final quarter = ((now.month - 1) / 3).floor();
        setState(() {
          _selectedStartDate = DateTime(year, (quarter * 3) + 1, 1);
          _selectedEndDate = DateTime(year, (quarter * 3) + 3, 31);
        });
        break;
      case PeriodType.monthly:
        setState(() {
          _selectedStartDate = DateTime(year, now.month, 1);
          _selectedEndDate = DateTime(year, now.month + 1, 0);
        });
        break;
    }
  }

  void _addBudgetItem() async {
    final result = await showDialog<BudgetItem?>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: BudgetItemFormWidget(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _budgetItems.add(result);
      });
    }
  }

  void _editBudgetItem(int index) async {
    final item = _budgetItems[index];
    final result = await showDialog<BudgetItem?>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: BudgetItemFormWidget(item: item),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _budgetItems[index] = result;
      });
    }
  }

  void _removeBudgetItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Budget Item'),
        content: const Text('Are you sure you want to remove this budget item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _budgetItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_budgetItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one budget item'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedEndDate.isBefore(_selectedStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('End date must be after start date'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final budgetData = {
      'budgetName': _budgetNameController.text,
      'description': _descriptionController.text,
      'fiscalYear': _fiscalYearController.text,
      'periodType': _selectedPeriodType.name,
      'startDate': _selectedStartDate.toIso8601String(),
      'endDate': _selectedEndDate.toIso8601String(),
      'items': _budgetItems.map((item) => item.toJson()).toList(),
    };

    final success = widget.budget == null
        ? await ref.read(budgetProvider.notifier).createBudget(budgetData)
        : await ref.read(budgetProvider.notifier).updateBudget(widget.budget!.id!, budgetData);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _budgetNameController.dispose();
    _descriptionController.dispose();
    _fiscalYearController.dispose();
    super.dispose();
  }
}