import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/vitals/reference_ranges.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/vital_labels.dart';

/// Colour dot + text label for a reference-range result. The text is always
/// shown so colour is never the only signal (colour-blind users, greyscale
/// screens).
class FlagChip extends StatelessWidget {
  final RangeResult result;
  final bool dense;

  const FlagChip({super.key, required this.result, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = AppTheme.flagColor(result.level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(result.level), size: dense ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              VitalLabels.range(l10n, result.category),
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: dense ? 12 : 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(FlagLevel level) {
    switch (level) {
      case FlagLevel.normal:
        return Icons.check_circle;
      case FlagLevel.caution:
        return Icons.error;
      case FlagLevel.alert:
        return Icons.warning_rounded;
    }
  }
}

/// The "seek medical care" box shown for very high BP / critically low SpO2.
class UrgentNotice extends StatelessWidget {
  final String message;

  const UrgentNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.flagAlert.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.flagAlert),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_hospital, color: AppTheme.flagAlert),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppTheme.flagAlert)),
          ),
        ],
      ),
    );
  }
}

/// Informational-only disclaimer (design doc §4: no clinical claims).
class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.disclaimerShort,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
