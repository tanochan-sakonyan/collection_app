import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/collection_app.dart';

void main() {
  runApp(
    const ProviderScope(child: CollectionApp()),
  );
}
