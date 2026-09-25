import 'package:flutter/widgets.dart';

/// A StreamBuilder that only re-subscribes when [streamKey] changes.
///
/// A plain StreamBuilder given `service.watchX()` inside build() gets a
/// brand-new Firestore listener on every rebuild, which briefly shows the
/// empty state (flicker) and wastes reads.
class CachedStreamBuilder<T> extends StatefulWidget {
  final Object streamKey;
  final Stream<T> Function() create;
  final AsyncWidgetBuilder<T> builder;

  const CachedStreamBuilder({super.key, required this.streamKey, required this.create, required this.builder});

  @override
  State<CachedStreamBuilder<T>> createState() => _CachedStreamBuilderState<T>();
}

class _CachedStreamBuilderState<T> extends State<CachedStreamBuilder<T>> {
  late Stream<T> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.create();
  }

  @override
  void didUpdateWidget(covariant CachedStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamKey != widget.streamKey) _stream = widget.create();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(stream: _stream, builder: widget.builder);
}
