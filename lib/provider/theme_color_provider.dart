import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/theme/theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeColorPrefsKey = 'selectedThemeColor';

final themeColorProvider =
    StateNotifierProvider<ThemeColorNotifier, ThemeColorOption>((ref) {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends StateNotifier<ThemeColorOption> {
  ThemeColorNotifier() : super(ThemeColorOption.defaultColor) {
    _loadThemeColor();
  }

  // 保存済みテーマカラーを読み込む
  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(_themeColorPrefsKey);
    state = ThemeColorOption.fromKey(storedKey);
  }

  // テーマカラーを変更して永続化する
  Future<void> updateThemeColor(ThemeColorOption option) async {
    state = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorPrefsKey, option.keyName);
  }

  // 選択されたテーマカラーを取得する
  ThemeColorOption currentColor() => state;
}
