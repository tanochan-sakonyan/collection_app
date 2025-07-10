import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/amount_loading_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/member/add_member_dialog.dart';
import 'package:mr_collection/ui/components/dialog/member/delete_member_dialog.dart';
import 'package:mr_collection/ui/components/dialog/member/edit_member_name_dialog.dart';
import 'package:mr_collection/ui/components/dialog/member/status_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mr_collection/ui/screen/amount_screen/input_amount_screen.dart';
import 'package:mr_collection/generated/s.dart';

class MemberList extends ConsumerWidget {
  final Event event;
  final List<Member>? members;
  final String eventId;
  final String eventName;

  final GlobalKey? memberAddKey;
  final GlobalKey? slidableKey;
  final GlobalKey? sortKey;

  const MemberList({
    super.key,
    required this.event,
    required this.members,
    required this.eventId,
    required this.eventName,
    this.memberAddKey,
    this.slidableKey,
    this.sortKey,
  });
  Future<void> _updateMemberStatus(
    WidgetRef ref,
    String userId,
    String eventId,
    String memberId,
    int? status,
  ) async {
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
    // TODO: 未払い、支払い済は、一旦コメントアウト
    // final int? attendanceCount =
    //     members?.where((member) => member.status == PaymentStatus.paid).length;
    // final int? unpaidCount = members
    //     ?.where((member) => member.status == PaymentStatus.unpaid)
    //     .length;
    //
    // const double iconSize = 30.0;

    final isAmountLoading = ref.watch(amountLoadingProvider(eventId));

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 29, right: 29),
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
                        border: Border(bottom: BorderSide(color: Colors.black)),
                      ),
                      height: 32,
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          Text(
                            S.of(context)!.member,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            S.of(context)!.paymentStatus,
                            style: GoogleFonts.notoSansJp(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
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
                      child:
                          // TODO: 規約対応
                          // (event.lineGroupId != null &&
                          //         DateTime.now().isAfter(event.lineMembersFetchedAt!
                          //             .add(const Duration(hours: 24))) &&
                          //         (members == null || members!.isEmpty))
                          //     ? Center(
                          //         child: Text(
                          //           S.of(context)!.memberDeletedAfter24h ??
                          //               "Member information has been deleted after 24 hours.",
                          //           style: Theme.of(context)
                          //               .textTheme
                          //               .bodyMedium
                          //               ?.copyWith(
                          //                 fontSize: 14,
                          //                 color: Colors.grey,
                          //               ),
                          //           textAlign: TextAlign.center,
                          //         ),
                          //       )
                          //    :
                          SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: SlidableAutoCloseBehavior(
                          child: ListView.builder(
                            itemCount: members?.length,
                            itemBuilder: (context, index) {
                              final member = members?[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                ),
                                child: Column(
                                  children: [
                                    Slidable(
                                      key: ValueKey(member!.memberId),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        extentRatio: 0.60,
                                        children: [
                                          CustomSlidableAction(
                                            onPressed: (context) {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  context,
                                                ) =>
                                                    EditMemberNameDialog(
                                                  userId: ref
                                                      .read(
                                                        userProvider,
                                                      )!
                                                      .userId,
                                                  eventId: eventId,
                                                  memberId: member.memberId,
                                                  currentName:
                                                      member.memberName,
                                                ),
                                              );
                                            },
                                            backgroundColor: Colors.grey,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 4),
                                                AutoSizeText(
                                                  S.of(context)!.edit,
                                                  maxLines: 1,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          CustomSlidableAction(
                                            onPressed: (context) {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  context,
                                                ) =>
                                                    DeleteMemberDialog(
                                                  userId: ref
                                                      .read(
                                                        userProvider,
                                                      )!
                                                      .userId,
                                                  eventId: eventId,
                                                  memberId: member.memberId,
                                                ),
                                              );
                                            },
                                            backgroundColor: Colors.red,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 4),
                                                AutoSizeText(
                                                  S.of(context)!.delete,
                                                  maxLines: 1,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
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
                                          minTileHeight: 44,
                                          title: (member.memberName != null)
                                              ? Text(
                                                  member.memberName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(
                                                    context,
                                                  )
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: member.status ==
                                                                PaymentStatus
                                                                    .absence
                                                            ? Colors.grey
                                                            : Colors.black,
                                                      ),
                                                )
                                              : null,
                                          subtitle: isAmountLoading
                                              ? const Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SpinKitThreeBounce(
                                                        color: Colors.black,
                                                        size: 15),
                                                  ],
                                                )
                                              : (member.memberMoney != null)
                                                  ? Text(
                                                      "${member.memberMoney} ${S.of(context)!.currencyUnit}",
                                                      style: TextStyle(
                                                        color: member.status ==
                                                                PaymentStatus
                                                                    .absence
                                                            ? Colors.grey
                                                            : Colors.black,
                                                      ),
                                                    )
                                                  : Text(
                                                      "--- ${S.of(context)!.currencyUnit}",
                                                      style: TextStyle(
                                                        color: member.status ==
                                                                PaymentStatus
                                                                    .absence
                                                            ? Colors.grey
                                                            : Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                          trailing: _buildStatusIcon(
                                            member.status,
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatusDialog(
                                                userId: ref
                                                    .read(userProvider)!
                                                    .userId,
                                                eventId: eventId.toString(),
                                                memberId: member.memberId,
                                                member: member.memberName,
                                                onStatusChange: (
                                                  String userId,
                                                  String eventId,
                                                  String memberId,
                                                  int status,
                                                ) {
                                                  _updateMemberStatus(
                                                    ref,
                                                    userId,
                                                    eventId,
                                                    memberId,
                                                    status,
                                                  );
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
                    const Divider(color: Colors.black, thickness: 1, height: 1),
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
                                    'assets/icons/user-add.svg',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  S.of(context)!.addMembers,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // const SizedBox(width: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                width: 324,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF75DCC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InputAmountScreen(
                          eventId: eventId,
                          eventName: eventName,
                          members: members!,
                        ),
                      ),
                    );
                  },
                  child: (event.totalMoney != null)
                      ? Text(
                          "合計 ${event.totalMoney.toString()} ${S.of(context)!.currencyUnit}",
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                        )
                      : Text(
                          S.of(context)!.settlePayment,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                        ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       SizedBox(
              //         width: 64,
              //         child: Text(
              //           S.of(context)!.unpaid,
              //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.black,
              //               ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //       SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.25,
              //         height: iconSize,
              //         child: Stack(
              //           children: unpaidCount != null
              //               ? List.generate(unpaidCount, (index) {
              //                   double containerWidth =
              //                       MediaQuery.of(context).size.width * 0.25;
              //                   double spacing = (unpaidCount > 1)
              //                       ? (containerWidth - iconSize) /
              //                           (unpaidCount - 1)
              //                       : 0;
              //                   double left = (unpaidCount > 1)
              //                       ? index * spacing
              //                       : (containerWidth - iconSize) / 2;
              //                   return Positioned(
              //                     left: left,
              //                     child: SvgPicture.asset(
              //                       'assets/icons/sad_face.svg',
              //                       width: iconSize,
              //                       height: iconSize,
              //                     ),
              //                   );
              //                 })
              //               : const <Widget>[],
              //         ),
              //       ),
              //       const SizedBox(width: 4),
              //       const Text("・・・・・"),
              //       const SizedBox(width: 20),
              //       Text(
              //         "$unpaidCount${S.of(context)!.person}",
              //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.black,
              //             ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       SizedBox(
              //         width: 60,
              //         child: Text(
              //           S.of(context)!.paid,
              //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.black,
              //               ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //       SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.25,
              //         height: iconSize,
              //         child: Stack(
              //           children: attendanceCount != null
              //               ? List.generate(attendanceCount, (index) {
              //                   double containerWidth =
              //                       MediaQuery.of(context).size.width * 0.25;
              //                   double spacing = (attendanceCount > 1)
              //                       ? (containerWidth - iconSize) /
              //                           (attendanceCount - 1)
              //                       : 0;
              //                   double left = (attendanceCount > 1)
              //                       ? index * spacing
              //                       : (containerWidth - iconSize) / 2;
              //                   return Positioned(
              //                     left: left,
              //                     child: SvgPicture.asset(
              //                       'assets/icons/flag.svg',
              //                       width: iconSize,
              //                       height: iconSize,
              //                     ),
              //                   );
              //                 })
              //               : const <Widget>[],
              //         ),
              //       ),
              //       const SizedBox(width: 4),
              //       const Text("・・・・・"),
              //       const SizedBox(width: 20),
              //       Text(
              //         "$attendanceCount${S.of(context)!.person}",
              //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.black,
              //             ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
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
