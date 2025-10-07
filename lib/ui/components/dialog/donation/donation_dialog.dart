import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationDialog extends ConsumerStatefulWidget {
  const DonationDialog({super.key});
  @override
  DonationDialogState createState() => DonationDialogState();
}

class DonationDialogState extends ConsumerState<DonationDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          width: 320,
          height: 310,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              Text(
                "開発者にドリンク１杯をご馳走する",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                "「集金くん」は学生エンジニアによって\n赤字開発されています。\nよりよい機能を継続的に届けられるよう、\nご支援いただけると幸いです。",
                style: GoogleFonts.notoSansJp(
                    fontSize: 11,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                  onTap: () {
                    print("カフェモカが押されました。");
                  },
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // 角丸
                      border: Border.all(
                        color: Colors.grey.shade300, // 枠線の色
                        width: 1, // 枠線の太さ
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // 薄い影
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset("assets/icons/ic_coffee.svg",
                            width: 48),
                        const SizedBox(height: 4),
                        Text("カフェモカ",
                            style: GoogleFonts.notoSansJp(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text("120円",
                            style: GoogleFonts.notoSansJp(
                                fontSize: 10,
                                color: const Color(0xFF006956),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    print("フラッペが押されました。");
                  },
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // 角丸
                      border: Border.all(
                        color: Colors.grey.shade300, // 枠線の色
                        width: 1, // 枠線の太さ
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // 薄い影
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset("assets/icons/ic_frappe.svg",
                            width: 52),
                        const SizedBox(height: 4),
                        Text("抹茶フラッペ",
                            style: GoogleFonts.notoSansJp(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text("550円",
                            style: GoogleFonts.notoSansJp(
                                fontSize: 10,
                                color: const Color(0xFF006956),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    print("スイーツセットが押されました。");
                  },
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // 角丸
                      border: Border.all(
                        color: Colors.grey.shade300, // 枠線の色
                        width: 1, // 枠線の太さ
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // 薄い影
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset("assets/icons/ic_sweets.svg",
                            width: 58),
                        const SizedBox(height: 4),
                        Text("スイーツセット",
                            style: GoogleFonts.notoSansJp(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text("1200円",
                            style: GoogleFonts.notoSansJp(
                                fontSize: 10,
                                color: const Color(0xFF006956),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
