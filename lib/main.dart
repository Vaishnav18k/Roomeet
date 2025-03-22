import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:roomeet/screen/calender.dart';
import 'package:roomeet/screen/graphql_config.dart';

void main() {
  runApp(
    GraphQLProvider(
      client: client,
      child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
    ),
  );
}

String _formatTime(TimeOfDay? time) {
  if (time == null) return '';
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

class _TabItem extends StatelessWidget {
  final String text;
  const _TabItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DateTime _currentTime;
  late Timer _timer;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _meetingNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _meetingNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isStartTime
              ? (_startTime ?? TimeOfDay.now())
              : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roomeet', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://avatar.iran.liara.run/public/11',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(
                        TimeOfDay(
                          hour: _currentTime.hour,
                          minute: _currentTime.minute,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(_currentTime),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // Date Picker
                    Row(
                      children: const [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatDate(_selectedDate),
                            ),
                            decoration: InputDecoration(
                              hintText: "dd/mm/yyyy",
                              suffixIcon: IconButton(
                                onPressed: () => _selectDate(context),
                                icon: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Time Picker (Start & End Time)
                    Row(
                      children: const [
                        Text(
                          'Time',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Start Time Input
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatTime(_startTime),
                            ),
                            decoration: InputDecoration(
                              hintText: "hh:mm",
                              suffixIcon: IconButton(
                                onPressed: () => _selectTime(context, true),
                                icon: const Icon(
                                  Icons.access_time,
                                  color: Colors.blue,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "-",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // End Time Input
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatTime(_endTime),
                            ),
                            decoration: InputDecoration(
                              hintText: "hh:mm",
                              suffixIcon: IconButton(
                                onPressed: () => _selectTime(context, false),
                                icon: const Icon(
                                  Icons.access_time,
                                  color: Colors.blue,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Room Selection Dropdown
                    const SizedBox(height: 15),
                    Row(
                      children: const [
                        Text(
                          'Room',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: "Room A",
                      items:
                          [
                                "Room A",
                                "Room B",
                                "Room C",
                                "Room D",
                                "Room E",
                                "Room F",
                              ]
                              .map(
                                (room) => DropdownMenuItem(
                                  value: room,
                                  child: Text(
                                    room,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        // Handle room selection change
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Meeting Name Field
                    Row(
                      children: const [
                        Text(
                          'Meeting Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _meetingNameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Participants Field
                    Row(
                      children: const [
                        Text(
                          'Participants',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Add a participant",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Repeat Option Field
                    Row(
                      children: const [
                        Text(
                          'Repeat',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: "Once",
                      items:
                          ["Once", "Daily", "Weekly", "Monthly"]
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // "Book a Room" Button
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action when button is pressed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Book a room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(child: _TabItem(text: "Overview")),
                          Tab(child: _TabItem(text: "Calendar")),
                          Tab(child: _TabItem(text: "My Meeting")),
                        ],
                        indicatorColor: Colors.blue,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3.0,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text("Overview Content"),
                            ),
                          ),
                          CalendarScreen(
                            selectedDate: _selectedDate ?? DateTime.now(),
                            startTime: _startTime ?? TimeOfDay.now(),
                            endTime: _endTime ?? TimeOfDay.now(),
                            meetingName:
                                _meetingNameController.text.isNotEmpty
                                    ? _meetingNameController.text
                                    : "No Meeting Name",
                          ),
                          Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text("My Meeting Content"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
