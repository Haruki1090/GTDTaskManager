import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/repositories/task_repository.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository());

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  var userId = ref.watch(authStateProvider).data?.value?.uid;
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.getTasks(userId);
});

extension on AsyncValue<User?> {
  get data => null;
}

final taskViewModelProvider = Provider<TaskViewModel>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskViewModel(taskRepository: taskRepository);
});

class TaskViewModel {
  final TaskRepository taskRepository;
  TaskViewModel({required this.taskRepository});

  // 指定ユーザーのタスクを取得し、Notion へ同期する
  Future<void> syncTasksWithNotion(
      String userId, NotionAccount notionAccount) async {
    final tasks = await taskRepository.getTasks(userId).first;
    await NotionService.syncTasksWithNotion(notionAccount, tasks);
  }
}
