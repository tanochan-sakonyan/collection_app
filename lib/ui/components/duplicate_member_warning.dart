import 'package:flutter/material.dart';
import 'package:mr_collection/generated/s.dart';

class DuplicateMemberWarning extends StatelessWidget {
  const DuplicateMemberWarning({
    super.key,
    required this.duplicateNames,
    required this.onClose,
  });

  final List<String> duplicateNames;
  final VoidCallback onClose;

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
          border: Border.all(color: const Color.fromARGB(255, 211, 89, 41)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color.fromARGB(255, 211, 89, 41),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context)!.duplicateMemberWarningTitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                    ],
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
            IconButton(
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.close,
                size: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
