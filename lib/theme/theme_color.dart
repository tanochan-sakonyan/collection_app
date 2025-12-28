import 'package:flutter/material.dart';

class ThemeColorOption {
  final String keyName;
  final String displayName;
  final Color color;

  const ThemeColorOption._(this.keyName, this.displayName, this.color);

  static const ThemeColorOption defaultColor =
      ThemeColorOption._('default', 'デフォルト', Color(0xFF76DCC6));
  static const ThemeColorOption sakura =
      ThemeColorOption._('sakura', 'サクラ', Color(0xFFED80AF));
  static const ThemeColorOption ajisai =
      ThemeColorOption._('ajisai', 'アジサイ', Color(0xFF7698DC));
  static const ThemeColorOption ichou =
      ThemeColorOption._('ichou', 'イチョウ', Color(0xFFF2D532));

  static const List<ThemeColorOption> values = [
    defaultColor,
    sakura,
    ajisai,
    ichou,
  ];

  // 保存されたキーからテーマカラーを取得する
  static ThemeColorOption fromKey(String? key) {
    if (key == null) {
      return defaultColor;
    }
    return values.firstWhere(
      (option) => option.keyName == key,
      orElse: () => defaultColor,
    );
  }
}
