import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/screen/access_token_screen.dart';
import 'package:mr_collection/screen/home_screen.dart';

class CollectionApp extends StatelessWidget {
  const CollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.montserratTextTheme();

    final collectionAppTextTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16.0),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14.0),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12.0),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: 11.0),
      labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: 10.0),
    );

    return MaterialApp(
      title: '集金くん',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
        ),
        brightness: Brightness.light,
        textTheme: collectionAppTextTheme,
      ),
      home: AccessTokenScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
