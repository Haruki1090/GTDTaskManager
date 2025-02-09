import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/repositories/notion_repository.dart';

final notionRepositoryProvider =
    Provider<NotionRepository>((ref) => NotionRepository());

final notionViewModelProvider = Provider<NotionViewModel>((ref) {
  final repository = ref.watch(notionRepositoryProvider);
  return NotionViewModel(notionRepository: repository);
});

class NotionViewModel {
  final NotionRepository notionRepository;
  NotionAccount? currentNotionAccount;

  NotionViewModel({required this.notionRepository});

  // Notion 連携を開始し、連携成功なら currentNotionAccount を設定する
  Future<NotionAccount?> linkNotion() async {
    final account = await notionRepository.linkNotion();
    if (account != null) {
      currentNotionAccount = account;
    }
  }
}
