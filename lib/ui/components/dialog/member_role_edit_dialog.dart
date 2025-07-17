import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/data/model/freezed/member.dart';

class MemberRoleEditDialog extends StatefulWidget {
  final Member member;
  final List<Map<String, dynamic>> roles;
  final String? currentRole;
  final Function(String? newRole) onRoleChange;

  const MemberRoleEditDialog({
    super.key,
    required this.member,
    required this.roles,
    required this.currentRole,
    required this.onRoleChange,
  });

  @override
  State<MemberRoleEditDialog> createState() => _MemberRoleEditDialogState();
}

class _MemberRoleEditDialogState extends State<MemberRoleEditDialog> {
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.currentRole;
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.member.memberName}の役割を修正',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 役割リスト
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.roles.length,
                itemBuilder: (context, index) {
                  final role = widget.roles[index];
                  final roleName = role['role'] as String;
                  final isSelected = selectedRole == roleName;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          roleName,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        trailing: SvgPicture.asset(
                          'assets/icons/ic_next.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF75DCC6),
                            BlendMode.srcIn,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedRole = roleName;
                          });
                          widget.onRoleChange(roleName);
                          Navigator.pop(context);
                        },
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
            // 役割なしオプション
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: selectedRole == null
                      ? SvgPicture.asset(
                          'assets/icons/ic_check_circle_teal.svg',
                          width: 24,
                          height: 24,
                        )
                      : null,
                  title: Text(
                    '役割なし',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: selectedRole == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: SvgPicture.asset(
                    'assets/icons/ic_next.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedRole = null;
                    });
                    widget.onRoleChange(null);
                    Navigator.pop(context);
                  },
                ),
                const Divider(
                  thickness: 1,
                  height: 1,
                  color: Color(0xFFE8E8E8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
