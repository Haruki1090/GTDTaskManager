import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/viewmodels/notion_viewmodel.dart';
import 'package:gtd_task_manager/viewmodels/task_viewmodel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotionAccount? _notionAccount;

  Future<void> _linkNotion() async {
    final notionViewModel = ref.read(notionViewModelProvider);
    try {
      final account = await notionViewModel.linkNotion();
      if (account != null) {
        setState(() {
          _notionAccount = account;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notionとの連携に成功しました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notion連携エラー: $e')),
      );
    }
  }

  Future<void> _syncNotion() async {
    if (_notionAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('まずNotionと連携してください')),
      );
      return;
    }
    try {
      // 実際の認証済みユーザーのIDに置き換える
      const userId = "currentUserId";
      final taskViewModel = ref.read(taskViewModelProvider);
      await taskViewModel.syncTasksWithNotion(userId, _notionAccount!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notionとの同期に成功しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notion同期エラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _linkNotion,
              child: const Text('Notionと連携'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _syncNotion,
              child: const Text('Notionと同期'),
            ),
          ],
        ),
      ),
    );
  }
}
