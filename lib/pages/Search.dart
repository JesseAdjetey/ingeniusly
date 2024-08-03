import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graphview/GraphView.dart';
import '../components/Nodulo.dart';

class TreeViewPage extends StatefulWidget {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  var json;
  var selectedNode = ValueNotifier<int>(0);
  final controller = TransformationController();
  final _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();
    initializeGraph();
  }

  Future<void> _saveMindMap(String mapName) async {
    try {
      await _firestore.collection('mind_maps').add({
        'name': mapName,
        'data': json,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Mind map saved successfully");
    } catch (e) {
      print("Error saving mind map: $e");
    }
  }

  Future<void> _loadMindMaps() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('mind_maps').get();
      if (querySnapshot.docs.isNotEmpty) {
        // Do something with the mind maps
        for (var doc in querySnapshot.docs) {
          print("Mind map: ${doc.data()}");
        }
      }
    } catch (e) {
      print("Error loading mind maps: $e");
    }
  }

  int addNode() {
    int newId = json["nodes"].length + 1;
    json['nodes'].add({
      "id": newId,
      "label": 'NEW NODE',
      "isCommonNode": true
    }); // Add "isCommonNode" field
    return newId;
  }

  void addEdge(int from, int to) {
    graph.addEdge(Node.Id(from), Node.Id(to));
  }

  void resetZoom() {
    controller.value = Matrix4.identity();
  }

  void createSon() {
    int newId = addNode();
    setState(() {});
    json['edges'].add({"from": selectedNode.value, "to": newId});
    addEdge(selectedNode.value, newId);
  }

  void createBro() {
    int newId = addNode();
    var previousNode = json['edges']
        .firstWhere((element) => element["to"] == selectedNode.value);
    int previousConnection = previousNode['from'];
    json['edges'].add({"from": previousConnection, "to": newId});
    setState(() {});
    addEdge(previousConnection, newId);
  }

  void deleteNode() {
    if (selectedNode.value == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete the root node")),
      );
      return;
    }
    var edges = json['edges'];
    var nodes = json['nodes'];
    var nodeIdArray = [selectedNode.value];
    for (var i = 0; i < edges.length; i++) {
      for (var index = 0; index < nodeIdArray.length; index++) {
        if (edges[i]['from'] == nodeIdArray[index]) {
          nodeIdArray.add(edges[i]['to']);
        }
      }
    }

    setState(() {
      nodeIdArray.forEach((element) {
        json['nodes'].removeWhere((node) => node['id'] == element);
        json['edges'].removeWhere(
            (node) => node['from'] == element || node['to'] == element);
      });
      graph.removeNode(Node.Id(nodeIdArray[0]));
    });
  }

  void setSelectedNode(int newNodeId) {
    selectedNode.value = newNodeId;
  }

  void initializeGraph() {
    json = {
      "nodes": [
        {"id": 1, "label": 'Initial', "isCommonNode": false}
      ],
      "edges": []
    };
    var nodes = json['nodes']!;
    graph.addNode(Node.Id(1));

    builder
      ..siblingSeparation = (50)
      ..levelSeparation = (100)
      ..subtreeSeparation = (50)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.value = Matrix4.identity()
        ..translate(12.0, 10.0)
        ..scale(0.5);
    });
  }

  void updateGraph(Map<String, dynamic> newJson) {
    setState(() {
      json = newJson;
    });
    var edges = json['edges']!;
    edges.forEach((element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: InteractiveViewer(
              transformationController: controller,
              constrained: false,
              boundaryMargin: EdgeInsets.all(1000),
              minScale: 0.01,
              maxScale: 2,
              child: GraphView(
                graph: graph,
                algorithm:
                    BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()
                  ..color = Colors.greenAccent
                  ..strokeWidth = 3
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  var a = node.key!.value as int?;
                  var nodes = json['nodes']!;
                  var nodeValue =
                      nodes.firstWhere((element) => element['id'] == a);
                  return rectangleWidget(nodeValue['id'], nodeValue['label'],
                      nodeValue['isCommonNode'] ?? false);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FloatingActionButton(
            onPressed: resetZoom,
            child: Icon(Icons.zoom_out_map),
            backgroundColor: Colors.purple,
          ),
        ),
        FloatingActionButton(
          onPressed: deleteNode,
          child: Icon(Icons.delete_outline_rounded),
          backgroundColor: Colors.redAccent,
        ),
      ]),
    );
  }

  Widget rectangleWidget(int? id, String? title, bool isCommonNode) {
    return Nodulo(
      id,
      title,
      selectedNode,
      setSelectedNode,
      createSon,
      createBro,
      controller,
      isCommonNode, // Pass the new parameter
    );
  }

  Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
}
