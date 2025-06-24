import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/countdown_timer.dart';

class LineGroupUpdateCountdownDialog extends ConsumerWidget {
  final Event currentEvent;

  const LineGroupUpdateCountdownDialog({
    super.key,
    required this.currentEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userProvider)?.userId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 320,
        height: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "メンバー情報有効期限が\nもうすぐ切れます",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "LINEの利用規約に則り、メンバー情報有効期限を過ぎる\nと、メンバーと支払い状況の情報が削除されます。\n再取得をし、有効期限をリセットしてください。",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: const Color(0xFF6A6A6A),
              ),
            ),
            const SizedBox(height: 20),
            CountdownTimer(
              expiretime: currentEvent.lineMembersFetchedAt!.add(const Duration(hours: 24)),
              textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  height: 36,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "取得しない",
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedGroup = await ref.read(userProvider.notifier).refreshLineGroupMember(currentEvent.lineGroupId!, userId!);
                      Navigator.of(context).pop(updatedGroup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "再取得",
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}