import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/dialog/add_member_dialog.dart';
import 'package:mr_collection/components/dialog/confirmation_dialog.dart';
import 'package:mr_collection/components/dialog/status_dialog.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

class MemberList extends StatelessWidget {
  final List<Member> members;

  const MemberList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 29, right: 29),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  height: 32,
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      const Text('メンバー'),
                      const Spacer(),
                      const Text('支払い状況'),
                      const SizedBox(width: 3),
                      SvgPicture.asset('assets/icons/filter.svg'),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => StatusDialog(
                              member: member.memberName.toString(),
                            ),
                          );
                        },
                        child: ListTile(
                          minTileHeight: 32,
                          title: Text(
                            member.memberName.length > 17
                                ? '${member.memberName.substring(0, 10)}...'
                                : member.memberName,
                            style: TextStyle(
                              color: member.status == PaymentStatus.absence
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: _buildStatusIcon(member.status),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, //TODO リリース初期段階では中央に一つのボタンを配置
                    children: [
                      // const SizedBox(width: 53),
                      // ElevatedButton(
                      //   onPressed: () {},
                      //   style: ElevatedButton.styleFrom(
                      //     elevation: 0,
                      //     side: const BorderSide(
                      //       color: Colors.black,
                      //       width: 1.0,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(20),
                      //     ),
                      //     minimumSize: const Size(12, 24),
                      //     backgroundColor: Colors.white,
                      //   ),
                      //   child: Text(
                      //     '一括編集',
                      //     style: Theme.of(context).textTheme.labelSmall,
                      //   ),
                      // ),
                      // const SizedBox(width: 100),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AddMemberDialog(),
                          );
                        },
                        icon: SvgPicture.asset('assets/icons/circle_plus.svg'),
                      ),
                      // const SizedBox(width: 30),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 44),
          ElevatedButton(
            onPressed: () {
              {
                showDialog(
                  context: context,
                  builder: (context) => const ConfirmationDialog(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 40),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFE2E2E2),
            ),
            child: Text(
              '支払い催促',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 12),
          //TODO メンバーのステータスによって表示を変える
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 11),
            Text(
              "出席",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 30),
            SizedBox(
                width: 30, child: SvgPicture.asset('assets/icons/flag.svg')),
            const SizedBox(width: 4),
            const Text("・・・・・・"),
            const SizedBox(width: 26),
            const Text("2人")
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 11),
            Text(
              "未払い",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 30),
            SizedBox(
                width: 30,
                child: SvgPicture.asset('assets/icons/sad_face.svg')),
            const SizedBox(width: 4),
            const Text("・・・・・・"),
            const SizedBox(width: 26),
            const Text("1人")
          ]),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check, color: Color(0xFF5AFF9C));
      case PaymentStatus.unpaid:
        return const Icon(Icons.close, color: Colors.red);
      case PaymentStatus.absence:
      default:
        return const Icon(Icons.remove, color: Color(0xFFC0C0C0));
    }
  }
}
