import 'package:flutter/material.dart';
import 'dart:math';

class EstimateButton extends StatefulWidget {
  final VoidCallback onPressed;

  EstimateButton({required this.onPressed});

  @override
  _EstimateButtonState createState() => _EstimateButtonState();
}

class _EstimateButtonState extends State<EstimateButton> {
  int _selectedTime = 0; // Time in minutes

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showEstimateDialog(context);
        widget.onPressed();
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          color: Colors.amber, // Yellow color
        ),
        child: Transform.rotate(
          angle: 0,
          child: _selectedTime == 0
              ? Icon(Icons.timer, color: Colors.black) // Black icon color
              : Text(
                  '$_selectedTime ',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _showEstimateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempTime = _selectedTime; // Temp variable for the dialog

        return AlertDialog(
          title: Text("Set Time Estimate"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Time Estimate"),
              Slider(
                value: tempTime.toDouble(),
                min: 0,
                max: 120,
                divisions: 120,
                label: '$tempTime min',
                onChanged: (value) {
                  setState(() {
                    tempTime = value.toInt();
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  hintText: 'Enter minutes',
                ),
                onChanged: (value) {
                  setState(() {
                    tempTime = int.tryParse(value) ?? tempTime;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTime = tempTime;
                });
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
