import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_collection/main.dart' as app;
import 'package:mr_collection/collection_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel lineChannel = MethodChannel('com.linecorp/flutter_line_sdk');
  const MethodChannel adsChannel = MethodChannel('google_mobile_ads');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(lineChannel, (MethodCall methodCall) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(adsChannel, (MethodCall methodCall) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(lineChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(adsChannel, null);
  });

  testWidgets('main() initializes and runs app', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.byType(CollectionApp), findsOneWidget);
  });
}
