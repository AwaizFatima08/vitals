import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/vitals/reference_ranges.dart';
import '../../core/vitals/validation.dart';
import '../../core/vitals/vital_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/patient.dart';
import '../../models/vital_reading.dart';
import '../../services/vital_service.dart';
import '../../widgets/flag_chip.dart';
import '../../widgets/formatters.dart';
import '../../widgets/numeric_keypad.dart';

/// Firestore write futures only complete once the server acknowledges, so
/// offline they'd hang forever — even though the write is already safely
/// queued locally and shows up in every stream. Wait briefly for the ack,
/// then treat the write as queued.
Future<void> awaitWriteOrQueue(Future<Object?> write) {
  // Map to Future<void> first: `timeout`'s onTimeout must return the
  // source future's type, and add() returns Future<String>.
  return write.then<void>((_) {}).timeout(const Duration(seconds: 4), onTimeout: () {});
}

/// One entry screen per vital type (design doc §2): large number boxes, an
/// oversized on-screen keypad, and nothing else competing for attention.
/// Also used to edit an existing reading.
class VitalEntryScreen extends StatefulWidget {
  final Patient patient;
  final VitalType type;
  final VitalReading? existing;

  /// Injectable clock for tests.
  final DateTime Function() now;

  const VitalEntryScreen({
    super.key,
    required this.patient,
    required this.type,
    this.existing,
    this.now = DateTime.now,
  });

  @override
  State<VitalEntryScreen> createState() => _VitalEntryScreenState();
}

class _VitalEntryScreenState extends State<VitalEntryScreen> {
  // Field 0 = systolic (BP) or the single value; field 1 = diastolic.
  final List<String> _text = ['', ''];
  final List<String?> _errors = [null, null];
  int _activeField = 0;
  GlucoseContext? _glucoseContext;
  String? _glucoseContextError;
  late DateTime _measuredAt;
  String? _timeError;
  final _noteController = TextEditingController();
  final _noteFocus = FocusNode();
  bool _saving = false;

  VitalType get _type => widget.type;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _measuredAt = e?.measuredAt ?? widget.now();
    if (e != null) {
      if (_type.isDual) {
        _text[0] = VitalReading.formatNumber(e.systolic!);
        _text[1] = VitalReading.formatNumber(e.diastolic!);
      } else {
        _text[0] = VitalReading.formatNumber(e.value!);
      }
      _glucoseContext = e.glucoseContext;
      _noteController.text = e.note;
    }
    _noteFocus.addListener(() => setState(() {}));
    // A "Reading saved" snackbar from the previous entry would sit on top of
    // this screen's Save button; clear it so the first tap always lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  int _maxDigitsFor(int field) {
    final limits = _limitsFor(field);
    return limits.max.toInt().toString().length;
  }

  VitalLimits _limitsFor(int field) {
    if (_type.isDual) return field == 0 ? VitalValidation.systolic : VitalValidation.diastolic;
    return VitalValidation.limitsFor(_type);
  }

  void _onKey(String key) {
    setState(() {
      final updated = KeypadInput.apply(
        _text[_activeField],
        key,
        allowDecimal: _type.allowsDecimal,
        maxDigits: _maxDigitsFor(_activeField),
      );
      _text[_activeField] = updated;
      _errors[_activeField] = null;
      // Systolic is always 2-3 digits; once it has 3, jump to diastolic so
      // a full BP reading is just six taps + Save.
      if (_type.isDual && _activeField == 0 && updated.length == 3 && _text[1].isEmpty) {
        _activeField = 1;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_type.isDual && _activeField == 1 && _text[1].isEmpty) {
        _activeField = 0;
      }
      _text[_activeField] = KeypadInput.backspace(_text[_activeField]);
      _errors[_activeField] = null;
    });
  }

  /// Live preview of the flag while typing — only once the numbers are
  /// complete and plausible, so it never flashes "Low" at the first digit.
  RangeResult? get _previewRange {
    if (_type.isDual) {
      if (VitalValidation.validateSystolic(_text[0]) != null) return null;
      if (VitalValidation.validateDiastolic(_text[1], _text[0]) != null) return null;
      return ReferenceRanges.bloodPressure(VitalValidation.parse(_text[0])!, VitalValidation.parse(_text[1])!);
    }
    if (VitalValidation.validateSingle(_type, _text[0]) != null) return null;
    final v = VitalValidation.parse(_text[0])!;
    switch (_type) {
      case VitalType.spo2:
        return ReferenceRanges.spo2(v);
      case VitalType.pulse:
        return ReferenceRanges.pulse(v);
      case VitalType.glucose:
        return _glucoseContext == null ? null : ReferenceRanges.glucose(v, _glucoseContext!);
      case VitalType.weight:
        final heightCm = context.read<AppState>().patientById(widget.patient.id)?.heightCm ?? widget.patient.heightCm;
        return VitalReading(
          id: '',
          type: VitalType.weight,
          value: v,
          measuredAt: _measuredAt,
          createdByUid: '',
        ).bmiRange(heightCm);
      case VitalType.bloodPressure:
        return null;
    }
  }

  bool _validate(AppLocalizations l10n) {
    final unit = _type.unit;
    if (_type.isDual) {
      final sysError = VitalValidation.validateSystolic(_text[0]);
      final diaError = VitalValidation.validateDiastolic(_text[1], _text[0]);
      _errors[0] = sysError == null ? null : VitalLabels.validation(l10n, sysError, VitalValidation.systolic, unit);
      _errors[1] = diaError == null ? null : VitalLabels.validation(l10n, diaError, VitalValidation.diastolic, unit);
      if (sysError != null) {
        _activeField = 0;
      } else if (diaError != null) {
        _activeField = 1;
      }
    } else {
      final error = VitalValidation.validateSingle(_type, _text[0]);
      _errors[0] = error == null ? null : VitalLabels.validation(l10n, error, VitalValidation.limitsFor(_type), unit);
    }
    _glucoseContextError = (_type == VitalType.glucose && _glucoseContext == null) ? l10n.selectGlucoseContext : null;
    _timeError = _measuredAt.isAfter(widget.now().add(const Duration(minutes: 1))) ? l10n.futureTimeError : null;
    return _errors.every((e) => e == null) && _glucoseContextError == null && _timeError == null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final ok = _validate(l10n);
    setState(() {});
    if (!ok) return;

    final vitalService = context.read<VitalService>();
    final uid = context.read<AppState>().uid ?? '';
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final reading = VitalReading(
      id: widget.existing?.id ?? '',
      type: _type,
      systolic: _type.isDual ? VitalValidation.parse(_text[0]) : null,
      diastolic: _type.isDual ? VitalValidation.parse(_text[1]) : null,
      value: _type.isDual ? null : VitalValidation.parse(_text[0]),
      glucoseContext: _type == VitalType.glucose ? _glucoseContext : null,
      measuredAt: _measuredAt,
      note: _noteController.text.trim(),
      createdByUid: widget.existing?.createdByUid ?? uid,
      createdAt: widget.existing?.createdAt,
    );

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await awaitWriteOrQueue(vitalService.updateReading(widget.patient.id, reading));
      } else {
        await awaitWriteOrQueue(vitalService.addReading(widget.patient.id, reading));
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.readingSaved), duration: const Duration(seconds: 2)));
      navigator.pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final vitalService = context.read<VitalService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReadingTitle),
        content: Text(l10n.deleteReadingBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            key: const ValueKey('confirm_delete_reading'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(88, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await awaitWriteOrQueue(vitalService.deleteReading(widget.patient.id, widget.existing!.id));
      messenger.showSnackBar(SnackBar(content: Text(l10n.readingDeleted), duration: const Duration(seconds: 2)));
      navigator.pop(true);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  Future<void> _pickTime() async {
    final now = widget.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _measuredAt.isAfter(now) ? now : _measuredAt,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_measuredAt));
    if (time == null) return;
    setState(() {
      _measuredAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _timeError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = VitalLabels.name(l10n, _type);
    final range = _previewRange;
    final urgent = VitalLabels.urgentMessage(l10n, range);
    final showKeypad = !_noteFocus.hasFocus;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editReading : name),
        actions: [
          if (_isEdit)
            IconButton(
              key: const ValueKey('delete_reading'),
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  Text('${widget.patient.name} · $name', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  if (_type.isDual)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _valueBox(0, l10n.systolic)),
                        Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: Text(' / ', style: theme.textTheme.headlineMedium),
                        ),
                        Expanded(child: _valueBox(1, l10n.diastolic)),
                      ],
                    )
                  else
                    _valueBox(0, name),
                  const SizedBox(height: 10),
                  if (range != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FlagChip(result: range),
                    ),
                  if (urgent != null) ...[const SizedBox(height: 8), UrgentNotice(message: urgent)],
                  if (_type == VitalType.glucose) ...[
                    const SizedBox(height: 12),
                    Text(l10n.glucoseContextLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in GlucoseContext.values)
                          ChoiceChip(
                            key: ValueKey('ctx_${c.key}'),
                            label: Text(VitalLabels.glucoseContext(l10n, c)),
                            selected: _glucoseContext == c,
                            onSelected: (_) => setState(() {
                              _glucoseContext = c;
                              _glucoseContextError = null;
                            }),
                          ),
                      ],
                    ),
                    if (_glucoseContextError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_glucoseContextError!, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                  ],
                  const SizedBox(height: 8),
                  ListTile(
                    key: const ValueKey('measured_at'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: Text('${l10n.measuredAt}: ${formatReadingTime(context, _measuredAt, now: widget.now())}'),
                    subtitle: _timeError == null
                        ? null
                        : Text(_timeError!, style: TextStyle(color: theme.colorScheme.error)),
                    trailing: TextButton(onPressed: _pickTime, child: Text(l10n.change)),
                  ),
                  TextField(
                    key: const ValueKey('reading_note'),
                    controller: _noteController,
                    focusNode: _noteFocus,
                    maxLength: 200,
                    decoration: InputDecoration(labelText: l10n.noteOptional, hintText: l10n.noteHint, isDense: true),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _noteFocus.unfocus(),
                  ),
                ],
              ),
            ),
            if (showKeypad)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: NumericKeypad(onKey: _onKey, onBackspace: _onBackspace, allowDecimal: _type.allowsDecimal),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                key: const ValueKey('save_reading'),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(showKeypad ? l10n.save : l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueBox(int field, String label) {
    final theme = Theme.of(context);
    final active = _activeField == field && !_noteFocus.hasFocus;
    final error = _errors[field];
    final borderColor = error != null
        ? theme.colorScheme.error
        : active
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    return Semantics(
      label: label,
      value: _text[field],
      button: true,
      child: GestureDetector(
        key: ValueKey('field_$field'),
        onTap: () {
          _noteFocus.unfocus();
          setState(() => _activeField = field);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 76,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: active ? 3 : 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _text[field].isEmpty ? '—' : _text[field],
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _text[field].isEmpty ? theme.colorScheme.outline : null,
                      ),
                    ),
                    if (!_type.isDual) TextSpan(text: '  ${_type.unit}', style: theme.textTheme.titleMedium),
                  ],
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(error, style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
              ),
            if (_type.isDual && field == 1 && error == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_type.unit, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}
