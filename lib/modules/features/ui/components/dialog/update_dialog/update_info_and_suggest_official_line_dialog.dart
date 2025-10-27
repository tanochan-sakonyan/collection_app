import 'package:flutter/material.dart';
import 'package:mr_collection/modules/features/ui/components/dialog/update_dialog/suggest_official_line_dialog_after.dart';
import 'package:mr_collection/modules/features/ui/components/dialog/update_dialog/update_info_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// 44行目のversion,first,second,thirdを変えて、どのバージョンでも実装可能
// アップデート情報と、公式LINE追加のサジェストの2ページを持つ
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
                  UpdateInfoDialog(
                    version: "2.4.0",
                    first: "ステータスにPayPayを追加",
                    second: "通信時のセキュリティを強化",
                    third: "支援機能を追加させていただきました",
                  ),
                  SuggestOfficialLineDialogAfter(),
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
