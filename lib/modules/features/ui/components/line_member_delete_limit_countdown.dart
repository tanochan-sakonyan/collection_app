import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/modules/features/data/model/freezed/event.dart';
import 'package:mr_collection/modules/features/data/model/freezed/line_group.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/modules/features/provider/user_provider.dart';
import 'countdown_timer.dart';
import 'dialog/line/line_group_update_countdown_dialog.dart';

class LineMemberDeleteLimitCountdown extends ConsumerWidget {
  final Event currentEvent;
  final String currentEventId;

  const LineMemberDeleteLimitCountdown({
    super.key,
    required this.currentEvent,
    required this.currentEventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        if (DateTime.now().isAfter(currentEvent.lineMembersFetchedAt!
            .add(const Duration(hours: 24)))) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    content: Text(
                      S.of(context)!.cannotreflesh,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                  ));
        } else {
          final updatedGroup = await showDialog<LineGroup>(
            context: context,
            builder: (BuildContext context) {
              return LineGroupUpdateCountdownDialog(currentEvent: currentEvent);
            },
          );
          if (updatedGroup != null) {
            ref
                .read(userProvider.notifier)
                .updateMemberDifference(currentEventId, updatedGroup);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...(currentEvent.lineMembersFetchedAt != null)
              ? [
                  Text(S.of(context)!.autoDeleteMemberCountdown,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontSize: 14, color: Colors.black)),
                  CountdownTimer(
                    expireTime: currentEvent.lineMembersFetchedAt!
                        .add(const Duration(hours: 24)),
                    textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                    onExpired: () {
                      ref
                          .read(userProvider.notifier)
                          .clearMembersOfEvent(currentEventId);
                    },
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/ic_update.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 36),
                ]
              : [
                  const SizedBox(height: 4),
                ],
        ],
      ),
    );
  }
}
