import 'package:flutter/material.dart';
import 'package:mr_collection/data/model/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

class MemberList extends StatelessWidget {
  final List<Member> members;

  const MemberList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('メンバー'),
            Text('支払い状況'),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          child: ListView.separated(
            itemCount: members.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                title: Text(
                  member.name,
                  style: TextStyle(
                    color: member.status == PaymentStatus.unknown
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                trailing: _buildStatusIcon(member.status),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('一括編集'),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check, color: Colors.green);
      case PaymentStatus.unpaid:
        return const Icon(Icons.close, color: Colors.red);
      case PaymentStatus.unknown:
      default:
        return const Icon(Icons.remove, color: Colors.grey);
    }
  }
}
