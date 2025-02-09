import 'package:freezed_annotation/freezed_annotation.dart';

part 'notion_account.freezed.dart';
part 'notion_account.g.dart';

@freezed
class NotionAccount with _$NotionAccount {
  factory NotionAccount({
    // Notion API アクセストークン
    required String accessToken,
    // ユーザー専用のNotionデータベースID
    required String databaseId,
  }) = _NotionAccount;

  factory NotionAccount.fromJson(Map<String, dynamic> json) =>
      _$NotionAccountFromJson(json);
}
