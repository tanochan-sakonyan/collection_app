import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/ads/interstitial_singleton.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/screen/line_add_member/invite_official_account_to_line_group_screen.dart';
import 'package:mr_collection/ui/screen/line_add_member/select_line_group_screen.dart';
import 'package:mr_collection/ui/screen/transfer/choice_event_screen.dart';

/// AddEventNameDialog の表示モード
enum AddEventMode {
  fromLineGroup,
  transferMembers,
  empty,
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
          builder: (_) => const InviteOfficialAccountToLineGroupScreen(),
        ),
      );
    } else {
      final picked = await Navigator.of(context).push<LineGroup>(
        MaterialPageRoute(
          builder: (_) => SelectLineGroupScreen(lineGroups: lineGroups),
        ),
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
                _selectedEvent!.eventId,
                eventName,
                userId,
              );
          break;
        case AddEventMode.fromLineGroup:
          if (_lineGroup == null) {
            throw Exception('LINEグループが選択されていません');
          }
          createdEventId = await ref
              .read(userProvider.notifier)
              .createEventAndGetMembersFromLine(
                userId,
                _lineGroup!.groupId,
                eventName,
                _lineGroup!.members,
              );
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
