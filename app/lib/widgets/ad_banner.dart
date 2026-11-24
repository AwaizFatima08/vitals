import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/ads_service.dart';

/// A single anchored adaptive banner, used only at the bottom of the
/// history screens: away from Save, the keypad and the bottom navigation,
/// never floating over content (AdMob placement policy), and clearly
/// labelled so older users don't mistake it for part of the app.
///
/// Takes no space at all until an ad has actually loaded.
class AdBanner extends StatefulWidget {
  final String adUnitId;

  const AdBanner({super.key, required this.adUnitId});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;
  AdsController? _ads;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ads = context.read<AdsController>();
    if (!identical(ads, _ads)) {
      _ads?.canShowAds.removeListener(_maybeLoad);
      _ads = ads;
      ads.canShowAds.addListener(_maybeLoad);
    }
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    final ads = _ads;
    if (_requested || ads == null || !ads.canShowAds.value || !mounted) return;
    _requested = true;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: ads.buildRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    setState(() => _ad = ad);
    await ad.load();
  }

  @override
  void dispose() {
    _ads?.canShowAds.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        key: const ValueKey('ad_banner'),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).adLabel,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ],
        ),
      ),
    );
  }
}
