import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

class RoleAssignmentDialog extends StatefulWidget {
  final String roleName;
  final List<Member> members;
  final Function(List<Member>) onAssign;

  const RoleAssignmentDialog({
    super.key,
    required this.roleName,
    required this.members,
    required this.onAssign,
  });

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  List<Member> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    // デフォルトでは誰も選択されていない状態
    selectedMembers = [];
  }

  void _toggleMember(Member member) {
    setState(() {
      if (selectedMembers.contains(member)) {
        selectedMembers.remove(member);
      } else {
        selectedMembers.add(member);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 352,
        height: 376,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '「${widget.roleName}」${S.of(context)!.assignRoleToMembers}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // メンバーリスト
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  final isSelected = selectedMembers.contains(member);
                  final isAbsent = member.status == PaymentStatus.absence;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: GestureDetector(
                          onTap: isAbsent ? null : () => _toggleMember(member),
                          child: SvgPicture.asset(
                            isSelected && !isAbsent
                                ? 'assets/icons/ic_check_circle_teal.svg'
                                : 'assets/icons/ic_check_circle_off.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        title: Text(
                          member.memberName,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 16,
                            color: isAbsent ? Colors.grey : Colors.black,
                          ),
                        ),
                        onTap: isAbsent ? null : () => _toggleMember(member),
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
            const SizedBox(height: 24),
            // 割り当てボタン
            SizedBox(
              width: 114,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAssign(selectedMembers);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DCC6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context)!.assign,
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
