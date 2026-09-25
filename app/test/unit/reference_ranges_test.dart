// Boundary tests for every threshold in design doc §6 (locked values).
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/reference_ranges.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';

void main() {
  group('blood pressure (higher category of the two numbers wins)', () {
    RangeCategory c(num s, num d) => ReferenceRanges.bloodPressure(s, d).category;

    test('normal: below 120 / below 80', () {
      expect(c(119, 79), RangeCategory.bpNormal);
      expect(c(100, 65), RangeCategory.bpNormal);
    });

    test('elevated: 120–129 / below 80', () {
      expect(c(120, 79), RangeCategory.bpElevated);
      expect(c(129, 70), RangeCategory.bpElevated);
    });

    test('stage 1: 130–139 or 80–89', () {
      expect(c(130, 70), RangeCategory.bpStage1);
      expect(c(139, 89), RangeCategory.bpStage1);
      expect(c(115, 80), RangeCategory.bpStage1, reason: 'diastolic alone can raise the category');
      expect(c(125, 85), RangeCategory.bpStage1);
    });

    test('stage 2: 140+ or 90+', () {
      expect(c(140, 70), RangeCategory.bpStage2);
      expect(c(120, 90), RangeCategory.bpStage2);
      expect(c(180, 120), RangeCategory.bpStage2, reason: 'exactly 180/120 is not yet "above"');
    });

    test('very high: above 180 or above 120, flagged urgent', () {
      final r1 = ReferenceRanges.bloodPressure(181, 100);
      final r2 = ReferenceRanges.bloodPressure(150, 121);
      expect(r1.category, RangeCategory.bpVeryHigh);
      expect(r2.category, RangeCategory.bpVeryHigh);
      expect(r1.urgent, isTrue);
      expect(r1.level, FlagLevel.alert);
    });

    test('colour levels', () {
      expect(ReferenceRanges.bloodPressure(110, 70).level, FlagLevel.normal);
      expect(ReferenceRanges.bloodPressure(125, 70).level, FlagLevel.caution);
      expect(ReferenceRanges.bloodPressure(135, 85).level, FlagLevel.caution);
      expect(ReferenceRanges.bloodPressure(145, 95).level, FlagLevel.alert);
      expect(ReferenceRanges.bloodPressure(145, 95).urgent, isFalse);
    });
  });

  group('SpO2', () {
    test('normal 95–100', () {
      expect(ReferenceRanges.spo2(95).category, RangeCategory.spo2Normal);
      expect(ReferenceRanges.spo2(100).category, RangeCategory.spo2Normal);
    });
    test('low 90–94', () {
      expect(ReferenceRanges.spo2(94).category, RangeCategory.spo2Low);
      expect(ReferenceRanges.spo2(90).category, RangeCategory.spo2Low);
      expect(ReferenceRanges.spo2(92).level, FlagLevel.caution);
    });
    test('critical below 90, urgent', () {
      final r = ReferenceRanges.spo2(89);
      expect(r.category, RangeCategory.spo2Critical);
      expect(r.level, FlagLevel.alert);
      expect(r.urgent, isTrue);
    });
  });

  group('pulse', () {
    test('low below 60', () => expect(ReferenceRanges.pulse(59).category, RangeCategory.pulseLow));
    test('normal 60–100', () {
      expect(ReferenceRanges.pulse(60).category, RangeCategory.pulseNormal);
      expect(ReferenceRanges.pulse(100).category, RangeCategory.pulseNormal);
      expect(ReferenceRanges.pulse(72).level, FlagLevel.normal);
    });
    test('high above 100', () => expect(ReferenceRanges.pulse(101).category, RangeCategory.pulseHigh));
  });

  group('glucose — fasting / before meal', () {
    for (final ctx in [GlucoseContext.fasting, GlucoseContext.beforeMeal]) {
      test('${ctx.key}: low <70, normal 70–99, prediabetic 100–125, diabetic 126+', () {
        expect(ReferenceRanges.glucose(69, ctx).category, RangeCategory.glucoseLow);
        expect(ReferenceRanges.glucose(70, ctx).category, RangeCategory.glucoseNormal);
        expect(ReferenceRanges.glucose(99, ctx).category, RangeCategory.glucoseNormal);
        expect(ReferenceRanges.glucose(100, ctx).category, RangeCategory.glucosePrediabetic);
        expect(ReferenceRanges.glucose(125, ctx).category, RangeCategory.glucosePrediabetic);
        expect(ReferenceRanges.glucose(126, ctx).category, RangeCategory.glucoseDiabetic);
      });
    }
  });

  group('glucose — after meal / random', () {
    for (final ctx in [GlucoseContext.afterMeal, GlucoseContext.random]) {
      test('${ctx.key}: low <70, normal <140, prediabetic 140–199, diabetic 200+', () {
        expect(ReferenceRanges.glucose(69, ctx).category, RangeCategory.glucoseLow);
        expect(ReferenceRanges.glucose(139, ctx).category, RangeCategory.glucoseNormal);
        expect(ReferenceRanges.glucose(140, ctx).category, RangeCategory.glucosePrediabetic);
        expect(ReferenceRanges.glucose(199, ctx).category, RangeCategory.glucosePrediabetic);
        expect(ReferenceRanges.glucose(200, ctx).category, RangeCategory.glucoseDiabetic);
      });
    }

    test('same number flags differently depending on context', () {
      expect(ReferenceRanges.glucose(120, GlucoseContext.fasting).category, RangeCategory.glucosePrediabetic);
      expect(ReferenceRanges.glucose(120, GlucoseContext.afterMeal).category, RangeCategory.glucoseNormal);
    });

    test('low glucose is an alert (red), not a caution', () {
      expect(ReferenceRanges.glucose(60, GlucoseContext.random).level, FlagLevel.alert);
    });
  });

  group('BMI', () {
    test('underweight <18.5', () => expect(ReferenceRanges.bmi(18.4).category, RangeCategory.bmiUnderweight));
    test('normal 18.5–24.9', () {
      expect(ReferenceRanges.bmi(18.5).category, RangeCategory.bmiNormal);
      expect(ReferenceRanges.bmi(24.9).category, RangeCategory.bmiNormal);
    });
    test('overweight 25–29.9', () {
      expect(ReferenceRanges.bmi(25).category, RangeCategory.bmiOverweight);
      expect(ReferenceRanges.bmi(29.9).category, RangeCategory.bmiOverweight);
    });
    test('obese 30+', () => expect(ReferenceRanges.bmi(30).category, RangeCategory.bmiObese));
  });
}
