// lib/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/components/dialog/confirmation_dialog.dart';
import 'package:mr_collection/components/dialog/logout_dialog.dart';
import 'package:mr_collection/components/dialog/paypay_dialog.dart';
import 'package:mr_collection/screen/privacy_policy_screen.dart';
import 'package:mr_collection/screen/terms_of_service_screen.dart';

class TanochanDrawer extends StatelessWidget {
  const TanochanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F2),
      width: MediaQuery.of(context).size.width * 0.71,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text(
              "設定",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context,
              text: "PayPay連携",
              icon: SvgPicture.asset("assets/icons/drawer_yen.svg"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => PayPayDialog(),
                );
              },
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
            const SizedBox(height: 20),
            _buildMenuItem(
              context,
              text: "ログアウト",
              icon: SvgPicture.asset("assets/icons/drawer_key.svg"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => const LogoutDialog());
              },
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context,
              text: "利用規約",
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
              text: "プライパシーポリシー",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()),
                );
              },
              icon: SvgPicture.asset("assets/icons/drawer_file.svg"),
            ),
            const SizedBox(height: 100),
          ],
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
