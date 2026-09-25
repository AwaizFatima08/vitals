import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../auth/sign_in_screen.dart';
import '../auth/sign_up_screen.dart';

/// First screen after install. The "who is this for" choice only decides
/// what happens right after sign-up — patients can always be added later
/// (design doc §3). Existing LiveHealthy users (e.g. from Medicine Reminder)
/// get a prominent sign-in path, since it's the same account.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset('assets/images/app_icon.png', width: 56, height: 56),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.brandName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        l10n.appSubtitle,
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.tagline, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 36),
            Text(l10n.onboardingTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _ChoiceCard(
              key: const ValueKey('choice_just_me'),
              title: l10n.onboardingJustMe,
              subtitle: l10n.onboardingJustMeSubtitle,
              icon: Icons.person,
              onTap: () => _startSignUp(context, isFamily: false),
            ),
            const SizedBox(height: 12),
            _ChoiceCard(
              key: const ValueKey('choice_family'),
              title: l10n.onboardingFamily,
              subtitle: l10n.onboardingFamilySubtitle,
              icon: Icons.family_restroom,
              onTap: () => _startSignUp(context, isFamily: true),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              key: const ValueKey('welcome_sign_in'),
              icon: const Icon(Icons.login),
              label: Text(l10n.haveAccountSignIn, textAlign: TextAlign.center),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignInScreen())),
            ),
            const SizedBox(height: 8),
            Text(l10n.sharedAccountNote, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Text(
              l10n.onboardingDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startSignUp(BuildContext context, {required bool isFamily}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignUpScreen(startedAsFamilyCaregiver: isFamily)));
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceCard({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
