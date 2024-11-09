import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/repository/event_repository.dart';

class EventService {
  final EventRepository eventRepository;

  EventService({required this.eventRepository});

  Future<Event> createEvent(String eventName) async {
    return await eventRepository.createEvent(eventName);
  }

  Future<Event> editEventName(int eventId, String newEventName) async {
    return await eventRepository.editEventName(eventId, newEventName);
  }

  Future<void> deleteEvent(List<int> eventIdList) async {
    await eventRepository.deleteEvent(eventIdList);
  }
}
