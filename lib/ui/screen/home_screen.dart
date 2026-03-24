import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mr_collection/ads/ad_helper.dart';
import 'package:mr_collection/ads/idle_interstitial_manager.dart';
import 'package:mr_collection/route_observer.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/logging/analytics_ads_logger.dart';
import 'package:mr_collection/logging/analytics_event_logger.dart';
import 'package:mr_collection/logging/analytics_ui_logger.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:mr_collection/ui/components/button/floating_action_button_off.dart';
import 'package:mr_collection/ui/components/button/floating_action_button_on.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/event/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/event/edit_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_and_suggest_official_line_dialog.dart';
import 'package:mr_collection/ui/screen/onboarding_screen.dart';
import 'package:mr_collection/ui/components/home_app_bar.dart';
import 'package:mr_collection/ui/components/line_member_delete_limit_countdown.dart';
import 'package:mr_collection/ui/screen/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/ui/screen/share/share_screen.dart';
import 'package:mr_collection/ui/components/duplicate_member_warning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_collection/ui/components/event_zero_components.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/provider/pending_event_focus_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.user});
  final User? user;
  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  late TabController tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _tabTitles = [];
  int _currentTabIndex = 0;
  BannerAd? _banner;
  bool _isBannerLoaded = false;
  static const int _maxBannerLoadAttempts = 3;
  int _bannerLoadAttempts = 0;
  static const String _tabOrderPrefsKey = 'tab_order_event_ids';
  ProviderSubscription<List<String>>? _tabTitlesSubscription;
  String? _pendingFocusedEventId;
  final Map<String, GlobalKey> _tabItemKeys = {};
  final Set<String> _dismissedDuplicateWarningEventIds = {};
  final Set<String> _loggedDuplicateWarningEventIds = {};
  ProviderSubscription<bool>? _adsRemovalSubscription;

  final GlobalKey eventAddKey = GlobalKey();
  ProviderSubscription<String?>? _pendingFocusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AnalyticsUiLogger.logHomeScreenViewed());
    });
    _tabTitles = ref.read(tabTitlesProvider);
    tabController = TabController(length: _tabTitles.length, vsync: this);
    _pendingFocusSubscription = ref.listenManual<String?>(
      pendingEventFocusProvider,
      (previous, next) {
        if (next != null) {
          _queueFocusOnEvent(next);
          ref.read(pendingEventFocusProvider.notifier).state = null;
        }
      },
      fireImmediately: true,
    );
    _adsRemovalSubscription = ref.listenManual<bool>(
      adsRemovalProvider,
      (previous, next) {
        if (next) {
          _banner?.dispose();
          setState(() {
            _banner = null;
            _isBannerLoaded = false;
          });
          idleInterstitialManager.stop();
        }
      },
      fireImmediately: false,
    );

    tabController.addListener(() {
      if (tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = tabController.index;
          _saveTabIndex(_currentTabIndex);
        });
        _scrollCurrentTabIntoView();
      }
    });

    tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (tabController.index != _currentTabIndex) {
          setState(() {
            _currentTabIndex = tabController.index;
            _saveTabIndex(_currentTabIndex);
          });
          _scrollCurrentTabIntoView();
        }
      }
    });

    _tabTitlesSubscription = ref.listenManual<List<String>>(
      tabTitlesProvider,
      (previous, next) {
        _handleTabTitlesUpdate(next);
      },
      fireImmediately: false,
    );

    unawaited(_loadSavedTabOrder());
    _loadSavedTabIndex();
    unawaited(_restoreAdsRemovalStatusOnStart());
  }

  // 起動時に広告削除状態を復元してからバナーを作成し、アイドルタイマーを開始する。
  // Androidでは課金機能がないためIAP復元をスキップする。
  Future<void> _restoreAdsRemovalStatusOnStart() async {
    if (!Platform.isAndroid) {
      await ref
          .read(adsRemovalProvider.notifier)
          .restoreAdsRemovalStatus();
      if (!mounted) return;
    }
    _createBannerAd();
    if (!ref.read(adsRemovalProvider)) {
      idleInterstitialManager.start();
    }
  }

  void _createBannerAd() {
    if (ref.read(adsRemovalProvider)) {
      return;
    }
    _banner?.dispose();
    _isBannerLoaded = false;

    final banner = BannerAd(
      adUnitId:
          kReleaseMode ? AdHelper.bannerProdId() : AdHelper.bannerTestId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = true;
            _bannerLoadAttempts = 0;
          });
          unawaited(AnalyticsAdsLogger.logBannerAdShown());
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad load failed: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = false;
            _banner = null;
          });
          if (_bannerLoadAttempts < _maxBannerLoadAttempts) {
            _bannerLoadAttempts += 1;
            _createBannerAd();
          }
        },
      ),
    );

    banner.load();
    _banner = banner;
  }


  bool _startupChecked = false;

  bool _routeAwareSubscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeAwareSubscribed) {
      final route = ModalRoute.of(context);
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _routeAwareSubscribed = true;
      }
    }
    if (_startupChecked) return;

    final route = ModalRoute.of(context);
    final anim = route?.animation;

    if (anim == null || anim.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkOnboardingOrUpdateDialog();
      });
    } else {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _checkOnboardingOrUpdateDialog();
          anim.removeStatusListener(listener);
        }
      }

      anim.addStatusListener(listener);
    }
    _startupChecked = true;
  }

  /// 初回起動時はオンボーディング→完了後にアップデートダイアログ、
  /// 2回目以降はアップデートダイアログのみ表示
  Future<void> _checkOnboardingOrUpdateDialog() async {
    final shouldShowOnboarding = await OnboardingScreen.shouldShow();
    if (!mounted) return;

    if (shouldShowOnboarding) {
      _showOnboardingScreen(showUpdateDialogAfter: true);
    } else {
      _checkAndShowUpdateDialog();
    }
  }

  /// オンボーディング画面を表示
  void _showOnboardingScreen({bool showUpdateDialogAfter = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingScreen(
          onCompleted: () {
            Navigator.of(context).pop();
            if (showUpdateDialogAfter) {
              _checkAndShowUpdateDialog();
            }
          },
        ),
      ),
    );
  }


  // Detects duplicate member names within a specific event.
  List<String> _findDuplicatedMemberNames(Event? event) {
    if (event == null || event.members.isEmpty) {
      return [];
    }

    final Map<String, int> nameCount = {};
    for (final member in event.members) {
      final trimmed = member.memberName.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      nameCount.update(trimmed, (value) => value + 1, ifAbsent: () => 1);
    }

    return nameCount.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  // 別の画面がプッシュされてHomeScreenが非表示になった時、タイマーを停止する。
  void didPushNext() {
    idleInterstitialManager.stop();
  }

  @override
  // 別の画面からHomeScreenに戻ってきた時、タイマーをリセットして再開する。
  void didPopNext() {
    if (!ref.read(adsRemovalProvider)) {
      idleInterstitialManager.start();
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _tabTitlesSubscription?.close();
    tabController.dispose();
    _banner?.dispose();
    _pendingFocusSubscription?.close();
    _adsRemovalSubscription?.close();
    idleInterstitialManager.dispose();
    super.dispose();
  }

  void _updateTabController(int newLength) {
    tabController.dispose();
    tabController = TabController(length: newLength, vsync: this);
    tabController.addListener(() {
      if (tabController.index != _currentTabIndex &&
          !tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = tabController.index;
          _saveTabIndex(_currentTabIndex);
        });
        _scrollCurrentTabIntoView();
      }
    });
    tabController.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (tabController.index != _currentTabIndex) {
          setState(() {
            _currentTabIndex = tabController.index;
            _saveTabIndex(_currentTabIndex);
          });
          _scrollCurrentTabIntoView();
        }
      }
    });
  }

  // Applies provider updates to the current tab order while keeping manual sorting intact.
  void _handleTabTitlesUpdate(List<String> providerTitles) {
    final merged = _mergeTabTitles(providerTitles);
    final bool didOrderChange = !listEquals(merged, _tabTitles);
    final bool didLengthChange = providerTitles.length != tabController.length;
    if (!didOrderChange && !didLengthChange) {
      return;
    }

    final String? activeEventId =
        _tabTitles.isNotEmpty && _currentTabIndex < _tabTitles.length
            ? _tabTitles[_currentTabIndex]
            : null;

    setState(() {
      _tabTitles = merged;
      if (didLengthChange) {
        _updateTabController(_tabTitles.length);
      }

      if (_tabTitles.isEmpty) {
        _currentTabIndex = 0;
        _pendingFocusedEventId = null;
        return;
      }

      if (_pendingFocusedEventId != null &&
          _tabTitles.contains(_pendingFocusedEventId)) {
        _currentTabIndex = _tabTitles.indexOf(_pendingFocusedEventId!);
        _pendingFocusedEventId = null;
      } else if (activeEventId != null) {
        final updatedIndex = _tabTitles.indexOf(activeEventId);
        _currentTabIndex =
            updatedIndex != -1 ? updatedIndex : _tabTitles.length - 1;
      } else if (_currentTabIndex >= _tabTitles.length) {
        _currentTabIndex = _tabTitles.length - 1;
      }
    });

    if (_tabTitles.isNotEmpty) {
      _animateTabControllerTo(_currentTabIndex);
    }
    _saveTabIndex(_currentTabIndex);
    unawaited(_saveTabOrder());
  }

  // Generates the merged tab order using the current arrangement as primary.
  List<String> _mergeTabTitles(List<String> providerTitles) {
    final retained =
        _tabTitles.where((id) => providerTitles.contains(id)).toList();
    final additions = providerTitles
        .where((id) => !retained.contains(id))
        .toList(growable: false);
    return [...retained, ...additions];
  }

  // Loads the saved tab order from shared preferences on startup.
  Future<void> _loadSavedTabOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList(_tabOrderPrefsKey);
    if (savedOrder == null || savedOrder.isEmpty || _tabTitles.isEmpty) {
      return;
    }

    final ordered = <String>[
      ...savedOrder.where((id) => _tabTitles.contains(id)),
      ..._tabTitles.where((id) => !savedOrder.contains(id)),
    ];

    if (listEquals(ordered, _tabTitles)) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tabTitles = ordered;
      if (_currentTabIndex >= _tabTitles.length) {
        _currentTabIndex = _tabTitles.length - 1;
      }
    });

    if (_tabTitles.isNotEmpty) {
      _animateTabControllerTo(_currentTabIndex);
      _saveTabIndex(_currentTabIndex);
    }
  }

  // Persists the manually arranged tab order.
  Future<void> _saveTabOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tabOrderPrefsKey, _tabTitles);
  }

  // Ensures we focus on a specific event tab as soon as it exists.
  void _queueFocusOnEvent(String eventId) {
    if (_tabTitles.contains(eventId)) {
      final index = _tabTitles.indexOf(eventId);
      setState(() {
        _currentTabIndex = index;
      });
      _animateTabControllerTo(index);
      _saveTabIndex(index);
    } else {
      _pendingFocusedEventId = eventId;
    }
  }

  Future<void> _showAddEventDialog() async {
    await AnalyticsEventLogger.logAddEventButtonPressed(
      source: 'home_tab',
    );
    final String? createdEventId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AddEventDialog(
          userId: ref.read(userProvider)!.userId,
        );
      },
    );

    if (createdEventId != null) {
      _queueFocusOnEvent(createdEventId);
    }
  }

  // Shows delete dialog for the currently selected event tab.
  void _showDeleteDialogForCurrentEvent() {
    if (_tabTitles.isEmpty || _currentTabIndex >= _tabTitles.length) {
      return;
    }
    final currentEventId = _tabTitles[_currentTabIndex];
    if (currentEventId.isEmpty) {
      return;
    }

    final user = ref.read(userProvider);
    final currentEvent = user?.events.firstWhere(
      (event) => event.eventId == currentEventId,
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
    final currentEventName = currentEvent?.eventName ?? "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteEventDialog(
          userId: ref.read(userProvider)!.userId,
          eventId: currentEventId,
          eventName: currentEventName,
        );
      },
    );
  }

  void _animateTabControllerTo(int index) {
    if (!mounted || tabController.length == 0) {
      return;
    }
    if (index < 0 || index >= tabController.length) {
      return;
    }
    tabController.animateTo(index);
    _scrollCurrentTabIntoView();
  }

  void _scrollCurrentTabIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      BuildContext? targetContext;
      if (_tabTitles.isNotEmpty && _currentTabIndex < _tabTitles.length) {
        final key = _tabItemKeys[_tabTitles[_currentTabIndex]];
        targetContext = key?.currentContext;
      } else {
        targetContext = eventAddKey.currentContext;
      }

      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
          curve: Curves.easeInOut,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      }
    });
  }

  // Handles chip drag-and-drop ordering.
  void _onReorderTabs(int oldIndex, int newIndex) {
    if (_tabTitles.isEmpty) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    int safeIndex = _currentTabIndex;
    if (safeIndex < 0) {
      safeIndex = 0;
    } else if (safeIndex >= _tabTitles.length) {
      safeIndex = _tabTitles.length - 1;
    }
    _currentTabIndex = safeIndex;
    final String activeEventId = _tabTitles[safeIndex];

    setState(() {
      final moved = _tabTitles.removeAt(oldIndex);
      _tabTitles.insert(newIndex, moved);
      final updatedIndex = _tabTitles.indexOf(activeEventId);
      if (updatedIndex != -1) {
        _currentTabIndex = updatedIndex;
      }
    });

    _animateTabControllerTo(_currentTabIndex);
    _saveTabIndex(_currentTabIndex);
    unawaited(_saveTabOrder());
  }

  // Builds the draggable tab chips shown in the app bar.
  Widget _buildReorderableTabs({
    required BuildContext context,
    required User user,
    required double screenHeight,
    required Color primaryColor,
  }) {
    if (_tabTitles.isEmpty) {
      return ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildAddEventTabButton(
              screenHeight: screenHeight,
              primaryColor: primaryColor,
            ),
          ),
        ],
      );
    }

    return ReorderableListView.builder(
      key: const PageStorageKey('home_tab_list'),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderStart: (_) {
        unawaited(AnalyticsUiLogger.logTabLongPressed());
      },
      onReorder: (oldIndex, newIndex) {
        final maxIndex = _tabTitles.length;
        if (oldIndex >= maxIndex) {
          return;
        }
        var targetIndex = newIndex;
        if (targetIndex > maxIndex) {
          targetIndex = maxIndex;
        }
        _onReorderTabs(oldIndex, targetIndex);
      },
      itemCount: _tabTitles.length + 2,
      itemBuilder: (context, index) {
        if (index == _tabTitles.length) {
          return Container(
            key: const ValueKey('add_event_tab_button'),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildAddEventTabButton(
              screenHeight: screenHeight,
              primaryColor: primaryColor,
            ),
          );
        }
        if (index == _tabTitles.length + 1) {
          return Container(
            key: const ValueKey('delete_event_tab_button'),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildDeleteEventTabButton(
              screenHeight: screenHeight,
              primaryColor: primaryColor,
            ),
          );
        }
        final eventId = _tabTitles[index];
        final bool isSelected = index == _currentTabIndex;
        final tabKey = _tabItemKeys.putIfAbsent(
            eventId, () => GlobalKey(debugLabel: eventId));
        final event = user.events.firstWhere(
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
            event.members
                .every((member) => member.status != PaymentStatus.unpaid);

        final Color tabTextColor = isFullyPaid
            ? const Color(0xFF35C759)
            : Theme.of(context).textTheme.bodySmall?.color ?? Colors.black;

        return Container(
          key: ValueKey(eventId),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ReorderableDelayedDragStartListener(
            index: index,
            child: GestureDetector(
              onTap: () {
                if (index == _currentTabIndex) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditEventDialog(
                        userId: ref.read(userProvider)!.userId,
                        eventId: eventId,
                        currentEventName: event.eventName,
                      );
                    },
                  );
                } else {
                  setState(() => _currentTabIndex = index);
                  _animateTabControllerTo(index);
                }
              },
              child: SizedBox(
                height: screenHeight * 0.04,
                child: Container(
                  key: tabKey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      event.eventName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isSelected ? Colors.white : tabTextColor,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w400,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddEventTabButton({
    required double screenHeight,
    required Color primaryColor,
  }) {
    return GestureDetector(
      key: eventAddKey,
      onTap: _showAddEventDialog,
      child: Container(
        height: screenHeight * 0.04,
        width: screenHeight * 0.04,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/plus.svg',
            width: screenHeight * 0.02,
            height: screenHeight * 0.02,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  // Builds the delete-event button shown next to the plus button.
  Widget _buildDeleteEventTabButton({
    required double screenHeight,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: _showDeleteDialogForCurrentEvent,
      child: Container(
        height: screenHeight * 0.04,
        width: screenHeight * 0.04,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/delete.svg',
            width: screenHeight * 0.02,
            height: screenHeight * 0.02,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
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
      _animateTabControllerTo(savedIndex);
    }
  }

  // 2025年7月28日、LINEから取得したグループ情報が、24時間で切れることを利用規約・プライバシーポリシーに追記。
  // versionForUpdateDialogを、2025/04現在は1.2.0で定義
  // これがshownVersionFor120と異なる時、ポップアップを出す。
  // 今後のアップデートの際は、shownVersionFor〇〇〇のpreferenceを更新する。(2箇所)
  // 20250529追記。shownVersionFor130作成済み
  // 20250630追記。shownVersionFor200作成済み
  // 20260106追記。shownVersionFor270作成済み
  // 20260107追記。shownVersionFor280作成済み
  // 20260110追記。shownVersionFor290作成済み
  Future<void> _checkAndShowUpdateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('shownVersionFor290') ?? false;
    debugPrint('shownVersion: $shown');
    if (!shown) {
      showDialog(
        context: context,
        builder: (_) => UpdateInfoAndSuggestQuestionnaireDialog(
          vsync: this,
          onPageChanged: (i) {},
        ),
      );
      await prefs.setBool('shownVersionFor290', true);
      debugPrint('Update dialog shown for version "true"');
    } else {
      debugPrint('すでに表示されています。');
    }
  }

  void _showEditNoteBottomSheet(BuildContext context, Event event) {
    unawaited(AnalyticsUiLogger.logMemoBottomSheetOpened());
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
                        S.of(context)!.editNote,
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
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            hintText: S.of(context)!.memoPlaceholder,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).primaryColor.withOpacity(
                                          0.6,
                                        ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor,
                              ),
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
                                      unawaited(
                                          AnalyticsUiLogger.logMemoSaved());
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
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              S.of(context)!.save,
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
    final primaryColor = Theme.of(context).primaryColor;

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

    final tabTitles = _tabTitles;
    final String currentEventId =
        tabTitles.isNotEmpty && _currentTabIndex < tabTitles.length
            ? tabTitles[_currentTabIndex]
            : "";
    final Event? currentEvent =
        user?.events.firstWhereOrNull((e) => e.eventId == currentEventId);
    final duplicateMemberNames = _findDuplicatedMemberNames(currentEvent);
    final bool shouldShowDuplicateWarning = duplicateMemberNames.isNotEmpty &&
        currentEventId.isNotEmpty &&
        !_dismissedDuplicateWarningEventIds.contains(currentEventId);
    if (shouldShowDuplicateWarning &&
        !_loggedDuplicateWarningEventIds.contains(currentEventId)) {
      _loggedDuplicateWarningEventIds.add(currentEventId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(AnalyticsUiLogger.logDuplicateMemberWarningShown());
      });
    }

    debugPrint('currentEvent: $currentEvent');
    debugPrint('lineGroupId: ${currentEvent?.lineGroupId}');
    debugPrint('lineMembersFetchedAt: ${currentEvent?.lineMembersFetchedAt}');

    final bool isLineConnected = currentEvent != null &&
        currentEvent.lineGroupId != null &&
        currentEvent.lineGroupId!.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Listener(
      onPointerDown: (_) => idleInterstitialManager.resetTimer(),
      onPointerMove: (_) => idleInterstitialManager.resetTimer(),
      child: WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawerScrimColor: Colors.transparent,
        onDrawerChanged: (isOpen) {
          if (isOpen) {
            unawaited(AnalyticsUiLogger.logDrawerOpened());
          } else {
            unawaited(AnalyticsUiLogger.logDrawerClosed());
          }
        },
        appBar: HomeAppBar(
          hasTabs: tabTitles.isNotEmpty,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onSharePressed: () {
            unawaited(AnalyticsUiLogger.logShareButtonPressed());
            if (currentEvent == null) {
              _showSnackBar('イベントが選択されていません');
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShareScreen(event: currentEvent),
              ),
            );
          },
          onHelpPressed: () {
            _showOnboardingScreen();
          },
          onSettingsPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          tabBar: _buildReorderableTabs(
            context: context,
            user: user,
            screenHeight: screenHeight,
            primaryColor: primaryColor,
          ),
        ),
        drawer: const TanochanDrawer(),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                physics: const ClampingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    const SliverToBoxAdapter(child: SizedBox(height: 6)),
                    if (isLineConnected)
                      SliverToBoxAdapter(
                        child: LineMemberDeleteLimitCountdown(
                          currentEvent: currentEvent,
                          currentEventId: currentEventId,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 6)),
                    if (shouldShowDuplicateWarning)
                      SliverToBoxAdapter(
                        child: DuplicateMemberWarning(
                          duplicateNames: duplicateMemberNames,
                          onClose: () {
                            if (currentEventId.isEmpty) {
                              return;
                            }
                            setState(() {
                              _dismissedDuplicateWarningEventIds
                                  .add(currentEventId);
                            });
                          },
                        ),
                      ),
                    if (shouldShowDuplicateWarning)
                      const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  ];
                },
                body: tabTitles.isEmpty
                    ? const EventZeroComponents()
                    : TabBarView(
                        controller: tabController,
                        children: tabTitles.asMap().entries.map((entry) {
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
                          final bool isEventConnected =
                              event.lineGroupId != null &&
                                  event.lineGroupId!.isNotEmpty;
                          return Stack(
                            children: [
                              CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: MemberList(
                                      event: event,
                                      members: event.eventId != ""
                                          ? event.members
                                          : [],
                                      eventId: event.eventId != ""
                                          ? event.eventId
                                          : "",
                                      eventName: event.eventName,
                                    ),
                                  ),
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: GestureDetector(
                                      onTap: () => _showEditNoteBottomSheet(
                                          context, event),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              S.of(context)!.note,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: (event
                                                            .memo?.isNotEmpty ==
                                                        true)
                                                    ? Text(
                                                        event.memo!,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
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
                                  child: isEventConnected
                                      ? FloatingActionButtonOn(
                                          tabController: tabController,
                                          event: event,
                                        )
                                      : FloatingActionButtonOff(
                                          tabController: tabController,
                                          event: event,
                                        ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
            if (!ref.watch(adsRemovalProvider) &&
                _isBannerLoaded &&
                _banner != null)
              SafeArea(
                top: false,
                child: SizedBox(
                  width: _banner!.size.width.toDouble(),
                  height: _banner!.size.height.toDouble(),
                  child: AdWidget(ad: _banner!),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  // スナックバーを表示する。
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
