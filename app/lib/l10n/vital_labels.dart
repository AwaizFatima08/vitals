import 'package:flutter/material.dart';

import '../core/vitals/reference_ranges.dart';
import '../core/vitals/validation.dart';
import '../core/vitals/vital_type.dart';
import '../models/vital_reading.dart';
import 'generated/app_localizations.dart';

/// Maps domain enums to localized text and icons, so the pure-Dart domain
/// layer never depends on Flutter or l10n.
class VitalLabels {
  VitalLabels._();

  static String name(AppLocalizations l10n, VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return l10n.vitalBloodPressure;
      case VitalType.spo2:
        return l10n.vitalSpo2;
      case VitalType.pulse:
        return l10n.vitalPulse;
      case VitalType.weight:
        return l10n.vitalWeight;
      case VitalType.glucose:
        return l10n.vitalGlucose;
    }
  }

  static IconData icon(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return Icons.bloodtype_outlined;
      case VitalType.spo2:
        return Icons.air;
      case VitalType.pulse:
        return Icons.monitor_heart_outlined;
      case VitalType.weight:
        return Icons.monitor_weight_outlined;
      case VitalType.glucose:
        return Icons.water_drop_outlined;
    }
  }

  static String glucoseContext(AppLocalizations l10n, GlucoseContext context) {
    switch (context) {
      case GlucoseContext.fasting:
        return l10n.glucoseFasting;
      case GlucoseContext.beforeMeal:
        return l10n.glucoseBeforeMeal;
      case GlucoseContext.afterMeal:
        return l10n.glucoseAfterMeal;
      case GlucoseContext.random:
        return l10n.glucoseRandom;
    }
  }

  static String range(AppLocalizations l10n, RangeCategory category) {
    switch (category) {
      case RangeCategory.bpNormal:
        return l10n.rangeBpNormal;
      case RangeCategory.bpElevated:
        return l10n.rangeBpElevated;
      case RangeCategory.bpStage1:
        return l10n.rangeBpStage1;
      case RangeCategory.bpStage2:
        return l10n.rangeBpStage2;
      case RangeCategory.bpVeryHigh:
        return l10n.rangeBpVeryHigh;
      case RangeCategory.spo2Normal:
        return l10n.rangeSpo2Normal;
      case RangeCategory.spo2Low:
        return l10n.rangeSpo2Low;
      case RangeCategory.spo2Critical:
        return l10n.rangeSpo2Critical;
      case RangeCategory.pulseLow:
        return l10n.rangePulseLow;
      case RangeCategory.pulseNormal:
        return l10n.rangePulseNormal;
      case RangeCategory.pulseHigh:
        return l10n.rangePulseHigh;
      case RangeCategory.glucoseLow:
        return l10n.rangeGlucoseLow;
      case RangeCategory.glucoseNormal:
        return l10n.rangeGlucoseNormal;
      case RangeCategory.glucosePrediabetic:
        return l10n.rangeGlucosePrediabetic;
      case RangeCategory.glucoseDiabetic:
        return l10n.rangeGlucoseDiabetic;
      case RangeCategory.bmiUnderweight:
        return l10n.rangeBmiUnderweight;
      case RangeCategory.bmiNormal:
        return l10n.rangeBmiNormal;
      case RangeCategory.bmiOverweight:
        return l10n.rangeBmiOverweight;
      case RangeCategory.bmiObese:
        return l10n.rangeBmiObese;
    }
  }

  /// The "seek care" notice for urgent results, or null.
  static String? urgentMessage(AppLocalizations l10n, RangeResult? result) {
    if (result == null || !result.urgent) return null;
    return result.category == RangeCategory.spo2Critical ? l10n.urgentSpo2 : l10n.urgentBp;
  }

  static String validation(AppLocalizations l10n, ValidationError error, VitalLimits limits, String unit) {
    switch (error) {
      case ValidationError.required:
        return l10n.validationRequired;
      case ValidationError.outOfRange:
        return l10n.validationOutOfRange(
          VitalReading.formatNumber(limits.min),
          VitalReading.formatNumber(limits.max),
          unit,
        );
      case ValidationError.diastolicNotBelowSystolic:
        return l10n.validationDiastolic;
    }
  }

  /// Keys match what Medicine Reminder writes ("other family member"
  /// included verbatim), so both apps read each other's patients cleanly.
  static const relationships = ['self', 'mother', 'father', 'spouse', 'grandparent', 'child', 'other family member'];

  static String relationship(AppLocalizations l10n, String key) {
    switch (key) {
      case 'self':
        return l10n.relSelf;
      case 'mother':
        return l10n.relMother;
      case 'father':
        return l10n.relFather;
      case 'spouse':
        return l10n.relSpouse;
      case 'grandparent':
        return l10n.relGrandparent;
      case 'child':
        return l10n.relChild;
      default:
        // "other family member", plus anything unrecognised.
        return l10n.relOther;
    }
  }
}
