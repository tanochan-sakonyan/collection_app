import 'package:flutter/material.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/provider/event_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteEventDialog extends ConsumerWidget {
  final int eventId;
  const DeleteEventDialog({required this.eventId, super.key});

  Future<void> _deleteEvent(BuildContext context, WidgetRef ref, int id) async {
    final eventId = id;

    if (eventId <= 0) { // 例: eventIdが0以下の場合は無効とみなす
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無効なイベントIDです')), // 必要に応じてメッセージを表示
      );
      return;
    }

    try {
      await ref.read(eventProvider.notifier).deleteEvent([eventId]);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントを削除しました')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントの削除に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Event> events;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Container(
        width: 296,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 44.0, bottom: 50.0),
              child: Column(
                children: [
                  Text(
                    'このイベントを',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '削除しますか？',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black),
            Stack(
              children: [
                Container(
                    height: 59,
                    alignment: Alignment.center,
                    child:
                        const VerticalDivider(width: 1, color: Colors.black)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _deleteEvent(context, ref, eventId),
                      child: Container(
                        height: 59,
                        alignment: Alignment.center,
                        child: const Text(
                          'はい',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 59,
                        alignment: Alignment.center,
                        child: const Text(
                          'いいえ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
