import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_name_dialog.dart';
import 'package:mr_collection/ui/screen/transfer/check_selected_event_screen.dart';
import 'package:mr_collection/generated/s.dart';

class ChoiceEventScreen extends ConsumerStatefulWidget {
  const ChoiceEventScreen({super.key});
  @override
  ConsumerState<ChoiceEventScreen> createState() => ChoiceEventScreenState();
}

class ChoiceEventScreenState extends ConsumerState<ChoiceEventScreen> {
  Future<void> _checkSelectedEvent(Event event) async {
    final selectedEvent = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
          builder: (_) => CheckSelectedEventScreen(selectedEvent: event)),
    );
    if (selectedEvent != null) {
      Navigator.of(context).pop(selectedEvent);
      showDialog(
          context: context,
          builder: (_) => AddEventNameDialog(
              mode: AddEventMode.transferMembers,
              selectedEvent: selectedEvent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final events = user?.events ?? <Event>[];
    final primaryColor = Theme.of(context).primaryColor;

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
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                S.of(context)!.back,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            S.of(context)!.transferMembers,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context)!.selectEventToTransfer,
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        trailing: SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                            'assets/icons/ic_next.svg',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
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
