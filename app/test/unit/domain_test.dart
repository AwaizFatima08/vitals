import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/bmi.dart';
import 'package:livehealthy_vitals/core/vitals/reference_ranges.dart';
import 'package:livehealthy_vitals/core/vitals/validation.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/vital_reading.dart';
import 'package:livehealthy_vitals/models/vital_reminder.dart';
import 'package:livehealthy_vitals/services/notification_service.dart';
import 'package:livehealthy_vitals/widgets/numeric_keypad.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('Bmi', () {
    test('computes weight / height²', () {
      expect(Bmi.calculate(weightKg: 70, heightCm: 175), closeTo(22.86, 0.01));
      expect(Bmi.format(Bmi.calculate(weightKg: 70, heightCm: 175)!), '22.9');
    });

    test('null when an input is missing or nonsense', () {
      expect(Bmi.calculate(weightKg: null, heightCm: 170), isNull);
      expect(Bmi.calculate(weightKg: 70, heightCm: null), isNull);
      expect(Bmi.calculate(weightKg: 70, heightCm: 0), isNull);
      expect(Bmi.calculate(weightKg: -1, heightCm: 170), isNull);
    });
  });

  group('VitalValidation', () {
    test('parse', () {
      expect(VitalValidation.parse(''), isNull);
      expect(VitalValidation.parse('.'), isNull);
      expect(VitalValidation.parse('72.'), 72);
      expect(VitalValidation.parse('72.4'), 72.4);
    });

    test('single values: required and plausibility bounds', () {
      expect(VitalValidation.validateSingle(VitalType.pulse, ''), ValidationError.required);
      expect(VitalValidation.validateSingle(VitalType.pulse, '72'), isNull);
      expect(VitalValidation.validateSingle(VitalType.pulse, '1200'), ValidationError.outOfRange);
      expect(VitalValidation.validateSingle(VitalType.spo2, '101'), ValidationError.outOfRange);
      expect(VitalValidation.validateSingle(VitalType.spo2, '100'), isNull);
      expect(VitalValidation.validateSingle(VitalType.glucose, '9'), ValidationError.outOfRange);
      expect(VitalValidation.validateSingle(VitalType.weight, '0.5'), ValidationError.outOfRange);
    });

    test('blood pressure: diastolic must be below systolic', () {
      expect(VitalValidation.validateSystolic('120'), isNull);
      expect(VitalValidation.validateSystolic('12'), ValidationError.outOfRange);
      expect(VitalValidation.validateDiastolic('80', '120'), isNull);
      expect(VitalValidation.validateDiastolic('120', '120'), ValidationError.diastolicNotBelowSystolic);
      expect(VitalValidation.validateDiastolic('', '120'), ValidationError.required);
      // Out-of-range wins over the ordering check.
      expect(VitalValidation.validateDiastolic('250', '120'), ValidationError.outOfRange);
    });

    test('height', () {
      expect(VitalValidation.validateHeight('170'), isNull);
      expect(VitalValidation.validateHeight('17'), ValidationError.outOfRange);
    });
  });

  group('KeypadInput', () {
    String type(String keys, {bool decimal = false, int max = 3}) {
      var s = '';
      for (final k in keys.split('')) {
        s = KeypadInput.apply(s, k, allowDecimal: decimal, maxDigits: max);
      }
      return s;
    }

    test('appends digits up to maxDigits', () {
      expect(type('128'), '128');
      expect(type('1289'), '128');
      expect(type('1000', max: 4), '1000');
    });

    test('no leading zeros', () => expect(type('072'), '72'));

    test('decimal only when allowed, once, one place', () {
      expect(type('72.4', decimal: false), '724');
      expect(type('72.45', decimal: true), '72.4');
      expect(type('7..2', decimal: true), '7.2');
      expect(type('.5', decimal: true), '0.5');
    });

    test('backspace', () {
      expect(KeypadInput.backspace('128'), '12');
      expect(KeypadInput.backspace(''), '');
    });
  });

  group('VitalReading', () {
    final t = DateTime(2026, 9, 25, 8, 30);

    test('display values', () {
      expect(
        VitalReading(
          id: 'a',
          type: VitalType.bloodPressure,
          systolic: 128,
          diastolic: 82,
          measuredAt: t,
          createdByUid: 'u',
        ).displayValue,
        '128/82',
      );
      expect(
        VitalReading(id: 'a', type: VitalType.weight, value: 72.4, measuredAt: t, createdByUid: 'u').displayValue,
        '72.4',
      );
      expect(
        VitalReading(id: 'a', type: VitalType.pulse, value: 72, measuredAt: t, createdByUid: 'u').displayValue,
        '72',
      );
    });

    test('toMap stores only the fields for its type', () {
      final bp = VitalReading(
        id: '',
        type: VitalType.bloodPressure,
        systolic: 128,
        diastolic: 82,
        measuredAt: t,
        createdByUid: 'u',
      ).toMap();
      expect(bp.containsKey('value'), isFalse);
      expect(bp['type'], 'bloodPressure');
      final g = VitalReading(
        id: '',
        type: VitalType.glucose,
        value: 104,
        glucoseContext: GlucoseContext.fasting,
        measuredAt: t,
        createdByUid: 'u',
      ).toMap();
      expect(g['glucoseContext'], 'fasting');
      expect(g.containsKey('systolic'), isFalse);
    });

    test('weight has no own flag but flags its BMI', () {
      final w = VitalReading(id: 'a', type: VitalType.weight, value: 90, measuredAt: t, createdByUid: 'u');
      expect(w.range, isNull);
      expect(w.bmiRange(null), isNull);
      expect(w.bmiRange(170)!.category, RangeCategory.bmiObese); // 31.1
      expect(w.bmi(170), closeTo(31.14, 0.01));
    });

    test('incomplete readings are detected', () {
      expect(
        VitalReading(id: 'a', type: VitalType.glucose, value: 100, measuredAt: t, createdByUid: 'u').isComplete,
        isFalse,
      );
      expect(
        VitalReading(
          id: 'a',
          type: VitalType.bloodPressure,
          systolic: 120,
          measuredAt: t,
          createdByUid: 'u',
        ).isComplete,
        isFalse,
      );
    });
  });

  group('VitalReminder', () {
    test('round-trips and rejects bad data', () {
      const r = VitalReminder(patientId: 'p1', type: VitalType.glucose, enabled: true, hour: 7, minute: 30);
      final back = VitalReminder.fromMap(r.toMap())!;
      expect(back.docId, 'p1_glucose');
      expect(back.enabled, isTrue);
      expect(back.hour, 7);
      expect(VitalReminder.fromMap({...r.toMap(), 'hour': 25}), isNull);
      expect(VitalReminder.fromMap({...r.toMap(), 'type': 'mood'}), isNull);
    });

    test('defaults are morning times', () {
      expect(VitalReminder.defaultTimeFor(VitalType.glucose).hour, 7);
      expect(VitalReminder.defaultTimeFor(VitalType.bloodPressure).hour, 9);
    });
  });

  group('notifications', () {
    test('payload encode/decode', () {
      const p = ReminderPayload(patientId: 'p1', type: VitalType.bloodPressure);
      final decoded = ReminderPayload.decode(p.encode())!;
      expect(decoded.patientId, 'p1');
      expect(decoded.type, VitalType.bloodPressure);
      expect(ReminderPayload.decode('garbage'), isNull);
      expect(ReminderPayload.decode('p1|mood'), isNull);
      expect(ReminderPayload.decode(null), isNull);
    });

    test('notification ids are stable and distinct per patient+vital', () {
      final a = ScheduledReminder.notificationIdFor('p1', VitalType.pulse);
      expect(ScheduledReminder.notificationIdFor('p1', VitalType.pulse), a);
      expect(ScheduledReminder.notificationIdFor('p1', VitalType.spo2), isNot(a));
      expect(ScheduledReminder.notificationIdFor('p2', VitalType.pulse), isNot(a));
      expect(a, greaterThanOrEqualTo(0));
    });

    test('nextInstanceOf: later today, else tomorrow', () {
      tzdata.initializeTimeZones();
      final loc = tz.getLocation('Asia/Karachi');
      final now = tz.TZDateTime(loc, 2026, 9, 25, 8, 0);
      expect(NotificationService.nextInstanceOf(9, 0, now), tz.TZDateTime(loc, 2026, 9, 25, 9, 0));
      expect(NotificationService.nextInstanceOf(7, 0, now), tz.TZDateTime(loc, 2026, 9, 26, 7, 0));
      expect(NotificationService.nextInstanceOf(8, 0, now), tz.TZDateTime(loc, 2026, 9, 26, 8, 0));
    });
  });
}
