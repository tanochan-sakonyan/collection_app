import 'package:flutter/material.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_dialog_for_120.dart.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/suggest_official_line_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UpdateInfoFor120AndSuggestOfficialLineDialog extends StatefulWidget {
  final TickerProvider vsync;
  final void Function(int) onPageChanged;
  const UpdateInfoFor120AndSuggestOfficialLineDialog(
      {super.key, required this.vsync, required this.onPageChanged});

  @override
  State<UpdateInfoFor120AndSuggestOfficialLineDialog> createState() =>
      _UpdateInfoFor120AndSuggestOfficialLineDialogState();
}

class _UpdateInfoFor120AndSuggestOfficialLineDialogState
    extends State<UpdateInfoFor120AndSuggestOfficialLineDialog> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: widget.onPageChanged,
                children: const [
                  SuggestOfficialLineDialog(),
                  UpdateInfoDialogFor120(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: const WormEffect(dotHeight: 8, dotWidth: 8, spacing: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
