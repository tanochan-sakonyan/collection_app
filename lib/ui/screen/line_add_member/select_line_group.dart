import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/ui/components/dialog/event/invite_official_acount_to_line_group.dart';
import 'package:mr_collection/ui/screen/transfer/check_selected_event_screen.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class SelectLineGroupScreen extends ConsumerStatefulWidget {
  const SelectLineGroupScreen({super.key});
  @override
  ConsumerState<SelectLineGroupScreen> createState() => SelectLineGroupScreenState();
}

class SelectLineGroupScreenState extends ConsumerState<SelectLineGroupScreen> {
  Future<void> _checkSelectedEvent(Event event) async {
    final picked = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
          builder: (_) => CheckSelectedEventScreen(selectedEvent: event)),
    );
    if (picked != null) {
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
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 44,
                height: 44,
              ),
              Text(
                '戻る',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF76DCC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const InviteOfficialAcountToLineGroupDialog(),
                );
              },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "LINEグループが表示されない？",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C5C5C),
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/question_circle.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            "LINEグループから\nメンバー追加",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF06C755),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            "追加したいメンバーの\nLINEグループを選択してください",
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
                              //TODO: 現在はイベント引継ぎ画面を再利用しているが、バックと繋ぐときにLINEグループ名をリスト表示するように変更する
                              event.eventName,
                              style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset('assets/icons/ic_next.svg'),
                            ),
                            onTap: () => _checkSelectedEvent(event)),
                      ),
                      const Divider(
                        color: Color(0xFFE8E8E8),
                        thickness: 1,
                        height: 1,
                      ),
                    ],
                  );
                },
              )),
        ]),
      ),
    );
  }
}
