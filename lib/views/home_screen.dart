import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // ※ここではタスク一覧は未実装のプレースホルダーとしています
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.read(authViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
            },
          ),
        ],
      ),
      body: Center(child: Text('タスク一覧の表示（未実装）')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: タスク追加処理を実装
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
