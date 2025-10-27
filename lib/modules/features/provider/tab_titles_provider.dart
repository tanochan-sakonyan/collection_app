import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/modules/features/provider/user_provider.dart';
import 'package:mr_collection/modules/features/data/model/payment_status.dart';

final tabTitlesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(userProvider);

  if (user == null) {
    return [];
  }

  bool isAllMembersPaid(event) => event.members.isNotEmpty &&
          event.members.every((member) => member.status != PaymentStatus.unpaid);

  final unpaidEvents = user.events.where((event) => !isAllMembersPaid(event)).toList();

  final fullyPaidEvents = user.events.where((event) => isAllMembersPaid(event)).toList();

  if (unpaidEvents.isEmpty) {
    return fullyPaidEvents.map((event) => event.eventId).toList();
  }

  final newCreatedEvent = unpaidEvents.last;
  final otherUnpaidEvents = unpaidEvents.sublist(0, unpaidEvents.length - 1);

  return [
    newCreatedEvent.eventId,
    ...otherUnpaidEvents.map((event) => event.eventId),
    ...fullyPaidEvents.map((event) => event.eventId),
  ];
});
