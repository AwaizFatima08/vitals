// Regression: an earlier theme build rendered most text near-white on white
// (invisible) — widget-finder tests can't see that, so check contrast.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/theme/app_theme.dart';

void main() {
  test('every text style has a dark, sized, readable colour', () {
    final theme = AppTheme.light();
    final styles = {
      'displaySmall': theme.textTheme.displaySmall,
      'headlineSmall': theme.textTheme.headlineSmall,
      'titleLarge': theme.textTheme.titleLarge,
      'titleMedium': theme.textTheme.titleMedium,
      'titleSmall': theme.textTheme.titleSmall,
      'bodyLarge': theme.textTheme.bodyLarge,
      'bodyMedium': theme.textTheme.bodyMedium,
      'bodySmall': theme.textTheme.bodySmall,
      'labelLarge': theme.textTheme.labelLarge,
    };
    for (final entry in styles.entries) {
      final style = entry.value!;
      expect(style.fontSize, isNotNull, reason: '${entry.key} has no size');
      expect(style.color, isNotNull, reason: '${entry.key} has no colour');
      expect(style.color!.computeLuminance(), lessThan(0.2), reason: '${entry.key} is too light to read');
    }
  });

  testWidgets('text inside a Scaffold renders dark', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(body: Text('Blood pressure', style: Theme.of(context).textTheme.titleMedium)),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText).first);
    expect(rich.text.style!.color!.computeLuminance(), lessThan(0.2));
  });
}
