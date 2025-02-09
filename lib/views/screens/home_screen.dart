import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/constants/notion_colors.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/notion_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/task_viewmodel.dart';
import 'package:gtd_task_manager/views/widgets/glass_app_bar.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // キーボード分の余白
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _taskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'タスクのタイトルを入力',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // todo: タスク詳細入力欄を追加(カレンダーなど)
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(blueColor),
                            ),
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
                              // Notion 連携
                              final notionVM =
                                  ref.read(notionViewModelProvider);
                              final notionAccount =
                                  notionVM.currentNotionAccount;
                              if (notionAccount != null) {
                                try {
                                  await NotionService.addTask(
                                      notionAccount, newTask);
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTaskDetailModal(Task task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // キーボードに合わせて高さ調整
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // キーボード分の余白
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _taskTitleController..text = task.title,
                        decoration: const InputDecoration(
                          hintText: 'タスクのタイトルを入力',
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _taskDescController
                          ..text = task.description ?? '',
                        decoration: const InputDecoration(
                          hintText: 'タスクの詳細を入力',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(blueColor),
                            ),
                            onPressed: () async {
                              final taskVM = ref.read(taskViewModelProvider);
                              await taskVM.updateTask(
                                task.copyWith(
                                  title: _taskTitleController.text.trim(),
                                  description: _taskDescController.text.trim(),
                                ),
                              );

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(),
      body: Container(
        color: Colors.white,
        child: tasksAsync.when(
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
                    color: task.status == TaskStatus.completed
                        ? Colors.green
                        : null,
                  ),
                  // todo: タップ時の処理を追加(タスク詳細画面へ遷移)→TaskDetailScreenを表示
                  // BottomModalSheetでタスクの詳細を表示する
                  onTap: () {
                    _showTaskDetailModal(task);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('エラー: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        onPressed: _showAddTaskModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
