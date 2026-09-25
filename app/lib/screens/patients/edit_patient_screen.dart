import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/vitals/validation.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/patient.dart';
import '../../models/vital_reading.dart';
import '../../services/patient_service.dart';

/// Add a patient, or edit an existing one's name/relationship/height.
/// Height is captured once here and drives BMI.
class EditPatientScreen extends StatefulWidget {
  final Patient? patient; // null = add new

  /// Shown right after a "tracking for family" sign-up.
  final bool isFirstFamilyMember;

  /// Shown when a signed-in account has no patients at all.
  final bool isFirstPatient;

  const EditPatientScreen({super.key, this.patient, this.isFirstFamilyMember = false, this.isFirstPatient = false});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late String _relationship;
  late final String _initialRelationship;
  bool _submitting = false;
  String? _error;

  bool get _isEdit => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p?.name ?? '');
    _heightController = TextEditingController(text: p?.heightCm == null ? '' : VitalReading.formatNumber(p!.heightCm!));
    if (p != null) {
      _relationship = VitalLabels.relationships.contains(p.relationship) ? p.relationship : 'other family member';
    } else {
      _relationship = widget.isFirstPatient ? 'self' : 'mother';
    }
    _initialRelationship = _relationship;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSelfPatient = widget.patient?.isSelf ?? false;
    final prompt = widget.isFirstFamilyMember
        ? l10n.firstFamilyMemberPrompt
        : widget.isFirstPatient
        ? l10n.noPatientsPrompt
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editPatient : l10n.addPatient),
        automaticallyImplyLeading: !widget.isFirstPatient,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (prompt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(prompt, style: Theme.of(context).textTheme.bodyLarge),
                ),
              TextFormField(
                key: const ValueKey('patient_name'),
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.patientName),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              // The account holder's own "self" profile keeps its
              // relationship — changing it would confuse Medicine Reminder too.
              if (!isSelfPatient)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _relationship,
                  decoration: InputDecoration(labelText: l10n.relationshipToYou),
                  items: [
                    for (final r in VitalLabels.relationships)
                      if (r != 'self' || widget.isFirstPatient)
                        DropdownMenuItem(value: r, child: Text(VitalLabels.relationship(l10n, r))),
                  ],
                  onChanged: (v) => setState(() => _relationship = v ?? _relationship),
                ),
              if (!isSelfPatient) const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('patient_height'),
                controller: _heightController,
                decoration: InputDecoration(labelText: l10n.heightCm, helperText: l10n.heightHelp, suffixText: 'cm'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d?)?'))],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final error = VitalValidation.validateHeight(v);
                  return error == null ? null : VitalLabels.validation(l10n, error, VitalValidation.heightCm, 'cm');
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('patient_save'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEdit ? l10n.save : l10n.addPatient),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final appState = context.read<AppState>();
    final patientService = context.read<PatientService>();
    final navigator = Navigator.of(context);
    final height = VitalValidation.parse(_heightController.text);

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        final p = widget.patient!;
        await patientService.updatePatient(
          p.id,
          name: _nameController.text.trim(),
          // Only write it if changed: never normalise a value Medicine
          // Reminder wrote just because this screen was saved.
          relationship: (p.isSelf || _relationship == _initialRelationship) ? null : _relationship,
          heightCm: height,
          clearHeight: height == null && p.heightCm != null,
        );
      } else {
        final id = await patientService.addPatient(
          name: _nameController.text.trim(),
          ownerUid: appState.uid!,
          relationship: _relationship,
          heightCm: height,
        );
        final created = await patientService.getPatient(id);
        if (created != null) await appState.setActivePatient(created);
      }
      if (widget.isFirstPatient) return; // RootRouter swaps screens itself
      navigator.pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.saveFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
