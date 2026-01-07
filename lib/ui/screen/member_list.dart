import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/logging/analytics_logger.dart';
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
  final Set<String> _selectedMemberIds = <String>{};
  bool _isBulkActionInProgress = false;

  void closeAllSlidables(List<GlobalKey> keys) {
    for (final key in keys) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Slidable.of(ctx)?.close();
      }
    }
  }

  bool get _hasBulkSelection => _selectedMemberIds.isNotEmpty;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future<void> _showBulkStatusDialog({VoidCallback? onSuccess}) async {
    if (!_hasBulkSelection || _isBulkActionInProgress) return;
    final user = ref.read(userProvider);
    if (user == null) return;

    final members = widget.members ?? [];
    Member? firstSelected;
    for (final member in members) {
      if (_selectedMemberIds.contains(member.memberId)) {
        firstSelected = member;
        break;
      }
    }
    if (firstSelected == null) return;
    final Member selectedMember = firstSelected;

    final displayName = _selectedMemberIds.length > 1
        ? '${selectedMember.memberName} (+${_selectedMemberIds.length - 1})'
        : selectedMember.memberName;

    await showDialog(
      context: context,
      builder: (_) => StatusDialog(
        userId: user.userId,
        eventId: widget.eventId,
        memberId: selectedMember.memberId,
        member: displayName,
        onStatusChange: (
          String userId,
          String eventId,
          String memberId,
          int status,
        ) async {
          await _performBulkStatusUpdate(
            status,
            onSuccess: onSuccess,
          );
        },
      ),
    );
  }

  Future<void> _performBulkStatusUpdate(
    int status, {
    VoidCallback? onSuccess,
  }) async {
    final user = ref.read(userProvider);
    if (user == null || !_hasBulkSelection || !mounted) return;

    _safeSetState(() => _isBulkActionInProgress = true);
    final bulkCount = _selectedMemberIds.length;
    try {
      await ref.read(userProvider.notifier).bulkUpdateMemberStatus(
            user.userId,
            widget.eventId,
            _selectedMemberIds.toList(),
            status,
          );
      await AnalyticsLogger.logMemberStatusChanged(
        eventId: widget.eventId,
        status: status,
        isBulk: true,
        memberCount: bulkCount,
      );
      if (!mounted) return;
      _safeSetState(() {
        _selectedMemberIds.clear();
      });
      onSuccess?.call();
    } catch (error) {
      debugPrint('一括ステータス更新中にエラーが発生しました: $error');
    } finally {
      _safeSetState(() => _isBulkActionInProgress = false);
    }
  }

  Future<void> _showBulkDeleteDialog({VoidCallback? onSuccess}) async {
    if (!_hasBulkSelection || _isBulkActionInProgress) return;
    final user = ref.read(userProvider);
    if (user == null) return;

    final firstId = _selectedMemberIds.first;
    final bulkCount = _selectedMemberIds.length;

    final message = S.of(context)!.bulkDeleteConfirm(_selectedMemberIds.length);

    await showDialog(
      context: context,
      builder: (_) => DeleteMemberDialog(
        userId: user.userId,
        eventId: widget.eventId,
        memberId: firstId,
        message: message,
        onConfirm: () async {
          await _performBulkDelete(onSuccess: onSuccess);
          await AnalyticsLogger.logMemberDeleted(
            eventId: widget.eventId,
            isBulk: true,
            memberCount: bulkCount,
          );
        },
      ),
    );
  }

  Future<void> _performBulkDelete({VoidCallback? onSuccess}) async {
    final user = ref.read(userProvider);
    if (user == null || !_hasBulkSelection) return;

    if (!mounted) return;
    _safeSetState(() => _isBulkActionInProgress = true);
    try {
      await ref.read(userProvider.notifier).deleteMembers(
            user.userId,
            widget.eventId,
            _selectedMemberIds.toList(),
          );
      if (!mounted) return;
      _safeSetState(() {
        _selectedMemberIds.clear();
      });
      onSuccess?.call();
    } catch (error) {
      debugPrint('一括削除中にエラーが発生しました: $error');
    } finally {
      _safeSetState(() => _isBulkActionInProgress = false);
    }
  }

  Future<void> _showBulkEditBottomSheet() async {
    await AnalyticsLogger.logBulkEditOpened(
      eventId: widget.eventId,
    );
    final members = widget.members ?? [];
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double safeTopPadding = mediaQuery.padding.top;
    final double safeBottomPadding = mediaQuery.padding.bottom;
    _safeSetState(() {
      _selectedMemberIds.clear();
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final selectedCount = _selectedMemberIds.length;
            final bool hasSelection = selectedCount > 0;

            void updateSelection(String memberId, bool shouldSelect) {
              if (_isBulkActionInProgress) return;
              _safeSetState(() {
                if (shouldSelect) {
                  _selectedMemberIds.add(memberId);
                } else {
                  _selectedMemberIds.remove(memberId);
                }
              });
              setSheetState(() {});
            }

            return SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  height: screenHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: safeTopPadding + 24),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _isBulkActionInProgress
                                    ? null
                                    : () => Navigator.of(sheetContext).pop(),
                                icon: const Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Center(
                                child: Text(
                                  S.of(sheetContext)!.bulkEdit,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 64),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: members.isEmpty
                              ? Center(
                                  child: Text(
                                    S.of(sheetContext)!.noMembers,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: members.length,
                                  itemBuilder: (context, index) {
                                    final member = members[index];
                                    final isSelected = _selectedMemberIds
                                        .contains(member.memberId);
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: _isBulkActionInProgress
                                              ? null
                                              : () => updateSelection(
                                                    member.memberId,
                                                    !isSelected,
                                                  ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isSelected,
                                                  fillColor: WidgetStateProperty
                                                      .resolveWith((states) {
                                                    if (states.contains(
                                                        WidgetState.selected)) {
                                                      return Theme.of(context)
                                                          .primaryColor;
                                                    }
                                                  }),
                                                  onChanged:
                                                      _isBulkActionInProgress
                                                          ? null
                                                          : (value) =>
                                                              updateSelection(
                                                                member.memberId,
                                                                value ?? false,
                                                              ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        member.memberName
                                                                .isNotEmpty
                                                            ? member.memberName
                                                            : S
                                                                .of(sheetContext)!
                                                                .member,
                                                        style: Theme.of(
                                                                sheetContext)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      if (member.memberMoney !=
                                                          null)
                                                        Text(
                                                          '${member.memberMoney} ${S.of(sheetContext)!.currencyUnit}',
                                                          style: Theme.of(
                                                                  sheetContext)
                                                              .textTheme
                                                              .bodySmall,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                _buildStatusIcon(member.status),
                                                const SizedBox(width: 40),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(height: 1),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16 + safeBottomPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      (!hasSelection || _isBulkActionInProgress)
                                          ? null
                                          : () async {
                                              await _showBulkDeleteDialog(
                                                onSuccess: () {
                                                  if (Navigator.of(sheetContext)
                                                      .canPop()) {
                                                    Navigator.of(sheetContext)
                                                        .pop();
                                                  }
                                                },
                                              );
                                            },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text(
                                    hasSelection
                                        ? '${S.of(sheetContext)!.delete}($selectedCount)'
                                        : S.of(sheetContext)!.delete,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      (!hasSelection || _isBulkActionInProgress)
                                          ? null
                                          : () async {
                                              await _showBulkStatusDialog(
                                                onSuccess: () {
                                                  if (Navigator.of(sheetContext)
                                                      .canPop()) {
                                                    Navigator.of(sheetContext)
                                                        .pop();
                                                  }
                                                },
                                              );
                                            },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(sheetContext).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text(
                                    hasSelection ? '変更($selectedCount)' : '変更',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );

    if (!mounted) return;
    _safeSetState(() {
      _selectedMemberIds.clear();
      _isBulkActionInProgress = false;
    });
  }

  Widget _buildMemberTile(Member member, int index, bool isAmountLoading,
      List<Member> members, List<GlobalKey> slidableKeys) {
    final Widget? roleBadge = _buildRoleBadge(context, member, members);

    Widget buildListTile() {
      return ListTile(
        minTileHeight: 44,
        leading: roleBadge,
        title: (member.memberName.isNotEmpty)
            ? Text(
                member.memberName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: member.status == PaymentStatus.absence
                          ? Colors.grey
                          : Colors.black,
                    ),
              )
            : null,
        subtitle: isAmountLoading
            ? const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpinKitThreeBounce(color: Colors.black, size: 15),
                ],
              )
            : (member.memberMoney != null)
                ? Text(
                    '${member.memberMoney} ${S.of(context)!.currencyUnit}',
                    style: TextStyle(
                      color: member.status == PaymentStatus.absence
                          ? Colors.grey
                          : Colors.black,
                    ),
                  )
                : Text(
                    '--- ${S.of(context)!.currencyUnit}',
                    style: TextStyle(
                      color: member.status == PaymentStatus.absence
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 12,
                    ),
                  ),
        trailing: _buildStatusIcon(member.status),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => StatusDialog(
              userId: ref.read(userProvider)!.userId,
              eventId: widget.eventId.toString(),
              memberId: member.memberId,
              member: member.memberName,
              onStatusChange: (
                String userId,
                String eventId,
                String memberId,
                int status,
              ) async {
                await _updateMemberStatus(
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
      );
    }

    final tileContent = Container(
      key: ValueKey(member.memberId),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    closeAllSlidables(slidableKeys);
                    showDialog(
                      context: context,
                      builder: (context) => EditMemberNameDialog(
                        userId: ref.read(userProvider)!.userId,
                        eventId: widget.eventId,
                        memberId: member.memberId,
                        currentName: member.memberName,
                      ),
                    );
                  },
                  backgroundColor: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                    closeAllSlidables(slidableKeys);
                    showDialog(
                      context: context,
                      builder: (context) => DeleteMemberDialog(
                        userId: ref.read(userProvider)!.userId,
                        eventId: widget.eventId,
                        memberId: member.memberId,
                      ),
                    );
                  },
                  backgroundColor: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
            child: buildListTile(),
          ),
          const Divider(
            thickness: 1,
            height: 1,
            color: Color(0xFFE8E8E8),
          ),
        ],
      ),
    );

    return tileContent;
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
      await AnalyticsLogger.logMemberStatusChanged(
        eventId: eventId,
        memberId: memberId,
        status: status,
        isBulk: false,
      );
    } catch (error) {
      debugPrint('ステータス更新中にエラーが発生しました。 $error');
    }
  }

  // Handles member reordering triggered via long-press drag.
  void _onReorderMember(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    ref
        .read(userProvider.notifier)
        .reorderMembers(widget.eventId, oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.members ?? [];
    final isAmountLoading = ref.watch(amountLoadingProvider(widget.eventId));
    final slidableKeys = List.generate(members.length, (_) => GlobalKey());
    final primaryColor = Theme.of(context).primaryColor;
    final oneEightPadding = MediaQuery.of(context).size.width / 8;

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
                            const SizedBox(width: 32),
                            Text(
                              S.of(context)!.member,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              S.of(context)!.sort,
                              style: GoogleFonts.notoSansJp(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              key: widget.sortKey,
                              onTap: () {
                                AnalyticsLogger.logSortPressed();
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
                                    S.of(context)!.memberDeletedAfter24h,
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
                                  child: ReorderableListView.builder(
                                    key: ValueKey(
                                        'member_list_${widget.eventId}'),
                                    buildDefaultDragHandles: false,
                                    padding: EdgeInsets.zero,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: members.length,
                                    onReorder: _onReorderMember,
                                    onReorderStart: (_) {
                                      AnalyticsLogger.logMemberLongPressed();
                                    },
                                    itemBuilder: (context, index) {
                                      return ReorderableDelayedDragStartListener(
                                        key: ValueKey(members[index].memberId),
                                        index: index,
                                        child: _buildMemberTile(
                                          members[index],
                                          index,
                                          isAmountLoading,
                                          members,
                                          slidableKeys,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _isBulkActionInProgress
                                  ? null
                                  : _showBulkEditBottomSheet,
                              style: TextButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: SvgPicture.asset(
                                      'assets/icons/ic_bulk_delete.svg',
                                      colorFilter: const ColorFilter.mode(
                                        Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    S.of(context)!.bulkEdit,
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
                            SizedBox(width: oneEightPadding),
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
                                mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: 10),
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
