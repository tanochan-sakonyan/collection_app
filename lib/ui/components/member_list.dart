import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/add_member_dialog.dart';
import 'package:mr_collection/ui/components/dialog/delete_member_dialog.dart';
import 'package:mr_collection/ui/components/dialog/status_dialog.dart';

class MemberList extends ConsumerWidget {
  final List<Member>? members;
  final String eventId;

  final GlobalKey? memberAddKey;
  final GlobalKey? slidableKey;
  final GlobalKey? sortKey;
  final GlobalKey? fabKey;

  const MemberList({
    super.key,
    required this.members,
    required this.eventId,
    this.memberAddKey,
    this.slidableKey,
    this.sortKey,
    this.fabKey,
  });

  Future<void> _updateMemberStatus(WidgetRef ref, String userId, String eventId,
      String memberId, int? status) async {
    try {
      await ref
          .read(userProvider.notifier)
          .updateMemberStatus(userId, eventId, memberId, status!);
    } catch (error) {
      debugPrint('ステータス更新中にエラーが発生しました。 $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? attendanceCount =
        members?.where((member) => member.status == PaymentStatus.paid).length;
    final int? unpaidCount = members
        ?.where((member) => member.status == PaymentStatus.unpaid)
        .length;

    const double iconSize = 30.0;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 29, right: 29),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      height: 32,
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          const Text('メンバー'),
                          const Spacer(),
                          const Text('支払い状況'),
                          const SizedBox(width: 3),
                          GestureDetector(
                            key: sortKey,
                            onTap: () {
                              ref
                                  .read(userProvider.notifier)
                                  .sortingMembers(eventId);
                            },
                            child: SvgPicture.asset('assets/icons/sort.svg'),
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ),
                    ClipRect(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: SlidableAutoCloseBehavior(
                          child: ListView.builder(
                            itemCount: members?.length,
                            itemBuilder: (context, index) {
                              final member = members?[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Column(
                                  children: [
                                    Slidable(
                                      key: ValueKey(member!.memberId),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        extentRatio: 0.26,
                                        children: [
                                          /*
                                      CustomSlidableAction(
                                        onPressed: (context) {
                                          // TODO: メンバー名編集機能の実装
                                          debugPrint('編集ボタンが押されました: ${member.memberId}');
                                        },
                                        backgroundColor: Colors.grey,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(
                                              '編集',
                                              style: TextStyle(
                                                fontSize: 14, // 14px に指定
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                       */
                                          CustomSlidableAction(
                                            onPressed: (context) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DeleteMemberDialog(
                                                  userId: ref
                                                      .read(userProvider)!
                                                      .userId,
                                                  eventId: eventId,
                                                  memberId: member!.memberId,
                                                ),
                                              );
                                            },
                                            backgroundColor: Colors.red,
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 4),
                                                Text(
                                                  '削除',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        key: (index == 0) ? slidableKey : null,
                                        child: ListTile(
                                          minTileHeight: 32,
                                          title: (member?.memberName != null)
                                              ? Text(
                                                  member!.memberName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: member.status ==
                                                            PaymentStatus
                                                                .absence
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                )
                                              : null,
                                          trailing:
                                              _buildStatusIcon(member?.status),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatusDialog(
                                                userId: ref
                                                    .read(userProvider)!
                                                    .userId,
                                                eventId: eventId.toString(),
                                                memberId: member!.memberId,
                                                member: member.memberName,
                                                onStatusChange: (String userId,
                                                    String eventId,
                                                    String memberId,
                                                    int status) {
                                                  _updateMemberStatus(
                                                      ref,
                                                      userId,
                                                      eventId,
                                                      memberId,
                                                      status);
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Color(0xFFE8E8E8),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //TODO リリース初期段階では中央に一つのボタンを配置
                        children: [
                          // const SizedBox(width: 53),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   style: ElevatedButton.styleFrom(
                          //     elevation: 0,
                          //     side: const BorderSide(
                          //       color: Colors.black,
                          //       width: 1.0,
                          //     ),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //     minimumSize: const Size(12, 24),
                          //     backgroundColor: Colors.white,
                          //   ),
                          //   child: Text(
                          //     '一括編集',
                          //     style: Theme.of(context).textTheme.labelSmall,
                          //   ),
                          // ),
                          // const SizedBox(width: 100),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddMemberDialog(
                                  userId: ref.read(userProvider)!.userId,
                                  eventId: eventId,
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Row(
                              key: memberAddKey,
                              children: [
                                SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: SvgPicture.asset(
                                        'assets/icons/user-add.svg')),
                                const SizedBox(width: 4),
                                Text(
                                  'メンバー追加',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // const SizedBox(width: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              //TODO メンバーのステータスによって表示を変える
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      "未払い",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: iconSize,
                    child: Stack(
                      children: unpaidCount != null
                          ? List.generate(
                              unpaidCount,
                              (index) {
                                double containerWidth =
                                    MediaQuery.of(context).size.width * 0.25;
                                double spacing = (unpaidCount > 1)
                                    ? (containerWidth - iconSize) /
                                        (unpaidCount - 1)
                                    : 0;
                                double left = (unpaidCount > 1)
                                    ? index * spacing
                                    : (containerWidth - iconSize) / 2;
                                return Positioned(
                                  left: left,
                                  child: SvgPicture.asset(
                                    'assets/icons/sad_face.svg',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                );
                              },
                            )
                          : const <Widget>[],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("・・・・・・"),
                  const SizedBox(width: 26),
                  Text("$unpaidCount人"),
                ]),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      "支払済",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: iconSize,
                    child: Stack(
                      children: attendanceCount != null
                          ? List.generate(
                              attendanceCount,
                              (index) {
                                double containerWidth =
                                    MediaQuery.of(context).size.width * 0.25;
                                double spacing = (attendanceCount > 1)
                                    ? (containerWidth - iconSize) /
                                        (attendanceCount - 1)
                                    : 0;
                                double left = (attendanceCount > 1)
                                    ? index * spacing
                                    : (containerWidth - iconSize) / 2;
                                return Positioned(
                                  left: left,
                                  child: SvgPicture.asset(
                                    'assets/icons/flag.svg',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                );
                              },
                            )
                          : const <Widget>[],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("・・・・・・"),
                  const SizedBox(width: 26),
                  Text("$attendanceCount人"),
                ]),
              ),
            ],
          ),
          Positioned(
            right: 4,
            bottom: 100,
            child: SizedBox(
              height: 60,
              width: 60,
              child: FloatingActionButton(
                key: fabKey,
                backgroundColor: const Color(0xFFBABABA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 56.0, horizontal: 24.0),
                      content: Text(
                        'LINEへの認証申請中のため、\n機能解禁までしばらくお待ちください',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  //TODO LINE認証申請が通ったらこちらに戻す
                  /*showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(),
                  );*/
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
                            Colors.white, BlendMode.srcIn),
                      ),
                      SvgPicture.asset(
                        'assets/icons/yen.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFFBABABA), BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus? status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check, color: Color(0xFF35C759));
      case PaymentStatus.unpaid:
        return const Icon(Icons.close, color: Colors.red);
      case PaymentStatus.absence:
      default:
        return const Icon(Icons.remove, color: Color(0xFFC0C0C0));
    }
  }
}
