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

  const RoleSetupDialog({
    super.key,
    required this.members,
    required this.onConfirm,
    required this.onRoleConfirm,
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
    if (roles.isEmpty) {
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

  void _showRoleAssignmentDialog(int roleIndex) {
    showDialog(
      context: context,
      builder: (context) => RoleAssignmentDialog(
        roleName: roles[roleIndex]['role'],
        members: widget.members,
        onAssign: (selectedMembers) {
          setState(() {
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
            Text(
              S.of(context)!.roleSetup,
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // 役割リスト
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
                    return Slidable(
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
                        margin: const EdgeInsets.only(bottom: 1),
                        child: ListTile(
                          title: Text(
                            role['role'],
                            style: GoogleFonts.notoSansJp(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE5E5E5)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _numFmt.format(role['amount']),
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '円',
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () =>
                                    _showRoleAssignmentDialog(index),
                                icon: SvgPicture.asset(
                                  'assets/icons/ic_next.svg',
                                  width: 16,
                                  height: 16,
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
            // 確定ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onRoleConfirm(roles);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DCC6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context)!.confirm,
                  style: GoogleFonts.notoSansJp(
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
