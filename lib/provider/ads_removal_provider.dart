import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String adsRemovalProductId = 'app.web.mrCollection.remove_ads';
const String _adsRemovedPrefsKey = 'ads_removed';

final adsRemovalProvider =
    StateNotifierProvider<AdsRemovalNotifier, bool>((ref) {
  return AdsRemovalNotifier();
});

class AdsRemovalNotifier extends StateNotifier<bool> {
  AdsRemovalNotifier() : super(false) {
    _loadFromPrefs();
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _storeVerified = false;

  // キャッシュから広告削除状態を読み込む（ストア検証前の仮状態）。
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool(_adsRemovedPrefsKey) ?? false;
    if (cached && mounted && !_storeVerified) {
      state = true;
    }
  }

  // 購入復元で広告削除状態を確認する。
  Future<bool> restoreAdsRemovalStatus() async {
    final completer = Completer<bool>();
    final pendingPurchases = <PurchaseDetails>[];
    StreamSubscription<List<PurchaseDetails>>? subscription;

    subscription = _inAppPurchase.purchaseStream.listen(
      (purchases) {
        for (final purchase in purchases) {
          pendingPurchases.add(purchase);
          if (purchase.productID != adsRemovalProductId) {
            continue;
          }
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            if (!completer.isCompleted) {
              completer.complete(true);
            }
            break;
          }
        }
      },
      onError: (Object error) {
        debugPrint('[IAP] restore purchaseStream error: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await _inAppPurchase.restorePurchases();
      final restored =
          await completer.future.timeout(const Duration(seconds: 3),
              onTimeout: () {
        return false;
      });

      // 保留中のトランザクションを完了させる。
      for (final purchase in pendingPurchases) {
        if (purchase.pendingCompletePurchase) {
          try {
            await _inAppPurchase.completePurchase(purchase);
          } catch (_) {}
        }
      }

      debugPrint('ストアの情報：${restored ? '購入済み' : '未購入'}');
      _storeVerified = true;
      if (mounted) state = restored;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adsRemovedPrefsKey, restored);
      return restored;
    } finally {
      await subscription.cancel();
    }
  }

  // 広告削除の状態を更新して永続化する。
  Future<void> setAdsRemoved(bool value) async {
    state = value;
    if (value) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adsRemovedPrefsKey, true);
    }
  }
}
