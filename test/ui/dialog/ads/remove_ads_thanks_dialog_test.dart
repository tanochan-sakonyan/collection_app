import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_collection/ui/components/dialog/ads/remove_ads_thanks_dialog.dart';

void main() {
  Widget buildDialog() {
    return const MaterialApp(
      home: Scaffold(
        body: RemoveAdsThanksDialog(),
      ),
    );
  }

  group('RemoveAdsThanksDialog - 表示', () {
    testWidgets('"Thank you!" テキストが表示される', (tester) async {
      await tester.pumpWidget(buildDialog());

      expect(find.text('Thank you!'), findsOneWidget);
    });

    testWidgets('"すでに広告は削除済みです。" テキストが表示される', (tester) async {
      await tester.pumpWidget(buildDialog());

      expect(find.text('すでに広告は削除済みです。'), findsOneWidget);
    });

    testWidgets('"閉じる" ボタンが表示される', (tester) async {
      await tester.pumpWidget(buildDialog());

      expect(find.text('閉じる'), findsOneWidget);
    });
  });

  group('RemoveAdsThanksDialog - 操作', () {
    testWidgets('"閉じる" ボタンでダイアログが閉じる', (tester) async {
      // ダイアログとして開けるよう、ボタン経由で表示する
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const RemoveAdsThanksDialog(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Thank you!'), findsOneWidget);

      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      expect(find.text('Thank you!'), findsNothing);
    });
  });
}
