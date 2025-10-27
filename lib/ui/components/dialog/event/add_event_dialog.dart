import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/admob/interstitial_singleton.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/ui/components/circular_loading_indicator.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_name_dialog.dart';
import 'package:mr_collection/ui/screen/line_add_member/invite_official_account_to_line_group_screen.dart';
import 'package:mr_collection/ui/screen/transfer/choice_event_screen.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/screen/line_add_member/select_line_group_screen.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  final String userId;

  const AddEventDialog({required this.userId, super.key});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends ConsumerState<AddEventDialog> {
  final TextEditingController _controller = TextEditingController();
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
        setState(() {});
      } else {
        setState(() {});
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

  // メンバー引き継ぎ
  Future<void> _choiceEvent() async {
    final selectedEvent = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
        builder: (_) => const ChoiceEventScreen(),
      ),
    );
    if (selectedEvent != null) {
      setState(() {});
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
      if (!mounted) return;
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

    if (!mounted) return;

    if (lineGroups.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const InviteOfficialAccountToLineGroupScreen()),
      );
    } else {
      final selectedLineGroup = await Navigator.of(context).push<LineGroup>(
        MaterialPageRoute(
            builder: (_) => SelectLineGroupScreen(lineGroups: lineGroups)),
      );
      if (!mounted) return;
      if (selectedLineGroup != null) {
        setState(() {
          lineGroup = selectedLineGroup;
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
                      const SizedBox(width: 28),
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
                        onTap: _selectLineGroup),
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
                        onTap: _choiceEvent),
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
