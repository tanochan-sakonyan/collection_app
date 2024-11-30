import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/dialog/add_member_dialog.dart';
import 'package:mr_collection/components/dialog/confirmation_dialog.dart';
import 'package:mr_collection/components/dialog/status_dialog.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/user_provider.dart';

class MemberList extends ConsumerWidget {
  final List<Member> members;
  final String eventId;

  const MemberList({super.key, required this.members, required this.eventId});

  Future<void> _changeStatus(
      WidgetRef ref, String eventId, String memberId, int status) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.changeStatus(eventId, memberId, status);
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text('ステータスが更新されました')),
      );
    } catch (error) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text('ステータスの更新に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 29, right: 29),
      child: Stack(
        children: [
          Column(
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
                          SvgPicture.asset('assets/icons/sort.svg'),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return Column(
                            children : [
                            GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => StatusDialog(
                                  eventId: eventId,
                                  memberId: member.memberId,
                                  member: member.memberName,
                                  onStatusChange: (String eventId, int memberId,
                                      int status) {
                                    _changeStatus(ref, eventId,
                                        memberId.toString(), status);
                                  },
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
                          ),
                          const Divider(
                            thickness: 1,
                            height: 1,
                          ),
                          ],
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
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //TODO リリース初期段階では中央に一つのボタンを配置
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
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const AddMemberDialog(),
                              );
                            },
                            style: TextButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: SvgPicture.asset(
                                        'assets/icons/user-add.svg')),
                                const SizedBox(width: 4),
                                Text(
                                  'メンバー追加',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // const SizedBox(width: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              //TODO メンバーのステータスによって表示を変える
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 11),
                Text(
                  "出席",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 30),
                SizedBox(
                    width: 30,
                    child: SvgPicture.asset('assets/icons/flag.svg')),
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
          Positioned(
            right: 4,
            bottom: 163,
            child: SizedBox(
              height: 60,
              width: 60,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFBABABA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(),
                  );
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/chat_bubble.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      SvgPicture.asset(
                        'assets/icons/yen.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFFBABABA), BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
