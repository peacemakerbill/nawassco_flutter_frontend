import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../models/leave/leave_application.dart';
import '../../../../../providers/leave_provider.dart';


class LeaveCalendarWidget extends ConsumerStatefulWidget {
  const LeaveCalendarWidget({super.key});

  @override
  ConsumerState<LeaveCalendarWidget> createState() =>
      _LeaveCalendarWidgetState();
}

class _LeaveCalendarWidgetState extends ConsumerState<LeaveCalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentMonth;
  List<LeaveApplication> _leaveApplications = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    final calendarData = await ref.read(leaveProvider.notifier).loadCalendar(
      month: _currentMonth.month,
      year: _currentMonth.year,
        );

    // Convert calendar data to leave applications
    // This would need to be adapted based on your API response structure
    setState(() {
      _leaveApplications = []; // Populate from calendarData
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        1,
      );
    });
    _loadCalendarData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        1,
      );
    });
    _loadCalendarData();
  }

  Widget _buildDayHeader() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = _currentMonth;
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final totalDays = lastDayOfMonth.day;

    // Calculate days from previous month
    final previousMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month - 1,
      1,
    );
    final lastDayPreviousMonth = DateTime(
      previousMonth.year,
      previousMonth.month + 1,
      0,
    ).day;

    List<Widget> dayWidgets = [];

    // Previous month days
    for (int i = firstWeekday - 2; i >= 0; i--) {
      final day = lastDayPreviousMonth - i;
      dayWidgets.add(_buildDayCell(day, isCurrentMonth: false));
    }

    // Current month days
    for (int day = 1; day <= totalDays; day++) {
      dayWidgets.add(_buildDayCell(day));
    }

    // Next month days
    final totalCells = 42; // 6 weeks
    for (int i = dayWidgets.length; i < totalCells; i++) {
      final day = i - dayWidgets.length + 1;
      dayWidgets.add(_buildDayCell(day, isCurrentMonth: false));
    }

    return Wrap(
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, {bool isCurrentMonth = true}) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);

    // Get leaves for this day
    final leavesForDay = _leaveApplications.where((leave) {
      return date.isAfter(leave.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(leave.endDate.add(const Duration(days: 1)));
    }).toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 7,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A237E).withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF1A237E)
                              : isSelected
                              ? const Color(0xFF1A237E)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? Colors.white
                                  : isSelected
                                  ? Colors.white
                                  : isCurrentMonth
                                  ? Colors.black
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (leavesForDay.isNotEmpty)
                    ...leavesForDay.take(2).map((leave) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: leave.leaveType.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: leave.leaveType.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                leave.employeeName.split(' ').first,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: leave.leaveType.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  if (leavesForDay.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        '+${leavesForDay.length - 2} more',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                        ),
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildLeaveListForSelectedDate() {
    final leavesForSelectedDate = _leaveApplications.where((leave) {
      return _selectedDate.isAfter(
        leave.startDate.subtract(const Duration(days: 1)),
      ) &&
          _selectedDate.isBefore(leave.endDate.add(const Duration(days: 1)));
    }).toList();

    if (leavesForSelectedDate.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No leaves scheduled for this day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leavesForSelectedDate.length,
      itemBuilder: (context, index) {
        final leave = leavesForSelectedDate[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: leave.leaveType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              leave.leaveType.icon,
              size: 20,
              color: leave.leaveType.color,
            ),
          ),
          title: Text(leave.employeeName),
          subtitle: Text(leave.leaveType.displayName),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: leave.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              leave.statusText,
              style: TextStyle(
                fontSize: 10,
                color: leave.statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Navigation
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDayHeader(),
                  _buildCalendarGrid(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Selected Date Leaves
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaves for ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLeaveListForSelectedDate(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}