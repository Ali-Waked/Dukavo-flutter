import 'package:flutter/animation.dart';

/// The choreography of the Dukavo introduction.
///
/// The first three phases run on a 2500 ms controller. The exit is a separate
/// controller so a slow auth bootstrap can hold the finished brand frame for as
/// long as necessary without replaying or cutting the storyboard short. When
/// the session resolves quickly the two controllers run back to back and the
/// whole introduction is 3000 ms.
class SplashTimeline {
  const SplashTimeline._();

  /// Phases 1-3: reveal, ecosystem and the final brand moment.
  static const Duration intro = Duration(milliseconds: 2500);

  /// Phase 4: fade and scale into the application.
  static const Duration exit = Duration(milliseconds: 500);

  /// The intended length when initialization keeps up with the animation.
  static const Duration total = Duration(milliseconds: 3000);

  /// 0-700 ms: the logo scales and fades into place.
  static const Interval logoReveal = Interval(
    0,
    0.28,
    curve: Curves.easeOutCubic,
  );

  /// The soft brand glow arrives just behind the logo.
  static const Interval glow = Interval(
    0,
    0.34,
    curve: Curves.easeOut,
  );

  /// 700-1800 ms: ecosystem nodes and their connecting paths bloom outwards.
  static const Interval ecosystem = Interval(
    0.24,
    0.74,
    curve: Curves.easeOutCubic,
  );

  /// 1800-2400 ms: the nodes converge and the logo receives a highlight.
  static const Interval collapse = Interval(
    0.70,
    0.96,
    curve: Curves.easeInOutCubic,
  );

  /// A short accent pulse on the logo at the final brand moment.
  static const Interval highlight = Interval(
    0.70,
    0.92,
    curve: Curves.easeInOut,
  );

  /// 1800-2400 ms: the tagline rises into view.
  static const Interval tagline = Interval(
    0.74,
    0.98,
    curve: Curves.easeOutCubic,
  );
}
