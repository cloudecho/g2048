import 'package:flutter/material.dart';

class Swipeable extends StatelessWidget {
  const Swipeable({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  final Widget child;

  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Dismissible(
          key: Key('${key?.toString()}-Dismissible-horizontal'),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) {
            switch (direction) {
              case DismissDirection.endToStart:
                onSwipeLeft?.call();
              case DismissDirection.startToEnd:
                onSwipeRight?.call();
              case _:
                ;
            }
            return Future.value(false);
          },
          child: Dismissible(
            key: Key('${key?.toString()}-Dismissible-vertical'),
            direction: DismissDirection.vertical,
            confirmDismiss: (direction) {
              switch (direction) {
                case DismissDirection.up:
                  onSwipeUp?.call();
                case DismissDirection.down:
                  onSwipeDown?.call();
                case _:
                  ;
              }
              return Future.value(false);
            },
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
