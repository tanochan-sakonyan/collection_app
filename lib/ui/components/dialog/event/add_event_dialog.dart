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
import 'package:mr_collection/ui/screen/transfer/choice_event_screen.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/screen/line_add_member/select_line_group_screen.dart';
import 'package:mr_collection/ui/screen/line_add_member/invite_official_account_to_line_group_screen.dart';
import 'package:mr_collection/services/analytics_service.dart';

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
    AnalyticsService().logDialogOpen('add_event_dialog');
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
      if (_isTransferMode) {
        await ref.read(userProvider.notifier).createEventAndTransferMembers(
            _selectedEvent!.eventId, eventName, userId);
      } else if (lineGroup != null) {
        await ref.read(userProvider.notifier).createEventAndGetMembersFromLine(
            userId, lineGroup!.groupId, eventName, lineGroup!.members);
      } else {
        await ref.read(userProvider.notifier).createEvent(eventName, userId);
      }
      debugPrint('イベント名: $eventName, ユーザーID: $userId');
      AnalyticsService().logDialogClose(
        'add_event_dialog',
        'event_created'
      );
      Navigator.of(context).pop();
    } catch (error) {
      AnalyticsService().logDialogClose(
        'add_event_dialog',
        'event_creation_error'
      );
      debugPrint('イベントの追加に失敗しました: $error');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

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
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
              child: Container(
                width: 320,
                height: 330,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        S.of(context)!.addEvent,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        // textAlignVertical: TextAlignVertical.center,
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
                    // Options Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
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
                                        color: Colors.black),
                              ),
                              trailing: SizedBox(
                                width: 112,
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: _isButtonEnabled ? () {
                                    AnalyticsService().logButtonTap(
                                      'transfer_members',
                                      screen: 'add_event_dialog'
                                    );
                                    _choiceEvent();
                                  } : null,
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
                                        color: Colors.black),
                              ),
                              trailing: lineGroup != null
                                  ? SizedBox(
                                      width: 112,
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF06C755),
                                          elevation: 2,
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
                                        ),
                                        child: Text(
                                          lineGroup!.groupName,
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
                                      ))
                                  : IconButton(
                                      icon: SvgPicture.asset(
                                        'assets/icons/line.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                      onPressed: (_isButtonEnabled &&
                                              !ref.watch(loadingProvider))
                                          ? () {
                                              AnalyticsService().logButtonTap(
                                                'select_line_group',
                                                screen: 'add_event_dialog'
                                              );
                                              _selectLineGroup();
                                            }
                                          : null,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 272,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? () {
                          AnalyticsService().logButtonTap(
                            'confirm_create_event',
                            screen: 'add_event_dialog'
                          );
                          _createEvent();
                        } : null,
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
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
