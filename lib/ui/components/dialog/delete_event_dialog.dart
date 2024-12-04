import 'package:flutter/material.dart';
import 'package:mr_collection/data/model/freezed/event.dart';

class DeleteEventDialog extends StatelessWidget {
  final int? eventId;
  const DeleteEventDialog({required this.eventId, super.key});

  get eventRepository => null;

  Future<void> _deleteEvent(BuildContext context, String id) async {
    final eventId = id;

    if (eventId.isEmpty) {
      return;
    }

    try {
      final event = await eventRepository.sendPaypayLink(eventId);
      Navigator.of(context).pop(event);
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
  Widget build(BuildContext context) {
    final List<Event> events;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 320,
        height: 179,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '{一次会}を削除しますか？', //TODO 実際にイベント名を取得
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  height: 36,
                  width: 107,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7D7D7),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'いいえ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  width: 107,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'はい',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
