import 'package:flutter/material.dart';
import 'package:mr_collection/home_screen/home_screen.dart';

class CollectionApp extends StatelessWidget {
  const CollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
