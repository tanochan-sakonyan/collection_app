import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class InviteOfficialAccountToLineGroupDialog extends StatelessWidget {
  const InviteOfficialAccountToLineGroupDialog({super.key});

  Future<void> _launchLine() async {
    final uri = Uri.parse('https://lin.ee/cLwUgQtP');
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('LINE を起動できませんでした');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              S.of(context)!.inviteOfficialAccountTitle ??
                  "Invite the official LINE account to the group",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context)!.inviteOfficialAccountDesc1 ??
                  "You can only get members from LINE groups where 'Shukin-kun' is invited.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF6A6A6A),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 36),
            IconButton(
                onPressed: () {
                  _launchLine();
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: SvgPicture.asset(
                  'assets/icons/suggest_official_line.svg',
                  width: 180,
                  height: 56,
                )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/icons/icon.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Row(children: [
                      Image.asset(
                        'assets/icons/line_official_badge.png',
                        width: 12,
                        height: 12,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        S.of(context)!.shukinkun ?? "Shukinkun",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(width: 18),
                SvgPicture.asset(
                  'assets/icons/ic_arrow_right.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 18),
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_default_group.svg',
                      width: 44,
                      height: 44,
                    ),
                    Text(
                      S.of(context)!.group ?? "Group",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
