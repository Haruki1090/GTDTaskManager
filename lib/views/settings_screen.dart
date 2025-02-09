import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _linkNotion(BuildContext context) async {
    try {
      await NotionService().linkNotion();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notionとの連携が完了しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
            // 他の設定項目があればここに追加
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _linkNotion(context),
              child: const Text('Notionと連携'),
            ),
          ],
        ),
      ),
    );
  }
}
