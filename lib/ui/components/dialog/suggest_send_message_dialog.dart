import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class SuggestSendMessageDialog extends StatelessWidget {
  const SuggestSendMessageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        S.of(context)!.lineNotConnectedMessage1,
      ),
      content: Text(
        S.of(context)!.lineNotConnectedMessage2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            S.of(context)!.ok,
          ),
        ),
      ],
    );
  }
}
