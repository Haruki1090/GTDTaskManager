import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/notion_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/task_viewmodel.dart';
import 'package:gtd_task_manager/views/screens/account_settings_screen.dart';
import 'package:gtd_task_manager/views/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String uid;
  const HomeScreen({super.key, required this.uid});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // キーボードに合わせて高さ調整
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // キーボード分の余白
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                const Text(
                  'タスクを追加',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taskDescController,
                  decoration: const InputDecoration(
                    labelText: '説明 (任意)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final title = _taskTitleController.text.trim();
                    final desc = _taskDescController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('タイトルは必須です。')),
                      );
                      return;
                    }
                    final newTask = Task(
                      title: title,
                      description: desc,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      userId: widget.uid,
                      status: TaskStatus.inbox,
                    );
                    // Firebase にタスク追加
                    final taskVM = ref.read(taskViewModelProvider);
                    await taskVM.addTask(newTask);
                    // Notion 連携している場合は Notion へ同期
                    final notionVM = ref.read(notionViewModelProvider);
                    final notionAccount = notionVM.currentNotionAccount;
                    if (notionAccount != null) {
                      try {
                        await NotionService.addTask(notionAccount, newTask);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notion同期失敗: $e')),
                        );
                      }
                    }
                    _taskTitleController.clear();
                    _taskDescController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('追加'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = ref.read(authViewModelProvider);
    // tasksProvider は family で uid を渡して Firestore 上のタスク一覧を取得する前提
    final tasksAsync = ref.watch(tasksProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.face),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AccountSettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              // サインアウト後の遷移は各自実装
            },
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('タスクがありません。'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle:
                    (task.description != null && task.description!.isNotEmpty)
                        ? Text(task.description!)
                        : null,
                trailing: Icon(
                  task.status == TaskStatus.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      task.status == TaskStatus.completed ? Colors.green : null,
                ),
                onTap: () {
                  // タスク編集画面への遷移があれば実装
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
