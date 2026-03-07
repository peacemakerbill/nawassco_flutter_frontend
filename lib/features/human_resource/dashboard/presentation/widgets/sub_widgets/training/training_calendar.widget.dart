import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class TrainingCalendar extends ConsumerStatefulWidget {
  final Function(Training) onTrainingSelect;

  const TrainingCalendar({super.key, required this.onTrainingSelect});

  @override
  ConsumerState<TrainingCalendar> createState() => _TrainingCalendarState();
}

class _TrainingCalendarState extends ConsumerState<TrainingCalendar> {
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<Training>> _trainingsByDate = {};

  @override
  Widget build(BuildContext context) {
    final trainings = ref.watch(trainingProvider).trainings;

    // Group trainings by date
    if (_trainingsByDate.isEmpty) {
      _groupTrainingsByDate(trainings);
    }

    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    return Column(
      children: [
        // Month selector
        _buildMonthSelector(),
        const SizedBox(height: 16),

        // Calendar grid
        Expanded(
          child: _buildCalendarGrid(monthStart, monthEnd),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                });
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime monthStart, DateTime monthEnd) {
    final daysInMonth = monthEnd.day;
    final firstWeekday = monthStart.weekday;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayOffset = index - (firstWeekday - 1);
        final date = DateTime(monthStart.year, monthStart.month, dayOffset + 1);

        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return Container(); // Empty cell for days outside month
        }

        final trainingsOnDate = _trainingsByDate[date] ?? [];
        final isToday = date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        return _buildCalendarCell(date, trainingsOnDate, isToday);
      },
    );
  }

  Widget _buildCalendarCell(DateTime date, List<Training> trainings, bool isToday) {
    return Card(
      margin: const EdgeInsets.all(2),
      color: isToday ? Colors.blue.shade50 : Colors.white,
      child: InkWell(
        onTap: trainings.isNotEmpty ? () => _showTrainingsForDate(date, trainings) : null,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.blue : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              if (trainings.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trainings.length,
                    itemBuilder: (context, index) {
                      final training = trainings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: training.statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          training.trainingTitle,
                          style: TextStyle(
                            fontSize: 8,
                            color: training.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrainingsForDate(DateTime date, List<Training> trainings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('dd MMMM yyyy').format(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...trainings.map((training) {
                return ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: training.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(training.trainingTitle),
                  subtitle: Text('${training.typeText} • ${training.venue}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTrainingSelect(training);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _groupTrainingsByDate(List<Training> trainings) {
    for (final training in trainings) {
      final currentDate = training.startDate;
      final endDate = training.endDate;

      // Add training to each day it spans
      var date = currentDate;
      while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        _trainingsByDate[normalizedDate] ??= [];
        _trainingsByDate[normalizedDate]!.add(training);
        date = date.add(const Duration(days: 1));
      }
    }
  }
}