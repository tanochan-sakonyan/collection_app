import 'package:flutter/material.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_dialog_for_120.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/suggest_official_line_dialog_before.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UpdateInfoAndSuggestOfficialLineDialog extends StatefulWidget {
  final TickerProvider vsync;
  final void Function(int) onPageChanged;
  const UpdateInfoAndSuggestOfficialLineDialog(
      {super.key, required this.vsync, required this.onPageChanged});

  @override
  State<UpdateInfoAndSuggestOfficialLineDialog> createState() =>
      _UpdateInfoAndSuggestOfficialLineDialogState();
}

class _UpdateInfoAndSuggestOfficialLineDialogState
    extends State<UpdateInfoAndSuggestOfficialLineDialog> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
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
                  SuggestOfficialLineDialogBefore(),
                  UpdateInfoDialogFor120(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    activeDotColor: Colors.black,
                    dotColor: Color(0xFFA7A7A7),
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
