import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/repositories/task_repository.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository());

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

final taskViewModelProvider = Provider<TaskViewModel>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskViewModel(taskRepository: taskRepository);
});

class TaskViewModel {
  final TaskRepository taskRepository;
  TaskViewModel({required this.taskRepository});

  // タスクを Firestore に追加する
  Future<void> addTask(Task task) async {
    await taskRepository.addTask(task);
  }

  // 指定ユーザーのタスク一覧を取得し、Notion へ同期する
  Future<void> syncTasksWithNotion(
      String userId, NotionAccount notionAccount) async {
    final tasks = await taskRepository.getTasks(userId).first;
    await NotionService.syncTasksWithNotion(notionAccount, tasks);
  }
}
