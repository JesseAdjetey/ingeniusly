import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTask(Map<String, dynamic> task) async {
    await _db.collection('tasks').add(task);
  }

  Future<void> updateTask(String id, Map<String, dynamic> task) async {
    await _db.collection('tasks').doc(id).update(task);
  }

  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getTasks() {
    return _db.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }
}
