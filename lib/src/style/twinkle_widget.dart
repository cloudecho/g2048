import 'package:flutter/material.dart';

class TwinkleWidget extends StatefulWidget {
  const TwinkleWidget({
    super.key,
    this.begin = 1,
    this.end = 0.5,
    this.speed = const Duration(milliseconds: 1000),
    this.repeat = true,
    required this.child,
  });

  final double begin;
  final double end;
  final Duration speed;
  final Widget child;
  final bool repeat;

  @override
  State<TwinkleWidget> createState() => _TwinkleWidgetState();
}

class _TwinkleWidgetState extends State<TwinkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.speed,
      vsync: this,
    );
    if (widget.repeat) {
      controller.repeat(reverse: true);
    } else {
      controller.forward();
    }

    opacity = Tween(
      begin: widget.begin,
      end: widget.end,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Opacity(
        opacity: opacity.value,
        child: widget.child,
      ),
    );
  }
}
