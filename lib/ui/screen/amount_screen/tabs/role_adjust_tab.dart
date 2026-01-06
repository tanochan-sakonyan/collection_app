import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';

class RoleAdjustTab extends StatelessWidget {
  const RoleAdjustTab({
    super.key,
    required this.roles,
    required this.memberRoles,
    required this.members,
    required this.onOpenRoleSetup,
    required this.onEditMemberRole,
    required this.getRoleAmount,
    required this.buildRoleDescription,
    required this.numberFormat,
  });

  final List<Map<String, dynamic>> roles;
  final Map<String, String> memberRoles;
  final List<Member> members;
  final VoidCallback onOpenRoleSetup;
  final void Function(Member member) onEditMemberRole;
  final int Function(String? roleKey) getRoleAmount;
  final TextSpan Function(BuildContext context) buildRoleDescription;
  final NumberFormat numberFormat;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    if (roles.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                    Text.rich(
                      buildRoleDescription(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 164,
                height: 48,
                child: ElevatedButton(
                  onPressed: onOpenRoleSetup,
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
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, i) {
                final member = members[i];
                final memberRole = memberRoles[member.memberId];
                final roleAmount = getRoleAmount(memberRole);

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
                      leading: GestureDetector(
                        onTap: () => onEditMemberRole(member),
                        child: memberRole != null && memberRole.isNotEmpty
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.17,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  memberRole,
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.17,
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
                                  textAlign: TextAlign.center,
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
                            numberFormat.format(roleAmount),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context)!.currencyUnit,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 112,
            height: 29,
            child: ElevatedButton(
              onPressed: onOpenRoleSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              child: Text(
                S.of(context)!.modifyRole,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700, color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
