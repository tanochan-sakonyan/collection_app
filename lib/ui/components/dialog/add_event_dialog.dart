import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/repository/event_repository.dart';
import 'package:mr_collection/ui/components/button/toggle_button.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  final String userId;

  const AddEventDialog({required this.userId, super.key});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends ConsumerState<AddEventDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;
  bool isToggleOn = false;

  final EventRepository eventRepository = EventRepository(baseUrl: baseUrl);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 8) {
        setState(() {
          _errorMessage = '最大8文字まで入力可能です';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    final eventName = _controller.text.trim();
    // final isCopy = isToggleOn;
    final userId = ref.read(userProvider)!.userId;

    if (!_isButtonEnabled) return;
    setState(() {
      _isButtonEnabled = false;
    });

    if (eventName.isEmpty) {
      _errorMessage = "イベント名を入力してください";
    }
    else if(eventName.length > 8){
      _errorMessage = "最大8文字まで入力可能です";
    }
    else{
      _errorMessage = null;
    }

    if(eventName.isEmpty || eventName.length > 8){
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    try {
      debugPrint('イベント名: $eventName, ユーザーID: $userId');
      await ref.read(userProvider.notifier).createEvent(eventName, userId);
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('イベントの追加に失敗しました: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
        child: Container(
          width: 320,
          height: 330,
          color: const Color(0xFFF2F2F2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child:Text(
                  'イベント追加',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Event",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 272,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: TextField(
                  controller: _controller,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child:
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  )
              else const SizedBox(height: 24),
              // Options Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 272,
                      height: 48,
                      child: ListTile(
                      title: const Text(
                          '参加者引継ぎ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),),
                      trailing: ToggleButton(
                        initialValue: isToggleOn,
                        onChanged: (bool isOn) {
                          setState(() {
                            isToggleOn = isOn;
                          });
                        },
                      ),
                    ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                    SizedBox(
                      width: 272,
                      height: 48,
                      child: ListTile(
                        dense: true,
                        title: const Text(
                            'LINEから参加者取得',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                        trailing: IconButton(
                          icon: SvgPicture.asset(
                          'assets/icons/line.svg',
                          width: 28,
                          height: 28,
                        ),
                        onPressed: () {
                          //LINE認証申請前の臨時ダイアログ
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 56.0, horizontal: 24.0),
                              content: Text(
                                'LINEへの認証申請中のため、\n機能解禁までしばらくお待ちください',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                          //TODO LINE認証申請が通ったらこちらに戻す
                          /*showDialog(
                            context: context,
                            builder: (context) => const ConfirmationDialog(),
                          );*/
                        },
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 272,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () => _createEvent()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    elevation: 4,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    '決定',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
              ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
