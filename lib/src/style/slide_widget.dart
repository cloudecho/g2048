import 'package:flutter/material.dart';

class SlideWidget extends StatefulWidget {
  const SlideWidget({
    super.key,
    required this.child,
    this.offset = const Offset(1, 0.0),
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration duration;
  final Offset offset;

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();
    _offsetAnimation = Tween(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _offsetAnimation,
            child: widget.child,
          );
        });
  }
}
