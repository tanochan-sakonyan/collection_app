import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/member_list.dart';
import 'package:mr_collection/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/member.dart';
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '一次会'),
            Tab(text: '二次会'),
            Tab(text: 'カラオケ'),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
        ),
      ),
      drawer: const TanochanDrawer(),
      body: TabBarView(controller: _tabController, children: [
        MemberList(
          members: [
            Member(name: 'Rina Kusaba', status: PaymentStatus.paid),
            Member(name: 'Yuma Ikeo', status: PaymentStatus.unpaid),
            Member(name: 'Kanta Unagami', status: PaymentStatus.absence),
            Member(name: 'Mio Osato', status: PaymentStatus.absence),
          ],
        ),
        const Center(child: Text("二次会のコンテンツ")),
        const Center(child: Text("カラオケのコンテンツ")),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '追加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}
