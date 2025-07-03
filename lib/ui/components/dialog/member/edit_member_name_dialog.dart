import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';

class EditMemberNameDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;
  final String memberId;
  final String currentName;

  const EditMemberNameDialog(
      {required this.userId,
      required this.eventId,
      required this.memberId,
      required this.currentName,
      super.key});

  @override
  ConsumerState<EditMemberNameDialog> createState() =>
      EditMemberNameDialogState();
}

class EditMemberNameDialogState extends ConsumerState<EditMemberNameDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentName;

    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 9) {
        setState(() {
          _errorMessage = S.of(context)?.maxCharacterMessage_9 ??
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
        _errorMessage =
            S.of(context)?.enterMemberPrompt ?? "Please enter a member name.";
      } else if (memberName.length > 9) {
        _errorMessage = S.of(context)?.maxCharacterMessage_9 ??
            "You can enter up to 9 characters.";
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
      await ref.read(userProvider.notifier).editMemberName(widget.userId,
          widget.eventId, widget.memberId, _controller.text.trim());
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isButtonEnabled = true;
        });
      });
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'メンバー名の更新に失敗しました : edit_member_name_dialog.dart';
        _isButtonEnabled = true;
      });
    }finally {
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
                S.of(context)?.editMemberName ?? "Edit Member Name",
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
                    "Name",
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                  onPressed: _isButtonEnabled ? () => _editMemberName() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    elevation: 2,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    S.of(context)?.confirm ?? "Confirm",
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
