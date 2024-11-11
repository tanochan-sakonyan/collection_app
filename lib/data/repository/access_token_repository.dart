import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class AccessTokenRepository {
  // アクセストークンを取得する非同期関数
  Future<StoredAccessToken?> fetchAccessToken() async {
    try {
      // currentAccessTokenを取得
      StoredAccessToken? accessToken =
          await LineSDK.instance.currentAccessToken;
      return accessToken;
    } on PlatformException catch (e) {
      // エラーハンドリング
      print("Error code: ${e.code}, Message: ${e.message}");
      return null; // エラーの場合はnullを返す
    }
  }
}
