import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title, this.user});

  final String title;
  final User? user;

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> _tabTitles = [];

  @override
  void initState() {
    super.initState();

    _tabTitles = ref.read(tabTitlesProvider);
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabController(int newLength) {
    _tabController.dispose();
    _tabController = TabController(length: newLength, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final tabTitles = ref.watch(tabTitlesProvider);

    if (tabTitles.length != _tabController.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateTabController(tabTitles.length);
            _tabTitles = tabTitles;
          });
        }
      });
    } else {
      _tabTitles = tabTitles;
    }

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
                          tabs: tabTitles.map((eventName) {
                            final event = user?.events.firstWhere(
                              (e) => e.eventName == eventName,
                              orElse: () => const Event(
                                  eventId: -1, eventName: '', members: []),
                            );
                            final eventId = event?.eventId;

                            return GestureDetector(
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteEventDialog(
                                    eventId: eventId,
                                  );
                                },
                              ),
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
        children: tabTitles.map((memberId) {
          return MemberList(
            members: user?.events[0].members,
            eventId: user?.events[0].eventId,
          );
        }).toList(),
      ),
    );
  }
}
