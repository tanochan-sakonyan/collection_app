import 'package:flutter/material.dart';
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
    // すでに選択されているメンバーがあれば初期化
    selectedMembers = List<Member>.from(widget.members);
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
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '「${widget.roleName}」${S.of(context)!.assignRoleToMembers}',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // メンバーリスト
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  final isSelected = selectedMembers.contains(member);
                  final isAbsent = member.status == PaymentStatus.absence;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: isAbsent ? null : () => _toggleMember(member),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAbsent 
                                ? Colors.grey.shade300
                                : isSelected 
                                    ? const Color(0xFF75DCC6)
                                    : Colors.white,
                            border: Border.all(
                              color: isAbsent 
                                  ? Colors.grey.shade300
                                  : isSelected 
                                      ? const Color(0xFF75DCC6)
                                      : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected && !isAbsent
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
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
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // 割り当てボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAssign(selectedMembers);
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
                  S.of(context)!.assign,
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