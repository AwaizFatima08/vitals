// Regression from the Galaxy A12 run: 720x1600, display zoom (density 340),
// 1.3x system font — typical for older users. Key actions must stay reachable.
// Width-sensitive checks (chip wrapping, nav labels) live in the on-device
// test instead: the widget-test font renders every glyph 1em wide.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('welcome: sign-in is on screen without scrolling at 1.3x font', (tester) async {
    final h = await TestHarness.create(signedIn: false);
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 340 / 160;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(h.app());
    await settle(tester);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final button = tester.getRect(find.byKey(const ValueKey('welcome_sign_in')));
    expect(button.bottom, lessThanOrEqualTo(screen.height));
    expect(button.top, greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull); // no overflow at this size
  });

  testWidgets('entry keypad and Save fit on screen at 1.3x font', (tester) async {
    final h = await TestHarness.create();
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 340 / 160;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(h.app());
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('add_bloodPressure')));
    await settle(tester);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(tester.getRect(find.byKey(const ValueKey('save_reading'))).bottom, lessThanOrEqualTo(screen.height));
    expect(tester.getRect(find.byKey(const ValueKey('key_0'))).bottom, lessThanOrEqualTo(screen.height));
    expect(tester.takeException(), isNull);
  });
}
