import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar.dart'; // Import CalendarPage if it's in a separate file

class TaskDialog extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onSave;

  TaskDialog({required this.task, required this.onSave});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final Map<String, Color> _quadrantColors = {
    'None': Colors.grey,
    'Important/Urgent': Colors.red,
    'Important/Not Urgent': Colors.green,
    'Not Important/Urgent': Colors.orange,
    'Not Important/Not Urgent': Colors.blue,
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late String importance;
  late DateTime startDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.task['name'] ?? '';
    _descriptionController.text = widget.task['description'] ?? '';
    importance = widget.task['importance'] ?? 'Important/Urgent';
    startDate = DateTime.parse(widget.task['startDate']);
    String startTimeStr = widget.task['startTime'] ?? '';
    startTime = TimeOfDay(
        hour: int.parse(startTimeStr.split(":")[0]),
        minute: int.parse(startTimeStr.split(":")[1]));
    String endTimeStr = widget.task['endTime'] ?? '';
    endTime = TimeOfDay(
        hour: int.parse(endTimeStr.split(":")[0]),
        minute: int.parse(endTimeStr.split(":")[1]));
  }

  Future<void> _saveTaskToFirestore() async {
    // Add new task
    await FirebaseFirestore.instance.collection('events').add({
      'name': _nameController.text,
      'importance': importance,
      'description': _descriptionController.text,
      'startDate': startDate.toString(),
      'startTime': startTime.format(context),
      'endTime': endTime.format(context),
    });
  }

  Future<void> _deleteTaskFromFirestore() async {
    // List of collections to search through
    final List<String> collections = [
      'events',
      'important-urgent',
      'not-important-urgent',
      'important-not-urgent',
      'not-important-not-urgent'
    ];

    for (String collection in collections) {
      // Query the collection for documents with the matching name
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('name', isEqualTo: _nameController.text)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        // Ensure the dialog content is scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              DropdownButtonFormField<String>(
                value: importance,
                items: _quadrantColors.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: _quadrantColors[key]),
                        SizedBox(width: 8.0),
                        Text(key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    importance = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Importance'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              ListTile(
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != startDate)
                    setState(() {
                      startDate = picked;
                    });
                },
              ),
              ListTile(
                title: Text('Start Time: ${startTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null && picked != startTime)
                    setState(() {
                      startTime = picked;
                    });
                },
              ),
              ListTile(
                title: Text('End Time: ${endTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null && picked != endTime)
                    setState(() {
                      endTime = picked;
                    });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Save to Firestore
                  await _saveTaskToFirestore();

                  // Call the onSave callback with the task details
                  widget.onSave({
                    'name': _nameController.text,
                    'importance': importance,
                    'description': _descriptionController.text,
                    'startDate': startDate,
                    'startTime': startTime,
                    'endTime': endTime,
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Delete from Firestore
                  await _deleteTaskFromFirestore();

                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
                style: ElevatedButton.styleFrom(iconColor: Colors.red),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
