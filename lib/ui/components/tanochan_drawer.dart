// lib/custom_drawer.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/auth/delete_account_dialog.dart';
import 'package:mr_collection/ui/components/dialog/auth/logout_dialog.dart';
import 'package:mr_collection/ui/components/dialog/paypay_dialog.dart';
import 'package:mr_collection/ui/components/dialog/questionnaire_dialog.dart';
import 'package:mr_collection/ui/components/dialog/update_dialog/update_info_and_suggest_official_line_dialog.dart';
import 'package:mr_collection/ui/screen/privacy_policy_screen.dart';
import 'package:mr_collection/ui/screen/terms_of_service_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mr_collection/generated/s.dart';

class TanochanDrawer extends StatefulWidget {
  const TanochanDrawer({super.key});

  @override
  TanochanDrawerState createState() => TanochanDrawerState();
}

class TanochanDrawerState extends State<TanochanDrawer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      glassContainsChild: false,
      settings: const LiquidGlassSettings(
        blur: 5, // 背景をしっかりぼかす
        glassColor: Color(0x2DFFFFFF), // ガラスの色味
        lightAngle: 0.25 * pi, // 光を斜め45度からあてる
        lightIntensity: 20, // 光を少し強めにする
        thickness: 60, // ガラスの縁を太くする
        saturation: 0.9, // 背景の彩度を抑える
        lightness: 1.05, // 背景をわずかに明るく
      ),
      shape: const LiquidRoundedSuperellipse(
        borderRadius: Radius.circular(20),
      ),
      child: Drawer(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.71,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/icons/icon.png',
                    width: 33,
                    height: 33,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    S.of(context)!.shukinkun,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                color: Colors.black,
                thickness: 1,
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                text: S.of(context)!.paypay,
                icon: SvgPicture.asset("assets/icons/drawer_yen.svg"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const PayPayDialog(),
                  );
                },
              ),
              const SizedBox(height: 14),
              const Divider(
                indent: 20,
                color: Colors.grey,
                thickness: 1,
              ),
              // const SizedBox(height: 20),
              // _buildMenuItem(
              //   context,
              //   text: "テーマカラーの変更",
              //   icon: SvgPicture.asset("assets/icons/drawer_star.svg"),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const TermsOfServiceScreen()),
              //     );
              //   },
              // ),
              const SizedBox(height: 14),
              _buildMenuItem(
                context,
                text: S.of(context)!.questionnaire,
                icon: SvgPicture.asset("assets/icons/drawer_envelope.svg"),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const QuestionnaireDialog();
                      });
                },
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                text: S.of(context)!.logout,
                icon: SvgPicture.asset("assets/icons/drawer_key.svg"),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => const LogoutDialog());
                },
              ),
              const SizedBox(height: 14),
              const Divider(
                indent: 20,
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 14),
              _buildMenuItem(
                context,
                text: S.of(context)!.xLink,
                icon: SvgPicture.asset("assets/icons/drawer_x.svg"),
                onTap: () async {
                  const url = "https://x.com/shukinkun";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context)!.officialSite)),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                text: S.of(context)!.officialSite,
                icon: SvgPicture.asset("assets/icons/drawer_monitor.svg"),
                onTap: () async {
                  const url = "https://tanochan.studio.site/";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context)!.officialSite)),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                text: S.of(context)!.updateInformation,
                icon: SvgPicture.asset("assets/icons/drawer_megaphone.svg"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => UpdateInfoAndSuggestOfficialLineDialog(
                      vsync: this,
                      onPageChanged: (i) {},
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              const Divider(
                indent: 20,
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 14),
              _buildMenuItem(
                context,
                text: S.of(context)!.termsOfService,
                icon: SvgPicture.asset("assets/icons/drawer_file.svg"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                text: S.of(context)!.privacyPolicy,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen()),
                  );
                },
                icon: SvgPicture.asset("assets/icons/drawer_file.svg"),
              ),
              const SizedBox(height: 14),
              const Divider(
                indent: 20,
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 14),
              Consumer(builder: (context, ref, child) {
                final user = ref.watch(userProvider);
                return _buildMenuItem(
                  context,
                  text: S.of(context)!.deleteAccount,
                  onTap: () {
                    if (user != null) {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              DeleteAccountDialog(userId: user.userId));
                    }
                  },
                  icon: SvgPicture.asset(
                      "assets/icons/drawer_delete_account.svg"),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required String text,
      required Widget icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
