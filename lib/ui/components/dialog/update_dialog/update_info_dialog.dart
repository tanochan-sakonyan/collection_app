import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mr_collection/generated/s.dart';

class UpdateInfoDialog extends StatelessWidget {
  const UpdateInfoDialog(
      {super.key,
      required this.version,
      required this.first,
      required this.second,
      required this.third});

  final String version;
  final String first;
  final String? second;
  final String? third;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          right: 16,
          left: 16,
        ),
        child: Column(
          children: [
            Text(
              S.of(context)!.updateAnnouncement,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text("Ver.$version",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              width: 140,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: SvgPicture.asset(
                      'assets/icons/reverse_icon.svg',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      theme: SvgTheme(
                        currentColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 4,
                    bottom: 8,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Positioned(
                    right: 4,
                    top: 8,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/icons/ic_check_circle.svg',
                      width: 24,
                      height: 24,
                      theme: SvgTheme(
                        currentColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      first,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                (second != null)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/icons/ic_check_circle.svg',
                            width: 24,
                            height: 24,
                            theme: SvgTheme(
                              currentColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            second!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 20),
                const SizedBox(height: 8),
                (third != null)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/icons/ic_check_circle.svg',
                            width: 24,
                            height: 24,
                            theme: SvgTheme(
                              currentColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            third!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context)!.updateFeedbackMessage,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
