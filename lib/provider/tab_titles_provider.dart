import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';

final tabTitlesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(userProvider);

  if (user == null) {
    return [];
  }

  return user.events.map((event) => event.eventName).toList();
});
