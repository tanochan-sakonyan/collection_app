import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';

Future<void> registerUser(WidgetRef ref, String email, String password) async {
  final userRepository = ref.read(userRepositoryProvider);
  try {
    final user = await userRepository.registerUser(email, password);
    ref.read(userProvider.notifier).state = user;
  } catch (e) {
    debugPrint('Error: $e');
  }
}
