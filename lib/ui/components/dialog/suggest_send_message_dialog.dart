import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class SuggestSendMessageDialog extends StatelessWidget {
  const SuggestSendMessageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 400,
        width: 320,
        child: Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 28, right: 28, bottom: 40),
            child: Column(children: [
              Text(
                S.of(context)!.lineNotConnectedMessage1,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context)!.lineNotConnectedMessage2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Image.asset(
                'assets/images/img_add_from_line.png',
                width: 200,
                height: 200,
              ),
            ])),
      ),
    );
  }
}
