import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/ui/components/dialog/delete_complete_dialog.dart';

import '../../../provider/user_provider.dart';

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
              const Text(
                'アカウントの削除',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '※ 注意 ※',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'アカウントを削除した場合、\nすべてのデータが初期化されます。\n'
                'データの復旧を行うことは\nできません。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '本当によろしいですか？',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                  const Expanded(
                    child: Text(
                      '上記を確認し、削除を希望する',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                        'いいえ',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                        'はい',
                        style: Theme.of(context).textTheme.bodyMedium,
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
