import 'dart:async';
import 'dart:developer';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/ads/interstitial_service.dart';

/// アイドル時インタースティシャル広告用のシングルトン。
InterstitialService _idleInterstitial = InterstitialService(
  useProd: kReleaseMode,
  adUnitIdOverride: kReleaseMode
      ? AdHelper.idleInterstitialProdId()
      : AdHelper.idleInterstitialTestId(),
);

@visibleForTesting
// テスト用にアイドル時インタースティシャル広告を差し替える。
void setIdleInterstitialForTesting(InterstitialService service) {
  _idleInterstitial = service;
}

/// アイドル時インタースティシャル広告のインスタンスを取得する。
InterstitialService get idleInterstitial => _idleInterstitial;

/// アイドルタイマーマネージャーのシングルトンインスタンス。
final idleInterstitialManager = IdleInterstitialManager();

/// HomeScreenのアイドル時にインタースティシャル広告を表示するマネージャー。
class IdleInterstitialManager {
  final Duration idleTimeout;
  final Duration cooldownDuration;

  Timer? _idleTimer;
  DateTime? _lastShownAt;
  VoidCallback? _onShowAd;

  IdleInterstitialManager({
    this.idleTimeout = const Duration(seconds: 30),
    this.cooldownDuration = const Duration(minutes: 10),
  });

  /// 広告表示時のコールバックを設定する。
  set onShowAd(VoidCallback? callback) => _onShowAd = callback;

  /// アイドルタイマーを開始する。
  void start() {
    _resetTimer();
  }

  /// ユーザー操作を検知してタイマーをリセットする。
  void resetTimer() {
    if (_idleTimer == null) return; // タイマーが動いていない場合は何もしない
    _resetTimer();
  }

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, _onIdle);
  }

  /// アイドル時間経過時の処理。
  Future<void> _onIdle() async {
    if (_isInCooldown()) {
      log('Idle interstitial skipped: in cooldown');
      _resetTimer(); // クールダウン中でも次の検出のためにタイマーを再開する
      return;
    }
    if (!_idleInterstitial.isReady) {
      log('Idle interstitial skipped: ad not ready');
      _resetTimer();
      return;
    }
    _lastShownAt = clock.now();
    _onShowAd?.call();
    await _idleInterstitial.show();
    // 広告表示後にタイマーを再スタートする（クールダウン判定で弾かれる）
    _resetTimer();
  }

  /// クールダウン中かどうか判定する。
  bool _isInCooldown() {
    if (_lastShownAt == null) return false;
    return clock.now().difference(_lastShownAt!) < cooldownDuration;
  }

  /// タイマーを停止する。
  void stop() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  /// リソースを解放する（シングルトンとして使う場合は stop と同じ動作）。
  void dispose() {
    stop();
  }
}
