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
  NotionViewModel({required this.notionRepository});

  Future<NotionAccount?> linkNotion() async {
    return await notionRepository.linkNotion();
  }
}
