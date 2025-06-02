import 'dart:io';

// テスト用のIDを出すヘルパークラス
class AdHelper {
  static String bannerTestId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android バナー
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS バナー
    }
    throw UnsupportedError('Unsupported platform');
  }

  // 参考：本番用 ID を返すメソッドを足しておくと切替えがラク
  static String bannerProdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa'; // 後々設定
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8038336425425966/9529142673';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
