import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:upgrader/upgrader.dart';
import 'package:mr_collection/generated/s.dart';

class CustomUpgradeAlert extends StatefulWidget {
  final Widget child;
  final Upgrader upgrader;

  const CustomUpgradeAlert({
    super.key,
    required this.child,
    required this.upgrader,
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCustomDialog();
      });
      _dialogShown = true;
    }
  }

  void _showCustomDialog() async {
    await widget.upgrader.initialize();

    final appStoreVersion = widget.upgrader.currentAppStoreVersion ?? "";
    final releaseNotes = widget.upgrader.releaseNotes ?? "リリースノートなし";
    final notesList = releaseNotes
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(3)
        .toList();
    final installedVersion = widget.upgrader.currentInstalledVersion ?? "";

    debugPrint("現在のバージョン: $installedVersion");
    debugPrint("新しいバージョン: $appStoreVersion");
    debugPrint("アップデートが必要: ${widget.upgrader.shouldDisplayUpgrade()}");

    // アップデートが必要な場合のみダイアログを表示
    if (!widget.upgrader.shouldDisplayUpgrade()) {
      debugPrint("アップデート不要のため、ダイアログを表示しません");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context)!.upgradeTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(width: 2),
              const Text(
                '🎉',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                S.of(context)!.updateDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              Row(
                children: [
                  Text(
                    S.of(context)!.newFeatures,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notesList
                      .map((line) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/ic_check_circle_teal.svg',
                                width: 22,
                                height: 22,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(
                                line,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                              )),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context)!.notNow,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      )),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 36),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.upgrader.sendUserToAppStore();
                Navigator.of(context).pop();
              },
              child: Text(S.of(context)!.update,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
