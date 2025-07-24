import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/services/analytics_service.dart';

class DeleteMemberDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;
  final String memberId;
  const DeleteMemberDialog({
    required this.userId,
    required this.eventId,
    required this.memberId,
    super.key,
  });

  @override
  ConsumerState<DeleteMemberDialog> createState() => _DeleteMemberDialogState();
}

class _DeleteMemberDialogState extends ConsumerState<DeleteMemberDialog> {
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logDialogOpen('delete_member_dialog');
  }

  Future<void> _deleteMember() async {
    if (!_isButtonEnabled) return;

    setState(() {
      _isButtonEnabled = false;
    });

    ref.read(loadingProvider.notifier).state = true;

    try {
      await ref
          .read(userProvider.notifier)
          .deleteMember(widget.userId, widget.eventId, widget.memberId);
      AnalyticsService().logDialogClose(
        'delete_member_dialog',
        'member_deleted'
      );
      Navigator.of(context).pop();
    } catch (error) {
      AnalyticsService().logDialogClose(
        'delete_member_dialog',
        'delete_error'
      );
      debugPrint('メンバー削除に失敗しました: $error');
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isButtonEnabled = true;
        });
      });
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleIndicator(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                S.of(context)!.confirmDeleteMember,
                style: GoogleFonts.notoSansJp(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
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
                          screen: 'delete_member_dialog'
                        );
                        AnalyticsService().logDialogClose(
                          'delete_member_dialog',
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    width: 107,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? () {
                        AnalyticsService().logButtonTap(
                          'confirm_delete',
                          screen: 'delete_member_dialog'
                        );
                        _deleteMember();
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F2F2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        S.of(context)!.yes,
                        style: Theme.of(context).textTheme.bodyMedium,
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
