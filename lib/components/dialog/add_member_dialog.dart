import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});
  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _addMember() {
    setState(() {
      if (_controller.text.isEmpty) {
        _errorMessage = 'メンバーを入力してください';
      } else {
        _errorMessage = null;
        // TODO: メンバーを追加するロジック
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: const Color(0xFFF2F2F2),
          height: 144,
          width: 380,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'メンバーを入力',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/line.svg"),
                    color: const Color(0xFF06C755),
                    onPressed: () {
                      // TODO
                    },
                  ),
                  SizedBox(
                    width: 118,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _addMember,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5AFF9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0),
                      child: Text(
                        'メンバー追加',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
