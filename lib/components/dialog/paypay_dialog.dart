import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';

class PayPayDialog extends ConsumerStatefulWidget {
  PayPayDialog({super.key});
  @override
  _PayPayDialogState createState() => _PayPayDialogState();
}

class _PayPayDialogState extends ConsumerState<PayPayDialog> {
  final TextEditingController controller = TextEditingController();
  String? _errorMessage;

  Future<void> _sendPaypayLink(BuildContext context) async {
    final paypayLink = controller.text;

    if (paypayLink.isEmpty) {
      setState(() {
        _errorMessage = 'PayPayリンクを入力してください';
      });
      return;
    }

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final user = ref.read(userProvider);
      final userId = user?.userId.toString();

      await userRepository.sendPaypayLink(userId, paypayLink);
      Navigator.of(context).pop();
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 320,
          height: 216,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 4),
              Text(
                'PayPayリンクを入力してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 247,
                child: TextField(
                  controller: controller,
                  cursorColor: Color(0xFFA3A3A3),
                  decoration: InputDecoration(
                    hintText: '受け取りリンクを入力',
                    hintStyle: const TextStyle(color: Color(0xFFA3A3A3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    errorText: _errorMessage,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 40,
                width: 272,
                child: ElevatedButton(
                  onPressed: () {
                    _sendPaypayLink(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: Theme.of(context).textTheme.bodyMedium,
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
