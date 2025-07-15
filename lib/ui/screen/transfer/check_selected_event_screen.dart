import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/generated/s.dart';

class CheckSelectedEventScreen extends ConsumerStatefulWidget {
  final Event selectedEvent;
  const CheckSelectedEventScreen({super.key, required this.selectedEvent});
  @override
  ConsumerState<CheckSelectedEventScreen> createState() =>
      CheckSelectedEventScreenState();
}

class CheckSelectedEventScreenState
    extends ConsumerState<CheckSelectedEventScreen> {
  @override
  Widget build(BuildContext context) {
    final event = widget.selectedEvent;
    final eventName = event.eventName;

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S.of(context)!.transferMembers,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E8E93),
                ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context)!.confirmTransferFromEvent ??
                "Do you want to transfer members from this event?",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 352,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        height: 32,
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              S.of(context)!.member,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: event.members.length,
                          itemBuilder: (context, index) {
                            final member = event.members[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: SizedBox(
                                    height: 44,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        member.memberName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                      ),
                                    ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(event);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF76DCC6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context)!.transferThisMember,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
