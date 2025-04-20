// lib/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/components/dialog/delete_account_dialog.dart';
import 'package:mr_collection/ui/components/dialog/logout_dialog.dart';
import 'package:mr_collection/ui/screen/privacy_policy_screen.dart';
import 'package:mr_collection/ui/screen/terms_of_service_screen.dart';

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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                // showDialog(
                //   context: context,
                //   builder: (context) => PayPayDialog(),
                // );
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 56.0, horizontal: 24.0),
                    content: Text(
                      'LINEへの認証申請中のため、\n機能解禁までしばらくお待ちください',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
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
              text: "プライバシーポリシー",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()),
                );
              },
              icon: SvgPicture.asset("assets/icons/drawer_file.svg"),
            ),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, child) {
              final user = ref.watch(userProvider);
              return _buildMenuItem(
                context,
                text: "アカウントの削除",
                onTap: () {
                  if (user != null) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            DeleteAccountDialog(userId: user.userId));
                  }
                },
                icon:
                    SvgPicture.asset("assets/icons/drawer_delete_account.svg"),
              );
            }),
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
