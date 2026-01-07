import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/generated/s.dart';

class SplitEquallyTab extends StatelessWidget {
  const SplitEquallyTab({
    super.key,
    required this.members,
    required this.numberFormat,
    required this.evenShare,
  });

  final List<Member> members;
  final NumberFormat numberFormat;
  final int evenShare;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      itemCount: members.length,
      itemBuilder: (context, i) {
        final member = members[i];
        return Column(
          children: [
            ListTile(
              minTileHeight: 44,
              title: Text(
                member.memberName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: member.status == PaymentStatus.absence
                          ? const Color(0xFFC0C0C0)
                          : Colors.black,
                    ),
              ),
              trailing: IntrinsicWidth(
                child: member.status == PaymentStatus.absence
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
                          Text(
                            numberFormat.format(evenShare),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            S.of(context)!.currencyUnit,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
