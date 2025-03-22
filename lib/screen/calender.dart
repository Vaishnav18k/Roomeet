import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(
    MaterialApp(
      // ✅ Removed 'const' to allow DateTime.now()
      home: CalendarScreen(
        selectedDate: DateTime.now(),
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 0),
        meetingName: "Default Meeting",
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CalendarScreen extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String meetingName;

  const CalendarScreen({
    super.key,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.meetingName,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final EventController _eventController;
  CalendarView _currentView = CalendarView.week; // Default: Week View
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _eventController = EventController();
    _currentDate = widget.selectedDate;

    // Ensure event addition happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventController.add(
        CalendarEventData(
          date: widget.selectedDate,
          title: widget.meetingName,
          startTime: DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            widget.startTime.hour,
            widget.startTime.minute,
          ),
          endTime: DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            widget.endTime.hour,
            widget.endTime.minute,
          ),
          description: "Scheduled Meeting",
          event: "Meeting Event",
        ),
      );
    });
  }

  String getFormattedDateRange() {
    DateTime startDate, endDate;

    if (_currentView == CalendarView.day) {
      startDate = _currentDate;
      endDate = _currentDate;
    } else if (_currentView == CalendarView.week) {
      startDate = _currentDate.subtract(
        Duration(days: _currentDate.weekday - 1),
      );
      endDate = startDate.add(const Duration(days: 6));
    } else {
      startDate = DateTime(_currentDate.year, _currentDate.month, 1);
      endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    }

    return "${_formatDate(startDate)} - ${_formatDate(endDate)}";
  }

  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _currentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 📅 Date Range + Calendar Icon
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Text(
                  getFormattedDateRange(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: _selectDate,
                ),
                const Spacer(),
                // 🔄 View Toggle Buttons (Day | Week | Month)
                _buildToggleButton("Day", CalendarView.day),
                _buildToggleButton("Week", CalendarView.week),
                _buildToggleButton("Month", CalendarView.month),
              ],
            ),
          ),

          // 📆 Calendar View
          Expanded(
            child: CalendarControllerProvider(
              controller: _eventController,
              child: Builder(
                builder: (context) {
                  switch (_currentView) {
                    case CalendarView.day:
                      return const DayView();
                    case CalendarView.week:
                      return const WeekView();
                    case CalendarView.month:
                    default:
                      return const MonthView();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, CalendarView viewType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: () {
          if (_currentView != viewType) {
            setState(() {
              _currentView = viewType;
            });
          }
        },
        style: TextButton.styleFrom(
          backgroundColor:
              _currentView == viewType ? Colors.blue[100] : Colors.white,
          foregroundColor:
              _currentView == viewType ? Colors.blue : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: _currentView == viewType ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

