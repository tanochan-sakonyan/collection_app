import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/mock/mock_user.dart';

final tabTitlesProvider = Provider<List<String>>((ref) {
  return mockUser.events
      .map((event) => event.eventName)
      .toList(); // ゆくゆくはuserをBEから取得
});
