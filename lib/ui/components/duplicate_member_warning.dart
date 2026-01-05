import 'package:flutter/material.dart';
import 'package:mr_collection/generated/s.dart';

class DuplicateMemberWarning extends StatelessWidget {
  const DuplicateMemberWarning({
    super.key,
    required this.duplicateNames,
  });

  final List<String> duplicateNames;

  @override
  Widget build(BuildContext context) {
    final warningText =
        S.of(context)!.duplicateMemberWarningMessage(duplicateNames.join(', '));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFC58F)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF8A00),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.duplicateMemberWarningTitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    warningText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
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
