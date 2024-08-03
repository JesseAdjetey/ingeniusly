import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ingeniusly/calendar.dart';
import 'package:ingeniusly/task_dialog.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _tasks = [];

  final Map<String, List<Map<String, dynamic>>> _quadrants = {
    'Important/Urgent': [],
    'Important/Not Urgent': [],
    'Not Important/Urgent': [],
    'Not Important/Not Urgent': [],
  };

  final Map<String, Color> _quadrantColors = {
    'Important/Urgent': Colors.red,
    'Important/Not Urgent': Colors.green,
    'Not Important/Urgent': Colors.orange,
    'Not Important/Not Urgent': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _fetchEvents();
    _fetchAllEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('events').get();
      setState(() {
        _tasks = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _fetchAllEvents() async {
    try {
      // Fetch data for each quadrant
      QuerySnapshot importantUrgentSnapshot =
          await FirebaseFirestore.instance.collection('important-urgent').get();
      QuerySnapshot importantNotUrgentSnapshot = await FirebaseFirestore
          .instance
          .collection('important-not-urgent')
          .get();
      QuerySnapshot notImportantUrgentSnapshot = await FirebaseFirestore
          .instance
          .collection('not-important-urgent')
          .get();
      QuerySnapshot notImportantNotUrgentSnapshot = await FirebaseFirestore
          .instance
          .collection('not-important-not-urgent')
          .get();

      setState(() {
        // Assign tasks to the respective quadrants
        _quadrants['Important/Urgent'] = importantUrgentSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _quadrants['Important/Not Urgent'] = importantNotUrgentSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _quadrants['Not Important/Urgent'] = notImportantUrgentSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _quadrants['Not Important/Not Urgent'] = notImportantNotUrgentSnapshot
            .docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  // Define the async function
  Future<void> _deleteTaskFromFirebase(
      String taskName, String collection) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('name', isEqualTo: taskName)
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(doc.id)
            .delete();
      }
    } catch (e) {
      print('Error deleting task from Firebase: $e');
    }
  }

  void _showEditDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDialog(
          task: task,
          onSave: (updatedTask) {
            setState(() {
              task
                ..['name'] = updatedTask['name']
                ..['duration'] = updatedTask['duration']
                ..['importance'] = updatedTask['importance']
                ..['description'] = updatedTask['description']
                ..['startDate'] = updatedTask['startDate']
                ..['startTime'] = updatedTask['startTime']
                ..['endTime'] = updatedTask['endTime'];
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Quadrants layout
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Quadrant(
                              title: 'Important/Urgent',
                              icon: Icons.priority_high,
                              iconColor: _quadrantColors['Important/Urgent']!,
                              items: _quadrants['Important/Urgent']!,
                              onAccept: (task) {
                                setState(() {
                                  task['importance'] = 'Important/Urgent';
                                  _quadrants['Important/Urgent']!.add(task);
                                  _tasks.remove(task);
                                  FirebaseFirestore.instance
                                      .collection('important-urgent')
                                      .add(task);
                                });
                              },
                              onRevert: (task) {
                                setState(() {
                                  _quadrants['Important/Urgent']!.remove(task);
                                  _tasks.add(task);
                                });

                                // Call the async function separately
                                _deleteTaskFromFirebase(
                                    task['name'], 'important-urgent');
                              },
                              showEditDialog: _showEditDialog,
                            ),
                          ),
                          Expanded(
                            child: Quadrant(
                              title: 'Important/Not Urgent',
                              icon: Icons.label_important,
                              iconColor:
                                  _quadrantColors['Important/Not Urgent']!,
                              items: _quadrants['Important/Not Urgent']!,
                              onAccept: (task) {
                                setState(() {
                                  task['importance'] = 'Important/Not Urgent';
                                  _quadrants['Important/Not Urgent']!.add(task);
                                  _tasks.remove(task);
                                  FirebaseFirestore.instance
                                      .collection('important-not-urgent')
                                      .add(task);
                                });
                              },
                              onRevert: (task) {
                                setState(() {
                                  _quadrants['Important/Not Urgent']!
                                      .remove(task);
                                  _tasks.add(task);
                                });
                                _deleteTaskFromFirebase(
                                    task['name'], 'important-not-urgent');
                              },
                              showEditDialog: _showEditDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Quadrant(
                              title: 'Not Important/Urgent',
                              icon: Icons.access_time,
                              iconColor:
                                  _quadrantColors['Not Important/Urgent']!,
                              items: _quadrants['Not Important/Urgent']!,
                              onAccept: (task) {
                                setState(() {
                                  task['importance'] = 'Not Important/Urgent';
                                  _quadrants['Not Important/Urgent']!.add(task);
                                  _tasks.remove(task);
                                  FirebaseFirestore.instance
                                      .collection('not-important-urgent')
                                      .add(task);
                                });
                              },
                              onRevert: (task) {
                                setState(() {
                                  _quadrants['Not Important/Urgent']!
                                      .remove(task);
                                  _tasks.add(task);
                                });
                                _deleteTaskFromFirebase(
                                    task['name'], 'not-important-urgent');
                              },
                              showEditDialog: _showEditDialog,
                            ),
                          ),
                          Expanded(
                            child: Quadrant(
                              title: 'Not Important/Not Urgent',
                              icon: Icons.info,
                              iconColor:
                                  _quadrantColors['Not Important/Not Urgent']!,
                              items: _quadrants['Not Important/Not Urgent']!,
                              onAccept: (task) {
                                setState(() {
                                  task['importance'] =
                                      'Not Important/Not Urgent';
                                  _quadrants['Not Important/Not Urgent']!
                                      .add(task);
                                  _tasks.remove(task);
                                  FirebaseFirestore.instance
                                      .collection('not-important-not-urgent')
                                      .add(task);
                                });
                              },
                              onRevert: (task) {
                                setState(() {
                                  _quadrants['Not Important/Not Urgent']!
                                      .remove(task);
                                  _tasks.add(task);
                                });
                                _deleteTaskFromFirebase(
                                    task['name'], 'not-important-not-urgent');
                              },
                              showEditDialog: _showEditDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Draggable list
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.04,
                maxChildSize: 1.0,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                          toolbarHeight: 40,
                          pinned: true,
                          floating: false,
                          expandedHeight: 40.0,
                          flexibleSpace: Center(
                            child: Text(
                              "Tasks",
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                child: Align(
                                  alignment:
                                      Alignment.center, // Center the button
                                  child: Container(
                                    width: constraints.maxWidth *
                                        0.7, // Button width
                                    child: Draggable<Map<String, dynamic>>(
                                      data: _tasks[index],
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: constraints.maxWidth *
                                              0.5, // Button feedback size
                                          padding: EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            child: Text(_tasks[index]['name']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[
                                                  300], // Slightly gray background
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        width: constraints.maxWidth *
                                            0.5, // Button width when dragging
                                        margin: EdgeInsets.only(
                                            right:
                                                8.0), // Margin between buttons
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: Text(_tasks[index]['name']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[
                                                200], // Slightly lighter gray
                                            foregroundColor: Colors.black,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right:
                                                8.0), // Margin between buttons
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showEditDialog(_tasks[index]);
                                          },
                                          child: Text(_tasks[index]['name']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[
                                                300], // Slightly gray background
                                            foregroundColor: Colors.black,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onDragStarted: () {
                                        print('Dragging started');
                                      },
                                      onDraggableCanceled: (velocity, offset) {
                                        print('Dragging canceled');
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _tasks.length,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                right: 8,
                child: FloatingActionButton(
                  onPressed: () {
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
                  },
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Quadrant extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor; // New parameter for icon color
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onAccept;
  final Function(Map<String, dynamic>) onRevert;
  final Function(Map<String, dynamic>) showEditDialog;

  Quadrant({
    required this.title,
    required this.icon,
    required this.iconColor, // New parameter for icon color
    required this.items,
    required this.onAccept,
    required this.onRevert,
    required this.showEditDialog,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 25, // Icon size
                    color: iconColor, // Use the icon color
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.0,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Ensure no extra padding
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.5, // 50% width of the available space
                        child: Draggable<Map<String, dynamic>>(
                          data: items[index],
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(items[index]['name']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      iconColor, // Use quadrant color for feedback
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(items[index]['name']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.grey[200], // Slightly lighter gray
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 2.0), // Margin between buttons
                            child: ElevatedButton(
                              onPressed: () {
                                showEditDialog(items[index]);
                              },
                              child: Text(items[index]['name']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    iconColor, // Use quadrant color for buttons
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          onDragCompleted: () {
                            onRevert(items[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
