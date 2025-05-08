import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/payment_status.dart';
import 'package:mr_collection/provider/tab_titles_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/add_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/delete_event_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_for_120_and_suggest_official_line_dialog.dart';
import 'package:mr_collection/ui/components/member_list.dart';
import 'package:mr_collection/ui/components/tanochan_drawer.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/ui/screen/check_selected_event_screen.dart';
import 'package:mr_collection/ui/tutorial/tutorial_targets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:mr_collection/ui/components/event_zero_components.dart';

import 'home_screen.dart';

class ChoiceEventScreen extends ConsumerStatefulWidget {
  const ChoiceEventScreen({super.key, this.user});
  final User? user;
  @override
  ConsumerState<ChoiceEventScreen> createState() => ChoiceEventScreenState();
}

class ChoiceEventScreenState extends ConsumerState<ChoiceEventScreen>
    with TickerProviderStateMixin {

  Future<void> _checkSelectedEvent (Event event) async {
    final picked = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
          builder: (_) => CheckSelectedEventScreen(selectedEvent: event)
      ),
    );
    if(picked != null){
      Navigator.of(context).pop(picked);
    }
}

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final events = user?.events ?? <Event>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
          leadingWidth: 40,
          leading: IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            padding: EdgeInsets.zero,
            icon: SizedBox(
              width: 21, height: 21,
              child: SvgPicture.asset('assets/icons/back.svg'),
            ),),
          titleSpacing: 0,
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(
              '戻る',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF76DCC6),
              ),
            ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  'メンバー引継ぎ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E8E93),
              ),),
              const SizedBox(height: 32),
              Text(
                'メンバーを引き継ぎたい\nイベントを選択してください',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Column(
                      children: [
                      SizedBox(
                        height: 44,
                        child: ListTile(
                          title: Text(
                            event.eventName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: SizedBox(
                            width: 16, height: 16,
                            child: SvgPicture.asset('assets/icons/disclosure_indicator.svg'),
                          ),
                          onTap: () => _checkSelectedEvent(event)
                        ),
                      ),
                      const Divider(
                        color: Color(0xFFE8E8E8),
                        thickness: 1,
                        height: 1,
                      ),
                      ],
                    );
                  },
                )
              ),
            ]
        ),
      ),
    );
  }
}
