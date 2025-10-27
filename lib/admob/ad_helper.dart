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
}
