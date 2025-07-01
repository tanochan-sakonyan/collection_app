import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/data/model/freezed/lineGroup.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
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
  late final BannerAd _banner;
  bool _loaded = false;

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

    _banner = BannerAd(
      adUnitId: AdHelper.bannerTestId(), // ad_helperを呼び出す
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
    _banner.dispose();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller =
            TextEditingController(text: event.memo ?? "");
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                S.of(context)?.editNote ?? "Edit Note",
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
                    hintText: S.of(context)?.memoPlaceholder ??
                        "You can enter a note",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: 108,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newNote = controller.text.trim();
                      await ref.read(userProvider.notifier).addNote(
                          ref.read(userProvider)!.userId,
                          event.eventId,
                          newNote);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      S.of(context)?.save ?? "Save",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 22),
                      backgroundColor: Color(0xFF76DCC6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final tabTitles = ref.watch(tabTitlesProvider);
    final String currentEventId =
        tabTitles.isNotEmpty && _currentTabIndex < tabTitles.length
            ? tabTitles[_currentTabIndex]
            : "";
    final Event? currentEvent =
        user?.events.firstWhere((e) => e.eventId == currentEventId);
    final bool isLineConnected = currentEvent != null &&
        currentEvent.lineGroupId != null &&
        currentEvent.lineGroupId!.isNotEmpty;
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
                                eventId: "",
                                eventName: "",
                                lineGroupId: "",
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
                                  _tabController.animateTo(index);
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
                  Text(
                      S.of(context)?.autoDeleteMemberCountdown ??
                          "Auto member deletion in",
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.black)),
                  CountdownTimer(
                    expiretime: currentEvent.lineMembersFetchedAt!
                        .add(const Duration(hours: 24)),
                    textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                ],
              ),
            ),
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
                          eventId: "",
                          eventName: "",
                          lineGroupId: null,
                          lineMembersFetchedAt: null,
                          members: [],
                          memo: "",
                          totalMoney: 0,
                        ),
                      );
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
                                    ? memberAddKey
                                    : null,
                                slidableKey: (_currentTabIndex == index)
                                    ? slidableKey
                                    : null,
                                sortKey: (_currentTabIndex == index)
                                    ? sortKey
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
                                          S.of(context)?.note ?? "note",
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
                              child: FloatingActionButton(
                                key: fabKey,
                                backgroundColor: const Color(0xFFBABABA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 56.0,
                                        horizontal: 24.0,
                                      ),
                                      content: Text(
                                        '${S.of(context)?.update_1}\n ${S.of(context)?.update_2}',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                      ),
                                    ),
                                  );
                                  //TODO LINE認証申請が通ったらこちらに戻す
                                  /*showDialog(
                context: context,
                builder: (context) => const ConfirmationDialog(),
              );*/
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
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/icons/yen.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFBABABA),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
