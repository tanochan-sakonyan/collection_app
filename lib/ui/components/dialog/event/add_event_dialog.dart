import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/ads/interstitial_singleton.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/screen/line_add_member/invite_official_account_to_line_group_screen.dart';
import 'package:mr_collection/ui/screen/transfer/choice_event_screen.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/screen/line_add_member/select_line_group_screen.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_name_dialog.dart';

enum AddEventMode {
  fromLineGroup, // LINEグループから作成
  transferMembers, // 他のイベントからメンバー引継ぎ
  empty, // 空のイベントを作成（中央の要素は非表示）
}

class AddEventDialog extends ConsumerStatefulWidget {
  final String userId;

  const AddEventDialog({required this.userId, super.key});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends ConsumerState<AddEventDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;
  Event? _selectedEvent;
  bool get _isTransferMode => _selectedEvent != null;
  LineGroup? lineGroup;

  Timer? _slowLoadingTimer;
  bool _showSlowLoadingMessage = false;
  late final ProviderSubscription<bool> _loadingSubscription;

  final EventRepository eventRepository = EventRepository(baseUrl: baseUrl);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 8) {
        setState(() {
          _errorMessage = S.of(context)!.maxCharacterMessage_8;
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    });

    _loadingSubscription = ref.listenManual<bool>(
      loadingProvider,
      (prev, next) {
        if (next) {
          _slowLoadingTimer?.cancel();
          _slowLoadingTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && ref.read(loadingProvider)) {
              setState(() => _showSlowLoadingMessage = true);
            }
          });
        } else {
          _slowLoadingTimer?.cancel();
          _showSlowLoadingMessage = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _loadingSubscription.close();
    _slowLoadingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    final eventName = _controller.text.trim();
    final userId = ref.read(userProvider)!.userId;

    if (!_isButtonEnabled) return;
    setState(() {
      _isButtonEnabled = false;
    });

    if (eventName.isEmpty) {
      _errorMessage = S.of(context)!.enterEventName;
    } else if (eventName.length > 8) {
      _errorMessage = S.of(context)!.maxCharacterMessage_8;
    } else {
      _errorMessage = null;
    }

    if (eventName.isEmpty || eventName.length > 8) {
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    ref.read(loadingProvider.notifier).state = true;

    try {
      String? createdEventId;
      if (_isTransferMode) {
        createdEventId = await ref
            .read(userProvider.notifier)
            .createEventAndTransferMembers(
                _selectedEvent!.eventId, eventName, userId);
      } else if (lineGroup != null) {
        createdEventId = await ref
            .read(userProvider.notifier)
            .createEventAndGetMembersFromLine(
                userId, lineGroup!.groupId, eventName, lineGroup!.members);
      } else {
        createdEventId = await ref
            .read(userProvider.notifier)
            .createEvent(eventName, userId);
      }
      debugPrint('イベント名: $eventName, ユーザーID: $userId');
      Navigator.of(context).pop(createdEventId);
    } catch (error) {
      debugPrint('イベントの追加に失敗しました: $error');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  // メンバー引き継ぎ
  Future<void> _choiceEvent() async {
    final picked = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
        builder: (_) => const ChoiceEventScreen(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedEvent = picked;
      });
    }
  }

  // LINEグループから追加
  Future<void> _selectLineGroup() async {
    final userId = ref.read(userProvider)?.userId;
    if (userId == null) return;

    debugPrint('LINE取得APIを実行しました。');
    ref.read(loadingProvider.notifier).state = true;

    // インターステイシャル広告を表示
    if (interstitial.isReady) {
      await interstitial.show();
    } else {
      debugPrint('Interstitial not ready → skip');
    }

    List<LineGroup> lineGroups = [];
    try {
      lineGroups = await ref.read(userProvider.notifier).getLineGroups(userId);
    } catch (e) {
      debugPrint('LINE グループ取得失敗: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
    debugPrint('取得したLINEグループ : $lineGroups');

    if (lineGroups.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const InviteOfficialAccountToLineGroupScreen()),
      );
    } else {
      final pickedLineGroup = await Navigator.of(context).push<LineGroup>(
        MaterialPageRoute(
            builder: (_) => SelectLineGroupScreen(lineGroups: lineGroups)),
      );
      if (pickedLineGroup != null) {
        setState(() {
          lineGroup = pickedLineGroup;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleIndicator(
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
              child: Container(
                width: 320,
                height: 360,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SvgPicture.asset('assets/icons/ic_clipboard_list.svg',
                          width: 56, height: 56),
                      const SizedBox(width: 8),
                      SvgPicture.asset('assets/icons/line.svg',
                          width: 56, height: 56),
                    ]),
                    const SizedBox(height: 20),
                    Text(
                      S.of(context)!.addEvent,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "“LINEグループから作成”をすると、\n自動でグループのメンバーを追加し、\nグループにメッセージを送信できます。",
                        style: GoogleFonts.notoSansJp(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    EventDialogComponent(
                        label: 'LINEグループから作成',
                        leading: SvgPicture.asset(
                          'assets/icons/ic_smile_bubble.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                              Colors.black38, BlendMode.srcIn),
                        ),
                        onTap: _selectLineGroup
                        // onTap: (_isButtonEnabled && !ref.watch(loadingProvider))
                        //     ? () async {
                        //         await showDialog<String?>(
                        //           context: context,
                        //           barrierDismissible: true,
                        //           builder: (_) => const AddEventNameDialog(
                        //             mode: AddEventMode.fromLineGroup,
                        //           ),
                        //         );
                        //       }
                        //     : null,
                        ),
                    const SizedBox(height: 8),
                    EventDialogComponent(
                        label: '他のイベントからメンバー引継ぎ',
                        leading: SvgPicture.asset(
                          'assets/icons/ic_download_file.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                              Colors.black38, BlendMode.srcIn),
                        ),
                        onTap: _choiceEvent
                        // onTap: () async {
                        //   await showDialog<String?>(
                        //     context: context,
                        //     barrierDismissible: true,
                        //     builder: (_) => const AddEventNameDialog(
                        //       mode: AddEventMode.transferMembers,
                        //     ),
                        //   );
                        // },
                        ),
                    const SizedBox(height: 8),
                    EventDialogComponent(
                      label: '空のイベントを作成',
                      leading: SvgPicture.asset(
                        'assets/icons/ic_empty_clipboard.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                            Colors.black38, BlendMode.srcIn),
                      ),
                      onTap: () async {
                        await showDialog<String?>(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => const AddEventNameDialog(
                            mode: AddEventMode.empty,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.35,
          child: Visibility(
            visible: isLoading && _showSlowLoadingMessage,
            child: Material(
              color: Colors.transparent,
              child: Text(
                S.of(context)!.loadingApologizeMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventDialogComponent extends StatelessWidget {
  const EventDialogComponent({
    super.key,
    required this.label,
    this.leading,
    this.onTap,
  });

  final String label;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 44,
      child: Material(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 20),
              SizedBox(
                width: 14,
                height: 14,
                child: leading,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.notoSansJp(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddEventNameDialog extends ConsumerStatefulWidget {
  const AddEventNameDialog({super.key, required this.mode});
  final AddEventMode mode;

  @override
  ConsumerState<AddEventNameDialog> createState() => _AddEventNameDialogState();
}

class _AddEventNameDialogState extends ConsumerState<AddEventNameDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;

  Event? _selectedEvent;
  LineGroup? _lineGroup;

  Timer? _slowLoadingTimer;
  bool _showSlowLoadingMessage = false;
  late final ProviderSubscription<bool> _loadingSubscription;

  final EventRepository eventRepository = EventRepository(baseUrl: baseUrl);

  bool get _isTransferMode => _selectedEvent != null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 8) {
        setState(() => _errorMessage = S.of(context)!.maxCharacterMessage_8);
      } else {
        setState(() => _errorMessage = null);
      }
    });

    _loadingSubscription = ref.listenManual<bool>(
      loadingProvider,
      (prev, next) {
        if (next) {
          _slowLoadingTimer?.cancel();
          _slowLoadingTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && ref.read(loadingProvider)) {
              setState(() => _showSlowLoadingMessage = true);
            }
          });
        } else {
          _slowLoadingTimer?.cancel();
          _showSlowLoadingMessage = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _loadingSubscription.close();
    _slowLoadingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _choiceEvent() async {
    final picked = await Navigator.of(context).push<Event>(
      MaterialPageRoute(builder: (_) => const ChoiceEventScreen()),
    );
    if (picked != null) {
      setState(() => _selectedEvent = picked);
    }
  }

  Future<void> _selectLineGroup() async {
    final userId = ref.read(userProvider)?.userId;
    if (userId == null) return;

    ref.read(loadingProvider.notifier).state = true;

    if (interstitial.isReady) {
      await interstitial.show();
    }

    List<LineGroup> lineGroups = [];
    try {
      lineGroups = await ref.read(userProvider.notifier).getLineGroups(userId);
    } catch (e) {
      debugPrint('LINE グループ取得失敗: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }

    if (!mounted) return;

    if (lineGroups.isEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const InviteOfficialAccountToLineGroupScreen()),
      );
    } else {
      final picked = await Navigator.of(context).push<LineGroup>(
        MaterialPageRoute(
            builder: (_) => SelectLineGroupScreen(lineGroups: lineGroups)),
      );
      if (picked != null) {
        setState(() => _lineGroup = picked);
      }
    }
  }

  Future<void> _createEvent() async {
    final eventName = _controller.text.trim();
    final userId = ref.read(userProvider)!.userId;

    if (!_isButtonEnabled) return;
    setState(() => _isButtonEnabled = false);

    if (eventName.isEmpty) {
      _errorMessage = S.of(context)!.enterEventName;
    } else if (eventName.length > 8) {
      _errorMessage = S.of(context)!.maxCharacterMessage_8;
    } else {
      _errorMessage = null;
    }

    if (_errorMessage != null) {
      setState(() => _isButtonEnabled = true);
      return;
    }

    ref.read(loadingProvider.notifier).state = true;

    try {
      String? createdEventId;
      switch (widget.mode) {
        case AddEventMode.transferMembers:
          if (_selectedEvent == null) {
            throw Exception('イベントが選択されていません');
          }
          createdEventId = await ref
              .read(userProvider.notifier)
              .createEventAndTransferMembers(
                  _selectedEvent!.eventId, eventName, userId);
          break;
        case AddEventMode.fromLineGroup:
          if (_lineGroup == null) {
            throw Exception('LINEグループが選択されていません');
          }
          createdEventId = await ref
              .read(userProvider.notifier)
              .createEventAndGetMembersFromLine(
                  userId, _lineGroup!.groupId, eventName, _lineGroup!.members);
          break;
        case AddEventMode.empty:
          createdEventId = await ref
              .read(userProvider.notifier)
              .createEvent(eventName, userId);
          break;
      }
      if (!mounted) return;
      Navigator.of(context).pop(createdEventId);
    } catch (e) {
      debugPrint('イベント作成失敗: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      if (mounted) setState(() => _isButtonEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 20),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context)!.addEvent,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Event",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 272,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    child: _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.red,
                                ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  // ---- Options Section (mode dependent) ----
                  if (widget.mode != AddEventMode.empty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          if (widget.mode == AddEventMode.transferMembers)
                            SizedBox(
                              width: 272,
                              height: 48,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  S.of(context)!.transferMembers,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                ),
                                trailing: SizedBox(
                                  width: 112,
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isButtonEnabled ? _choiceEvent : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isTransferMode
                                          ? const Color(0xFF76DCC6)
                                          : const Color(0xFFECECEC),
                                      elevation: 2,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 0),
                                    ),
                                    child: Text(
                                      _selectedEvent?.eventName ??
                                          S.of(context)!.selectEvent,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: _isTransferMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.mode == AddEventMode.fromLineGroup)
                            SizedBox(
                              width: 272,
                              height: 48,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  S.of(context)!.addFromLine,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                ),
                                trailing: _lineGroup != null
                                    ? SizedBox(
                                        width: 112,
                                        height: 28,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF06C755),
                                            elevation: 2,
                                            shape: const StadiumBorder(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 0),
                                          ),
                                          child: Text(
                                            _lineGroup!.groupName,
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/icons/line.svg',
                                          width: 32,
                                          height: 32,
                                        ),
                                        onPressed: (_isButtonEnabled &&
                                                !ref.watch(loadingProvider))
                                            ? () => _selectLineGroup()
                                            : null,
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // ---- Confirm Button ----
                  SizedBox(
                    width: 272,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _createEvent : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F2F2),
                        elevation: 2,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        S.of(context)!.confirm,
                        style: GoogleFonts.notoSansJp(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.35,
          child: Visibility(
            visible: isLoading && _showSlowLoadingMessage,
            child: Material(
              color: Colors.transparent,
              child: Text(
                S.of(context)!.loadingApologizeMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
