import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/ads/interstitial_singleton.dart';
import 'package:mr_collection/collection_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LineSDK.instance.setup('2006612683');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await MobileAds.instance.initialize();

  await interstitial.load();

  //TODO: Androidリリース後に広告搭載する時に使う
  // RequestConfiguration requestConfiguration = RequestConfiguration(
  //   testDeviceIds: ['4ABC92F2F1C3BE03787BD48F9E8B39EA'],
  // );
  // MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  runApp(
    const ProviderScope(child: CollectionApp()),
  );
}
