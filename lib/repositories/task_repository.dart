import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtd_task_manager/models/task.dart';

class TaskRepository {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    final docRef = tasksCollection.doc();
    final taskWithId = task.copyWith(id: docRef.id);
    await docRef.set(taskWithId.toJson());
  }

  Stream<List<Task>> getTasks(String userId) {
    return tasksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) return;
    await tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }
}
