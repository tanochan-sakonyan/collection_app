import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

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
        height: 352,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 48,
            left: 42,
            right: 42,
            bottom: 40,
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
                label: S.of(context)?.status_paid ?? "Paid",
                icon: Icons.check,
                iconColor: const Color(0xFF35C759),
                status: 1,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              _buildStatusButton(
                context,
                label: S.of(context)?.status_unpaid ?? "Unpaid",
                icon: Icons.close,
                iconColor: Colors.red,
                status: 2,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              _buildStatusButton(
                context,
                label: S.of(context)?.status_absence ?? "Absence",
                icon: Icons.remove,
                iconColor: const Color(0xFFC0C0C0),
                status: 3,
                labelStyle: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
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
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(label, style: const TextStyle(fontSize: 16))],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Icon(icon, color: iconColor)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
