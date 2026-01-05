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

class MemberList extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList>
    with TickerProviderStateMixin {
  late final List<GlobalKey> slidableKeys;

  @override
  void initState() {
    super.initState();
    slidableKeys =
        List.generate(widget.members?.length ?? 0, (_) => GlobalKey());
  }

  void closeAllSlidables(List<GlobalKey> keys) {
    for (final key in keys) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Slidable.of(ctx)?.close();
      }
    }
  }

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
  Widget build(BuildContext context) {
    final members = widget.members ?? [];
    final isAmountLoading = ref.watch(amountLoadingProvider(widget.eventId));
    final slidableKeys = List.generate(members.length, (_) => GlobalKey());
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        closeAllSlidables(slidableKeys);
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
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
                              key: widget.sortKey,
                              onTap: () {
                                ref
                                    .read(userProvider.notifier)
                                    .sortingMembers(widget.eventId);
                              },
                              child: SvgPicture.asset('assets/icons/sort.svg'),
                            ),
                            const SizedBox(width: 28),
                          ],
                        ),
                      ),
                      ClipRect(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: (widget.event.lineGroupId != null &&
                                  DateTime.now().isAfter(widget
                                      .event.lineMembersFetchedAt!
                                      .add(const Duration(hours: 24))))
                              ? Center(
                                  child: Text(
                                    S.of(context)!.memberDeletedAfter24h ??
                                        "Member information has been deleted after 24 hours.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : SlidableAutoCloseBehavior(
                                  child: ListView.builder(
                                    itemCount: widget.members?.length,
                                    itemBuilder: (context, index) {
                                      final member = widget.members?[index];
                                      if (member == null) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            Slidable(
                                              key: slidableKeys[index],
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                extentRatio: 0.60,
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (context) {
                                                      closeAllSlidables(
                                                          slidableKeys);
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
                                                          eventId:
                                                              widget.eventId,
                                                          memberId:
                                                              member.memberId,
                                                          currentName:
                                                              member.memberName,
                                                        ),
                                                      );
                                                    },
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                            height: 4),
                                                        AutoSizeText(
                                                          S.of(context)!.edit,
                                                          maxLines: 1,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CustomSlidableAction(
                                                    onPressed: (context) {
                                                      closeAllSlidables(
                                                          slidableKeys);
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
                                                          eventId:
                                                              widget.eventId,
                                                          memberId:
                                                              member.memberId,
                                                        ),
                                                      );
                                                    },
                                                    backgroundColor: Colors.red,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                            height: 4),
                                                        AutoSizeText(
                                                          S.of(context)!.delete,
                                                          maxLines: 1,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                key: (index == 0)
                                                    ? widget.slidableKey
                                                    : null,
                                                child: ListTile(
                                                  minTileHeight: 44,
                                                  leading: _buildRoleBadge(
                                                      context, member, members),
                                                  title: (member.memberName !=
                                                          null)
                                                      ? Text(
                                                          member.memberName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Theme.of(
                                                            context,
                                                          )
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: member.status ==
                                                                        PaymentStatus
                                                                            .absence
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                        )
                                                      : null,
                                                  subtitle: isAmountLoading
                                                      ? const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SpinKitThreeBounce(
                                                                color: Colors
                                                                    .black,
                                                                size: 15),
                                                          ],
                                                        )
                                                      : (member.memberMoney !=
                                                              null)
                                                          ? Text(
                                                              "${member.memberMoney} ${S.of(context)!.currencyUnit}",
                                                              style: TextStyle(
                                                                color: member.status ==
                                                                        PaymentStatus
                                                                            .absence
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            )
                                                          : Text(
                                                              "--- ${S.of(context)!.currencyUnit}",
                                                              style: TextStyle(
                                                                color: member.status ==
                                                                        PaymentStatus
                                                                            .absence
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
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
                                                        eventId: widget.eventId
                                                            .toString(),
                                                        memberId:
                                                            member.memberId,
                                                        member:
                                                            member.memberName,
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
                      Divider(
                        color: primaryColor,
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
                                closeAllSlidables(slidableKeys);
                                showDialog(
                                  context: context,
                                  builder: (context) => AddMemberDialog(
                                    userId: ref.read(userProvider)!.userId,
                                    eventId: widget.eventId,
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
                                key: widget.memberAddKey,
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      closeAllSlidables(slidableKeys);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InputAmountScreen(
                            eventId: widget.eventId,
                            eventName: widget.eventName,
                            members: widget.members!,
                          ),
                        ),
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.event.members.length.toString() +
                                S.of(context)!.person,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          (widget.event.totalMoney != null)
                              ? Text(
                                  "合計 ${widget.event.totalMoney.toString()} ${S.of(context)!.currencyUnit}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                )
                              : Text(
                                  S.of(context)!.settlePayment,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                ),
                        ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildRoleBadge(
      BuildContext context, Member member, List<Member>? members) {
    // 一人でもroleがあるメンバーがいるかチェック
    final hasAnyRole =
        members?.any((m) => m.role != null && m.role!.isNotEmpty) ?? false;

    if (!hasAnyRole) {
      // 誰も役割がない場合は何も表示しない
      return null;
    }

    if (member.role != null && member.role!.isNotEmpty) {
      // 役割がある場合は役割名を表示
      return Container(
        width: MediaQuery.of(context).size.width * 0.17,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          member.role!,
          style: GoogleFonts.notoSansJp(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      );
    } else {
      // 役割がない場合は「役割なし」を表示
      return Container(
        width: MediaQuery.of(context).size.width * 0.17,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AutoSizeText(
          S.of(context)!.noRole,
          style: GoogleFonts.notoSansJp(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      );
    }
  }

  Widget _buildStatusIcon(PaymentStatus? status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check, color: Color(0xFF35C759));
      case PaymentStatus.paypay:
        return Image.asset(
          'assets/icons/ic_paypay.png',
          width: 24,
          height: 24,
        );
      case PaymentStatus.unpaid:
        return const Icon(Icons.close, color: Colors.red);
      case PaymentStatus.absence:
      default:
        return const Icon(Icons.remove, color: Color(0xFFC0C0C0));
    }
  }
}
