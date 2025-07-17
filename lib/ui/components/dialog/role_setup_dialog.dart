import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/ui/components/dialog/role_assignment_dialog.dart';

class RoleSetupDialog extends StatefulWidget {
  final List<Member> members;
  final VoidCallback onConfirm;
  final Function(List<Map<String, dynamic>>) onRoleConfirm;
  final Map<String, String> memberRoles;
  final bool shouldRestoreDefaultRoles;

  const RoleSetupDialog({
    super.key,
    required this.members,
    required this.onConfirm,
    required this.onRoleConfirm,
    required this.memberRoles,
    this.shouldRestoreDefaultRoles = false,
  });

  @override
  State<RoleSetupDialog> createState() => _RoleSetupDialogState();
}

class _RoleSetupDialogState extends State<RoleSetupDialog> {
  List<Map<String, dynamic>> roles = [];
  final _numFmt = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    // デフォルトの役割を追加（多言語対応のため、buildメソッドで初期化）
  }

  void _initializeDefaultRoles() {
    if (roles.isEmpty && widget.shouldRestoreDefaultRoles) {
      roles = [
        {'role': S.of(context)!.seniorStudent, 'amount': 3000, 'members': []},
        {'role': S.of(context)!.freshmanStudent, 'amount': 1000, 'members': []},
      ];
    }
  }

  void _addRole(String roleName, int amount) {
    setState(() {
      roles.add({'role': roleName, 'amount': amount, 'members': []});
    });
  }

  void _showRoleInputDialog() {
    final TextEditingController roleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)!.roleSetup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roleController,
              decoration: InputDecoration(
                hintText: S.of(context)!.roleNameInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF75DCC6)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: S.of(context)!.enterAmount,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF75DCC6)),
                ),
                suffixText: '円',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (roleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                _addRole(roleController.text, int.parse(amountController.text));
                Navigator.pop(context);
              }
            },
            child: Text(S.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _deleteRole(int index) {
    setState(() {
      roles.removeAt(index);
    });
  }

  Map<String, String> _getCurrentMemberRoles() {
    final Map<String, String> currentMemberRoles = {};
    for (final role in roles) {
      final roleName = role['role'] as String;
      final roleMembers = role['members'] as List<dynamic>;
      for (final member in roleMembers) {
        if (member is Member) {
          currentMemberRoles[member.memberId] = roleName;
        }
      }
    }
    return currentMemberRoles;
  }

  void _showRoleAssignmentDialog(int roleIndex) {
    showDialog(
      context: context,
      builder: (context) => RoleAssignmentDialog(
        roleName: roles[roleIndex]['role'],
        members: widget.members,
        memberRoles: _getCurrentMemberRoles(),
        onAssign: (selectedMembers) {
          setState(() {
            // 他の役割から選択されたメンバーを削除
            for (int i = 0; i < roles.length; i++) {
              if (i != roleIndex) {
                final roleMembers = List<Member>.from(roles[i]['members'] as List);
                roleMembers.removeWhere((member) => 
                    selectedMembers.any((selected) => selected.memberId == member.memberId)
                );
                roles[i]['members'] = roleMembers;
              }
            }
            // 現在の役割にメンバーを設定
            roles[roleIndex]['members'] = selectedMembers;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeDefaultRoles();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context)!.roleSetup,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ClipRect(
                child: SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      final role = roles[index];
                      return Column(
                        children: [
                          Slidable(
                            key: ValueKey(role['role']),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.30,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (context) {
                                    _deleteRole(index);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  child: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      role['role'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Container(
                                    width: 68,
                                    height: 36,
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4, left: 12, right: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFC6C6C8)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(_numFmt.format(role['amount']),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        textAlign: TextAlign.right),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '円',
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () =>
                                        _showRoleAssignmentDialog(index),
                                    icon: SvgPicture.asset(
                                      'assets/icons/ic_next.svg',
                                      width: 14,
                                      height: 14,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF75DCC6),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            height: 1,
                            color: Color(0xFFE8E8E8),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 役割を入力するボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showRoleInputDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF75DCC6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context)!.roleNameInput,
                  style: GoogleFonts.notoSansJp(
                    color: const Color(0xFF75DCC6),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 108,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  widget.onRoleConfirm(roles);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DCC6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context)!.confirm,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
