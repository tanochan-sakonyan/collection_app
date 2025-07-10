import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/ui/components/dialog/suggest_send_message_dialog.dart';

class FloatingActionButtonOff extends StatelessWidget {
  final int index;
  final List<GlobalKey> fabKeys;
  final TabController tabController;
  final Event event;

  const FloatingActionButtonOff({
    super.key,
    required this.index,
    required this.fabKeys,
    required this.tabController,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: fabKeys[index],
      backgroundColor: const Color(0xFFBABABA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(48),
      ),
      onPressed: tabController.indexIsChanging
          ? null
          : () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SuggestSendMessageDialog();
                  });
            },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/chat_bubble.svg',
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            SvgPicture.asset(
              'assets/icons/yen.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFFBABABA),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
