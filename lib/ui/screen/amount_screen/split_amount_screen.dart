import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show FontFeature;
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/amount_guide_dialog.dart';
import 'package:mr_collection/ui/components/dialog/role_setup_dialog.dart';
import 'package:mr_collection/ui/components/dialog/member_role_edit_dialog.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'dart:convert';

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF75DCC6) : Colors.white,
            borderRadius: BorderRadius.circular(48),
            boxShadow: selected
                ? []
                : [
                    const BoxShadow(
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      color: Color(0x1A000000),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(48),
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplitAmountScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;
  final int amount;
  final List<Member> members;
  const SplitAmountScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.amount,
    required this.members,
  });

  @override
  ConsumerState<SplitAmountScreen> createState() => _SplitAmountScreenState();
}

class _SplitAmountScreenState extends ConsumerState<SplitAmountScreen>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _locked;
  late TabController _tabController;
  final _numFmt = NumberFormat.decimalPattern();
  late int _currentTab;
  List<Map<String, dynamic>> _roles = [];
  Map<String, String> _memberRoles = {};

  @override
  void initState() {
    super.initState();
    final activeMembers =
        widget.members.where((m) => m.status != PaymentStatus.absence).toList();
    final evenShare = (widget.amount / activeMembers.length).ceil();
    _controllers = widget.members
        .map(
          (m) => TextEditingController(
            text: _numFmt.format(
                m.status == PaymentStatus.absence ? 0 : evenShare), // ★修正
          ),
        )
        .toList();
    _focusNodes = List.generate(
      widget.members.length,
      (i) {
        final node = FocusNode();
        node.addListener(() {
          if (!node.hasFocus) {
            _handleSubmitted(i, _controllers[i].text);
          }
        });
        return node;
      },
    );
    _locked =
        widget.members.map((m) => m.status == PaymentStatus.absence).toList();
    _tabController = TabController(length: 3, vsync: this);
    _currentTab = 0;
    _tabController.addListener(() {
      if (_currentTab != _tabController.index && mounted) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void _showGuideDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'guide',
      barrierColor: Colors.black38,
      pageBuilder: (_, __, ___) => AmountGuideDialog(
        onPageChanged: (index) {},
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  TextStyle get _numberStyle => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  TextStyle get _yenStyle => _numberStyle.copyWith(fontSize: 36);

  Future<void> _onConfirm(
    userId,
    eventId,
  ) async {
    final Map<String, int> amountMap = {};

    if (_tabController.index == 0) {
      final activeMembers = widget.members
          .where((m) => m.status != PaymentStatus.absence)
          .toList();
      final evenShare = (widget.amount / activeMembers.length).ceil();
      for (final m in widget.members) {
        amountMap[m.memberId] =
            m.status == PaymentStatus.absence ? 0 : evenShare;
      }
    } else if (_tabController.index == 1) {
      for (var i = 0; i < widget.members.length; i++) {
        amountMap[widget.members[i].memberId] =
            widget.members[i].status == PaymentStatus.absence // ★修正
                ? 0
                : int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    } else if (_tabController.index == 2) {
      // 役割タブの場合の処理
      _calculateRoleBasedAmounts(amountMap);
    }
    debugPrint('送信する金額マップ: $amountMap');

    final List<Map<String, dynamic>> membersMoneyList = amountMap.entries
        .map((entry) => {
              'memberId': entry.key,
              'memberMoney': entry.value,
            })
        .toList();

    try {
      debugPrint("金額入力をします：$membersMoneyList");
      await ref
          .read(userProvider.notifier)
          .inputMembersMoney(userId, eventId, membersMoneyList, ref);
    } catch (e) {
      debugPrint('金額入力中にエラーが発生しました: $e');
      return;
    }
  }

  void _handleSubmitted(int index, String rawText) {
    int input = int.tryParse(rawText.replaceAll(',', '')) ?? 0;
    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      if (widget.members[i].status == PaymentStatus.absence) continue;
      if (_locked[i] && i != index) {
        lockedSum +=
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    int remaining = widget.amount - lockedSum;

    final bool wasTrimmed = input > remaining;
    if (wasTrimmed) {
      input = remaining;
    }

    setState(() {
      _controllers[index].text = _numFmt.format(input);
      _locked[index] = true;

      if (wasTrimmed) {
        for (int j = 0; j < widget.members.length; j++) {
          if (j != index && !_locked[j]) {
            _controllers[j].text = _numFmt.format(0);
          }
        }
      }

      _recalculateAmounts();
    });
  }

  void _toggleLock(int index) {
    setState(() {
      _locked[index] = !_locked[index];
      _recalculateAmounts();
    });
  }

  void _recalculateAmounts() {
    // 役割から調整タブの場合は役割に基づく金額計算
    if (_currentTab == 2 && _roles.isNotEmpty) {
      final Map<String, int> amountMap = {};
      _calculateRoleBasedAmounts(amountMap);
      
      // 各メンバーの金額を更新
      for (int i = 0; i < widget.members.length; i++) {
        final member = widget.members[i];
        final amount = amountMap[member.memberId] ?? 0;
        _controllers[i].text = _numFmt.format(amount);
      }
      setState(() {});
      return;
    }

    // 通常の計算ロジック
    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      if (widget.members[i].status == PaymentStatus.absence) continue;
      if (_locked[i]) {
        lockedSum +=
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }

    if (lockedSum >= widget.amount) {
      setState(() {});
      return;
    }

    final adjustables = <int>[];
    for (int i = 0; i < widget.members.length; i++) {
      if (widget.members[i].status == PaymentStatus.absence) continue;
      if (!_locked[i]) adjustables.add(i);
    }

    int remaining = widget.amount - lockedSum;

    if (adjustables.isEmpty) {
      for (int i = widget.members.length - 1; i >= 0; i--) {
        if (widget.members[i].status == PaymentStatus.absence) continue;
        if (_locked[i]) {
          int val = int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
          _controllers[i].text = _numFmt.format(val + remaining);
          break;
        }
      }
      setState(() {});
      return;
    }

    int share = (remaining / adjustables.length).ceil();

    for (int idx in adjustables) {
      _controllers[idx].text = _numFmt.format(share);
    }

    setState(() {});
  }

  void _calculateRoleBasedAmounts(Map<String, int> amountMap) {
    // 役割に基づいて金額を計算
    int totalRoleAmount = 0;

    for (final member in widget.members) {
      if (member.status == PaymentStatus.absence) {
        amountMap[member.memberId] = 0;
        continue;
      }

      final memberRole = _memberRoles[member.memberId];
      if (memberRole != null) {
        final role = _roles.firstWhere(
          (r) => r['role'] == memberRole,
          orElse: () => {'amount': 0},
        );
        final roleAmount = role['amount'] ?? 0;
        amountMap[member.memberId] = roleAmount as int;
        totalRoleAmount += roleAmount as int;
      } else {
        amountMap[member.memberId] = 0;
      }
    }

    // 残りの金額を役職なしのメンバーで分割
    final remainingAmount = widget.amount - totalRoleAmount;
    final noRoleMembers = widget.members
        .where((m) =>
            m.status != PaymentStatus.absence &&
            (_memberRoles[m.memberId] == null ||
                _memberRoles[m.memberId] == ''))
        .toList();

    if (noRoleMembers.isNotEmpty && remainingAmount > 0) {
      final perPersonAmount = (remainingAmount / noRoleMembers.length).ceil();
      for (final member in noRoleMembers) {
        amountMap[member.memberId] = perPersonAmount;
      }
    }
  }

  void _showRoleSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => RoleSetupDialog(
        members: widget.members,
        onConfirm: () {},
        onRoleConfirm: (roles) {
          setState(() {
            _roles = roles;
            // 役割に基づいてメンバーの役割を設定
            _memberRoles.clear();
            for (final role in roles) {
              final roleMembers = List<Member>.from(role['members'] as List);
              for (final member in roleMembers) {
                _memberRoles[member.memberId] = role['role'];
              }
            }
          });
        },
      ),
    );
  }

  void _showMemberRoleEditDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => MemberRoleEditDialog(
        member: member,
        roles: _roles,
        currentRole: _memberRoles[member.memberId],
        onRoleChange: (newRole) {
          setState(() {
            // 現在の役割から該当メンバーを削除
            for (final role in _roles) {
              final roleMembers = List<Member>.from(role['members'] as List);
              roleMembers.removeWhere((m) => m.memberId == member.memberId);
              role['members'] = roleMembers;
            }
            
            if (newRole == null) {
              _memberRoles.remove(member.memberId);
            } else {
              _memberRoles[member.memberId] = newRole;
              // 新しい役割にメンバーを追加
              final targetRole = _roles.firstWhere((r) => r['role'] == newRole);
              final targetRoleMembers = List<Member>.from(targetRole['members'] as List);
              targetRoleMembers.add(member);
              targetRole['members'] = targetRoleMembers;
            }
            
            // 金額を再計算
            _recalculateAmounts();
          });
        },
      ),
    );
  }

  void _outputJsonData() {
    // メンバーと金額、役割のマップデータを作成
    final List<Map<String, dynamic>> memberDataList = [];
    
    for (int i = 0; i < widget.members.length; i++) {
      final member = widget.members[i];
      final controller = _controllers[i];
      final amountText = controller.text;
      final amount = int.tryParse(amountText.replaceAll(',', '')) ?? 0;
      final role = _memberRoles[member.memberId];
      
      memberDataList.add({
        'memberId': member.memberId,
        'memberName': member.memberName,
        'amount': amount,
        'role': role,
        'status': member.status.toString(),
      });
    }
    
    final Map<String, dynamic> jsonData = {
      'eventId': widget.eventId,
      'totalAmount': widget.amount,
      'selectedTab': _currentTab,
      'members': memberDataList,
      'roles': _roles,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    debugPrint('=== Split Amount Data ===');
    debugPrint(jsonString);
    debugPrint('========================');
  }

  TextInputFormatter _buildAmountFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;
      if (text.isEmpty) return newValue;

      String digitsOnly = text.replaceAll(',', '');
      final int? value = int.tryParse(digitsOnly);
      if (value == null) return oldValue;
      if (value > 9990000) return oldValue;
      String newText = _numFmt.format(value);
      int oldCursor = newValue.selection.end;
      int nonCommaBefore =
          text.substring(0, oldCursor).replaceAll(',', '').length;
      int cursor = 0, count = 0;
      for (int i = 0; i < newText.length && count < nonCommaBefore; i++) {
        if (newText[i] != ',') count++;
        cursor++;
      }

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor),
      );
    });
  }

  Widget _buildRoleTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 説明文（役割がない場合のみ表示）
          if (_roles.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    S.of(context)!.roleBasedAmountSetting,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context)!.roleSetupDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 164,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _showRoleSetupDialog(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFF2F2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  S.of(context)!.inputRole,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF75DCC6),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          // メンバーリスト（役割が設定された場合のみ表示）
          if (_roles.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: widget.members.length,
                itemBuilder: (context, i) {
                  final member = widget.members[i];
                  final memberRole = _memberRoles[member.memberId];
                  final roleAmount = _getRoleAmount(memberRole);

                  return Column(
                    children: [
                      ListTile(
                        leading: GestureDetector(
                          onTap: () => _showMemberRoleEditDialog(member),
                          child: memberRole != null && memberRole.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF75DCC6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    memberRole,
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    S.of(context)!.noRole,
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ),
                        title: Text(
                          member.memberName,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 16,
                            color: member.status == PaymentStatus.absence
                                ? const Color(0xFFC0C0C0)
                                : Colors.black,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _numFmt.format(roleAmount),
                              style: GoogleFonts.notoSansJp(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.of(context)!.currencyUnit,
                              style: GoogleFonts.notoSansJp(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: Color(0xFFE8E8E8),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // 役割を修正ボタン
            SizedBox(
              width: 152,
              height: 48,
              child: OutlinedButton(
                onPressed: _showRoleSetupDialog,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF75DCC6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context)!.modifyRole,
                  style: GoogleFonts.notoSansJp(
                    color: const Color(0xFF75DCC6),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getRoleAmount(String? roleKey) {
    if (roleKey == null || roleKey.isEmpty) {
      // 役職なしの場合、残りの金額を均等割り
      int totalRoleAmount = 0;
      for (final role in _roles) {
        final roleMembers = List<Member>.from(role['members'] as List);
        totalRoleAmount += (role['amount'] as int) * roleMembers.length;
      }

      final remainingAmount = widget.amount - totalRoleAmount;
      final noRoleMembers = widget.members
          .where((m) =>
              m.status != PaymentStatus.absence &&
              (_memberRoles[m.memberId] == null ||
                  _memberRoles[m.memberId] == ''))
          .toList();

      if (noRoleMembers.isNotEmpty && remainingAmount > 0) {
        return (remainingAmount / noRoleMembers.length).ceil();
      }
      return 0;
    }

    final role = _roles.firstWhere(
      (r) => r['role'] == roleKey,
      orElse: () => {'amount': 0},
    );
    return role['amount'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider)!.userId;
    final activeCount =
        widget.members.where((m) => m.status != PaymentStatus.absence).length;
    final evenShare =
        activeCount == 0 ? 0 : (widget.amount / activeCount).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 44,
                height: 44,
              ),
              Text(
                S.of(context)!.back,
                style: GoogleFonts.notoSansJp(
                    color: const Color(0xFF76DCC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              widget.eventName,
              style: GoogleFonts.notoSansJp(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 10),
                Text(
                  S.of(context)!.setIndividualAmounts ??
                      "Set individual amounts",
                  style: GoogleFonts.notoSansJp(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                    onPressed: () => _showGuideDialog(),
                    icon: SvgPicture.asset(
                      'assets/icons/question_circle.svg',
                      width: 24,
                      height: 24,
                    )),
                const Spacer(flex: 8),
              ],
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: _numFmt.format(widget.amount),
                style: _numberStyle,
                children: [
                  TextSpan(text: S.of(context)!.currencyUnit, style: _yenStyle),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabPill(
                    label: S.of(context)!.splitEqually,
                    selected: _currentTab == 0,
                    onTap: () {
                      if (_currentTab == 0) return;
                      setState(() => _currentTab = 0);
                      _tabController.animateTo(0);
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabPill(
                    label: S.of(context)!.adjustAmounts,
                    selected: _currentTab == 1,
                    onTap: () {
                      if (_currentTab == 1) return;
                      setState(() => _currentTab = 1);
                      _tabController.animateTo(1);
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabPill(
                    label: S.of(context)!.adjustByRole,
                    selected: _currentTab == 2,
                    onTap: () {
                      if (_currentTab == 2) return;
                      setState(() => _currentTab = 2);
                      _tabController.animateTo(2);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 割り勘
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 44),
                      itemCount: widget.members.length,
                      itemBuilder: (context, i) {
                        final m = widget.members[i];
                        return Column(
                          children: [
                            ListTile(
                              minTileHeight: 44,
                              title: Text(m.memberName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: m.status == PaymentStatus.absence
                                            ? const Color(0xFFC0C0C0)
                                            : Colors.black,
                                      )),
                              trailing: IntrinsicWidth(
                                child: m.status == PaymentStatus.absence
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            S.of(context)!.status_absence ??
                                                "Absence",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFFC0C0C0),
                                                ),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            _numFmt.format(evenShare),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            S.of(context)!.currencyUnit ??
                                                "USD",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                          ],
                        );
                      },
                    ),
                    // 金額の調整
                    ListView.builder(
                      padding: const EdgeInsets.only(left: 34, right: 20),
                      itemCount: widget.members.length,
                      itemBuilder: (context, i) {
                        final m = widget.members[i];
                        return Column(
                          children: [
                            ListTile(
                              minTileHeight: 44,
                              title: Text(m.memberName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: m.status == PaymentStatus.absence
                                            ? const Color(0xFFC0C0C0)
                                            : Colors.black,
                                      )),
                              trailing: SizedBox(
                                width: 140,
                                child: m.status == PaymentStatus.absence
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            S.of(context)!.status_absence ??
                                                "Absence",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFFC0C0C0),
                                                ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 28,
                                              child: TextField(
                                                controller: _controllers[i],
                                                focusNode: _focusNodes[i],
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.right,
                                                inputFormatters: [
                                                  _buildAmountFormatter()
                                                ],
                                                decoration: InputDecoration(
                                                  isCollapsed: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFC6C6C8)),
                                                  ),
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontSize: 16,
                                                      fontWeight: _locked[i]
                                                          ? FontWeight.w700
                                                          : FontWeight
                                                              .w400, // ★変更
                                                    ),
                                                onSubmitted: (v) =>
                                                    _handleSubmitted(i, v),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            S.of(context)!.currencyUnit ??
                                                "USD",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(width: 24),
                                          GestureDetector(
                                            onTap: () => _toggleLock(i),
                                            child: SvgPicture.asset(
                                              _locked[i]
                                                  ? 'assets/icons/ic_lock_close.svg'
                                                  : 'assets/icons/ic_lock_open.svg',
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                          ],
                        );
                      },
                    ),
                    // 役割から調整タブ
                    _buildRoleTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 30, bottom: 60, right: 141, left: 141),
          child: SizedBox(
            width: 140,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTab == 2 && _roles.isEmpty
                    ? Colors.grey
                    : const Color(0xFF75DCC6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _currentTab == 2 && _roles.isEmpty
                  ? null
                  : () {
                      // JSONデータを出力
                      _outputJsonData();
                      
                      _onConfirm(
                        userId,
                        widget.eventId,
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    },
              child: Text(S.of(context)!.confirm,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
