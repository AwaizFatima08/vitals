import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/constants/links.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/account_deletion_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _deleting = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) => mounted ? setState(() => _version = '${info.version} (${info.buildNumber})') : null)
        .catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    const danger = Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user.displayName),
              subtitle: Text(user.email),
            ),
          ListTile(
            key: const ValueKey('settings_language'),
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(appState.languageCode == 'ur' ? l10n.languageUrdu : l10n.languageEnglish),
            onTap: () => _changeLanguage(context),
          ),
          const Divider(),
          ListTile(
            key: const ValueKey('settings_about_ranges'),
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutRanges),
            onTap: () => _showAboutRanges(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(Links.privacyPolicy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfUse),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(Links.terms),
          ),
          const Divider(),
          ListTile(
            key: const ValueKey('settings_sign_out'),
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOut),
            onTap: () => context.read<AppState>().signOut(),
          ),
          ListTile(
            key: const ValueKey('settings_delete_account'),
            leading: _deleting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_forever, color: danger),
            title: Text(l10n.deleteAccount, style: const TextStyle(color: danger)),
            subtitle: Text(l10n.deleteAccountSubtitle),
            onTap: _deleting ? null : () => _confirmAndDeleteAccount(context),
          ),
          if (_version.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${l10n.appTitle} · ${l10n.version(_version)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _changeLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final appState = context.read<AppState>();
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'en'), child: Text(l10n.languageEnglish)),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'ur'), child: Text(l10n.languageUrdu)),
        ],
      ),
    );
    if (choice != null) await appState.setLanguage(choice);
  }

  void _showAboutRanges(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutRanges),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.disclaimerShort),
              const SizedBox(height: 12),
              Text(l10n.disclaimerLimitations),
              const SizedBox(height: 12),
              Text(l10n.onboardingDisclaimer),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))],
      ),
    );
  }

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: SingleChildScrollView(child: Text(l10n.deleteAccountBody)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            key: const ValueKey('confirm_delete_account'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(88, 44),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteEverything),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _deleteAccount(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final firebaseUser = context.read<AuthService>().currentFirebaseUser;
    if (firebaseUser == null) return;
    final deletionService = context.read<AccountDeletionService>();
    final appState = context.read<AppState>();

    setState(() => _deleting = true);
    try {
      // Re-authenticate first: deleting Firestore data and then failing on
      // Auth's "requires-recent-login" would leave a login with no data.
      final reauthed = await _reauthenticate(context, firebaseUser);
      if (!reauthed) return;
      await appState.scheduler.cancelAll();
      await deletionService.deleteAccount(firebaseUser);
      // AppState's auth listener routes back to the welcome screen.
    } catch (_) {
      if (context.mounted) _showError(context, l10n.deleteFailed);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<bool> _reauthenticate(BuildContext context, User firebaseUser) async {
    final l10n = AppLocalizations.of(context);
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.confirmPasswordBody),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('reauth_password'),
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.password),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    final password = passwordController.text;
    passwordController.dispose();
    if (confirmed != true || password.isEmpty) return false;

    try {
      final credential = EmailAuthProvider.credential(email: firebaseUser.email!, password: password);
      await firebaseUser.reauthenticateWithCredential(credential);
      return true;
    } catch (_) {
      if (context.mounted) _showError(context, l10n.passwordMismatch);
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
