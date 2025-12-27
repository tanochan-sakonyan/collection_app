import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final shukinkunAdsLocationServiceProvider =
    Provider<ShukinkunAdsLocationService>(
  (ref) => const ShukinkunAdsLocationService(),
);

class ShukinkunAdsLocationService {
  const ShukinkunAdsLocationService();

  // 現在位置を取得する
  Future<Position?> fetchCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('位置情報サービスが無効です');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('位置情報の権限が拒否されました');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('位置情報の権限が永久に拒否されています');
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
