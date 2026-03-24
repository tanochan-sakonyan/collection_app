# CLAUDE.md

## プロジェクト概要

**集金くん** - 集金管理アプリのフロントエンドリポジトリです。

- メインコードは `lib/` 配下に集約されています
- `packages/` には `flutter_line_sdk` がクローンされています（**触らないこと**）
- ネイティブコードを修正する際は `ios/`・`android/` ディレクトリを使用します

## よく使うコマンド

```bash
# 依存解決
flutter pub get

# 静的解析（実装後に必ず実行）
flutter analyze

# コード生成（Freezed モデルや JSON シリアライズを変更した場合）
dart run build_runner build --delete-conflicting-outputs
```

実装の最後に、`flutter analyze` で静的エラーが出ていないことを**必ず**確認してください。

## アーキテクチャ

### ディレクトリ構成

| ディレクトリ | 役割 |
|---|---|
| `lib/ui/screen/` | 各画面 |
| `lib/ui/components/` | 再利用可能な UI コンポーネント・ダイアログ |
| `lib/provider/` | Riverpod プロバイダ（状態管理） |
| `lib/data/model/freezed/` | Freezed による不変データモデル |
| `lib/data/repository/` | API 通信処理（Repository パターン） |
| `lib/services/` | ビジネスロジック |
| `lib/logging/` | Firebase Analytics ロギング |
| `lib/ads/` | 広告・課金処理 |
| `lib/l10n/` | 多言語対応（日本語・英語） |
| `lib/generated/` | 自動生成ファイル（直接編集しない） |

### 状態管理

Riverpod の `StateNotifierProvider` を使用しています。新しい状態を追加する際は既存のプロバイダ（例: `lib/provider/`）を参考にしてください。

### データモデル

データモデルは Freezed で定義します。モデルを変更・追加した場合は `build_runner` でコード生成が必要です。

## コーディング規約

- 追加した関数には、一言**日本語**でコメントを付けてください
- ターミナルへの説明・回答は**日本語**で行ってください
- クラス名・プロバイダ名は PascalCase、変数名は camelCase

## テスト

テストは実装していません。静的解析（`flutter analyze`）を品質担保の手段としています。

## 広告実装ルール

- **広告削除チェック必須**: すべての広告表示箇所で `adsRemovalProvider` を確認し、課金済みユーザーには広告を表示しないこと
- 広告を新たに追加する場合は、既存パターン（`if (!ref.read(adsRemovalProvider)) { ... }`）に従うこと
- インタースティシャル広告は `lib/ads/interstitial_singleton.dart` のシングルトンを使用すること

## 禁止事項

- `packages/` 配下のコードを変更しない
- API キーや秘密情報をコードに埋め込まない
- `lib/generated/` 配下のファイルを直接編集しない
