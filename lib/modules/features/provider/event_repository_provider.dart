import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/modules/features/constants/base_url.dart';
import 'package:mr_collection/modules/features/data/repository/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(baseUrl: baseUrl);
});
