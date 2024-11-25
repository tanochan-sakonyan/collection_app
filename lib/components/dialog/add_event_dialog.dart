import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/components/button/toggle_button.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/provider/event_provider.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  const AddEventDialog({super.key});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends ConsumerState<AddEventDialog> {
  bool isToggleOn = true;

  final EventRepository eventRepository =
      EventRepository(baseUrl: 'https://your-api-base-url.com');

  Future<void> _createEvent(TextEditingController controller) async {
    final eventName = controller.text;
    final isCopy = isToggleOn;

    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベント名を入力してください')),
      );
      return;
    }

    try {
      ref.read(eventProvider.notifier).createEvent(eventName, isCopy);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントが作成されました')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベント作成に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
        child: Container(
          width: 328,
          height: 270,
          color: const Color(0xFFF2F2F2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/close_circle.svg"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'イベントの追加',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/check_circle.svg"),
                    onPressed: () => _createEvent(controller)
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'イベント名を入力',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Options Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('参加者引継ぎ'),
                      trailing: ToggleButton(
                        initialValue: isToggleOn,
                        onChanged: (bool isOn) {
                          setState(() {
                            isToggleOn = isOn;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                    ListTile(
                      title: const Text('LINEから参加者取得'),
                      trailing: IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/line.svg',
                          width: 28,
                          height: 28,
                        ),
                        onPressed: () {
                          // TODO: LINE から参加者取得のロジック
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 29)
            ],
          ),
        ),
      ),
    );
  }
}
