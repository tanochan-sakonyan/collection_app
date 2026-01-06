import 'package:flutter/material.dart';

enum RoundUpOption { none, ten, fifty, hundred }

class RoundUpModule extends StatelessWidget {
  const RoundUpModule({
    super.key,
    required this.currencyUnit,
    required this.selectedOption,
    required this.onOptionChanged,
    required this.changeAmountText,
  });

  final String currencyUnit;
  final RoundUpOption selectedOption;
  final ValueChanged<RoundUpOption> onOptionChanged;
  final String changeAmountText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '端数切り上げ',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildRoundOption(context, '10$currencyUnit', RoundUpOption.ten),
              _buildRoundOption(
                  context, '50$currencyUnit', RoundUpOption.fifty),
              _buildRoundOption(
                  context, '100$currencyUnit', RoundUpOption.hundred),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'お釣り',
                style:
                    textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                '$changeAmountText$currencyUnit',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundOption(
      BuildContext context, String label, RoundUpOption option) {
    final isSelected = selectedOption == option;
    return Expanded(
      child: InkWell(
        onTap: () => onOptionChanged(option),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onOptionChanged(option),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
