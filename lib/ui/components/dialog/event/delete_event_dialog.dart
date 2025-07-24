import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/services/analytics_service.dart';

class DeleteEventDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;
  const DeleteEventDialog({
    required this.userId,
    required this.eventId,
    super.key,
  });

  get eventRepository => null;

  @override
  ConsumerState<DeleteEventDialog> createState() => _DeleteEventDialogState();
}

class _DeleteEventDialogState extends ConsumerState<DeleteEventDialog> {
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logDialogOpen('delete_event_dialog');
  }
  Future<void> _deleteEvent(ref, String userId, String eventId) async {
    if (!_isButtonEnabled) return;
    setState(() {
      _isButtonEnabled = false;
    });

    ref.read(loadingProvider.notifier).state = true;

    try {
      await ref.read(userProvider.notifier).deleteEvent(userId, eventId);
      AnalyticsService().logDialogClose(
        'delete_event_dialog',
        'event_deleted'
      );
      Navigator.of(ref).pop();
    } catch (error) {
      AnalyticsService().logDialogClose(
        'delete_event_dialog',
        'delete_error'
      );
      debugPrint('イベントの削除に失敗しました: $error');
      setState(() {
        _isButtonEnabled = true;
      });
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleIndicator(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 320,
          height: 179,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context)!.confirmDeleteEvent ??
                    "Delete this event?", //TODO：イベント名を取得して表示
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    height: 36,
                    width: 107,
                    child: ElevatedButton(
                      onPressed: () {
                        AnalyticsService().logButtonTap(
                          'cancel_delete',
                          screen: 'delete_event_dialog'
                        );
                        AnalyticsService().logDialogClose(
                          'delete_event_dialog',
                          'cancel'
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD7D7D7),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        S.of(context)!.no,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    width: 107,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () {
                              AnalyticsService().logButtonTap(
                                'confirm_delete',
                                screen: 'delete_event_dialog'
                              );
                              _deleteEvent(ref, widget.userId, widget.eventId);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F2F2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        S.of(context)!.yes,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
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
      ),
    );
  }
}
