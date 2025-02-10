import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _iconUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final account = ref.read(authViewModelProvider).currentAccount;
    if (account != null) {
      _usernameController.text = account.username;
      _iconUrlController.text = account.iconUrl;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _iconUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateAccount() async {
    final newUsername = _usernameController.text.trim();
    final newIconUrl = _iconUrlController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザー名は必須です')),
      );
      return;
    }
    final authVM = ref.read(authViewModelProvider);
    try {
      await authVM.updateAccountInfo(
          username: newUsername, iconUrl: newIconUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(authViewModelProvider).currentAccount;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: account == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('メール: ${account.email}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'ユーザー名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // todo: アイコン画像のプレビューを表示する
                    // todo: アイコン画像をアップロードできるようにする(Firebase Storageを使う)
                    TextField(
                      controller: _iconUrlController,
                      decoration: const InputDecoration(
                        labelText: 'アイコン画像 URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateAccount,
                      child: const Text('更新'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
