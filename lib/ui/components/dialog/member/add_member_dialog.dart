import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/loading_indicator.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;

  const AddMemberDialog(
      {required this.userId, required this.eventId, super.key});

  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final lines = _controller.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      if (lines.any((n) => n.length > 9)) {
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

  Future<void> _createMember() async {
    final rawText = _controller.text;
    final memberNames = rawText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (memberNames.isEmpty) {
      setState(() => _errorMessage =
          S.of(context)?.enterMemberPrompt ?? "Please enter a member name.");
      return;
    } else if (memberNames.any((n) => n.length > 9)) {
      setState(() => _errorMessage = S.of(context)?.maxCharacterMessage_9 ??
          "You can enter up to 9 characters.");
      return;
    } else {
      _errorMessage = null;
    }

    setState(() {
      _isButtonEnabled = false;
      _errorMessage = null;
    });

    ref.read(loadingProvider.notifier).state = true;

    try {
      await ref
          .read(userProvider.notifier)
          .createMembers(widget.userId, widget.eventId, rawText);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'メンバーの追加に失敗しました';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
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
          height: 355,
          width: 320,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                S.of(context)?.addMembers ?? "Add Members",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Name",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 272,
                height: 220,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: S.of(context)?.multiMemberHint ??
                          "You can add multiple members by separating them with line breaks.",
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF999999)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 20,
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
              const SizedBox(height: 10),
              SizedBox(
                width: 272,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? () => _createMember() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    elevation: 2,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    S.of(context)?.confirm ?? "Confirm",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
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
