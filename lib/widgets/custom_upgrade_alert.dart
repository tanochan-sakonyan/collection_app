import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String get title => '新しいバージョンがあります';

  @override
  String get releaseNotes => '新機能';

  @override
  String get body => '';

  @override
  String get prompt => '';

  @override
  String get buttonTitleIgnore => '今はしない';

  @override
  String get buttonTitleLater => '';

  @override
  String get buttonTitleUpdate => 'アップデート';

  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return '';
      case UpgraderMessage.prompt:
        return '';
      case UpgraderMessage.releaseNotes:
        return '新機能';
      case UpgraderMessage.title:
        return '新しいバージョンがあります';
      case UpgraderMessage.buttonTitleIgnore:
        return '今はしない';
      case UpgraderMessage.buttonTitleUpdate:
        return 'アップデート';
      case UpgraderMessage.buttonTitleLater:
        return '';
    }
  }
}

class CustomUpgradeAlert extends StatefulWidget {
  final Widget child;
  final Upgrader? upgrader;

  const CustomUpgradeAlert({
    super.key,
    required this.child,
    this.upgrader,
  });

  @override
  State<CustomUpgradeAlert> createState() => _CustomUpgradeAlertState();
}

class _CustomUpgradeAlertState extends State<CustomUpgradeAlert> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      // デバッグモードでのみ表示するかの判定
      bool shouldShow = false;
      if (widget.upgrader != null) {
        // upgraderが渡されている場合は、そのupgraderの設定に従う
        shouldShow = true; // collection_app.dartでdebugDisplayAlwaysの制御を行う
      }
      
      if (shouldShow) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCustomDialog();
        });
      }
    }
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '新しいバージョンがあります',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'アップデートをすると',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '以下の新機能が使えるようになります',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '✨',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildFeatureItem('メンバーの役職から自動計算'),
              const SizedBox(height: 16),
              _buildFeatureItem('LINE取得情報の自動削除の更新機能'),
              const SizedBox(height: 16),
              _buildFeatureItem('デザインのバージョンアップ'),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontFamilyFallback: ['Noto Sans JP'],
                      ),
                    ),
                    child: const Text('今はしない'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // アップデートロジックをここに実装
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF75DCC6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontFamilyFallback: ['Noto Sans JP'],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('アップデート'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF75DCC6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Montserrat',
              fontFamilyFallback: ['Noto Sans JP'],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
