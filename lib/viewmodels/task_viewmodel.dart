import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/repositories/task_repository.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository());

// タスク一覧取得の Provider
// ユーザーがログインしている場合は、そのユーザーのタスク一覧を取得する
// ユーザーがログインしていない場合は、空のリストを返す
// ユーザーがログインしているかどうかは、authStateProvider で管理している
final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final asyncUser = ref.watch(authStateProvider);
  return asyncUser.when(
    data: (user) {
      final uid = user?.uid;
      final taskRepository = ref.watch(taskRepositoryProvider);
      if (uid == null) {
        return Stream.value([]);
      } else {
        return taskRepository.getTasks(uid);
      }
    },
    loading: () => Stream.value([]),
    error: (e, st) => Stream.value([]),
  );
});

// タスクの ViewModel の Provider
// taskRepositoryProvider を使って TaskViewModel を作成する
// この Provider を使って、タスクの追加、削除、更新、Notion への同期を行う
final taskViewModelProvider = Provider<TaskViewModel>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskViewModel(taskRepository: taskRepository);
});

// タスクの ViewModel クラス
// タスクの追加、削除、更新、Notion への同期を行う
class TaskViewModel {
  final TaskRepository taskRepository;
  TaskViewModel({required this.taskRepository});

  // タスクを Firestore に追加する
  Future<void> addTask(Task task) async {
    await taskRepository.addTask(task);
  }

  // タスクを Firestore から削除する
  Future<void> deleteTask(String taskId) async {
    await taskRepository.deleteTask(taskId);
  }

  // タスクを Firestore で更新する
  Future<void> updateTask(Task task) async {
    await taskRepository.updateTask(task);
  }

  // 指定ユーザーのタスク一覧を取得し、Notion へ同期する
  Future<void> syncTasksWithNotion(
      String userId, NotionAccount notionAccount) async {
    final tasks = await taskRepository.getTasks(userId).first;
    await NotionService.syncTasksWithNotion(notionAccount, tasks);
  }
}
