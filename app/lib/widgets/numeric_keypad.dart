import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Oversized on-screen number pad (design doc §1: "as few taps and as large
/// a keypad as possible"). Replaces the system keyboard on entry screens so
/// the keys are big, always in the same place, and there is nothing else to
/// mis-tap.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKey; // '0'-'9' or '.'
  final VoidCallback onBackspace;
  final bool allowDecimal;

  const NumericKeypad({super.key, required this.onKey, required this.onBackspace, this.allowDecimal = false});

  @override
  Widget build(BuildContext context) {
    // Digits always left-to-right, even when the UI is in Urdu (RTL).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            _row([for (final d in row) _digit(context, d)]),
          _row([
            allowDecimal ? _digit(context, '.') : const SizedBox.shrink(),
            _digit(context, '0'),
            _KeyButton(
              key: const ValueKey('key_backspace'),
              semanticLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
              onTap: () {
                HapticFeedback.selectionClick();
                onBackspace();
              },
              child: const Icon(Icons.backspace_outlined, size: 30),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(children: [for (final c in children) Expanded(child: c)]);
  }

  Widget _digit(BuildContext context, String d) {
    return _KeyButton(
      key: ValueKey('key_$d'),
      semanticLabel: d,
      onTap: () {
        HapticFeedback.selectionClick();
        onKey(d);
      },
      child: Text(d, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  const _KeyButton({super.key, required this.child, required this.onTap, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Semantics(
        button: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: Material(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(height: 64, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

/// Pure keypad text-editing rules, kept separate so they can be unit
/// tested without widgets.
class KeypadInput {
  KeypadInput._();

  /// Applies [key] to [current]; returns [current] unchanged if the key
  /// would make an invalid or absurdly long number.
  static String apply(String current, String key, {required bool allowDecimal, int maxDigits = 4}) {
    if (key == '.') {
      if (!allowDecimal || current.contains('.')) return current;
      return current.isEmpty ? '0.' : '$current.';
    }
    final parts = current.split('.');
    if (parts.length == 2) {
      // One decimal place is plenty for anything measured at home.
      if (parts[1].isNotEmpty) return current;
      return '$current$key';
    }
    if (current == '0') return key; // no leading zeros
    if (current.length >= maxDigits) return current;
    return '$current$key';
  }

  static String backspace(String current) => current.isEmpty ? current : current.substring(0, current.length - 1);
}
