import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:gtd_task_manager/models/notion_account.dart';
import 'package:http/http.dart' as http;

class NotionRepository {
  // Notion OAuthフローを開始し ユーザー固有のNotionAccountを返す
  Future<NotionAccount?> linkNotion() async {
    final clientId = dotenv.env['NOTION_CLIENT_ID']!;
    final redirectUri = dotenv.env['NOTION_REDIRECT_URI']!;
    final notionAuthUrl =
        'https://api.notion.com/v1/oauth/authorize?owner=user&client_id=$clientId&redirect_uri=$redirectUri&response_type=code';
    try {
      // OAuthフローを開始
      final result = await FlutterWebAuth.authenticate(
          url: notionAuthUrl, callbackUrlScheme: Uri.parse(redirectUri).scheme);
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Notion OAuth に失敗しました（codeが取得できません）');
      }
      // code を交換してアクセストークンを取得
      final account = await _exchangeCodeForToken(code);
      return account;
    } catch (e) {
      throw Exception('Notion連携に失敗しました: $e');
    }
  }

  Future<NotionAccount?> _exchangeCodeForToken(String code) async {
    final clientId = dotenv.env['NOTION_CLIENT_ID']!;
    final clientSecret = dotenv.env['NOTION_CLIENT_SECRET']!;
    final redirectUri = dotenv.env['NOTION_REDIRECT_URI']!;
    final url = Uri.parse('https://api.notion.com/v1/oauth/token');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Notion-Version': '2022-06-28',
        },
        body: jsonEncode(
          {
            'client_id': clientId,
            'client_secret': clientSecret,
            'redirect_uri': redirectUri,
            'code': code,
            'grant_type': 'authorization_code',
          },
        ));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final databaseId = data['database_id'] ?? 'default_database_id';
      return NotionAccount(accessToken: accessToken, databaseId: databaseId);
    } else {
      throw Exception(
          'Notionトークン取得失敗: ${response.statusCode} ${response.body}');
    }
  }
}
