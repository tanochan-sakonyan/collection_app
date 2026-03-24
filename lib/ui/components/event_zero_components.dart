import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/logging/analytics_event_logger.dart';
import 'package:mr_collection/provider/user_provider.dart';

import 'dialog/event/add_event_dialog.dart';

class EventZeroComponents extends ConsumerWidget {
  const EventZeroComponents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 160),
          Text(
            S.of(context)!.registerEvent,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            S.of(context)!.tryRegistering,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 28),
          Text(
            S.of(context)!.eventExample,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF383838)),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              await AnalyticsEventLogger.logAddEventButtonPressed(
                source: 'event_zero',
              );
              showDialog(
                context: context,
                builder: (_) => AddEventDialog(
                  userId: ref.read(userProvider)!.userId,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(152, 48),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            label: Text(S.of(context)!.addEventButton,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFFFFF))),
          ),
        ],
      ),
    );
  }
}
