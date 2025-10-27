import 'package:flutter/material.dart';

const _defaultTransitionDuration = Duration(seconds: 1);

class FadeInTransition extends StatefulWidget {
  const FadeInTransition({super.key, required this.child, this.duration = _defaultTransitionDuration});

  final Widget child;
  final Duration duration;

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _opacity = 1));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(duration: widget.duration, opacity: _opacity, child: widget.child);
  }
}
