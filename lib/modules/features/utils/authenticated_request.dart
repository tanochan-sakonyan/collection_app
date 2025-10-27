import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/modules/features/data/exception/auth_exception.dart';
import 'package:mr_collection/modules/features/utils/token_storage.dart';

typedef AuthenticatedRequestCallback = Future<http.Response> Function(
    String? accessToken);

class AuthenticatedRequestHelper {
  final String baseUrl;
  final String contextLabel;
  final http.Client _client;

  AuthenticatedRequestHelper({
    required this.baseUrl,
    this.contextLabel = '',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // 認証付きでHTTPリクエストを送り、必要ならトークンを更新する
  Future<http.Response> sendWithAuth(
    AuthenticatedRequestCallback request, {
    bool requireAuth = true,
  }) async {
    final refreshToken = await TokenStorage.getRefreshToken();
    var accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null && refreshToken != null) {
      _log('アクセストークンが見つからないためリフレッシュします。');
      accessToken = await _refreshAccessToken(refreshToken);
    }

    if (accessToken == null && requireAuth) {
      throw const RefreshTokenExpiredException('認証情報が見つかりません');
    }

    final response = await request(accessToken);
    if (response.statusCode != 401 || refreshToken == null) {
      return response;
    }

    final message = _extractMessage(response.body);
    if (message != 'Token has expired!') {
      return response;
    }

    _log('アクセストークン期限切れを検知。リフレッシュします。');
    final newAccessToken = await _refreshAccessToken(refreshToken);
    if (newAccessToken == null) {
      throw const RefreshTokenExpiredException('リフレッシュトークンが失効しています');
    }

    return request(newAccessToken);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/auth/refresh');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      _log('アクセストークンの更新に失敗しました: ${response.statusCode}');
      return null;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        _log('アクセストークン更新レスポンスの形式が不正です: ${response.body}');
        return null;
      }

      final newAccessToken =
          _readToken(data, 'access_token') ?? _readToken(data, 'accessToken');
      final newRefreshToken = _readToken(data, 'refresh_token') ??
          _readToken(data, 'refreshToken') ??
          refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        _log('新しいアクセストークンが取得できませんでした');
        return null;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      _log('リフレッシュトークンでアクセストークンを更新しました。');

      return newAccessToken;
    } catch (e) {
      _log('アクセストークン更新のレスポンス解析に失敗しました: $e');
      return null;
    }
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          return message;
        }
      }
    } catch (_) {
      // no-op
    }
    return null;
  }

  String? _readToken(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }

  void _log(String message) {
    if (contextLabel.isEmpty) {
      debugPrint(message);
    } else {
      debugPrint('$contextLabel: $message');
    }
  }
}
