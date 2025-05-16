import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/data/model/freezed/event.dart';


class CheckSelectedEventScreen extends ConsumerStatefulWidget {
  final Event selectedEvent;
  const CheckSelectedEventScreen({super.key, required this.selectedEvent});
  @override
  ConsumerState<CheckSelectedEventScreen> createState() => CheckSelectedEventScreenState();
}

class CheckSelectedEventScreenState extends ConsumerState<CheckSelectedEventScreen> {

  @override
  Widget build(BuildContext context) {
    final event = widget.selectedEvent;
    final eventName = event.eventName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 40,
        leading: IconButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          padding: EdgeInsets.zero,
          icon: SizedBox(
            width: 21, height: 21,
            child: SvgPicture.asset('assets/icons/ic_back.svg'),
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
      body: Column(
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
            '$eventNameのメンバーを引き継ぎますか？',
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
                  'メンバー',
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
                      padding:
                      const EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 44,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            member.memberName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    const SizedBox(height: 32),
        SizedBox(
          width: 240,
          height: 40,
          child: ElevatedButton(
            onPressed: (){
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
              'このメンバーを引継ぐ',
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
