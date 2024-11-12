import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PayPayDialog extends StatelessWidget {
  const PayPayDialog({super.key});

  get userRepository => null;

  Future<void> _sendPaypayLink(BuildContext context, String controller) async {
    final paypayLink = controller;

    if (paypayLink.isEmpty) {
      return;
    }

    try {
      final event = await userRepository.sendPaypayLink(paypayLink);
      Navigator.of(context).pop(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PayPayリンクを送信しました。')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PayPayリンクの送信に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 296,
          height: 240,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: SvgPicture.asset("assets/icons/close_circle.svg")),
                IconButton(
                  onPressed: () => _sendPaypayLink(context, controller.text),
                  icon: SvgPicture.asset("assets/icons/check_circle.svg"),
                )
              ]),
              Text(
                'PayPayリンクを\n入力してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),
              // Input field
              SizedBox(
                width: 247,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'PayPayの受け取りリンク',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
