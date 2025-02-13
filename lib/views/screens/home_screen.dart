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

  // 選択値用の state 変数
  int _selectedColor = 0xFF337EA9;
  DateTime? _selectedDate;
  TaskStatus _selectedStatus = TaskStatus.inbox;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  // 新規タスク追加モーダル（モーダルボトムシート）
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
                      // タイトル入力
                      TextField(
                        controller: _taskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'タスクのタイトルを入力',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 下段：各種選択ボタン
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // カラー選択ボタン
                          IconButton(
                            icon: const Icon(Icons.color_lens,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Color(_selectedColor)),
                            ),
                            onPressed: () async {
                              final selectedColor = await showDialog<int>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('カラーを選択'),
                                    content: Wrap(
                                      children: notionColors.map((color) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context, color);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Color(color),
                                                shape: BoxShape.circle,
                                                border: color == _selectedColor
                                                    ? Border.all(
                                                        color: Colors.grey,
                                                        width: 2)
                                                    : null,
                                              ),
                                              // デフォルトカラーの場合は「デフォルト」と表示
                                              child: color == 0xFF337EA9
                                                  ? const Center(
                                                      child: Text(
                                                        'デフォルト',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );
                              if (selectedColor != null) {
                                setState(() {
                                  _selectedColor = selectedColor;
                                });
                              }
                            },
                          ),
                          // 日付選択ボタン
                          IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
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
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                          // ステータス選択ボタン
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () async {
                              final selectedStatus =
                                  await showDialog<TaskStatus>(
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
                              if (selectedStatus != null) {
                                setState(() {
                                  _selectedStatus = selectedStatus;
                                });
                              }
                            },
                          ),
                          // todo: プロジェクト選択やコンテキスト選択は未実装
                          IconButton(
                            icon: const Icon(Icons.folder, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(greyColor),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.label, color: Colors.white),
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
                                status: _selectedStatus, // 選択したステータスを反映
                                dueDate: _selectedDate, // 選択した日付を反映
                                taskColor: _selectedColor, // 選択したカラーを反映
                              );
                              // Firebase にタスク追加
                              final taskVM = ref.read(taskViewModelProvider);
                              await taskVM.addTask(newTask);
                              // Notion 連携している場合は Notion にも追加
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
                              // 選択状態のリセット
                              setState(() {
                                _selectedColor = 0xFF337EA9;
                                _selectedDate = null;
                                _selectedStatus = TaskStatus.inbox;
                              });
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

  // タスク詳細編集用のモーダルボトムシート
  // todo: [bug]カラーが変更されない
  Future<void> _showTaskDetailModal(Task task) async {
    _taskTitleController.text = task.title;
    _taskDescController.text = task.description ?? '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
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
                      TextField(
                        controller: _taskDescController,
                        decoration: const InputDecoration(
                          hintText: 'タスクの詳細を入力',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 24),
                          // 下段：各種選択ボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // カラー選択ボタン
                              IconButton(
                                icon: const Icon(Icons.color_lens,
                                    color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Color(_selectedColor)),
                                ),
                                onPressed: () async {
                                  final selectedColor = await showDialog<int>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text('カラーを選択'),
                                        content: Wrap(
                                          children: notionColors.map((color) {
                                            return GestureDetector(
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
                                                            _selectedColor
                                                        ? Border.all(
                                                            color: Colors.grey,
                                                            width: 2)
                                                        : null,
                                                  ),
                                                  // デフォルトカラーの場合は「デフォルト」と表示
                                                  child: color == 0xFF337EA9
                                                      ? const Center(
                                                          child: Text(
                                                            'デフォルト',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8,
                                                            ),
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  );
                                  if (selectedColor != null) {
                                    setState(() {
                                      _selectedColor = selectedColor;
                                    });
                                  }
                                },
                              ),
                              // 日付選択ボタン
                              IconButton(
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(greyColor),
                                ),
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
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
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                },
                              ),
                              // ステータス選択ボタン
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(greyColor),
                                ),
                                onPressed: () async {
                                  final selectedStatus =
                                      await showDialog<TaskStatus>(
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
                                                Navigator.pop(context,
                                                    TaskStatus.nextAction);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Waiting'),
                                              onTap: () {
                                                Navigator.pop(context,
                                                    TaskStatus.waiting);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Someday'),
                                              onTap: () {
                                                Navigator.pop(context,
                                                    TaskStatus.someday);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                  if (selectedStatus != null) {
                                    setState(() {
                                      _selectedStatus = selectedStatus;
                                    });
                                  }
                                },
                              ),
                              // todo: プロジェクト選択やコンテキスト選択は未実装
                              IconButton(
                                icon: const Icon(Icons.folder,
                                    color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(greyColor),
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.label,
                                    color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(greyColor),
                                ),
                                onPressed: () {},
                              ),
                              // 追加送信ボタン
                              IconButton(
                                icon:
                                    const Icon(Icons.send, color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(blueColor),
                                ),
                                onPressed: () async {
                                  final title =
                                      _taskTitleController.text.trim();
                                  final desc = _taskDescController.text.trim();
                                  if (title.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('タイトルは必須です。')),
                                    );
                                    return;
                                  }
                                  final newTask = Task(
                                    title: title,
                                    description: desc,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    userId: widget.uid,
                                    status: _selectedStatus, // 選択したステータスを反映
                                    dueDate: _selectedDate, // 選択した日付を反映
                                    taskColor: _selectedColor, // 選択したカラーを反映
                                  );
                                  // Firebase にタスク追加
                                  final taskVM =
                                      ref.read(taskViewModelProvider);
                                  await taskVM.addTask(newTask);
                                  // Notion 連携している場合は Notion にも追加
                                  final notionVM =
                                      ref.read(notionViewModelProvider);
                                  final notionAccount =
                                      notionVM.currentNotionAccount;
                                  if (notionAccount != null) {
                                    try {
                                      await NotionService.addTask(
                                          notionAccount, newTask);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Notion同期失敗: $e')),
                                      );
                                    }
                                  }
                                  _taskTitleController.clear();
                                  _taskDescController.clear();
                                  // 選択状態のリセット
                                  setState(() {
                                    _selectedColor = 0xFF337EA9;
                                    _selectedDate = null;
                                    _selectedStatus = TaskStatus.inbox;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 100),
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
    ).whenComplete(() {
      // モーダルが閉じられた後にテキストフィールドをクリア
      _taskTitleController.clear();
      _taskDescController.clear();
    });
  }

  // タスクセクション（ステータスごと）の構築
  Widget _buildTaskSection(String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              if (title == 'Inbox')
                const Icon(Icons.inbox, color: Colors.grey, size: 22)
              else if (title == 'Next Action')
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 22)
              else if (title == 'Waiting')
                const Icon(Icons.hourglass_empty, color: Colors.grey, size: 22)
              else if (title == 'Someday')
                const Icon(Icons.calendar_today, color: Colors.grey, size: 22),
              const SizedBox(width: 8),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "タスクがありません。",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ...tasks.map((task) => _buildTaskTile(task)),
        const Divider(),
      ],
    );
  }

  // タスクリストのタイル
  Widget _buildTaskTile(Task task) {
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
    final tasksAsync = ref.watch(tasksProvider);
    final authVM = ref.read(authViewModelProvider);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(),
      key: scaffoldKey,
      drawer: Drawer(
        backgroundColor: blueColor,
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          children: [
            ListTile(
              title: const Text('アカウント', style: TextStyle(color: Colors.white)),
              leading: const Icon(Icons.face, color: Colors.white),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => AccountSettingsScreen(),
                );
              },
            ),
            ListTile(
              title: const Text('設定', style: TextStyle(color: Colors.white)),
              leading: const Icon(Icons.settings, color: Colors.white),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const SettingsScreen(),
                );
              },
            ),
            ListTile(
              title: const Text('ログアウト', style: TextStyle(color: Colors.white)),
              leading: const Icon(Icons.logout, color: Colors.white),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text(
                        '本当にログアウトしますか？',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 18),
                      ),
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
                          child: Text('はい', style: TextStyle(color: redColor)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(),
            const ListTile(
              title: Text('プロジェクト', style: TextStyle(color: Colors.white)),
              leading: Icon(Icons.folder, color: Colors.white),
            ),
            const ListTile(
              title: Text('ラベル', style: TextStyle(color: Colors.white)),
              leading: Icon(Icons.label, color: Colors.white),
            ),
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
            final inboxTasks =
                tasks.where((task) => task.status == TaskStatus.inbox).toList();
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
    );
  }
}
