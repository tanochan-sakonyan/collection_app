import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';

class AdjustAmountsTab extends StatelessWidget {
  const AdjustAmountsTab({
    super.key,
    required this.members,
    required this.controllers,
    required this.focusNodes,
    required this.locked,
    required this.amountFormatter,
    required this.currencyUnit,
    required this.onSubmitted,
    required this.onToggleLock,
  });

  final List<Member> members;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<bool> locked;
  final TextInputFormatter amountFormatter;
  final String currencyUnit;
  final void Function(int index, String value) onSubmitted;
  final void Function(int index) onToggleLock;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 34, right: 20),
      itemCount: members.length,
      itemBuilder: (context, i) {
        final member = members[i];
        final isAbsent = member.status == PaymentStatus.absence;
        final controller = controllers[i];
        final focusNode = focusNodes[i];
        return Column(
          children: [
            ListTile(
              minTileHeight: 44,
              title: Text(
                member.memberName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isAbsent ? const Color(0xFFC0C0C0) : Colors.black,
                    ),
              ),
              trailing: SizedBox(
                width: 140,
                child: isAbsent
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context)!.status_absence,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFC0C0C0),
                                ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 28,
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                inputFormatters: [amountFormatter],
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFC6C6C8),
                                    ),
                                  ),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: locked[i]
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                onSubmitted: (v) => onSubmitted(i, v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currencyUnit,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () => onToggleLock(i),
                            child: SvgPicture.asset(
                              locked[i]
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
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
          ],
        );
      },
    );
  }
}
