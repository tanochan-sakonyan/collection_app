import 'dart:io';

// テスト用のIDを返すメソッド
class AdHelper {
  static String bannerTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android バナー広告テストID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS バナー広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // 本番用 ID を返すメソッド
  static String bannerProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/9529142673'; // iOS バナー広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String interstitialTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS インタースティシャル広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String interstitialProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/bbbbbbbbbb'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/7488002928'; // iOS インタースティシャル広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // アイドル時インタースティシャル広告のテストIDを返す。
  static String idleInterstitialTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS インタースティシャル広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // アイドル時インタースティシャル広告の本番IDを返す。
  static String idleInterstitialProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/bbbbbbbbbb'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/2148213506'; // iOS アイドル時インタースティシャル広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // リワード広告のテストIDを返す。
  static String rewardedTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android リワード広告テストID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS リワード広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // リワード広告の本番IDを返す。
  static String rewardedProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/cccccccccc'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/1467488970'; // iOS リワード広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // LINEグループ追加時リワード広告のテストIDを返す。
  static String lineGroupRewardedTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android リワード広告テストID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS リワード広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // LINEグループ追加時リワード広告の本番IDを返す。
  static String lineGroupRewardedProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/cccccccccc'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/5937784276'; // iOS LINEグループ追加時リワード広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // 個別金額確定時リワード広告のテストIDを返す。
  static String amountConfirmRewardedTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android リワード広告テストID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS リワード広告テストID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // 個別金額確定時リワード広告の本番IDを返す。
  static String amountConfirmRewardedProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/cccccccccc'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/3213883164'; // iOS 個別金額確定時リワード広告本番ID
    }
    throw UnsupportedError('Unsupported platform');
  }
}
