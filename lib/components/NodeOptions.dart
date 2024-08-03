import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'buttons/CreateSonButton.dart';
import 'buttons/CreateBroButton.dart';
import 'dart:math';
import 'buttons/EstimateButton.dart'; // Import the updated button file

class NodeOptions extends StatelessWidget {
  final VoidCallback createSon;
  final VoidCallback createBro;
  final bool isFirst;
  final VoidCallback estimateButtonOnPressed; // Callback for EstimateButton

  NodeOptions(this.createSon, this.createBro, this.isFirst,
      this.estimateButtonOnPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          isFirst
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [CreateSonButton(createSon)],
                )
              : Transform.translate(
                  offset: Offset(0, 46),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CreateSonButton(createSon),
                      SizedBox(
                        height: 10,
                      ),
                      CreateBroButton(createBro),
                    ],
                  ),
                ),
          if (!isFirst)
            Positioned(
              top: 1, // Adjust to position at the top
              right: 0, // Adjust to position correctly
              child: Transform.rotate(
                angle: 0, // Rotate 90 degrees
                child: EstimateButton(
                  onPressed: estimateButtonOnPressed, // Pass the callback
                ),
              ),
            ),
        ],
      ),
    );
  }
}
