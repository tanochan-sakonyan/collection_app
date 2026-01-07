import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/logging/analytics_event_logger.dart';

class EditEventDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;
  final String currentEventName;

  const EditEventDialog(
      {required this.userId,
      required this.eventId,
      required this.currentEventName,
      super.key});

  @override
  ConsumerState<EditEventDialog> createState() => EditEventDialogState();
}

class EditEventDialogState extends ConsumerState<EditEventDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentEventName;

    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 9) {
        setState(() {
          _errorMessage = S.of(context)!.maxCharacterMessage_9 ??
              "You can enter up to 9 characters.";
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editMemberName() async {
    final memberName = _controller.text.trim();
    if (!_isButtonEnabled) return;

    setState(() {
      _isButtonEnabled = false;
      if (memberName.isEmpty) {
        _errorMessage = S.of(context)!.enterEventName;
      } else if (memberName.length > 9) {
        _errorMessage = S.of(context)!.maxCharacterMessage_8 ??
            "You can enter up to 8 characters.";
      } else {
        _errorMessage = null;
      }
    });

    if (memberName.isEmpty || memberName.length > 9) {
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    ref.read(loadingProvider.notifier).state = true;

    try {
      await ref.read(userProvider.notifier).editEventName(
          widget.userId, widget.eventId, _controller.text.trim());
      await AnalyticsEventLogger.logEventEdited(
        eventId: widget.eventId,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'イベント名の更新に失敗しました : edit_event_name_dialog.dart';
          _isButtonEnabled = true;
        });
      }
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleIndicator(
      child: Dialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            color: const Color(0xFFFFFFFF),
            height: 220,
            width: 320,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  S.of(context)!.editEventName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Event",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.red,
                                  ),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 272,
                  height: 40,
                  child: ElevatedButton(
                    onPressed:
                        _isButtonEnabled ? () => _editMemberName() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 2,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      S.of(context)!.confirm,
                      style: GoogleFonts.notoSansJp(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
