import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationThanksDialog extends StatelessWidget {
  const DonationThanksDialog({
    super.key,
    required this.title,
    required this.messageLines,
    required this.assetPath,
    required this.assetWidth,
  });

  final String title;
  final List<String> messageLines;
  final String assetPath;
  final double assetWidth;

  static const _cardColor = Color(0xFFF6F6F8);
  static const _sparkleColor = Color(0xFFFFC94B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              messageLines.join('\n'),
              style: GoogleFonts.notoSansJp(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: assetWidth + 80,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    bottom: 16,
                    left: 12,
                    child: _SparkleIcon(size: 20, color: _sparkleColor),
                  ),
                  const Positioned(
                    top: 12,
                    right: 18,
                    child: _SparkleIcon(size: 24, color: _sparkleColor),
                  ),
                  const Positioned(
                    bottom: 8,
                    right: 40,
                    child: _SparkleIcon(size: 16, color: _sparkleColor),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: assetWidth + 16),
                    child: SvgPicture.asset(
                      assetPath,
                      width: assetWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: color,
    );
  }
}
