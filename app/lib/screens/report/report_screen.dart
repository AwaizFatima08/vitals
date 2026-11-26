import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/report_service.dart';

/// Doctor report: pick a period, then share a PDF (or CSV) through the
/// Android share sheet — WhatsApp, email, Drive, print. Free, and no ads on
/// this screen.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _days = 30;
  ReportData? _data;
  bool _loading = true;
  bool _sharing = false;
  String? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final patient = context.watch<AppState>().activePatient;
    if (patient != null && patient.id != _patientId) {
      _patientId = patient.id;
      _load();
    }
  }

  Future<void> _load() async {
    final patient = context.read<AppState>().activePatient;
    if (patient == null) return;
    setState(() => _loading = true);
    try {
      final data = await context.read<ReportService>().collect(patient, days: _days);
      if (mounted) setState(() => _data = data);
    } catch (_) {
      if (mounted) {
        setState(() => _data = null);
        _showError();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).reportFailed)));
  }

  Future<void> _share(Future<void> Function(ReportData) share) async {
    final data = _data;
    if (data == null || data.isEmpty) return;
    setState(() => _sharing = true);
    try {
      await share(data);
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final patient = context.watch<AppState>().activePatient;
    final service = context.read<ReportService>();
    final data = _data;
    final count = data?.readings.values.fold<int>(0, (n, r) => n + r.length) ?? 0;
    final canShare = !_loading && !_sharing && data != null && !data.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Decorative header (homidev job 20261126-1447, approved by Homi).
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  AppImages.reportHeader,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  cacheWidth: 360,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (patient != null) Text(patient.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.reportIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Text(l10n.reportPeriodLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 7, label: Text(l10n.range7)),
                ButtonSegment(value: 30, label: Text(l10n.range30)),
                ButtonSegment(value: 90, label: Text(l10n.range90)),
              ],
              selected: {_days},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                setState(() => _days = s.first);
                _load();
              },
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (data == null || data.isEmpty)
              Text(l10n.reportNoReadings, key: const ValueKey('report_empty'), style: theme.textTheme.bodyMedium)
            else
              Text(l10n.reportCounts(count), key: const ValueKey('report_count'), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('report_share_pdf'),
              icon: _sharing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(l10n.reportSharePdf),
              onPressed: canShare ? () => _share(service.sharePdf) : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('report_share_csv'),
              icon: const Icon(Icons.table_chart_outlined),
              label: Text(l10n.reportShareCsv),
              onPressed: canShare ? () => _share(service.shareCsv) : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.reportEnglishNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
