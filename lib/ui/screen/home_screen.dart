import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_and_suggest_official_line_dialog.dart';
import 'package:mr_collection/ui/components/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/ui/tutorial/tutorial_targets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:mr_collection/ui/components/event_zero_components.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.user});
  final User? user;
  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _tabTitles = [];
  int _currentTabIndex = 0;

  final GlobalKey eventAddKey = GlobalKey();
  final GlobalKey leftTabKey = GlobalKey();
  final GlobalKey memberAddKey = GlobalKey();
  final GlobalKey slidableKey = GlobalKey();
  final GlobalKey sortKey = GlobalKey();
  final GlobalKey fabKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _tabTitles = ref.read(tabTitlesProvider);
    _tabController = TabController(length: _tabTitles.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex &&
          !_tabController.indexIsChanging) {
        _currentTabIndex = _tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });

    _tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_tabController.index != _currentTabIndex) {
          _currentTabIndex = _tabController.index;
          _saveTabIndex(_currentTabIndex);
        }
      }
    });
    _loadSavedTabIndex();
  }

  bool _updateDialogChecked = false; // 追加：一度だけ呼ぶためのフラグ

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_updateDialogChecked) return; // 2 回目以降はスキップ

    final route = ModalRoute.of(context);
    final anim = route?.animation;

    // アニメーションが無い、またはすでに完了しているならすぐ判定
    if (anim == null || anim.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkAndShowUpdateDialog();
      });
    } else {
      // アニメーションが動いている場合だけ listener を付ける
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _checkAndShowUpdateDialog();
          anim.removeStatusListener(listener); // listener を外してリーク防止
        }
      }

      anim.addStatusListener(listener);
    }

    _updateDialogChecked = true; // これ以上は呼ばない
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isTutorialShown120 = prefs.getBool('isTutorialShown120') ?? false;
    if (!isTutorialShown120) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 120));
        if (mounted) _showTutorial();
      });
      debugPrint('Tutorial shown');
    } else {
      debugPrint('Tutorial already shown');
    }
  }

  void _showTutorial() {
    targets = TutorialTargets.createTargets(
      context: context,
      eventAddKey: eventAddKey,
      leftTabKey: leftTabKey,
      memberAddKey: memberAddKey,
      slidableKey: slidableKey,
      sortKey: sortKey,
      fabKey: fabKey,
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      useSafeArea: true,
      colorShadow: const Color(0xFFE0E0E0),
      textSkip: S.of(context)?.skip ?? "Skip",
      textStyleSkip: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      paddingFocus: 6,
      onFinish: () {
        _setTutorialShown();
      },
      onSkip: () {
        _setTutorialShown();
        return true;
      },
    );
    tutorialCoachMark.show(context: context);
  }

  void _setTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTutorialShown120', true);
  }

  void _resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTutorialShown120', false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabController(int newLength) {
    _tabController.dispose();
    _tabController = TabController(length: newLength, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex &&
          !_tabController.indexIsChanging) {
        _currentTabIndex = _tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });
    _tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_tabController.index != _currentTabIndex) {
          _currentTabIndex = _tabController.index;
          _saveTabIndex(_currentTabIndex);
        }
      }
    });
  }

  Future<void> _saveTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTabIndex', index);
  }

  Future<void> _loadSavedTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('lastTabIndex') ?? 0;
    if (mounted && savedIndex < _tabController.length) {
      _currentTabIndex = savedIndex;
      _tabController.animateTo(savedIndex);
    }
  }

  // versionForUpdateDialogを、2025/04現在は1.2.0で定義
  // これがshownVersionFor120と異なる時、ポップアップを出す。
  // 今後のアップデートの際は、shownVersionFor〇〇〇のpreferenceを更新する。
  // 20240529追記。shownVersionFor130作成済み
  Future<void> _checkAndShowUpdateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('shownVersionFor130') ?? false;
    debugPrint('shownVersion: $shown');
    if (!shown) {
      showDialog(
        context: context,
        builder: (_) => UpdateInfoAndSuggestOfficialLineDialog(
          vsync: this,
          onPageChanged: (i) {},
        ),
      );
      await prefs.setBool('shownVersionFor130', true);
      debugPrint('Update dialog shown for version "true"');
    } else {
      debugPrint('すでに表示されています。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final tabTitles = ref.watch(tabTitlesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (tabTitles.length != _tabController.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateTabController(tabTitles.length);
            _tabTitles = tabTitles;
            _loadSavedTabIndex();
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
            IconButton(
              onPressed: () {
                _resetTutorial();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showTutorial();
                });
              },
              icon: SvgPicture.asset(
                'assets/icons/question_circle.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              SizedBox(
                width: screenWidth * 0.04,
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.04),
          child: Stack(
            children: [
              Container(
                height: screenHeight * 0.04,
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
                height: screenHeight * 0.04,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          tabs: _tabTitles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final eventId = entry.value;
                            final event = user!.events.firstWhere(
                              (e) => e.eventId == eventId,
                              orElse: () => const Event(
                                  eventId: "", eventName: '', members: []),
                            );
                            final bool isFullyPaid = event.members.isNotEmpty &&
                                event.members.every((member) =>
                                    member.status != PaymentStatus.unpaid);

                            final Color tabTextColor = isFullyPaid
                                ? const Color(0xFF35C759)
                                : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color ??
                                    Colors.black;

                            final bool isFirstTab = (index == 0);

                            return GestureDetector(
                              key: isFirstTab ? leftTabKey : null,
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteEventDialog(
                                    userId: ref.read(userProvider)!.userId,
                                    eventId: eventId,
                                  );
                                },
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Tab(
                                  child: Text(event.eventName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontSize: 14,
                                              color: tabTextColor)),
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
                          key: eventAddKey,
                          icon: SvgPicture.asset(
                            'assets/icons/plus.svg',
                            width: screenWidth * 0.07,
                            height: screenWidth * 0.07,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddEventDialog(
                                  userId: ref.read(userProvider)!.userId,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          width: screenWidth * 0.04,
                        ),
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
      body: Column(
        children: [
          Expanded(
            child: tabTitles.isEmpty
                ? const EventZeroComponents()
                : TabBarView(
                    controller: _tabController,
                    children: _tabTitles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final eventId = entry.value;
                      final event = user!.events.firstWhere(
                        (e) => e.eventId == eventId,
                        orElse: () => const Event(
                            eventId: "", eventName: '', members: []),
                      );
                      return MemberList(
                        memberAddKey:
                            (_currentTabIndex == index) ? memberAddKey : null,
                        slidableKey:
                            (_currentTabIndex == index) ? slidableKey : null,
                        sortKey: (_currentTabIndex == index) ? sortKey : null,
                        fabKey: (_currentTabIndex == index) ? fabKey : null,
                        members: event.eventId != "" ? event.members : [],
                        eventId: event.eventId != "" ? event.eventId : "",
                        eventName: event.eventName,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
