import 'package:flutter/material.dart';

class StatusPopup extends StatelessWidget {
  final String member;
  final VoidCallback onPaid;
  final VoidCallback onUnpaid;
  final VoidCallback onAbsent;

  const StatusPopup({
    super.key,
    required this.member,
    required this.onPaid,
    required this.onUnpaid,
    required this.onAbsent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$memberは',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatusButton(
              text: '支払い済み',
              icon: Icons.check,
              iconColor: Colors.green,
              onPressed: onPaid,
            ),
            const SizedBox(height: 16),
            StatusButton(
              text: '未払い',
              icon: Icons.close,
              iconColor: Colors.red,
              onPressed: onUnpaid,
            ),
            const SizedBox(height: 16),
            StatusButton(
              text: '欠席',
              icon: Icons.remove,
              iconColor: Colors.grey,
              onPressed: onAbsent,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const StatusButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2F2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black)),
          Icon(icon, color: iconColor),
        ],
      ),
    );
  }
}

void showStatusPopup(BuildContext context, String member) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatusPopup(
        member: member,
        onPaid: () {
          Navigator.of(context).pop();
          // 支払い済みの処理
        },
        onUnpaid: () {
          Navigator.of(context).pop();
          // 未払いの処理
        },
        onAbsent: () {
          Navigator.of(context).pop();
          // 欠席の処理
        },
      );
    },
  );
}
