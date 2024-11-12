import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/dialog/add_event_dialog.dart';
import 'package:mr_collection/components/dialog/delete_event_dialog.dart';
import 'package:mr_collection/components/member_list.dart';
import 'package:mr_collection/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/model/payment_status.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = ['一次会', '二次会', 'カラオケ']; // TODO BEから取得する

  final mockEvents = [
    const Event(
      eventId: 1,
      eventName: '一次会',
      members: [
        Member(
          memberId: 1,
          memberName: 'Aさん',
          lineUserId: 1001,
          status: PaymentStatus.absence,
        ),
        Member(
          memberId: 2,
          memberName: 'Bさん',
          lineUserId: 1002,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 3,
          memberName: 'Cさん',
          lineUserId: 1003,
          status: PaymentStatus.unpaid,
        ),
      ],
    ),
    const Event(
      eventId: 2,
      eventName: '二次会',
      members: [
        Member(
          memberId: 4,
          memberName: 'Dさん',
          lineUserId: 1001,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 5,
          memberName: 'Eさん',
          lineUserId: 1002,
          status: PaymentStatus.absence,
        ),
        Member(
          memberId: 6,
          memberName: 'Fさん',
          lineUserId: 1003,
          status: PaymentStatus.unpaid,
        ),
      ],
    ),
    const Event(
      eventId: 3,
      eventName: '三次会',
      members: [
        Member(
          memberId: 7,
          memberName: 'Gさん',
          lineUserId: 1001,
          status: PaymentStatus.unpaid,
        ),
        Member(
          memberId: 8,
          memberName: 'Hさん',
          lineUserId: 1002,
          status: PaymentStatus.paid,
        ),
        Member(
          memberId: 9,
          memberName: 'Iさん',
          lineUserId: 1003,
          status: PaymentStatus.absence,
        ),
      ],
    ),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 50),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset('assets/icons/settings.svg'),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Stack(
            children: [
              Container(
                height: 36,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFC0C8CA),
                      width: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          tabs: _tabTitles.map((eventName) {
                            // 対応するイベントのIDを取得
                            final event = mockEvents.firstWhere(
                              (e) => e.eventName == eventName,
                              orElse: () => const Event(
                                  eventId: -1, eventName: '', members: []),
                            );
                            final eventId = event.eventId;

                            return GestureDetector(
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteEventDialog(
                                    eventId: eventId.toString(),
                                  );
                                },
                              ).then((value) {
                                if (value == true) {
                                  // Yes button pressed
                                  // イベント削除の処理を追加
                                } else {
                                  // No button pressed
                                }
                              }),
                              child: SizedBox(
                                width: 52,
                                child: Tab(
                                  child: Text(
                                    eventName,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          indicatorColor: Colors.black,
                          indicatorWeight: 1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset('assets/icons/plus.svg'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddEventDialog();
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        // TODO リリース初期段階では、一括削除機能のボタンは非表示
                        // IconButton(
                        //   onPressed: () {
                        //     // TODO 一括削除処理
                        //   },
                        //   icon: SvgPicture.asset('assets/icons/delete.svg'),
                        // ),
                        // const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const TanochanDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: _tabTitles.map((memberId) {
          return MemberList(members: mockEvents[0].members);
        }).toList(),
      ),
    );
  }
}
