import 'package:flutter/material.dart';
import 'package:mr_collection/ui/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';import 'package:flutter_gen/gen_l10n/s.dart';

class DeleteCompleteDialog extends StatelessWidget {
  const DeleteCompleteDialog({super.key});

  Future<String> _getCurrentLoginMedia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentLoginMedia') ?? '';
  }

  Future<void> _updatePrefsAfterUserDeletion() async {
    final currentLoginMedia = await _getCurrentLoginMedia();
    if (currentLoginMedia == 'line') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLineLoggedIn', false);
      await prefs.remove('lineUserId');
    } else if (currentLoginMedia == 'apple') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAppleLoggedIn', false);
      await prefs.remove('appleUserId');
    } else {
      debugPrint('ログインメディアが不明です: delete_complete_dialog.dart');
      debugPrint('currentLoginMedia: $currentLoginMedia');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 216,
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context)?.deletionComplete ?? "Deletion completed.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              width: 272,
              child: ElevatedButton(
                onPressed: () {
                  _updatePrefsAfterUserDeletion();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F2F2),
                ),
                child: Text(
                  S.of(context)?.ok ?? "OK",
                  style: GoogleFonts.notoSansJp(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
