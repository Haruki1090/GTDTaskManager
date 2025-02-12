import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/constants/notion_colors.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:gtd_task_manager/services/notion_service.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/notion_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/task_viewmodel.dart';
import 'package:gtd_task_manager/views/screens/account_settings_screen.dart';
import 'package:gtd_task_manager/views/screens/settings_screen.dart';
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

  // 新規タスク追加モーダル
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
                          IconButton(
                            icon: const Icon(Icons.color_lens,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () {
                              // todo: [bug] 選択したカラーが反映されない.
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('カラーを選択'),
                                    content: Wrap(
                                      children: notionColors
                                          .map((color) => GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context, color);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Color(color),
                                                        shape: BoxShape.circle,
                                                        border: color ==
                                                                0xFF337EA9
                                                            ? Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 2)
                                                            : null,
                                                      ),
                                                      // デフォルトカラーの場合は「デフォルト」と表示
                                                      child: color == 0xFF337EA9
                                                          ? const Center(
                                                              child: Text(
                                                                'デフォルト',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 8,
                                                                ),
                                                              ),
                                                            )
                                                          : null),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors.white),
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(greyColor),
                              ),
                              onPressed: () {
                                // todo: [bug] 選択した日付が反映されない.
                                showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: blueColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });
                              }),
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () {
                              // todo: [bug] 選択したステータスが反映されない.
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('ステータスを選択'),
                                    content: Wrap(
                                      children: [
                                        ListTile(
                                          title: const Text('Inbox'),
                                          onTap: () {
                                            Navigator.pop(
                                                context, TaskStatus.inbox);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Next Action'),
                                          onTap: () {
                                            Navigator.pop(
                                                context, TaskStatus.nextAction);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Waiting'),
                                          onTap: () {
                                            Navigator.pop(
                                                context, TaskStatus.waiting);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Someday'),
                                          onTap: () {
                                            Navigator.pop(
                                                context, TaskStatus.someday);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // todo: タスクのプロジェクトを設定する機能の実装
                          IconButton(
                            icon: const Icon(Icons.folder, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () {},
                          ),
                          // todo: タスクのコンテキスト（ラベル）を設定する機能の実装
                          IconButton(
                            icon: Icon(Icons.label, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () {},
                          ),
                          // 追加送信ボタン
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

  Widget _buildTaskSection(String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // todo: セクションのアイコンを設定する
              Text(
                title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${tasks.length} tasks',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "タスクがありません。",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ...tasks.map((task) => _buildTaskTile(task)).toList(),
        const Divider(), // セクション間の区切り
      ],
    );
  }

  // タスクリストのタイル
  Widget _buildTaskTile(Task task) {
    // todo: inboxのタイルはtrailingのアイコンを別のものにする（ユーザーが任意に設定したステータスに変更できるボタン）
    return ListTile(
      textColor: Color(task.taskColor),
      title: Text(task.title),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(task.description!)
          : null,
      trailing: Icon(
        task.status == TaskStatus.completed
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color: task.status == TaskStatus.completed ? Colors.green : null,
      ),
      onTap: () {
        _showTaskDetailModal(task);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.read(authViewModelProvider);
    // tasksProvider は family で uid を渡して Firestore 上のタスク一覧を取得する前提
    final tasksAsync = ref.watch(tasksProvider);
    final authVM = ref.read(authViewModelProvider);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return PopScope(
      canPop: true, // 戻る操作を許可
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // todo: 戻る操作が許可された場合の処理
        } else {
          // todo: 戻る操作がブロックされた場合の処理
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(),
        key: scaffoldKey,
        drawer: Drawer(
          backgroundColor: blueColor,
          width: MediaQuery.of(context).size.width * 0.6,
          child: ListView(
            children: [
              ListTile(
                title:
                    const Text('アカウント', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.face, color: Colors.white),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (_) => AccountSettingsScreen());
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (_) => const AccountSettingsScreen()),
                  // );
                },
              ),
              ListTile(
                title: const Text('設定', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.settings, color: Colors.white),
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: (_) => const SettingsScreen());
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  // );
                },
              ),
              ListTile(
                title:
                    const Text('ログアウト', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.logout, color: Colors.white),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('本当にログアウトしますか？',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 18)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('いいえ',
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await authVM.signOut();
                            },
                            child:
                                Text('はい', style: TextStyle(color: redColor)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Divider(),
              // todo: プロジェクト一覧の表示
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return const Center(child: Text('タスクがありません。'));
              }

              // タスクをステータスごとに分類
              final inboxTasks = tasks
                  .where((task) => task.status == TaskStatus.inbox)
                  .toList();
              final nextActionTasks = tasks
                  .where((task) => task.status == TaskStatus.nextAction)
                  .toList();
              final waitingTasks = tasks
                  .where((task) => task.status == TaskStatus.waiting)
                  .toList();
              final somedayTasks = tasks
                  .where((task) => task.status == TaskStatus.someday)
                  .toList();

              return ListView(
                children: [
                  _buildTaskSection('Inbox', inboxTasks),
                  _buildTaskSection('Next Action', nextActionTasks),
                  _buildTaskSection('Waiting', waitingTasks),
                  _buildTaskSection('Someday', somedayTasks),
                ],
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
      ),
    );
  }
}
