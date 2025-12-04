import 'package:flutter/material.dart';

const _defaultTransitionDuration = Duration(seconds: 1);

class FadeInTransition extends StatefulWidget {
  const FadeInTransition({super.key, required this.child, this.duration = _defaultTransitionDuration});

  final Widget child;
  final Duration duration;

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition> with TickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.duration);
  late final _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () => _controller.forward());
    // WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
