import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/home_screen/home_screen.dart';

class CollectionApp extends StatelessWidget {
  const CollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '集金くん',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const HomeScreen(
        title: '集金くん',
      ),
    );
  }
}
