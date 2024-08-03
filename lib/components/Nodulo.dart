import 'package:flutter/material.dart';

import 'StartingNode.dart';
import 'CommonNode.dart';
import 'NodeOptions.dart';
import 'buttons/EstimateButton.dart'; // Import the updated button file

class Nodulo extends StatefulWidget {
  String? title;
  int? nodeId;
  ValueNotifier<int> selectedNode;
  final Function setSelectedNode;
  final VoidCallback createSon;
  final VoidCallback createBro;
  final TransformationController controller;
  final bool isCommonNode;

  Nodulo(this.nodeId, this.title, this.selectedNode, this.setSelectedNode,
      this.createSon, this.createBro, this.controller, this.isCommonNode);

  @override
  State<Nodulo> createState() => _NoduloState(nodeId, title, selectedNode,
      setSelectedNode, createSon, createBro, controller, isCommonNode);
}

class _NoduloState extends State<Nodulo> {
  var isSelected = false;
  bool isFirst = false;
  late FocusNode myFocusNode = new FocusNode();

  void handleFocus(value) {
    if (value == this.nodeId && isSelected == false) {
      isSelected = true;
    } else {
      isSelected = false;
    }
  }

  int? nodeId;
  String? title;
  ValueNotifier<int> selectedNode;
  final Function setSelectedNode;
  final VoidCallback createSon;
  final VoidCallback createBro;
  final TransformationController controller;
  final bool isCommonNode;

  _NoduloState(this.nodeId, this.title, this.selectedNode, this.setSelectedNode,
      this.createSon, this.createBro, this.controller, this.isCommonNode);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSelectedNode(nodeId);
      },
      onLongPress: () {
        setSelectedNode(nodeId);
      },
      child: ValueListenableBuilder(
        valueListenable: selectedNode,
        builder: (context, value, child) {
          handleFocus(value);
          return Stack(
            children: [
              Row(
                children: [
                  isFirst
                      ? StartingNode(isSelected, selectedNode, setSelectedNode,
                          nodeId, myFocusNode)
                      : CommonNode(isSelected, selectedNode, setSelectedNode,
                          nodeId, myFocusNode),
                  if (isSelected)
                    NodeOptions(
                      createSon,
                      createBro,
                      isFirst,
                      () {
                        // Define the action for the EstimateButton
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Estimate button pressed')),
                        );
                      },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (this.nodeId == 1) {
      isFirst = true;
    }
    setSelectedNode(nodeId);
    myFocusNode.requestFocus();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
