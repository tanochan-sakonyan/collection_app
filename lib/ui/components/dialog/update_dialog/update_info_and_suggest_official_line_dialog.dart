import 'package:flutter/material.dart';
import 'package:mr_collection/ui/components/dialog/questionnaire_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// 44行目のversion,first,second,thirdを変えて、どのバージョンでも実装可能
// アップデート情報と、機能追加アンケートの2ページを持つ
class UpdateInfoAndSuggestQuestionnaireDialog extends StatefulWidget {
  final TickerProvider vsync;
  final void Function(int) onPageChanged;
  const UpdateInfoAndSuggestQuestionnaireDialog(
      {super.key, required this.vsync, required this.onPageChanged});

  @override
  State<UpdateInfoAndSuggestQuestionnaireDialog> createState() =>
      _UpdateInfoAndSuggestQuestionnaireDialogState();
}

class _UpdateInfoAndSuggestQuestionnaireDialogState
    extends State<UpdateInfoAndSuggestQuestionnaireDialog> {
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
        width: MediaQuery.of(context).size.width * 0.9,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: widget.onPageChanged,
                children: const [
                  UpdateInfoDialog(
                    version: "2.8.0",
                    first: "金額設定時に端数を切り上げる機能",
                    second: "メンバー・タブの並び替えが可能に",
                    third: "一括編集機能を実装！",
                  ),
                  QuestionnaireDialog(),
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
