// Policy guard: Google forbids targeting personalized ads on health
// information, and nothing about a user's readings may reach an ad request.
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/services/ads_service.dart';

void main() {
  for (final entry in {
    'AdMobService': AdMobService.instance as AdsController,
    'disabled': AdsController.disabled(),
  }.entries) {
    test('${entry.key}: ad requests are non-personalized and carry no targeting data', () {
      final request = entry.value.buildRequest();
      expect(request.nonPersonalizedAds, isTrue);
      expect(request.keywords, isNull);
      expect(request.contentUrl, isNull);
      expect(request.neighboringContentUrls, isNull);
      expect(request.extras, isNull);
    });
  }

  test('debug/test builds never use the real ad unit', () {
    // flutter test runs in debug mode, so this must be Google's test unit.
    expect(AdIds.historyBanner, startsWith('ca-app-pub-3940256099942544/'));
  });
}
