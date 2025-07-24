import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/countdown_timer.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/services/analytics_service.dart';

class LineGroupUpdateCountdownDialog extends ConsumerWidget {
  final Event currentEvent;

  const LineGroupUpdateCountdownDialog({
    super.key,
    required this.currentEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userProvider)?.userId;

    // ダイアログ表示をログに記録
    AnalyticsService().logDialogOpen('line_group_update_countdown_dialog');

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
              S.of(context)!.lineGroupExpireTitle ??
                  "Member info will expire soon",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context)!.lineGroupExpireDesc ??
                  "According to LINE's terms of use, after the member info expires,\nmember and payment status information will be deleted.\nPlease reacquire to reset the expiration date.",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: const Color(0xFF6A6A6A),
                  ),
            ),
            const SizedBox(height: 20),
            CountdownTimer(
              expireTime: currentEvent.lineMembersFetchedAt!
                  .add(const Duration(hours: 24)),
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
                      AnalyticsService().logButtonTap(
                        'do_not_refresh',
                        screen: 'line_group_update_countdown_dialog'
                      );
                      AnalyticsService().logDialogClose(
                        'line_group_update_countdown_dialog',
                        'no_refresh'
                      );
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
                      S.of(context)!.doNotRefresh,
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
                      AnalyticsService().logButtonTap(
                        'refresh_line_group',
                        screen: 'line_group_update_countdown_dialog'
                      );
                      try {
                        final updatedGroup = await ref
                            .read(userProvider.notifier)
                            .refreshLineGroupMember(
                                currentEvent.lineGroupId!, userId!);
                        AnalyticsService().logDialogClose(
                          'line_group_update_countdown_dialog',
                          'refresh_success'
                        );
                        Navigator.of(context).pop(updatedGroup);
                      } catch (error) {
                        AnalyticsService().logDialogClose(
                          'line_group_update_countdown_dialog',
                          'refresh_error'
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      S.of(context)!.refresh,
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
