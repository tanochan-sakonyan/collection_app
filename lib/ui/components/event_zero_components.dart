import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/user_provider.dart';
import 'dialog/add_event_dialog.dart';

class EventZeroComponents extends ConsumerWidget {
  const EventZeroComponents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 160),
          Text(
            '集金管理するイベントを',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '登録してみよう',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '例) 飲み会、カラオケ、旅行 etc...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF383838)
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
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
            label: Text(
                'イベントを追加',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF76DCC6)
            )
            ),
          ),
        ],
      ),
    );
  }
}
