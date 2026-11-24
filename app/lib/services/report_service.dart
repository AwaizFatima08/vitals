import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../core/vitals/bmi.dart';
import '../core/vitals/reference_ranges.dart';
import '../core/vitals/stats.dart';
import '../core/vitals/vital_type.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/vital_labels.dart';
import '../models/patient.dart';
import '../models/vital_reading.dart';
import 'vital_service.dart';

/// Everything that goes into one doctor report.
class ReportData {
  final Patient patient;
  final DateTime from; // start of the first day
  final DateTime to; // when the report was made
  final Map<VitalType, List<VitalReading>> readings; // oldest first; only types with data

  const ReportData({required this.patient, required this.from, required this.to, required this.readings});

  bool get isEmpty => readings.values.every((r) => r.isEmpty);
}

/// Builds the doctor report as CSV and PDF. Pure apart from the fonts, so it
/// can be unit-tested. Report text is English for v1.1 (doctors read it, and
/// Urdu shaping in the PDF engine is unverified); patient names are printed
/// as typed.
class ReportBuilder {
  ReportBuilder._();

  /// English labels from the app's own localisations, so the report says
  /// exactly what the app says.
  static final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));

  static String _n(double v) => VitalReading.formatNumber(double.parse(v.toStringAsFixed(1)));

  static String flagLabel(VitalReading r, double? heightCm) {
    final RangeResult? flag = r.type == VitalType.weight ? r.bmiRange(heightCm) : r.range;
    return flag == null ? '' : VitalLabels.range(_en, flag.category);
  }

  // ---------------------------------------------------------------- CSV

  static String csv(ReportData data) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final rows = <List<String>>[
      [
        'Patient',
        'Vital',
        'Measured at',
        'Systolic',
        'Diastolic',
        'Value',
        'Unit',
        'Glucose context',
        'Flag',
        'BMI',
        'Note',
      ],
    ];
    for (final type in VitalType.values) {
      for (final r in data.readings[type] ?? const <VitalReading>[]) {
        final bmi = r.bmi(data.patient.heightCm);
        rows.add([
          data.patient.name,
          VitalLabels.name(_en, type),
          fmt.format(r.measuredAt),
          type.isDual ? _n(r.systolic!) : '',
          type.isDual ? _n(r.diastolic!) : '',
          type.isDual ? '' : _n(r.value!),
          type.unit,
          r.glucoseContext == null ? '' : VitalLabels.glucoseContext(_en, r.glucoseContext!),
          flagLabel(r, data.patient.heightCm),
          bmi == null ? '' : Bmi.format(bmi),
          r.note,
        ]);
      }
    }
    // UTF-8 BOM so spreadsheet apps show Urdu names correctly.
    return '﻿${rows.map((row) => row.map(_csvCell).join(',')).join('\r\n')}\r\n';
  }

  static String _csvCell(String v) {
    // Guard against spreadsheet formula injection from free-text notes.
    var s = v;
    if (s.isNotEmpty && '=+-@'.contains(s[0]) && double.tryParse(s) == null) s = "'$s";
    if (s.contains(RegExp(r'[",\r\n]'))) return '"${s.replaceAll('"', '""')}"';
    return s;
  }

  // ---------------------------------------------------------------- PDF

  static Future<Uint8List> pdf(ReportData data, {required pw.Font regular, required pw.Font bold}) async {
    final doc = pw.Document(
      title: 'Health readings — ${data.patient.name}',
      author: 'LiveHealthy: Vitals',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    final dateFmt = DateFormat('d MMM yyyy');
    final dtFmt = DateFormat('d MMM yyyy, h:mm a');
    const green = PdfColor.fromInt(0xFF0B6E4F);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox()
            : pw.Text(
                'Health readings — ${data.patient.name}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
        footer: (ctx) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'Readings entered by the patient or a family member from home devices. Colour flags use '
                    'general adult reference ranges and are for information only, not a diagnosis. '
                    'Made with LiveHealthy: Vitals.',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        build: (ctx) => [
          pw.Text(
            'Health readings report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: green),
          ),
          pw.SizedBox(height: 6),
          _kv('Patient', data.patient.name),
          _kv('Period', '${dateFmt.format(data.from)} – ${dateFmt.format(data.to)}'),
          _kv('Prepared', dtFmt.format(data.to)),
          if (data.patient.heightCm != null) _kv('Height', '${_n(data.patient.heightCm!)} cm'),
          pw.SizedBox(height: 10),
          if (data.isEmpty) pw.Text('No readings were logged in this period.'),
          for (final type in VitalType.values)
            if ((data.readings[type] ?? const []).isNotEmpty) ..._section(data, type, dtFmt),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _kv(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(k, style: const pw.TextStyle(color: PdfColors.grey700)),
        ),
        pw.Expanded(child: pw.Text(v)),
      ],
    ),
  );

  static List<pw.Widget> _section(ReportData data, VitalType type, DateFormat dtFmt) {
    final readings = data.readings[type]!;
    final heightCm = data.patient.heightCm;
    final stats = VitalStats.compute(type, readings, heightCm: heightCm);
    final unit = type.unit;
    final lines = <String>[];

    if (type.isDual) {
      lines.add(
        'Average ${stats.bpAverage!.display} $unit '
        '(lowest ${_n(stats.systolic!.min)}/${_n(stats.diastolic!.min)}, '
        'highest ${_n(stats.systolic!.max)}/${_n(stats.diastolic!.max)})',
      );
      if (stats.bpMorning != null) lines.add('Morning average ${stats.bpMorning!.display} $unit');
      if (stats.bpEvening != null) lines.add('Evening average ${stats.bpEvening!.display} $unit');
      final check = HomeBpProtocol.evaluate(readings, now: data.to);
      lines.add(switch (check) {
        HomeBpResult(:final average, :final days) =>
          '7-day home average (first day excluded, $days days): ${average.display} $unit',
        HomeBpNeedsMore() => '7-day home average: not enough readings in the last 7 days',
      });
    } else {
      final v = stats.value!;
      lines.add('Average ${_n(v.mean)} $unit (lowest ${_n(v.min)}, highest ${_n(v.max)})');
      if (stats.valueMorning != null) lines.add('Morning average ${_n(stats.valueMorning!.mean)} $unit');
      if (stats.valueEvening != null) lines.add('Evening average ${_n(stats.valueEvening!.mean)} $unit');
      if (stats.glucoseFastingOrBeforeMeal != null) {
        lines.add('Fasting / before meal average ${_n(stats.glucoseFastingOrBeforeMeal!.mean)} $unit');
      }
      if (stats.glucoseAfterMealOrRandom != null) {
        lines.add('After meal / random average ${_n(stats.glucoseAfterMealOrRandom!.mean)} $unit');
      }
    }
    if (stats.normalShare != null) {
      lines.add('${(stats.normalShare! * 100).round()}% of ${stats.count} readings in the normal range');
    } else {
      lines.add('${stats.count} readings');
    }

    return [
      pw.SizedBox(height: 14),
      pw.Header(level: 1, text: '${VitalLabels.name(_en, type)} ($unit)'),
      for (final l in lines) pw.Bullet(text: l, style: const pw.TextStyle(fontSize: 10)),
      if (readings.length >= 2) ...[pw.SizedBox(height: 6), _chart(data, type, readings)],
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellAlignment: pw.Alignment.centerLeft,
        headers: [
          'Date and time',
          'Reading',
          if (type == VitalType.glucose) 'When',
          if (type == VitalType.weight) 'BMI',
          'Flag',
          'Note',
        ],
        data: [
          for (final r in readings.reversed) // newest first, like the app
            [
              dtFmt.format(r.measuredAt),
              r.displayValue,
              if (type == VitalType.glucose) VitalLabels.glucoseContext(_en, r.glucoseContext!),
              if (type == VitalType.weight) r.bmi(heightCm) == null ? '' : Bmi.format(r.bmi(heightCm)!),
              flagLabel(r, heightCm),
              r.note,
            ],
        ],
      ),
    ];
  }

  static double _niceStep(double raw) {
    if (raw <= 0) return 1;
    var magnitude = 1.0;
    while (magnitude * 10 <= raw) {
      magnitude *= 10;
    }
    while (magnitude > raw) {
      magnitude /= 10;
    }
    for (final m in [1, 2, 5, 10]) {
      if (m * magnitude >= raw) return m * magnitude;
    }
    return 10 * magnitude;
  }

  static pw.Widget _chart(ReportData data, VitalType type, List<VitalReading> readings) {
    final days = data.to.difference(data.from).inHours / 24;
    double x(VitalReading r) => r.measuredAt.difference(data.from).inMinutes / (24 * 60);
    final values = [
      for (final r in readings) ...(type.isDual ? [r.systolic!, r.diastolic!] : [r.value!]),
    ];
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    // Round, readable steps (1, 2, 5, 10, 20, 50 …) and an axis that always
    // covers every reading, so the line never runs off the chart.
    final yStep = _niceStep((hi - lo) / 4);
    lo = ((lo - yStep / 2) / yStep).floorToDouble() * yStep;
    hi = ((hi + yStep / 2) / yStep).ceilToDouble() * yStep;
    final xStep = (days / 5).ceilToDouble().clamp(1, 1000).toDouble();
    final xMax = (days / xStep).ceilToDouble() * xStep;
    final dayFmt = DateFormat('d MMM');

    pw.LineDataSet<pw.PointChartValue> series(List<double> ys, PdfColor color, String legend) => pw.LineDataSet(
      legend: legend,
      color: color,
      lineColor: color,
      pointSize: 2.5,
      lineWidth: 1.5,
      data: [for (var i = 0; i < readings.length; i++) pw.PointChartValue(x(readings[i]), ys[i])],
    );

    return pw.SizedBox(
      height: 150,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis<double>(
            [for (var d = 0.0; d <= xMax + 0.001; d += xStep) d],
            format: (v) => dayFmt.format(data.from.add(Duration(minutes: (v * 24 * 60).round()))),
            textStyle: const pw.TextStyle(fontSize: 7),
          ),
          yAxis: pw.FixedAxis<double>(
            [for (var v = lo; v <= hi + 0.001; v += yStep) v],
            format: (v) => _n(v.toDouble()),
            textStyle: const pw.TextStyle(fontSize: 7),
            divisions: true,
            divisionsColor: PdfColors.grey300,
          ),
        ),
        datasets: type.isDual
            ? [
                series([for (final r in readings) r.systolic!], const PdfColor.fromInt(0xFF0B6E4F), 'Upper (systolic)'),
                series(
                  [for (final r in readings) r.diastolic!],
                  const PdfColor.fromInt(0xFF3F7CAC),
                  'Lower (diastolic)',
                ),
              ]
            : [
                series([for (final r in readings) r.value!], const PdfColor.fromInt(0xFF0B6E4F), type.unit),
              ],
        bottom: type.isDual ? pw.ChartLegend(textStyle: const pw.TextStyle(fontSize: 8)) : null,
      ),
    );
  }
}

/// Collects the data and hands the files to the Android share sheet
/// (WhatsApp, email, Drive, …).
class ReportService {
  final VitalService vitalService;

  ReportService({required this.vitalService});

  Future<ReportData> collect(Patient patient, {required int days, DateTime? now}) async {
    final end = now ?? DateTime.now();
    final today = DateTime(end.year, end.month, end.day);
    final from = today.subtract(Duration(days: days - 1));
    final readings = <VitalType, List<VitalReading>>{};
    for (final type in VitalType.values) {
      final list = await vitalService.fetchReadings(patient.id, type, since: from);
      if (list.isNotEmpty) readings[type] = list;
    }
    return ReportData(patient: patient, from: from, to: end, readings: readings);
  }

  static Future<(pw.Font, pw.Font)> loadFonts() async {
    final regular = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final bold = await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf');
    return (pw.Font.ttf(regular), pw.Font.ttf(bold));
  }

  String _fileStem(ReportData data) {
    final safeName = data.patient.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    final date = DateFormat('yyyy-MM-dd').format(data.to);
    return 'LiveHealthy_Vitals_${safeName.isEmpty ? 'report' : safeName}_$date';
  }

  Future<File> _write(String name, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> sharePdf(ReportData data) async {
    final (regular, bold) = await loadFonts();
    final bytes = await ReportBuilder.pdf(data, regular: regular, bold: bold);
    final file = await _write('${_fileStem(data)}.pdf', bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Health readings report',
      ),
    );
  }

  Future<void> shareCsv(ReportData data) async {
    final file = await _write('${_fileStem(data)}.csv', utf8.encode(ReportBuilder.csv(data)));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Health readings (CSV)',
      ),
    );
  }
}
