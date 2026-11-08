import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';

/// The Dukavo wordmark with its reveal, glow and final-brand highlight.
///
/// The asset is the real brand artwork from `assets/images/logo-full.png`; the
/// widget only scales and lights it, so the logo is never redrawn, stretched or
/// replaced with a look-alike.
class DukavoLogoAnimation extends StatelessWidget {
  const DukavoLogoAnimation({
    super.key,
    required this.reveal,
    required this.glow,
    required this.highlight,
    required this.exit,
    required this.size,
  });

  /// 0-1: the logo scales and fades in.
  final Animation<double> reveal;

  /// 0-1: the ambient brand glow.
  final Animation<double> glow;

  /// 0-1: a short accent pulse at the final brand moment.
  final Animation<double> highlight;

  /// 0-1: the splash fade/scale transition.
  final Animation<double> exit;

  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([reveal, glow, highlight, exit]),
      builder: (context, child) {
        // The timeline's intervals already carry their easing curves, so only
        // clamp here instead of easing a second time.
        final revealValue = reveal.value.clamp(0.0, 1.0);
        final highlightValue = highlight.value.clamp(0.0, 1.0);
        final exitValue = exit.value.clamp(0.0, 1.0);

        final opacity = (revealValue * (1 - exitValue)).clamp(0.0, 1.0);
        final scale = (0.90 + 0.10 * revealValue) *
            (1 + 0.025 * highlightValue) *
            (1 - 0.04 * exitValue);
        final glowAlpha =
            (0.10 + 0.30 * glow.value.clamp(0.0, 1.0) + 0.18 * highlightValue) *
                (1 - exitValue);

        return RepaintBoundary(
          child: SizedBox(
            width: size * 2.9,
            height: size * 2.1,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // The ambient light behind the mark. A radial gradient is far
                // cheaper than a large blurred shadow on low-end devices.
                IgnorePointer(
                  child: Container(
                    width: size * 2.6,
                    height: size * 2.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(
                            alpha: glowAlpha.clamp(0.0, 1.0),
                          ),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: EdgeInsets.all(3 + 2 * highlightValue),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.24),
                        border: Border.all(
                          color: AppColors.accent.withValues(
                            alpha: (0.55 * highlightValue).clamp(0.0, 1.0),
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: (0.20 * (1 - exitValue)).clamp(0.0, 1.0),
                            ),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: AppLogo(
        size: size,
        showWordmark: true,
        forceLightBackground: true,
      ),
    );
  }
}
