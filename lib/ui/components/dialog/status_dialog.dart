import 'package:flutter/material.dart';

class StatusDialog extends StatelessWidget {
  final String userId;
  final String eventId;
  final String memberId;
  final String member;
  final Function(String, String, String, int) onStatusChange;

  const StatusDialog({
    super.key,
    required this.userId,
    required this.eventId,
    required this.memberId,
    required this.member,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 280,
        height: 352,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 48, left: 42, right: 42, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$memberは',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusButton(
                context,
                label: '支払い済み',
                icon: Icons.check,
                iconColor: const Color(0xFF35C759),
                status: 1,
              ),
              const SizedBox(height: 32),
              _buildStatusButton(
                context,
                label: '未払い',
                icon: Icons.close,
                iconColor: Colors.red,
                status: 2,
              ),
              const SizedBox(height: 32),
              _buildStatusButton(
                context,
                label: '欠席',
                icon: Icons.remove,
                iconColor: const Color(0xFFC0C0C0),
                status: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color iconColor,
      required int status}) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        debugPrint('eventId: $eventId, memberId: $memberId, status: $status');
        await onStatusChange(userId, eventId, memberId, status);
      },
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF2F2F2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(icon, color: iconColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
