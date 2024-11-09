import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/services/event_service.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(
      baseUrl: 'https://your-api-base-url.com'); // TODO: 実際のURLに置き換えてください
});

final eventProvider = StateNotifierProvider<EventNotifier, List<Event>>((ref) {
  final eventService = ref.read(eventServiceProvider);
  return EventNotifier(eventService);
});

final eventServiceProvider = Provider<EventService>((ref) {
  final eventRepository = ref.read(eventRepositoryProvider);
  return EventService(eventRepository: eventRepository);
});

class EventNotifier extends StateNotifier<List<Event>> {
  final EventService eventService;

  EventNotifier(this.eventService) : super([]);

  Future<void> createEvent(String eventName) async {
    try {
      final newEvent = await eventService.createEvent(eventName);
      state = [...state, newEvent];
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> editEventName(int eventId, String newEventName) async {
    try {
      final updatedEvent =
          await eventService.editEventName(eventId, newEventName);
      state = state
          .map((event) => event.eventId == eventId ? updatedEvent : event)
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> deleteEvent(List<int> eventId) async {
    try {
      await eventService.deleteEvent(eventId);
      state = state.where((event) => event.eventId != eventId).toList();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
