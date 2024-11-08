import 'package:flutter/material.dart';

class MemberList extends StatelessWidget {
  final List<Member> members;

  const MemberList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー'),
        actions: [
          DropdownButton<String>(
            underline: Container(),
            items: <String>['支払い状況 ▼'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ],
      ),
      body: ListView.separated(
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
      bottomNavigationBar: Padding(
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

class Member {
  final String name;
  final PaymentStatus status;

  Member({required this.name, required this.status});
}

enum PaymentStatus {
  paid,
  unpaid,
  unknown,
}

void main() {
  runApp(MaterialApp(
    home: MemberList(
      members: [
        Member(name: 'Rina Kusaba', status: PaymentStatus.paid),
        Member(name: 'Yuma Ikeo', status: PaymentStatus.unpaid),
        Member(name: 'Kanta Unagami', status: PaymentStatus.unknown),
        Member(name: 'Mio Osato', status: PaymentStatus.unknown),
      ],
    ),
  ));
}
