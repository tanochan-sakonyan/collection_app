import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/model/payment_status.dart';

final tabTitlesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(userProvider);

  if (user == null) {
    return [];
  }

  bool isAllMembersPaid(event) => event.members.isNotEmpty &&
          event.members.every((member) => member.status != PaymentStatus.unpaid);

  final unpaidEvents = user.events.where((event) => !isAllMembersPaid(event)).toList();

  final fullyPaidEvents = user.events.where((event) => isAllMembersPaid(event)).toList();

  final sortedEvents = [...unpaidEvents, ...fullyPaidEvents];

  return sortedEvents.map((event) => event.eventId).toList();
});
