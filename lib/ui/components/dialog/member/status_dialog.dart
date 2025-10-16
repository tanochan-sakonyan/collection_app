import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/ui/components/dialog/guide/paypay_status_explanation_dialog.dart';

class StatusDialog extends StatelessWidget {
  final String userId;
  final String eventId;
  final String memberId;
  final String member;
  final Function(String, String, String, int) onStatusChange;

  const StatusDialog({
    super.key,
    required this.userId,
    required this.eventId,
    required this.memberId,
    required this.member,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 280,
        height: 420,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 32,
            left: 42,
            right: 42,
            bottom: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 20),
              _buildStatusButton(
                context,
                label: S.of(context)!.status_paid,
                trailingIcon: const Icon(
                  Icons.check,
                  color: Color(0xFF35C759),
                ),
                status: 1,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusButton(
                context,
                label: S.of(context)!.status_paypay,
                trailingIcon: const Image(
                  image: AssetImage('assets/icons/ic_paypay.png'),
                  width: 24,
                  height: 24,
                ),
                status: 4,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusButton(
                context,
                label: S.of(context)!.status_unpaid,
                trailingIcon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                status: 2,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusButton(
                context,
                label: S.of(context)!.status_absence,
                trailingIcon: const Icon(
                  Icons.remove,
                  color: Color(0xFFC0C0C0),
                ),
                status: 3,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => const PayPayStatusExplanationDialog());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/question_circle.svg",
                      width: 20,
                      height: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text("PayPayで支払い済みとは？",
                        style: GoogleFonts.notoSansJp(fontSize: 10))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required String label,
    required Widget trailingIcon,
    required int status,
    TextStyle? labelStyle,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        debugPrint('eventId: $eventId, memberId: $memberId, status: $status');
        await onStatusChange(userId, eventId, memberId, status);
      },
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF2F2F2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: labelStyle ??
                          const TextStyle(fontSize: 16, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
