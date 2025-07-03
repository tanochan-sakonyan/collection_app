import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PayPayDialog extends ConsumerStatefulWidget {
  const PayPayDialog({super.key});
  @override
  PayPayDialogState createState() => PayPayDialogState();
}

class PayPayDialogState extends ConsumerState<PayPayDialog> {
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
      debugPrint("PayPayリンクを送信しました");
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PayPayリンクを送信しました。')),
      );
      debugPrint("PayPayリンクの送信に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
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
              const SizedBox(height: 4),
              Text(
                'PayPayリンクを入力してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 247,
                child: TextField(
                  controller: controller,
                  cursorColor: const Color(0xFFA3A3A3),
                  decoration: InputDecoration(
                    hintText: '受け取りリンクを入力',
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
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
                    errorStyle:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: Colors.red,
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "反映まで3~5分ほどかかる場合があります。",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
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
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
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
