import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasTabs;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onSharePressed;
  final VoidCallback onHelpPressed;
  final VoidCallback onSettingsPressed;
  final Widget tabBar;

  const HomeAppBar({
    super.key,
    required this.hasTabs,
    required this.screenWidth,
    required this.screenHeight,
    required this.onSharePressed,
    required this.onHelpPressed,
    required this.onSettingsPressed,
    required this.tabBar,
  });

  @override
  // AppBarのサイズを返す。
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + screenHeight * 0.04,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        Row(
          children: [
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              icon: _buildShareIcon(context),
              onPressed: onSharePressed,
            ),
            hasTabs
                ? IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onPressed: onHelpPressed,
                    icon: SvgPicture.asset(
                      'assets/icons/ic_question_circle.svg',
                      width: 36,
                      height: 36,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : const SizedBox(width: 24),
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              icon: SvgPicture.asset(
                'assets/icons/ic_settings.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onSettingsPressed,
            ),
            SizedBox(width: screenWidth * 0.04),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.04),
        child: Stack(
          children: [
            SizedBox(
              height: screenHeight * 0.04,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: screenHeight * 0.04,
                        child: tabBar,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 共有アイコン(iOSとAndroidでボタンが違う)
  Widget _buildShareIcon(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    if (Platform.isAndroid) {
      return SvgPicture.asset(
        'assets/icons/ic_share_android.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          primaryColor,
          BlendMode.srcIn,
        ),
      );
    }

    return Icon(
      CupertinoIcons.share,
      size: 28,
      color: primaryColor,
    );
  }
}
