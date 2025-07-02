import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/auth/delete_complete_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  final String userId;
  const DeleteAccountDialog({required this.userId, super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _checked = false;

  Future<void> _deleteUser(String userId) async {
    try {
      await ref.read(userProvider.notifier).deleteUser(userId);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DeleteCompleteDialog(),
      );
    } catch (error) {
      debugPrint('ユーザーの削除に失敗しました: $error: delete_account_dialog.dart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23.0),
      ),
      child: SizedBox(
        width: 320,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context)?.deleteAccount ?? "Delete Account",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '※ ${S.of(context)?.caution ?? "Caution"} ※',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context)?.deleteAccountMessage ??
                    "Deleting your account will erase all data permanently. Recovery will not be possible.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context)?.confirmAction ?? "Are you sure?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _checked,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF000000);
                      }
                      return const Color(0xFFB8B7B7);
                    }),
                    side: const BorderSide(width: 0, color: Colors.transparent),
                    onChanged: (bool? value) {
                      setState(() {
                        _checked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      S.of(context)?.confirmDeleteAction ??
                          "I understand and want to delete my account.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 36,
                    width: 107,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _checked
                            ? const Color(0xFFD7D7D7)
                            : const Color(0xFF8C8C8C),
                      ),
                      child: Text(
                        S.of(context)?.no ?? "No",
                        style: GoogleFonts.notoSansJp(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  SizedBox(
                    height: 36,
                    width: 107,
                    child: ElevatedButton(
                      onPressed: _checked
                          ? () {
                              _deleteUser(widget.userId);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _checked
                            ? const Color(0xFFF2F2F2)
                            : const Color(0xFF8C8C8C),
                      ),
                      child: Text(
                        S.of(context)?.yes ?? "Yes",
                        style: GoogleFonts.notoSansJp(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
