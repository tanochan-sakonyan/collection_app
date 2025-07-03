import 'dart:io';

// テスト用のIDを返すメソッド
class AdHelper {
  static String bannerTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android バナー広告ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS バナー広告ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // 本番用 ID を返すメソッド
  static String bannerProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa'; // TODO: 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/9529142673';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
