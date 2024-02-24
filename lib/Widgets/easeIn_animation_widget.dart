import 'package:flutter/material.dart';

class EaseInAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  const EaseInAnimation({
    super.key,
    required this.child,
    required this.isAnimating,
  });

  @override
  State<EaseInAnimation> createState() => _EaseInAnimationState();
}

class _EaseInAnimationState extends State<EaseInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late CurvedAnimation easeInAnimation;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    easeInAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant EaseInAnimation oldWidget) {
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  startAnimation() async {
    if (widget.isAnimating) {
      await controller.forward().whenComplete(() async {
        controller.reset();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: easeInAnimation.value,
      duration: const Duration(milliseconds: 300),
      child: widget.child,
    );
  }
}
