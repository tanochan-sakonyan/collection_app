import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/button/floating_action_button_off.dart';
import 'package:mr_collection/ui/components/button/floating_action_button_on.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/components/countdown_timer.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/event/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/event/edit_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/line_group_update_countdown_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_and_suggest_official_line_dialog.dart';
import 'package:mr_collection/ui/screen/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/ui/tutorial/tutorial_targets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:mr_collection/ui/components/event_zero_components.dart';
import 'package:mr_collection/generated/s.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.user});
  final User? user;
  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _tabTitles = [];
  int _currentTabIndex = 0;
  late final BannerAd _banner;
  bool _loaded = false;

  final GlobalKey eventAddKey = GlobalKey();
  final GlobalKey leftTabKey = GlobalKey();
  late List<GlobalKey> _memberAddKeys;
  late List<GlobalKey> _slidableKeys;
  late List<GlobalKey> _sortKeys;
  late List<GlobalKey> fabKeys;

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _initKeys();
    _tabTitles = ref.read(tabTitlesProvider);
    tabController = TabController(length: _tabTitles.length, vsync: this);

    tabController.addListener(() {
      if (tabController.index != _currentTabIndex &&
          !tabController.indexIsChanging) {
        _currentTabIndex = tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });

    tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (tabController.index != _currentTabIndex) {
          _currentTabIndex = tabController.index;
          _saveTabIndex(_currentTabIndex);
        }
      }
    });
    _loadSavedTabIndex();

    _banner = BannerAd(
      adUnitId: AdHelper.bannerProdId(), // ad_helperを呼び出す
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad load failed: $error');
        },
      ),
    )..load();
  }

  void _initKeys() {
    final len = ref.read(tabTitlesProvider).length;
    _memberAddKeys = List.generate(len, (_) => GlobalKey());
    _slidableKeys = List.generate(len, (_) => GlobalKey());
    _sortKeys = List.generate(len, (_) => GlobalKey());
    fabKeys = List.generate(len, (_) => GlobalKey());
  }

  bool _updateDialogChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_updateDialogChecked) return;

    final route = ModalRoute.of(context);
    final anim = route?.animation;

    if (anim == null || anim.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkAndShowUpdateDialog();
      });
    } else {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _checkAndShowUpdateDialog();
          anim.removeStatusListener(listener);
        }
      }

      anim.addStatusListener(listener);
    }
    _updateDialogChecked = true;
  }

  void _showTutorial() {
    targets = TutorialTargets.createTargets(
      context: context,
      eventAddKey: eventAddKey,
      leftTabKey: leftTabKey,
      memberAddKey: _memberAddKeys[_currentTabIndex],
      slidableKey: _slidableKeys[_currentTabIndex],
      sortKey: _sortKeys[_currentTabIndex],
      fabKey: fabKeys[_currentTabIndex],
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      useSafeArea: true,
      colorShadow: const Color(0xFFE0E0E0),
      textSkip: S.of(context)!.skip ?? "Skip",
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
    tabController.dispose();
    _banner.dispose();
    super.dispose();
  }

  void _updateTabController(int newLength) {
    tabController.dispose();
    tabController = TabController(length: newLength, vsync: this);
    _initKeys();
    tabController.addListener(() {
      if (tabController.index != _currentTabIndex &&
          !tabController.indexIsChanging) {
        _currentTabIndex = tabController.index;
        _saveTabIndex(_currentTabIndex);
      }
    });
    tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (tabController.index != _currentTabIndex) {
          _currentTabIndex = tabController.index;
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
    if (mounted && savedIndex < tabController.length) {
      _currentTabIndex = savedIndex;
      tabController.animateTo(savedIndex);
    }
  }

  // versionForUpdateDialogを、2025/04現在は1.2.0で定義
  // これがshownVersionFor120と異なる時、ポップアップを出す。
  // 今後のアップデートの際は、shownVersionFor〇〇〇のpreferenceを更新する。
  // 20250529追記。shownVersionFor130作成済み
  // 20250630追記。shownVersionFor200作成済み
  Future<void> _checkAndShowUpdateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('shownVersionFor200') ?? false;
    debugPrint('shownVersion: $shown');
    if (!shown) {
      showDialog(
        context: context,
        builder: (_) => UpdateInfoAndSuggestOfficialLineDialog(
          vsync: this,
          onPageChanged: (i) {},
        ),
      );
      await prefs.setBool('shownVersionFor200', true);
      debugPrint('Update dialog shown for version "true"');
    } else {
      debugPrint('すでに表示されています。');
    }
  }

  void _showEditNoteBottomSheet(BuildContext context, Event event) {
    final TextEditingController controller =
        TextEditingController(text: event.memo ?? "");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final isSaving = ref.watch(loadingProvider);
            return WillPopScope(
              onWillPop: () async => !isSaving,
              child: CircleIndicator(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        S.of(context)!.editNote ?? "Edit Note",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: controller,
                          maxLines: 8,
                          minLines: 8,
                          decoration: InputDecoration(
                            hintText: S.of(context)!.memoPlaceholder ??
                                "You can enter a note",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: 108,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final newNote = controller.text.trim();
                                    ref.read(loadingProvider.notifier).state =
                                        true;
                                    try {
                                      await ref
                                          .read(userProvider.notifier)
                                          .addNote(
                                              ref.read(userProvider)!.userId,
                                              event.eventId,
                                              newNote);
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      debugPrint('メモ保存に失敗: $e');
                                    } finally {
                                      ref.read(loadingProvider.notifier).state =
                                          false;
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 22),
                              backgroundColor: const Color(0xFF76DCC6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              S.of(context)!.save ?? "Save",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: CircleIndicator(
          child: Center(
            child: Text("Loading..."),
          ),
        ),
      );
    }

    final tabTitles = ref.watch(tabTitlesProvider);
    final String currentEventId =
        tabTitles.isNotEmpty && _currentTabIndex < tabTitles.length
            ? tabTitles[_currentTabIndex]
            : "";
    final Event? currentEvent =
        user?.events.firstWhereOrNull((e) => e.eventId == currentEventId);

    final bool isLineConnected = currentEvent != null &&
        currentEvent.lineGroupId != null &&
        currentEvent.lineGroupId!.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (tabTitles.length != tabController.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateTabController(tabTitles.length);
            _tabTitles = tabTitles;
            if (_currentTabIndex >= tabTitles.length) {
              _currentTabIndex = tabTitles.isEmpty ? 0 : tabTitles.length - 1;
            }
            tabController.animateTo(_currentTabIndex);
            _saveTabIndex(_currentTabIndex);
          });
        }
      });
    } else {
      _tabTitles = tabTitles;
    }

    return Scaffold(
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
                          controller: tabController,
                          tabs: _tabTitles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final eventId = entry.value;
                            final event = user!.events.firstWhere(
                              (e) => e.eventId == eventId,
                              orElse: () => const Event(
                                eventId: "",
                                eventName: "",
                                members: [],
                                memo: "",
                                totalMoney: 0,
                                lineGroupId: null,
                                lineMembersFetchedAt: null,
                              ),
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
                              onTap: () {
                                if (index == _currentTabIndex) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EditEventDialog(
                                            userId:
                                                ref.read(userProvider)!.userId,
                                            eventId: eventId,
                                            currentEventName: event.eventName);
                                      });
                                } else {
                                  tabController.animateTo(index);
                                }
                              },
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
          const SizedBox(height: 6),
          if (isLineConnected)
            GestureDetector(
              onTap: () async {
                final updatedGroup = await showDialog<LineGroup>(
                  context: context,
                  builder: (BuildContext context) {
                    return LineGroupUpdateCountdownDialog(
                        currentEvent: currentEvent);
                  },
                );
                if (updatedGroup != null) {
                  ref
                      .read(userProvider.notifier)
                      .updateMemberDifference(currentEventId, updatedGroup);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...(currentEvent.lineMembersFetchedAt != null)
                      ? [
                          Text(
                              S.of(context)!.autoDeleteMemberCountdown ??
                                  "Auto member deletion in",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.black)),
                          CountdownTimer(
                            expireTime: currentEvent.lineMembersFetchedAt!
                                .add(const Duration(hours: 24)),
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.black,
                                ),
                            onExpired: () {
                              ref
                                  .read(userProvider.notifier)
                                  .clearMembersOfEvent(currentEventId);
                            },
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/ic_update.svg',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 36),
                        ]
                      : [
                          const SizedBox(height: 4),
                        ],
                ],
              ),
            ),
          Expanded(
            child: tabTitles.isEmpty
                ? const EventZeroComponents()
                : TabBarView(
                    controller: tabController,
                    children: _tabTitles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final eventId = entry.value;
                      final event = user!.events.firstWhere(
                        (e) => e.eventId == eventId,
                        orElse: () => const Event(
                          eventId: "",
                          eventName: "",
                          lineGroupId: null,
                          lineMembersFetchedAt: null,
                          members: [],
                          memo: "",
                          totalMoney: 0,
                        ),
                      );
                      final bool isEventConnected = event.lineGroupId != null &&
                          event.lineGroupId!.isNotEmpty;
                      return Stack(
                        children: [
                          Column(
                            children: [
                              MemberList(
                                event: event,
                                members:
                                    event.eventId != "" ? event.members : [],
                                eventId:
                                    event.eventId != "" ? event.eventId : "",
                                eventName: event.eventName,
                                memberAddKey: (_currentTabIndex == index)
                                    ? _memberAddKeys[index]
                                    : null,
                                slidableKey: (_currentTabIndex == index)
                                    ? _slidableKeys[index]
                                    : null,
                                sortKey: (_currentTabIndex == index)
                                    ? _sortKeys[index]
                                    : null,
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () =>
                                      _showEditNoteBottomSheet(context, event),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          S.of(context)!.note ?? "note",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: (event.memo?.isNotEmpty ==
                                                    true)
                                                ? Text(
                                                    event.memo!,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87),
                                                  )
                                                : Text(
                                                    S
                                                            .of(context)
                                                            ?.memoPlaceholder ??
                                                        "You can enter a note",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 28,
                            bottom: 120,
                            child: SizedBox(
                                height: 60,
                                width: 60,
                                child: (isEventConnected)
                                    ? FloatingActionButtonOn(
                                        index: index,
                                        fabKeys: fabKeys,
                                        tabController: tabController,
                                        event: event,
                                      )
                                    : FloatingActionButtonOff(
                                        index: index,
                                        fabKeys: fabKeys,
                                        tabController: tabController,
                                        event: event,
                                      )),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          if (_loaded)
            SafeArea(
              top: false,
              child: SizedBox(
                width: _banner.size.width.toDouble(),
                height: _banner.size.height.toDouble(),
                child: AdWidget(ad: _banner),
              ),
            ),
        ],
      ),
    );
  }
}
