import 'package:flutter/material.dart';

/// Phase 4: the composition fades and lifts slightly as the application takes
/// over. Keeping the transition inside the splash means the router can swap the
/// route only after the brand experience has finished.
class SplashTransition extends StatelessWidget {
  const SplashTransition({
    super.key,
    required this.exit,
    required this.child,
  });

  /// 0-1 across the 500 ms exit phase.
  final Animation<double> exit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: exit,
      builder: (context, child) {
        final progress = Curves.easeInCubic.transform(
          exit.value.clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: (1 - progress).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1 + 0.035 * progress,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
