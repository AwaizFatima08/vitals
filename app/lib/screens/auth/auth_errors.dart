import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/generated/app_localizations.dart';

/// Turns Firebase Auth failures into plain-language, localized messages.
String friendlyAuthError(AppLocalizations l10n, Object error, {bool isSignIn = false}) {
  final code = error is FirebaseAuthException ? error.code : error.toString();
  if (code.contains('network-request-failed')) return l10n.errorNetwork;
  if (isSignIn &&
      (code.contains('wrong-password') ||
          code.contains('user-not-found') ||
          code.contains('invalid-credential') ||
          code.contains('invalid-email'))) {
    return l10n.signInFailed;
  }
  if (code.contains('email-already-in-use')) return l10n.errorEmailInUse;
  if (code.contains('weak-password')) return l10n.errorWeakPassword;
  if (code.contains('invalid-email')) return l10n.errorInvalidEmail;
  return isSignIn ? l10n.signInFailed : l10n.errorGeneric;
}

bool looksLikeEmail(String? value) {
  final v = value?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}
