import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/ui/screen/send_line_message_bottom_sheet.dart';

class FloatingActionButtonOn extends StatelessWidget {
  final int index;
  final List<GlobalKey> fabKeys;
  final TabController tabController;
  final Event event;

  const FloatingActionButtonOn({
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
      backgroundColor: const Color(0xFF76DCC6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(48),
      ),
      onPressed: tabController.indexIsChanging
          ? null
          : () async {
              final unpaidMembers = event.members
                  .where((m) => m.status == PaymentStatus.unpaid)
                  .toList();
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) =>
                    LineMessageBottomSheet.lineMessageBottomSheet(
                  event: event,
                  unpaidMembers: unpaidMembers,
                ),
              );
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
                Color(0xFF75DCC6),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
