import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/member_list.dart';
import 'package:mr_collection/components/tanochan_drawer.dart';
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

  final Map<String, List<Member>> eventMembers = {
    '一次会': [
      const Member(
        memberId: 1,
        memberName: 'ああああああああああああああああああああああああああああ',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
      const Member(
        memberId: 2,
        memberName: '一次会 Bさん',
        lineUserId: 987654321,
        status: PaymentStatus.unpaid,
      ),
      const Member(
        memberId: 3,
        memberName: '一次会 Cさん',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
    ],
    '二次会': [
      const Member(
        memberId: 4,
        memberName: '二次会 Aさん',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
      const Member(
        memberId: 5,
        memberName: '二次会 Bさん',
        lineUserId: 987654321,
        status: PaymentStatus.unpaid,
      ),
      const Member(
        memberId: 6,
        memberName: '二次会 Cさん',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
    ],
    'カラオケ': [
      const Member(
        memberId: 7,
        memberName: 'カラオケ Aさん',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
      const Member(
        memberId: 8,
        memberName: 'カラオケ Bさん',
        lineUserId: 987654321,
        status: PaymentStatus.unpaid,
      ),
      const Member(
        memberId: 9,
        memberName: 'カラオケ Cさん',
        lineUserId: 123456789,
        status: PaymentStatus.paid,
      ),
    ],
  }; // TODO BEから取得

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
                            return SizedBox(
                              width: 52,
                              child: Tab(
                                child: Text(
                                  eventName,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                              builder: (context) => AlertDialog(
                                title: const Text('新しいタブ'),
                                content: const Text('ここにポップアップの内容を追加してください'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('閉じる'),
                                  ),
                                ],
                              ),
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
        children: _tabTitles.map((eventId) {
          return MemberList(members: eventMembers[eventId] ?? []);
        }).toList(),
      ),
    );
  }
}
