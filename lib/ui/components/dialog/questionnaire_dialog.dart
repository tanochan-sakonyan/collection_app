import 'package:flutter/material.dart';
import 'package:mr_collection/ui/components/webview/webview.dart';
import 'package:mr_collection/generated/s.dart';

class QuestionnaireDialog extends StatelessWidget {
  const QuestionnaireDialog({super.key});
  static const url = 'https://forms.gle/sncqxNDhWCvoUpSf6';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context)?.questionnaire ?? "Feedback Form",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context)?.questionnaireDescription ??
                  "If there's a feature you'd like to see in Shukinkun, we'd love to hear your thoughts.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context)?.feedbackThanks ??
                  "Your input will help us improve future versions.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 165,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F2F2),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SuggestionWebView(),
                    ),
                  );
                },
                child: Text(
                  S.of(context)?.suggest ?? "Suggest",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76DCC6),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
