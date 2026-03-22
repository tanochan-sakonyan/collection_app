import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/logging/analytics_ui_logger.dart';
import 'package:mr_collection/provider/theme_color_provider.dart';
import 'package:mr_collection/theme/theme_color.dart';

class ThemeColorDialog extends ConsumerWidget {
  const ThemeColorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = ref.watch(themeColorProvider);

    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    S.of(context)!.close,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context)!.themeColor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: ThemeColorOption.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = ThemeColorOption.values[index];
                    final isSelected = option.keyName == selectedColor.keyName;
                    return _ThemeColorTile(
                      option: option,
                      selected: isSelected,
                      onTap: () async {
                        await AnalyticsUiLogger.logThemeColorSelected(
                          colorKey: option.keyName,
                        );
                        await ref
                            .read(themeColorProvider.notifier)
                            .updateThemeColor(option);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeColorTile extends StatelessWidget {
  final ThemeColorOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeColorTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  // keyNameからローカライズされた表示名を返す
  String _localizedDisplayName(BuildContext context) {
    switch (option.keyName) {
      case 'default':
        return S.of(context)!.themeColorDefault;
      case 'sakura':
        return S.of(context)!.themeColorSakura;
      case 'ajisai':
        return S.of(context)!.themeColorAjisai;
      case 'ichou':
        return S.of(context)!.themeColorIchou;
      default:
        return option.displayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: selected ? Border.all(color: primaryColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _localizedDisplayName(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
