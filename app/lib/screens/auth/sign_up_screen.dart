import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/patient_service.dart';
import '../patients/edit_patient_screen.dart';
import 'auth_errors.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  final bool startedAsFamilyCaregiver;

  const SignUpScreen({super.key, required this.startedAsFamilyCaregiver});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _language;
  bool _submitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _language ??= Localizations.localeOf(context).languageCode == 'ur' ? 'ur' : 'en';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signUp)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                key: const ValueKey('signup_name'),
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('signup_email'),
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => looksLikeEmail(v) ? null : l10n.enterValidEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('signup_password'),
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                validator: (v) => (v == null || v.length < 6) ? l10n.passwordTooShort : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _language,
                decoration: InputDecoration(labelText: l10n.language),
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                  DropdownMenuItem(value: 'ur', child: Text(l10n.languageUrdu)),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('signup_submit'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.signUp),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignInScreen())),
                child: Text(l10n.alreadyHaveAccount),
              ),
              const SizedBox(height: 8),
              Text(l10n.sharedAccountNote, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final authService = context.read<AuthService>();
    final patientService = context.read<PatientService>();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final user = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        preferredLanguage: _language ?? 'en',
      );

      // Every account gets a "self" patient, exactly like Pill Reminder,
      // so the two apps agree on who's who.
      final selfPatientId = await patientService.addPatient(
        name: user.displayName,
        ownerUid: user.uid,
        relationship: 'self',
      );

      if (widget.startedAsFamilyCaregiver) {
        // The family member becomes the active patient once added.
        navigator.popUntil((route) => route.isFirst);
        navigator.push(MaterialPageRoute(builder: (_) => const EditPatientScreen(isFirstFamilyMember: true)));
      } else {
        await authService.setActivePatient(user.uid, selfPatientId);
        navigator.popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(l10n, e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
