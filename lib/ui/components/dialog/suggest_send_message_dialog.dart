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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context)!.lineNotConnectedMessage2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/img_add_from_line.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 28)
            ])),
      ),
    );
  }
}
