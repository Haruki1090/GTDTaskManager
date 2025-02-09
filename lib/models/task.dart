import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

// TaskStatusを文字列表現でJSONに出力するためのアノテーション
@JsonEnum(alwaysCreate: true)
enum TaskStatus {
  inbox,
  nextAction,
  waiting,
  completed,
  someday,
}

@freezed
class Task with _$Task {
  factory Task({
    String? id,
    required String title, // タスク名
    String? description, // 詳細
    @Default(TaskStatus.inbox) TaskStatus status, // ステータス
    DateTime? dueDate, // 期限日
    DateTime? createdAt, // 作成日時
    DateTime? updatedAt, // 更新日時
    String? project, // プロジェクト
    String? context, // コンテキスト 例：Work, Homeなど
    String? userId, // ユーザーID
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
