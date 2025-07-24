import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/services/analytics_service.dart';

class RoleAssignmentDialog extends StatefulWidget {
  final String roleName;
  final List<Member> members;
  final Function(List<Member>) onAssign;
  final Map<String, String> memberRoles;

  const RoleAssignmentDialog({
    super.key,
    required this.roleName,
    required this.members,
    required this.onAssign,
    required this.memberRoles,
  });

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  List<Member> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService().logDialogOpen('role_assignment_dialog');
    // 現在の役割が割り当てられているメンバーを初期選択状態にする
    selectedMembers = widget.members.where((member) {
      final existingRole = widget.memberRoles[member.memberId];
      return existingRole == widget.roleName;
    }).toList();
  }

  void _toggleMember(Member member) {
    AnalyticsService().logButtonTap(
      'toggle_member_role',
      screen: 'role_assignment_dialog',
      parameters: {
        'member_name': member.memberName,
        'role_name': widget.roleName
      }
    );
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

                  final existingRole = widget.memberRoles[member.memberId];
                  final hasExistingRole = existingRole != null &&
                      existingRole.isNotEmpty;
                  final isCurrentRole = existingRole == widget.roleName;

                  return Column(
                    children: [
                      ListTile(
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -2,
                        ),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        leading: hasExistingRole
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF75DCC6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  existingRole!,
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: isAbsent
                                    ? null
                                    : () => _toggleMember(member),
                                child: SvgPicture.asset(
                                  isSelected && !isAbsent
                                      ? 'assets/icons/ic_check_circle_teal.svg'
                                      : 'assets/icons/ic_check_circle_off.svg',
                                  width: 24,
                                  height: 24,
                                  color: const Color(0xFF75DCC6),
                                ),
                              ),
                        title: Text(
                          member.memberName,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 16,
                            color: isAbsent || (hasExistingRole && !isCurrentRole)
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        onTap: isAbsent || (hasExistingRole && !isCurrentRole)
                            ? null
                            : () => _toggleMember(member),
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
                  AnalyticsService().logButtonTap(
                    'assign_roles',
                    screen: 'role_assignment_dialog',
                    parameters: {
                      'role_name': widget.roleName,
                      'member_count': selectedMembers.length
                    }
                  );
                  AnalyticsService().logDialogClose(
                    'role_assignment_dialog',
                    'roles_assigned'
                  );
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
