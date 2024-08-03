import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ingeniusly/task_dialog.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  MeetingDataSource? events;
  bool isInitialLoaded = false;
  final fireStoreReference = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getDataFromFireStore().then((_) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  Future<void> getDataFromFireStore() async {
    try {
      // Fetch events from Firestore
      var snapShotsValue = await fireStoreReference.collection("events").get();
      final List<Meeting> list = snapShotsValue.docs.map((e) {
        final meeting = Meeting(
          eventName: e.data()['name'] ?? 'No Name',
          from: DateTime.parse(e.data()['startDate']),
          to: _combineDateTime(
              DateTime.parse(e.data()['startDate']), e.data()['endTime']),
          background:
              Colors.blue, // You can map this to a specific color if needed
          isAllDay: e.data()['isAllDay'] ?? false,
          id: e.id,
        );
        print(
            "Fetched Meeting: ${meeting.eventName}, ${meeting.from}, ${meeting.to}");
        return meeting;
      }).toList();

      print("All Fetched Meetings:");
      list.forEach((meeting) {
        print(
            "Meeting ID: ${meeting.id}, Name: ${meeting.eventName}, From: ${meeting.from}, To: ${meeting.to}");
      });

      setState(() {
        events = MeetingDataSource(list);
        isInitialLoaded = true;
      });

      // Set up real-time listener
      fireStoreReference.collection("events").snapshots().listen((event) {
        final List<Meeting> updatedList = event.docs.map((e) {
          final meeting = Meeting(
            eventName: e.data()['name'] ?? 'No Name',
            from: DateTime.parse(e.data()['startDate']),
            to: _combineDateTime(
                DateTime.parse(e.data()['startDate']), e.data()['endTime']),
            background: Colors.blue, // Map to specific color if needed
            isAllDay: e.data()['isAllDay'] ?? false,
            id: e.id,
          );
          print(
              "Real-time Updated Meeting: ${meeting.eventName}, ${meeting.from}, ${meeting.to}");
          return meeting;
        }).toList();

        print("All Real-time Updated Meetings:");
        updatedList.forEach((meeting) {
          print(
              "Meeting ID: ${meeting.id}, Name: ${meeting.eventName}, From: ${meeting.from}, To: ${meeting.to}");
        });

        setState(() {
          events!.updateAppointments(updatedList);
        });
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  DateTime _combineDateTime(DateTime date, String timeString) {
    final timeParts = timeString.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: SfCalendar(
                    backgroundColor: Colors.white,
                    view: CalendarView.week,
                    allowedViews: [
                      CalendarView.day,
                      CalendarView.week,
                      CalendarView.month,
                    ],
                    dataSource: events,
                    monthCellBuilder:
                        (BuildContext context, MonthCellDetails details) {
                      return Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.date.day.toString(),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            ...details.appointments.map((appointment) {
                              final Meeting meeting = appointment as Meeting;
                              return Container(
                                margin: const EdgeInsets.only(top: 2.0),
                                color: meeting.background,
                                child: Text(
                                  meeting.eventName,
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                    onTap: (CalendarTapDetails details) {
                      if (details.targetElement ==
                          CalendarElement.appointment) {
                        final Meeting? selectedMeeting =
                            details.appointments?.first as Meeting?;
                        if (selectedMeeting != null) {
                          _showMeetingDetailsDialog(selectedMeeting);
                        }
                      }
                    },
                    allowDragAndDrop: true,
                    onDragEnd: (AppointmentDragEndDetails details) {
                      if (details.appointment != null) {
                        final Meeting appointment =
                            details.appointment as Meeting;
                        // Update the meeting in Firebase or local data store
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.05,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(0.0, 3.0),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverAppBar(
                      scrolledUnderElevation: 0.0,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      toolbarHeight: 40,
                      pinned: true,
                      floating: false,
                      expandedHeight: 40.0,
                      flexibleSpace: Center(
                        child: Text(
                          "✅",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final meeting =
                              events?.appointments?[index] as Meeting?;
                          if (meeting == null) return null;
                          return ListTile(
                            leading: Icon(Icons.check),
                            title: Text(meeting.eventName),
                          );
                        },
                        childCount: events?.appointments?.length ?? 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _showAddDialog();
              },
              backgroundColor: Colors.amber,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _showMeetingDetailsDialog(Meeting meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(meeting.eventName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${DateFormat.yMMMd().add_jm().format(meeting.from)}'),
              Text('To: ${DateFormat.yMMMd().add_jm().format(meeting.to)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDialog(
          task: {
            'name': 'New Task',
            'importance': 'None',
            'description': '',
            'startDate': DateTime.now().toIso8601String(),
            'startTime': TimeOfDay.now().format(context),
            'endTime': TimeOfDay.now().format(context),
          },
          onSave: (updatedTask) {
            // Add new task to Firebase or local data store
          },
        );
      },
    );
  }
}

class Meeting {
  Meeting({
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
    this.id,
  });

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String? id;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  void updateAppointments(List<Meeting> meetings) {
    appointments = meetings;
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
