import 'package:flutter/material.dart';

class SummaryShareScreen extends StatelessWidget {
  const SummaryShareScreen({super.key});

  @override
  // 共有サマリー画面を表示する。
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サマリーカード共有'),
      ),
      body: const Center(
        child: Text('共有機能はこれから実装します'),
      ),
    );
  }
}
