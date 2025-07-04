import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/components/dialog/line_message_complete_dialog.dart';
import 'package:mr_collection/ui/components/dialog/line_message_failed_dialog.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class LineMessageConfirmDialog extends ConsumerWidget {
  final Event event;
  final String message;
  const LineMessageConfirmDialog(
      {super.key, required this.event, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    return CircleIndicator(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 352,
            maxHeight: 344,
            minWidth: 352,
            minHeight: 344,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(S.of(context)!.sendConfirmation,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        color: Colors.white,
                        child: Text(
                          message,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 14,
                            color: const Color(0xFF5C5C5C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF75DCC6), width: 1),
                          foregroundColor: const Color(0xFF75DCC6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context)!.back,
                          style: GoogleFonts.notoSansJp(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF75DCC6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 108,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final userId = ref.read(userProvider)?.userId;
                                if (userId == null) return;

                                ref.read(loadingProvider.notifier).state = true;
                                try {
                                  final isSuccess = await ref
                                      .read(userProvider.notifier)
                                      .sendMessage(
                                          userId, event.eventId, message);

                                  if (isSuccess) {
                                    await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            const LineMessageCompleteDialog());
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) => const HomeScreen()),
                                      (_) => false,
                                    );
                                  } else {
                                    await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            const LineMessageFailedDialog());
                                  }
                                } finally {
                                  ref.read(loadingProvider.notifier).state =
                                      false;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF75DCC6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context)!.send,
                          style: GoogleFonts.notoSansJp(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
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
      ),
    );
  }
}
