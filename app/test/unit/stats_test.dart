import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/stats.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/vital_reading.dart';

VitalReading bp(double s, double d, DateTime at) =>
    VitalReading(id: '', type: VitalType.bloodPressure, systolic: s, diastolic: d, measuredAt: at, createdByUid: 'u');

VitalReading one(VitalType t, double v, DateTime at, {GlucoseContext? ctx}) =>
    VitalReading(id: '', type: t, value: v, glucoseContext: ctx, measuredAt: at, createdByUid: 'u');

void main() {
  final day = DateTime(2026, 11, 20);
  DateTime at(int d, int h) => day.add(Duration(days: d, hours: h));

  group('SeriesStats', () {
    test('mean/min/max', () {
      final s = SeriesStats.of([70, 80, 90])!;
      expect(s.count, 3);
      expect(s.mean, 80);
      expect(s.min, 70);
      expect(s.max, 90);
    });
    test('empty is null', () => expect(SeriesStats.of([]), isNull));
  });

  group('VitalStats', () {
    test('BP: averages, morning vs evening, normal share', () {
      final readings = [
        bp(120, 80, at(0, 7)), // morning, stage 1 (dia 80)
        bp(110, 70, at(0, 8)), // morning, normal
        bp(140, 90, at(0, 20)), // evening, stage 2
        bp(100, 60, at(0, 13)), // afternoon, normal
      ];
      final s = VitalStats.compute(VitalType.bloodPressure, readings);
      expect(s.count, 4);
      expect(s.bpAverage!.display, '118/75');
      expect(s.bpMorning!.display, '115/75');
      expect(s.bpMorning!.count, 2);
      expect(s.bpEvening!.display, '140/90');
      expect(s.systolic!.max, 140);
      expect(s.diastolic!.min, 60);
      expect(s.normalShare, 0.5);
    });

    test('glucose split by context', () {
      final readings = [
        one(VitalType.glucose, 95, at(0, 7), ctx: GlucoseContext.fasting),
        one(VitalType.glucose, 105, at(1, 7), ctx: GlucoseContext.beforeMeal),
        one(VitalType.glucose, 160, at(1, 14), ctx: GlucoseContext.afterMeal),
      ];
      final s = VitalStats.compute(VitalType.glucose, readings);
      expect(s.glucoseFastingOrBeforeMeal!.mean, 100);
      expect(s.glucoseAfterMealOrRandom!.mean, 160);
      expect(s.value!.count, 3);
      // 95 normal, 105 prediabetic, 160 prediabetic (after meal)
      expect(s.normalShare, closeTo(1 / 3, 1e-9));
    });

    test('pulse gets morning/evening, others do not', () {
      final p = VitalStats.compute(VitalType.pulse, [one(VitalType.pulse, 70, at(0, 7))]);
      expect(p.valueMorning!.mean, 70);
      final w = VitalStats.compute(VitalType.weight, [one(VitalType.weight, 70, at(0, 7))]);
      expect(w.valueMorning, isNull);
    });

    test('weight normal share uses BMI only when height is known', () {
      final w = [one(VitalType.weight, 70, at(0, 7))];
      expect(VitalStats.compute(VitalType.weight, w).normalShare, isNull);
      expect(VitalStats.compute(VitalType.weight, w, heightCm: 175).normalShare, 1.0);
    });

    test('ignores readings of other types', () {
      final s = VitalStats.compute(VitalType.pulse, [one(VitalType.pulse, 70, at(0, 7)), bp(120, 80, at(0, 7))]);
      expect(s.count, 1);
    });
  });

  group('HomeBpProtocol (7-day check)', () {
    final now = DateTime(2026, 11, 27, 21); // day 7 evening
    List<VitalReading> week({required double sys, required double dia, int days = 7, int perDay = 4}) => [
      for (var d = 0; d < days; d++)
        for (var i = 0; i < perDay; i++) bp(sys, dia, DateTime(2026, 11, 21 + d, i < 2 ? 7 : 19, i)),
    ];

    test('full week above 135/85, first day dropped', () {
      // Day 1 is very high and must not count.
      final readings = [
        ...week(sys: 138, dia: 86).where((r) => r.measuredAt.day != 21),
        for (var i = 0; i < 4; i++) bp(190, 110, DateTime(2026, 11, 21, 7, i)),
      ];
      final r = HomeBpProtocol.evaluate(readings, now: now) as HomeBpResult;
      expect(r.average.display, '138/86');
      expect(r.days, 6);
      expect(r.atOrAboveThreshold, isTrue);
    });

    test('below threshold', () {
      final r = HomeBpProtocol.evaluate(week(sys: 124, dia: 78), now: now) as HomeBpResult;
      expect(r.atOrAboveThreshold, isFalse);
    });

    test('diastolic alone at 85 counts', () {
      final r = HomeBpProtocol.evaluate(week(sys: 120, dia: 85), now: now) as HomeBpResult;
      expect(r.atOrAboveThreshold, isTrue);
    });

    test('too few readings or days asks for more', () {
      final few = HomeBpProtocol.evaluate(week(sys: 130, dia: 80, days: 3, perDay: 4), now: now);
      // 3 days -> day 1 dropped -> 2 days left
      expect(few, isA<HomeBpNeedsMore>());
      expect((few as HomeBpNeedsMore).days, 2);
      expect(few.readings, 8);

      final sparse = HomeBpProtocol.evaluate(week(sys: 130, dia: 80, days: 7, perDay: 1), now: now);
      expect(sparse, isA<HomeBpNeedsMore>()); // 6 readings < 12
    });

    test('readings older than 7 days are ignored', () {
      final old = [
        for (var d = 0; d < 7; d++)
          for (var i = 0; i < 4; i++) bp(150, 95, DateTime(2026, 11, 1 + d, 7, i)),
      ];
      expect(HomeBpProtocol.evaluate(old, now: now), isA<HomeBpNeedsMore>());
    });
  });
}
