import 'dart:convert';

import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:gtd_task_manager/models/task.dart';
import 'package:http/http.dart' as http;

class NotionService {
  // ユーザーのNotionAccount情報を用いてタスク一覧を同期する
  static Future<void> syncTasksWithNotion(
      NotionAccount account, List<Task> tasks) async {
    const notionVersion = '2022-06-28';
    final url = Uri.parse('https://api.notion.com/v1/pages');

    for (final task in tasks) {
      final payload = {
        "parent": {"database_id": account.databaseId},
        "properties": {
          "Name": {
            "title": [
              {
                "text": {"content": task.title}
              }
            ]
          },
          "Status": {
            "select": {"name": task.status.toString().split('.').last}
          },
          if (task.dueDate != null)
            "Due Date": {
              "date": {"start": task.dueDate!.toIso8601String()}
            },
          if (task.project != null)
            "Project": {
              "rich_text": [
                {
                  "text": {"content": task.project}
                }
              ]
            },
          if (task.label != null)
            "Context": {
              "rich_text": [
                {
                  "text": {"content": task.label}
                }
              ]
            },
          if (task.label != null)
            "Description": {
              "rich_text": [
                {
                  "text": {"content": task.description}
                }
              ]
            },
        },
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${account.accessToken}",
          "Notion-Version": notionVersion,
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('タスク ${task.id} の同期に失敗: ${response.body}');
      }
    }
  }

  // ユーザーのNotionAccount情報を用いてタスクを追加する
  static Future<void> addTask(NotionAccount account, Task task) async {
    const notionVersion = '2022-06-28';
    final url = Uri.parse('https://api.notion.com/v1/pages');

    final payload = {
      "parent": {"database_id": account.databaseId},
      "properties": {
        "Name": {
          "title": [
            {
              "text": {"content": task.title}
            }
          ]
        },
        "Status": {
          "select": {"name": task.status.toString().split('.').last}
        },
        if (task.dueDate != null)
          "Due Date": {
            "date": {"start": task.dueDate!.toIso8601String()}
          },
        if (task.project != null)
          "Project": {
            "rich_text": [
              {
                "text": {"content": task.project}
              }
            ]
          },
        if (task.label != null)
          "Context": {
            "rich_text": [
              {
                "text": {"content": task.label}
              }
            ]
          },
        if (task.label != null)
          "Description": {
            "rich_text": [
              {
                "text": {"content": task.description}
              }
            ]
          },
      },
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${account.accessToken}",
        "Notion-Version": notionVersion,
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('タスク ${task.id} の追加に失敗: ${response.body}');
    }
  }
}
