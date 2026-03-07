import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nawassco/features/sales/providers/customer_provider.dart';
import 'package:nawassco/features/sales/providers/lead_provider.dart';
import 'package:nawassco/features/sales/providers/opportunity_provider.dart';
import 'package:nawassco/features/sales/providers/quote_provider.dart';
import '../../../../models/calendar.model.dart';
import '../../../../providers/proposal.provider.dart';

class CalendarEventForm extends ConsumerStatefulWidget {
  final CalendarEvent? initialEvent;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onCancel;

  const CalendarEventForm({
    super.key,
    this.initialEvent,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  ConsumerState<CalendarEventForm> createState() => _CalendarEventFormState();
}

class _CalendarEventFormState extends ConsumerState<CalendarEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cancellationController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _outcomeNotesController = TextEditingController();
  final _feedbackController = TextEditingController();

  final _customerSearchController = TextEditingController();
  final _leadSearchController = TextEditingController();
  final _opportunitySearchController = TextEditingController();
  final _quoteSearchController = TextEditingController();
  final _proposalSearchController = TextEditingController();

  CalendarEventType _selectedType = CalendarEventType.meeting;
  EventStatus _selectedStatus = EventStatus.scheduled;
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _allDay = false;
  String? _selectedCustomerId;
  String? _selectedLeadId;
  String? _selectedOpportunityId;
  String? _selectedQuoteId;
  String? _selectedProposalId;
  List<String> _selectedAttendeeIds = [];
  double? _rating;

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      final event = widget.initialEvent!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.location ?? '';
      _selectedType = event.type;
      _selectedStatus = event.status;
      _selectedPriority = event.priority;
      _startDate = event.startDate;
      _endDate = event.endDate;
      _allDay = event.allDay;
      _selectedCustomerId = event.customerId;
      _selectedLeadId = event.leadId;
      _selectedOpportunityId = event.opportunityId;
      _selectedQuoteId = event.quoteId;
      _selectedProposalId = event.proposalId;
      _selectedAttendeeIds = event.attendeeIds;
      _cancellationController.text = event.cancellationReason ?? '';
      _outcomeController.text = event.outcome ?? '';
      _outcomeNotesController.text = event.outcomeNotes ?? '';
      _feedbackController.text = event.feedback ?? '';
      _rating = event.rating;
      _updateSearchControllers();
    }
  }

  void _updateSearchControllers() {
    final customers = ref.read(customerProvider).customers;
    final leads = ref.read(leadProvider).leads;
    final opportunities = ref.read(opportunityProvider).opportunities;
    final quotes = ref.read(quoteProvider).quotes;
    final proposals = ref.read(proposalProvider).proposals;

    if (_selectedCustomerId != null && customers.isNotEmpty) {
      final customer = customers.firstWhere(
            (c) => c.id == _selectedCustomerId,
        orElse: () => customers.first,
      );
      if (customer.id == _selectedCustomerId) {
        _customerSearchController.text = customer.displayName;
      }
    }

    if (_selectedLeadId != null && leads.isNotEmpty) {
      final lead = leads.firstWhere(
            (l) => l.id == _selectedLeadId,
        orElse: () => leads.first,
      );
      if (lead.id == _selectedLeadId) {
        _leadSearchController.text = '${lead.leadNumber} - ${lead.contactDetails.fullName}';
      }
    }

    if (_selectedOpportunityId != null && opportunities.isNotEmpty) {
      final opp = opportunities.firstWhere(
            (o) => o.id == _selectedOpportunityId,
        orElse: () => opportunities.first,
      );
      if (opp.id == _selectedOpportunityId) {
        _opportunitySearchController.text = '${opp.opportunityNumber} - ${opp.description}';
      }
    }

    if (_selectedQuoteId != null && quotes.isNotEmpty) {
      final quote = quotes.firstWhere(
            (q) => q.id == _selectedQuoteId,
        orElse: () => quotes.first,
      );
      if (quote.id == _selectedQuoteId) {
        _quoteSearchController.text = '${quote.quoteNumber} - ${quote.customerName}';
      }
    }

    if (_selectedProposalId != null && proposals.isNotEmpty) {
      final proposal = proposals.firstWhere(
            (p) => p.id == _selectedProposalId,
        orElse: () => proposals.first,
      );
      if (proposal.id == _selectedProposalId) {
        _proposalSearchController.text = '${proposal.proposalNumber} - ${proposal.customerName}';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cancellationController.dispose();
    _outcomeController.dispose();
    _outcomeNotesController.dispose();
    _feedbackController.dispose();
    _customerSearchController.dispose();
    _leadSearchController.dispose();
    _opportunitySearchController.dispose();
    _quoteSearchController.dispose();
    _proposalSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (selectedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          if (isStart) {
            _startDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _startDate = _endDate.subtract(const Duration(hours: 1));
            }
          }
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType.name,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'allDay': _allDay,
        'status': _selectedStatus.name,
        'priority': _selectedPriority.name,
        'attendees': _selectedAttendeeIds,
      };

      // FIXED: Location should be an object
      if (_locationController.text.isNotEmpty) {
        data['location'] = {'name': _locationController.text.trim()};
      }
      if (_selectedCustomerId != null) {
        data['customer'] = _selectedCustomerId!;
      }
      if (_selectedLeadId != null) {
        data['lead'] = _selectedLeadId!;
      }
      if (_selectedOpportunityId != null) {
        data['opportunity'] = _selectedOpportunityId!;
      }
      if (_selectedQuoteId != null) {
        data['quote'] = _selectedQuoteId!;
      }
      if (_selectedProposalId != null) {
        data['proposal'] = _selectedProposalId!;
      }

      // Add outcome fields if they exist
      if (_outcomeController.text.isNotEmpty) {
        data['outcome'] = _outcomeController.text.trim();
      }
      if (_outcomeNotesController.text.isNotEmpty) {
        data['outcomeNotes'] = _outcomeNotesController.text.trim();
      }
      if (_rating != null) {
        data['rating'] = _rating!;
      }
      if (_feedbackController.text.isNotEmpty) {
        data['feedback'] = _feedbackController.text.trim();
      }
      if (_cancellationController.text.isNotEmpty) {
        data['cancellationReason'] = _cancellationController.text.trim();
      }

      print('Submitting form data: $data'); // Debug logging
      widget.onSubmit(data);
    }
  }

  Widget _buildTypeAheadField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<dynamic> items,
    required String Function(dynamic item) displayText,
    required String Function(dynamic item) value,
    required void Function(String?) onSelect,
    String? selectedId,
    bool showClearButton = true,
  }) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          suffixIcon: showClearButton && controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              controller.clear();
              onSelect(null);
            },
          )
              : null,
        ),
      ),
      suggestionsCallback: (pattern) {
        return items.where((item) {
          final text = displayText(item).toLowerCase();
          return text.contains(pattern.toLowerCase());
        }).toList();
      },
      itemBuilder: (context, item) {
        return ListTile(
          leading: Icon(icon, size: 20),
          title: Text(displayText(item)),
        );
      },
      onSuggestionSelected: (item) {
        controller.text = displayText(item);
        onSelect(value(item));
      },
      validator: (value) => null,
      noItemsFoundBuilder: (context) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No items found'),
        );
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider).customers;
    final leads = ref.watch(leadProvider).leads;
    final opportunities = ref.watch(opportunityProvider).opportunities;
    final quotes = ref.watch(quoteProvider).quotes;
    final proposals = ref.watch(proposalProvider).proposals;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.initialEvent == null ? Icons.add : Icons.edit,
                        color: const Color(0xFF1E3A8A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.initialEvent == null ? 'New Event' : 'Edit Event',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (isSmallScreen) ...[
                    DropdownButtonFormField<CalendarEventType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: CalendarEventType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon, color: type.color, size: 16),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PriorityLevel>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: PriorityLevel.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: priority.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(priority.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPriority = value);
                        }
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<CalendarEventType>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Event Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: CalendarEventType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(type.icon, color: type.color, size: 16),
                                    const SizedBox(width: 8),
                                    Text(type.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedType = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<PriorityLevel>(
                            value: _selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.priority_high),
                            ),
                            items: PriorityLevel.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: priority.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(priority.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedPriority = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  if (isSmallScreen) ...[
                    InkWell(
                      onTap: () => _selectDateTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date & Time *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatDate(_startDate)} ${_formatTime(_startDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDateTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date & Time *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatDate(_endDate)} ${_formatTime(_endDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDateTime(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date & Time *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatDate(_startDate)} ${_formatTime(_startDate)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDateTime(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date & Time *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatDate(_endDate)} ${_formatTime(_endDate)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text('All Day Event'),
                    value: _allDay,
                    onChanged: (value) => setState(() => _allDay = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Enter meeting location or virtual link',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<EventStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                    ),
                    items: EventStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(status.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Related Entities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (customers.isNotEmpty)
                    _buildTypeAheadField(
                      controller: _customerSearchController,
                      label: 'Customer',
                      icon: Icons.person,
                      items: customers,
                      displayText: (customer) => customer.displayName,
                      value: (customer) => customer.id,
                      onSelect: (value) => setState(() => _selectedCustomerId = value),
                      selectedId: _selectedCustomerId,
                    ),
                  if (customers.isNotEmpty) const SizedBox(height: 16),

                  if (leads.isNotEmpty)
                    _buildTypeAheadField(
                      controller: _leadSearchController,
                      label: 'Lead',
                      icon: Icons.leaderboard,
                      items: leads,
                      displayText: (lead) => '${lead.leadNumber} - ${lead.contactDetails.fullName}',
                      value: (lead) => lead.id,
                      onSelect: (value) => setState(() => _selectedLeadId = value),
                      selectedId: _selectedLeadId,
                    ),
                  if (leads.isNotEmpty) const SizedBox(height: 16),

                  if (opportunities.isNotEmpty)
                    _buildTypeAheadField(
                      controller: _opportunitySearchController,
                      label: 'Opportunity',
                      icon: Icons.trending_up,
                      items: opportunities,
                      displayText: (opp) => '${opp.opportunityNumber} - ${opp.description}',
                      value: (opp) => opp.id,
                      onSelect: (value) => setState(() => _selectedOpportunityId = value),
                      selectedId: _selectedOpportunityId,
                    ),
                  if (opportunities.isNotEmpty) const SizedBox(height: 16),

                  if (quotes.isNotEmpty)
                    _buildTypeAheadField(
                      controller: _quoteSearchController,
                      label: 'Quote',
                      icon: Icons.request_quote,
                      items: quotes,
                      displayText: (quote) => '${quote.quoteNumber} - ${quote.customerName}',
                      value: (quote) => quote.id,
                      onSelect: (value) => setState(() => _selectedQuoteId = value),
                      selectedId: _selectedQuoteId,
                    ),
                  if (quotes.isNotEmpty) const SizedBox(height: 16),

                  if (proposals.isNotEmpty)
                    _buildTypeAheadField(
                      controller: _proposalSearchController,
                      label: 'Proposal',
                      icon: Icons.description,
                      items: proposals,
                      displayText: (proposal) => '${proposal.proposalNumber} - ${proposal.customerName}',
                      value: (proposal) => proposal.id,
                      onSelect: (value) => setState(() => _selectedProposalId = value),
                      selectedId: _selectedProposalId,
                    ),

                  const SizedBox(height: 32),

                  if (isSmallScreen) ...[
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: const Text(
                        'SAVE EVENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: const Text(
                              'SAVE EVENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}