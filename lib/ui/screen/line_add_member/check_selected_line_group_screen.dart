import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

class CheckSelectedLineGroupScreen extends ConsumerStatefulWidget {
  const CheckSelectedLineGroupScreen({super.key});
  @override
  ConsumerState<CheckSelectedLineGroupScreen> createState() =>
      CheckSelectedLineGroupScreenState();
}

class CheckSelectedLineGroupScreenState
    extends ConsumerState<CheckSelectedLineGroupScreen> {

  @override
  Widget build(BuildContext context) {
    const event =  Event(
      eventId: 'dummy-id',
      eventName: 'テストグループ',
      members: [
        Member(memberId: '1', memberName: '太郎', status: PaymentStatus.unpaid,memberMoney: 1000,),
        Member(memberId: '2', memberName: '花子', status: PaymentStatus.unpaid,memberMoney: 1000,),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 44,
                height: 44,
              ),
              Text(
                '戻る',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF76DCC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "LINEグループから\nメンバー追加",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF06C755),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Text(
            "このメンバーでイベントを作成しますか？",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF06C755)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 352,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF06C755),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFF06C755)),
                          ),
                        ),
                        height: 32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              //TODO: 取得したlineグループ名
                              "グループ名",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: event.members.length,
                          itemBuilder: (context, index) {
                            final member = event.members[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: SizedBox(
                                    height: 44,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        member.memberName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Color(0xFFE8E8E8),
                                  thickness: 1,
                                  height: 1,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                //TODO: イベント作成ダイアログに戻す
                Navigator.of(context).pop(event);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF76DCC6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "このメンバーでイベント作成",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "※LINEグループから取得したメンバー情報は24時間で消去されるため、\nその都度再取得をするようお願いいたします。\n支払い状況は引き継がれます。",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6A6A6A),
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
