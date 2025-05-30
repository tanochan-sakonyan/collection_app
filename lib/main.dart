import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/collection_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LineSDK.instance.setup('2006612683');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(child: CollectionApp()),
  );
}
