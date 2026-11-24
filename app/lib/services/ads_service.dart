import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob IDs for LiveHealthy: Vitals (see docs/admob.md).
///
/// Debug and profile builds always use Google's public TEST unit, so tapping
/// an ad during development can never put the AdMob account at risk.
class AdIds {
  AdIds._();

  // App ID lives in AndroidManifest.xml (com.google.android.gms.ads.APPLICATION_ID):
  //   ca-app-pub-2087846699268567~7523537181
  static const String _historyBannerRelease = 'ca-app-pub-2087846699268567/4316201171';
  static const String _testAdaptiveBanner = 'ca-app-pub-3940256099942544/9214589741';

  static String get historyBanner => kReleaseMode ? _historyBannerRelease : _testAdaptiveBanner;
}

/// What the UI needs from ads. Tests use [AdsController.disabled], so no
/// platform channel is ever touched in widget tests.
abstract class AdsController {
  /// True once consent allows requesting ads and the SDK is initialised.
  ValueListenable<bool> get canShowAds;

  /// True when the user must be able to reopen the consent form (EEA/UK/CH):
  /// Settings then shows a "Privacy options for ads" entry.
  ValueListenable<bool> get privacyOptionsRequired;

  Future<void> initialize();

  Future<void> showPrivacyOptions();

  /// Every request is non-personalized and carries no keywords, content URL
  /// or custom targeting: Google's policy forbids targeting personalized ads
  /// on health information, and nothing about a user's readings or
  /// conditions may ever reach an ad request.
  AdRequest buildRequest();

  static AdsController disabled() => _DisabledAds();
}

class _DisabledAds implements AdsController {
  @override
  final ValueListenable<bool> canShowAds = ValueNotifier<bool>(false);
  @override
  final ValueListenable<bool> privacyOptionsRequired = ValueNotifier<bool>(false);
  @override
  Future<void> initialize() async {}
  @override
  Future<void> showPrivacyOptions() async {}
  @override
  AdRequest buildRequest() => const AdRequest(nonPersonalizedAds: true);
}

/// Google UMP consent + Mobile Ads SDK. Order matters: consent is gathered
/// (or confirmed not needed) BEFORE the SDK initialises or any ad loads.
class AdMobService implements AdsController {
  AdMobService._();

  static final AdMobService instance = AdMobService._();

  final ValueNotifier<bool> _canShowAds = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _privacyOptionsRequired = ValueNotifier<bool>(false);
  bool _started = false;

  @override
  ValueListenable<bool> get canShowAds => _canShowAds;

  @override
  ValueListenable<bool> get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  AdRequest buildRequest() => const AdRequest(nonPersonalizedAds: true);

  /// Safe to call on every launch; never throws and never blocks the UI.
  @override
  Future<void> initialize() async {
    if (_started) return;
    _started = true;
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (error) => updated.complete(), // offline etc.: fall back to last stored consent
      );
      await updated.future;

      final dismissed = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((_) => dismissed.complete());
      await dismissed.future;

      _privacyOptionsRequired.value =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;

      if (await ConsentInformation.instance.canRequestAds()) {
        await _startSdk();
      }
    } catch (e) {
      // Ads are optional: a consent/SDK failure must never break the app.
      debugPrint('Ads init failed: $e');
    }
  }

  Future<void> _startSdk() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        // Adult audience but family-safe ads only; no mature content beside
        // someone's health readings.
        maxAdContentRating: MaxAdContentRating.pg,
      ),
    );
    _canShowAds.value = true;
  }

  @override
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) => done.complete());
    await done.future;
    // The user may have withdrawn or granted consent.
    final allowed = await ConsentInformation.instance.canRequestAds();
    if (allowed && !_canShowAds.value) {
      await _startSdk();
    } else if (!allowed) {
      _canShowAds.value = false;
    }
  }
}
