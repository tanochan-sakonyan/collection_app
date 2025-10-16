import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/ui/components/dialog/event/add_event_name_dialog.dart';
import 'package:mr_collection/ui/components/dialog/line/invite_official_account_to_line_group_dialog.dart';
import 'check_selected_line_group_screen.dart';
import 'package:mr_collection/generated/s.dart';

class SelectLineGroupScreen extends StatelessWidget {
  final List<LineGroup> lineGroups;
  const SelectLineGroupScreen({Key? key, required this.lineGroups})
      : super(key: key);

  Future<void> _checkSelectedLineGroup(
      BuildContext context, LineGroup lineGroup) async {
    final selectedLineGroup = await Navigator.of(context).push<LineGroup>(
      MaterialPageRoute(
          builder: (_) => CheckSelectedLineGroupScreen(lineGroup: lineGroup)),
    );
    // ここでaddEventNameDialogに遷移
    if (selectedLineGroup != null) {
      Navigator.pop(context, selectedLineGroup);
      showDialog(
          context: context,
          builder: (_) => AddEventNameDialog(
              mode: AddEventMode.fromLineGroup,
              selectedLineGroup: selectedLineGroup));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                S.of(context)!.back,
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
                builder: (context) =>
                    const InviteOfficialAccountToLineGroupDialog(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  S.of(context)!.notDisplayedQuestion ??
                      "LINE group not displayed?",
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
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF8E8E93), BlendMode.srcIn),
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
            S.of(context)!.selectLineGroupTitle ??
                "Add members from LINE group",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF06C755),
                  height: 1.1,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context)!.selectLineGroupDesc1 ??
                "Select the LINE group where you want to add members.",
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
            itemCount: lineGroups.length,
            itemBuilder: (context, index) {
              final lineGroup = lineGroups[index];
              return Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: ListTile(
                        title: Text(
                          lineGroup.groupName,
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
                        onTap: () =>
                            _checkSelectedLineGroup(context, lineGroup)),
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
