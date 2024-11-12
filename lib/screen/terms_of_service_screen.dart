import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("利用規約")),
      body: const Center(
        child: Text("ここに利用規約を書く"),
      ),
    );
  }
}
