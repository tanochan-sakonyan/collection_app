import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/guide/amount_guide_dialog.dart';
import 'package:mr_collection/ui/components/dialog/role_setup_dialog.dart';
import 'package:mr_collection/ui/components/dialog/member_role_edit_dialog.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/screen/amount_screen/tabs/adjust_amounts_tab.dart';
import 'package:mr_collection/ui/screen/amount_screen/tabs/role_adjust_tab.dart';
import 'package:mr_collection/ui/screen/amount_screen/tabs/split_equally_tab.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/components/round_up_module.dart';

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
    final primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: SizedBox(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.white,
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
  final Map<String, String> _memberRoles = {};
  bool _isFirstTimeShowingRoleDialog = true;
  RoundUpOption _selectedRoundUpOption = RoundUpOption.none;

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

    // 過去のデータを引き継ぐ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreviousData();
    });
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
      );
  TextStyle get _yenStyle => _numberStyle.copyWith(fontSize: 36);

  Future<void> _onConfirm(
    userId,
    eventId,
  ) async {
    final Map<String, int> amountMap = {};

    if (_tabController.index == 0) {
      final evenShare = _calculateRoundedEvenShare();
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
      _calculateRoleBasedAmounts(amountMap);
    }
    debugPrint('送信する金額マップ: $amountMap');

    final List<Map<String, dynamic>> membersMoneyList = amountMap.entries
        .map((entry) => {
              'memberId': entry.key,
              'memberMoney': entry.value,
              'role': _memberRoles[entry.key] ?? '',
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

  void _loadPreviousData() {
    final user = ref.read(userProvider);
    if (user == null) return;

    try {
      final event = user.events.firstWhere(
        (e) => e.eventId == widget.eventId,
      );

      // 個別金額の引き継ぎ
      if (event.members.isNotEmpty) {
        for (int i = 0; i < widget.members.length; i++) {
          final member = widget.members[i];
          try {
            final eventMember = event.members.firstWhere(
              (m) => m.memberId == member.memberId,
            );

            if (eventMember.memberMoney != null) {
              _controllers[i].text = _numFmt.format(eventMember.memberMoney!);
              if (eventMember.role != null && eventMember.role!.isNotEmpty) {
                _memberRoles[member.memberId] = eventMember.role!;
              }
            }
          } catch (e) {
            debugPrint('${member.memberName}のデータが見つかりません: $e');
          }
        }
        _restoreRolesFromMemberRoles();
        setState(() {});
      }
    } catch (e) {
      debugPrint('過去のデータの読み込みに失敗しました: $e');
    }
  }

  void _restoreRolesFromMemberRoles() {
    if (_memberRoles.isEmpty) return;

    final Map<String, List<Member>> roleGroups = {};
    final Map<String, int> roleAmounts = {};

    final user = ref.read(userProvider);
    if (user != null) {
      try {
        final event = user.events.firstWhere(
          (e) => e.eventId == widget.eventId,
        );

        for (final eventMember in event.members) {
          if (eventMember.role != null &&
              eventMember.role!.isNotEmpty &&
              eventMember.memberMoney != null) {
            roleAmounts[eventMember.role!] = eventMember.memberMoney!;
          }
        }
      } catch (e) {
        debugPrint('過去のイベントデータの取得に失敗: $e');
      }
    }

    _memberRoles.forEach((memberId, roleName) {
      if (roleName.isNotEmpty) {
        roleGroups[roleName] ??= [];
        try {
          final member = widget.members.firstWhere(
            (m) => m.memberId == memberId,
          );
          roleGroups[roleName]!.add(member);
        } catch (e) {
          debugPrint('メンバーが見つかりません: $memberId');
        }
      }
    });

    _roles = roleGroups.entries
        .map((entry) => {
              'role': entry.key,
              'amount': roleAmounts[entry.key] ?? 0,
              'members': entry.value,
            })
        .toList();

    _isFirstTimeShowingRoleDialog = false;
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
    final lockedSum = _calculateLockedSum();

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

    int share;
    if (_currentTab == 1) {
      share = _calculateRoundedShareForGroup(remaining, adjustables.length);
    } else {
      share = (remaining / adjustables.length).ceil();
    }

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
        Map<String, dynamic>? role;
        try {
          role = _roles.firstWhere((r) => r['role'] == memberRole);
        } catch (e) {
          role = {'amount': 0};
        }
        final roleAmount = (role['amount'] ?? 0) as int;
        amountMap[member.memberId] = roleAmount;
        totalRoleAmount += roleAmount;
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
      final perPersonAmount =
          _calculateRoundedShareForGroup(remainingAmount, noRoleMembers.length);
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
        memberRoles: _memberRoles,
        shouldRestoreDefaultRoles: _isFirstTimeShowingRoleDialog,
        existingRoles: _roles.isNotEmpty ? _roles : null,
        onConfirm: () {},
        onRoleConfirm: (roles) {
          setState(() {
            // ロールリストは常に保持（メンバーが割り当てられていなくても）
            _roles = roles;

            // 新しい役割リストに存在しない役割のみメンバーロールから削除
            final newRoleNames =
                roles.map((role) => role['role'] as String).toSet();
            _memberRoles.removeWhere(
                (memberId, roleName) => !newRoleNames.contains(roleName));

            // 役割に基づいてメンバーの役割を設定（新しく追加された分のみ）
            for (final role in roles) {
              final roleMembers = List<Member>.from(role['members'] as List);
              for (final member in roleMembers) {
                _memberRoles[member.memberId] = role['role'];
              }
            }
            _isFirstTimeShowingRoleDialog = false;
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
              final targetRoleMembers =
                  List<Member>.from(targetRole['members'] as List);
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

  TextSpan _buildRoleDescriptionTextSpan(BuildContext context) {
    final description = S.of(context)!.roleSetupDescription;
    const boldPhrase = "役割別で割り勘"; // 太字にしたい部分

    if (description.contains(boldPhrase)) {
      final parts = description.split(boldPhrase);
      return TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: boldPhrase,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF383838),
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      );
    } else {
      // フォールバック：boldPhraseが見つからない場合は通常のテキスト
      return TextSpan(
        text: description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
      );
    }
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
        return _calculateRoundedShareForGroup(
            remainingAmount, noRoleMembers.length);
      }
      return 0;
    }

    Map<String, dynamic>? role;
    try {
      role = _roles.firstWhere((r) => r['role'] == roleKey);
    } catch (e) {
      role = {'amount': 0};
    }
    return (role['amount'] ?? 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider)!.userId;
    final evenShare = _calculateRoundedEvenShare();
    final changeAmount = _calculateChangeAmountForCurrentTab();
    final formattedChange = _numFmt.format(changeAmount);
    final primaryColor = Theme.of(context).primaryColor;
    final currencyUnit = S.of(context)!.currencyUnit;

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
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                S.of(context)!.back,
                style: GoogleFonts.notoSansJp(
                    color: primaryColor,
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 10),
                Text(
                  S.of(context)!.setIndividualAmounts,
                  style: GoogleFonts.notoSansJp(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onPressed: () => _showGuideDialog(),
                    icon: SvgPicture.asset(
                      'assets/icons/ic_question_circle.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor,
                        BlendMode.srcIn,
                      ),
                    )),
                const Spacer(flex: 8),
              ],
            ),
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
            const SizedBox(height: 12),
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
                    SplitEquallyTab(
                      members: widget.members,
                      numberFormat: _numFmt,
                      evenShare: evenShare,
                    ),
                    AdjustAmountsTab(
                      members: widget.members,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      locked: _locked,
                      amountFormatter: _buildAmountFormatter(),
                      currencyUnit: S.of(context)!.currencyUnit,
                      onSubmitted: _handleSubmitted,
                      onToggleLock: _toggleLock,
                    ),
                    RoleAdjustTab(
                      roles: _roles,
                      memberRoles: _memberRoles,
                      members: widget.members,
                      onOpenRoleSetup: _showRoleSetupDialog,
                      onEditMemberRole: _showMemberRoleEditDialog,
                      getRoleAmount: _getRoleAmount,
                      buildRoleDescription: _buildRoleDescriptionTextSpan,
                      numberFormat: _numFmt,
                    ),
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
              const EdgeInsets.only(top: 12, bottom: 60, right: 24, left: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentTab == 0 ||
                  _currentTab == 1 ||
                  (_currentTab == 2 && _roles.isNotEmpty))
                RoundUpModule(
                  currencyUnit: currencyUnit,
                  selectedOption: _selectedRoundUpOption,
                  onOptionChanged: _handleRoundOptionSelected,
                  changeAmountText: formattedChange,
                ),
              if (_currentTab == 0 ||
                  _currentTab == 1 ||
                  (_currentTab == 2 && _roles.isNotEmpty))
                const SizedBox(height: 16),
              SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentTab == 2 && _roles.isEmpty
                        ? Colors.grey
                        : primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _currentTab == 2 && _roles.isEmpty
                      ? null
                      : () {
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
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 選択中の設定に応じて均等割金額を計算します。
  int _calculateRoundedEvenShare() {
    final activeCount = _activeMemberCount();
    if (activeCount == 0) {
      return 0;
    }
    final baseShare = (widget.amount / activeCount).ceil();
    return _applyRoundUp(baseShare);
  }

  /// 選択している端数単位を返します。
  int get _roundUpUnit {
    switch (_selectedRoundUpOption) {
      case RoundUpOption.ten:
        return 10;
      case RoundUpOption.fifty:
        return 50;
      case RoundUpOption.hundred:
        return 100;
      case RoundUpOption.none:
      default:
        return 0;
    }
  }

  /// 端数単位に合わせて金額を切り上げます。
  int _applyRoundUp(int base) {
    final unit = _roundUpUnit;
    if (unit == 0 || base == 0) {
      return base;
    }
    final remainder = base % unit;
    return remainder == 0 ? base : base + (unit - remainder);
  }

  /// お釣りの金額を算出します。
  int _calculateChangeAmountForCurrentTab() {
    if (_currentTab == 0) {
      final activeCount = _activeMemberCount();
      if (activeCount == 0) {
        return 0;
      }
      final roundedShare = _calculateRoundedEvenShare();
      final totalCollected = roundedShare * activeCount;
      final change = totalCollected - widget.amount;
      return change < 0 ? 0 : change;
    } else if (_currentTab == 1) {
      final lockedSum = _calculateLockedSum();
      final adjustableCount = _countAdjustableMembers();
      if (adjustableCount == 0) {
        final change = lockedSum - widget.amount;
        return change < 0 ? 0 : change;
      }
      final remaining = widget.amount - lockedSum;
      final roundedShare =
          _calculateRoundedShareForGroup(remaining, adjustableCount);
      final totalCollected = lockedSum + roundedShare * adjustableCount;
      final change = totalCollected - widget.amount;
      return change < 0 ? 0 : change;
    } else if (_currentTab == 2) {
      final Map<String, int> temp = {};
      _calculateRoleBasedAmounts(temp);
      final totalCollected =
          temp.values.fold<int>(0, (sum, value) => sum + value);
      final change = totalCollected - widget.amount;
      return change < 0 ? 0 : change;
    }
    return 0;
  }

  /// 有効なメンバー数を取得します。
  int _activeMemberCount() {
    return widget.members
        .where((m) => m.status != PaymentStatus.absence)
        .length;
  }

  /// 鍵がかかっていないメンバー数を取得します。
  int _countAdjustableMembers() {
    int count = 0;
    for (int i = 0; i < widget.members.length; i++) {
      final member = widget.members[i];
      if (member.status == PaymentStatus.absence) continue;
      if (!_locked[i]) {
        count += 1;
      }
    }
    return count;
  }

  /// 鍵がかかっているメンバーの合計金額を計算します。
  int _calculateLockedSum() {
    int lockedSum = 0;
    for (int i = 0; i < widget.members.length; i++) {
      final member = widget.members[i];
      if (member.status == PaymentStatus.absence) continue;
      if (_locked[i]) {
        lockedSum +=
            int.tryParse(_controllers[i].text.replaceAll(',', '')) ?? 0;
      }
    }
    return lockedSum;
  }

  /// 残額を複数人で分割する際の切り上げ額を計算します。
  int _calculateRoundedShareForGroup(int remaining, int count) {
    if (count == 0 || remaining <= 0) {
      return 0;
    }
    final baseShare = (remaining / count).ceil();
    return _applyRoundUp(baseShare);
  }

  /// 端数切り上げの選択状態を更新します。
  void _handleRoundOptionSelected(RoundUpOption option) {
    final newValue =
        _selectedRoundUpOption == option ? RoundUpOption.none : option;
    setState(() {
      _selectedRoundUpOption = newValue;
    });
    if (_currentTab == 1 || _currentTab == 2) {
      _recalculateAmounts();
    }
  }
}
