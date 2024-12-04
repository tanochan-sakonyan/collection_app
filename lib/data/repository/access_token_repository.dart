import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class AccessTokenRepository {
  Future<StoredAccessToken?> fetchAccessToken() async {
    try {
      StoredAccessToken? accessToken =
          await LineSDK.instance.currentAccessToken;
      return accessToken;
    } on PlatformException catch (e) {
      debugPrint("Error code: ${e.code}, Message: ${e.message}");
      return null;
    }
  }
}
