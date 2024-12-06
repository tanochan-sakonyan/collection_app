import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/repository/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(baseUrl: baseUrl);
});
