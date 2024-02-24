import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback onEnd;
  final bool smallLike;
  const LikeAnimation(
      {super.key,
      required this.child,
      required this.isAnimating,
      this.duration = const Duration(microseconds: 150),
      required this.onEnd,
      this.smallLike = false});

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300));

    scale = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.5),
        weight: 0.3, // Represents the duration of the first half of the animation
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.5, end: 1.2),
        weight: 0.3, // Represents the duration of the second half of the animation
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.2, end: 1),
        weight: 0.3, // Represents the duration of the second half of the animation
      ),
    ]).animate(controller);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  startAnimation() async {
    if (widget.isAnimating || widget.smallLike) {
      controller.reset();
      await controller.forward().whenComplete(() async {
        if (!widget.smallLike) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        if (mounted) { // Check again before calling setState
          widget.onEnd();
        }
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
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
