import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:mr_collection/generated/s.dart';

class TutorialTargets {
  static List<TargetFocus> createTargets({
    required BuildContext context,
    required GlobalKey eventAddKey,
    required GlobalKey leftTabKey,
    required GlobalKey memberAddKey,
    required GlobalKey slidableKey,
    required GlobalKey sortKey,
    required GlobalKey fabKey,
  }) {
    return [
      TargetFocus(
        identify: "plus_button",
        keyTarget: eventAddKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.tapToAddEvent,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "left_tab",
        keyTarget: leftTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.longPressToDeleteEvent,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "member_add",
        keyTarget: memberAddKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.tapToAddMember,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "slidable",
        keyTarget: slidableKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.swipeToEditOrDeleteMember,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "sort_icon",
        keyTarget: sortKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.tapToSortByPayment,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "fab",
        keyTarget: fabKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Text(
                  S.of(context)!.tapToSendReminder,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
