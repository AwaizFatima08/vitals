import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/patient.dart';
import 'package:livehealthy_vitals/models/vital_reading.dart';
import 'package:livehealthy_vitals/services/report_service.dart';
import 'package:pdf/widgets.dart' as pw;

Patient patient(String name, {double? height}) => Patient(
  id: 'p1',
  name: name,
  ownerUid: 'u',
  memberUids: const ['u'],
  photoUrl: null,
  relationship: 'self',
  heightCm: height,
  createdAt: null,
);

VitalReading bp(double s, double d, DateTime at, {String note = ''}) => VitalReading(
  id: '',
  type: VitalType.bloodPressure,
  systolic: s,
  diastolic: d,
  measuredAt: at,
  note: note,
  createdByUid: 'u',
);

VitalReading one(VitalType t, double v, DateTime at, {GlucoseContext? ctx, String note = ''}) =>
    VitalReading(id: '', type: t, value: v, glucoseContext: ctx, measuredAt: at, note: note, createdByUid: 'u');

ReportData sample({String name = 'Ammi', double? height = 158}) {
  final from = DateTime(2026, 10, 26);
  final readings = <VitalType, List<VitalReading>>{
    VitalType.bloodPressure: [
      for (var d = 0; d < 30; d++) ...[
        bp(128 + d % 9.0, 82 + d % 5.0, from.add(Duration(days: d, hours: 7))),
        bp(134 + d % 7.0, 86 + d % 4.0, from.add(Duration(days: d, hours: 20)), note: d == 3 ? 'felt dizzy' : ''),
      ],
    ],
    VitalType.glucose: [
      one(VitalType.glucose, 104, from.add(const Duration(days: 1, hours: 7)), ctx: GlucoseContext.fasting),
      one(VitalType.glucose, 165, from.add(const Duration(days: 1, hours: 14)), ctx: GlucoseContext.afterMeal),
    ],
    VitalType.weight: [one(VitalType.weight, 63.4, from.add(const Duration(days: 2, hours: 8)))],
    VitalType.spo2: [one(VitalType.spo2, 97, from.add(const Duration(days: 2, hours: 8)))],
    VitalType.pulse: [one(VitalType.pulse, 72, from.add(const Duration(days: 2, hours: 8)))],
  };
  return ReportData(
    patient: patient(name, height: height),
    from: from,
    to: DateTime(2026, 11, 24, 21),
    readings: readings,
  );
}

Future<(pw.Font, pw.Font)> fonts() async {
  pw.Font load(String f) => pw.Font.ttf(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync()));
  return (load('DejaVuSans.ttf'), load('DejaVuSans-Bold.ttf'));
}

void main() {
  group('CSV', () {
    test('header, BOM, one row per reading, English labels', () {
      final csv = ReportBuilder.csv(sample());
      expect(csv.startsWith('﻿'), isTrue);
      final lines = csv.substring(1).trim().split('\r\n');
      expect(lines.first, startsWith('Patient,Vital,Measured at,Systolic,Diastolic,Value,Unit'));
      expect(lines.length, 1 + 60 + 2 + 1 + 1 + 1);
      expect(csv, contains('Ammi,Blood pressure,2026-10-26 07:00,128,82,,mmHg,,High (Stage 1)'));
      expect(csv, contains('Ammi,Blood glucose,2026-10-27 07:00,,,104,mg/dL,Fasting,Prediabetic range'));
      expect(csv, contains(',Weight,2026-10-28 08:00,,,63.4,kg,,Overweight,25.4,'));
    });

    test('quotes commas/quotes and neutralises spreadsheet formulas in notes', () {
      final data = ReportData(
        patient: patient('Khan, A.'),
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 2),
        readings: {
          VitalType.pulse: [
            one(VitalType.pulse, 70, DateTime(2026, 11, 1, 8), note: 'said "fine", ok'),
            one(VitalType.pulse, 71, DateTime(2026, 11, 1, 9), note: '=HYPERLINK("x")'),
          ],
        },
      );
      final csv = ReportBuilder.csv(data);
      expect(csv, contains('"Khan, A."'));
      expect(csv, contains('"said ""fine"", ok"'));
      expect(csv, contains('"\'=HYPERLINK(""x"")"'));
      expect(csv, isNot(contains(',=HYPERLINK')));
    });
  });

  group('PDF', () {
    test('builds a valid multi-section PDF', () async {
      final (regular, bold) = await fonts();
      final bytes = await ReportBuilder.pdf(sample(), regular: regular, bold: bold);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(10000));
      // Write it out for a manual look (scratch output, not committed).
      final out = Platform.environment['REPORT_PREVIEW'];
      if (out != null) File(out).writeAsBytesSync(bytes);
    });

    test('an empty period and an Urdu patient name still render', () async {
      final (regular, bold) = await fonts();
      final data = ReportData(
        patient: patient('امی جان'),
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 7),
        readings: const {},
      );
      final bytes = await ReportBuilder.pdf(data, regular: regular, bold: bold);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
