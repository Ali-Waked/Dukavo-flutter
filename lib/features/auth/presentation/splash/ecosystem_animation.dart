import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';

/// The five parts of the Dukavo ecosystem that orbit the brand mark.
class _EcosystemNode {
  const _EcosystemNode(this.icon, this.labelKey);

  final IconData icon;
  final String labelKey;
}

const _nodes = <_EcosystemNode>[
  _EcosystemNode(Icons.shopping_bag_rounded, 'products'),
  _EcosystemNode(Icons.receipt_long_rounded, 'orders'),
  _EcosystemNode(Icons.chat_bubble_rounded, 'whatsapp'),
  _EcosystemNode(Icons.inventory_2_rounded, 'inventory'),
  _EcosystemNode(Icons.auto_awesome_rounded, 'splashAi'),
];

/// Draws the Dukavo ecosystem around the logo: products, orders, WhatsApp,
/// inventory and AI automation connected by quietly animated paths.
///
/// Everything is painted with icons and a small [CustomPainter] rather than
/// particles or blurred layers, which keeps the frame cheap on low-end
/// Android hardware while still feeling deliberate.
class EcosystemAnimation extends StatelessWidget {
  const EcosystemAnimation({
    super.key,
    required this.progress,
    required this.collapse,
    required this.exit,
    required this.radiusX,
    required this.radiusY,
    required this.nodeSize,
  });

  /// 0-1: nodes and paths bloom outwards.
  final Animation<double> progress;

  /// 0-1: nodes converge back into the brand mark.
  final Animation<double> collapse;

  /// 0-1: the splash fade/scale transition.
  final Animation<double> exit;

  final double radiusX;
  final double radiusY;
  final double nodeSize;

  static final List<double> _angles = List<double>.generate(
    _nodes.length,
    (index) => -math.pi / 2 + index * (2 * math.pi / _nodes.length),
    growable: false,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = Theme.of(context).colorScheme.primary;
    const accentColor = AppColors.accent;

    return AnimatedBuilder(
      animation: Listenable.merge([progress, collapse, exit]),
      builder: (context, _) {
        // `collapse` is already an eased interval; easing it again would make
        // the convergence feel sluggish at the start.
        final progressValue = progress.value.clamp(0.0, 1.0);
        final pull = collapse.value.clamp(0.0, 1.0);
        final exitValue = exit.value.clamp(0.0, 1.0);
        final currentRadiusX = radiusX * (1 - 0.62 * pull);
        final currentRadiusY = radiusY * (1 - 0.62 * pull);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ConnectionsPainter(
                  progress: progressValue,
                  pull: pull,
                  exit: exitValue,
                  radiusX: radiusX,
                  radiusY: radiusY,
                  lineColor: lineColor,
                  accentColor: accentColor,
                ),
              ),
            ),
            for (var index = 0; index < _nodes.length; index++)
              _node(
                context,
                index: index,
                progress: progressValue,
                pull: pull,
                exit: exitValue,
                radiusX: currentRadiusX,
                radiusY: currentRadiusY,
                isDark: isDark,
                lineColor: lineColor,
              ),
          ],
        );
      },
    );
  }

  Widget _node(
    BuildContext context, {
    required int index,
    required double progress,
    required double pull,
    required double exit,
    required double radiusX,
    required double radiusY,
    required bool isDark,
    required Color lineColor,
  }) {
    final reveal = _nodeProgress(progress, index);
    if (reveal <= 0 || exit >= 1) return const SizedBox.shrink();

    final angle = _angles[index];
    final scale = (Curves.easeOutBack.transform(reveal) * (1 - 0.35 * pull))
        .clamp(0.0, 1.2);
    final opacity =
        (Curves.easeOut.transform(reveal) * (1 - 0.82 * pull) * (1 - exit))
            .clamp(0.0, 1.0);
    final node = _nodes[index];

    return Positioned.fill(
      child: Center(
        child: Transform.translate(
          offset: Offset(
            math.cos(angle) * radiusX,
            math.sin(angle) * radiusY,
          ),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Semantics(
                label: context.tr(node.labelKey),
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(nodeSize * 0.34),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lineColor.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    node.icon,
                    size: nodeSize * 0.44,
                    color: lineColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Each node has its own small entrance window inside the reveal.
  static double _nodeProgress(double progress, int index) {
    final start = 0.05 + index * 0.10;
    const span = 0.42;
    return ((progress - start) / span).clamp(0.0, 1.0);
  }
}

/// Draws gently curved paths from the logo out to each ecosystem node.
class _ConnectionsPainter extends CustomPainter {
  const _ConnectionsPainter({
    required this.progress,
    required this.pull,
    required this.exit,
    required this.radiusX,
    required this.radiusY,
    required this.lineColor,
    required this.accentColor,
  });

  final double progress;
  final double pull;
  final double exit;
  final double radiusX;
  final double radiusY;
  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || exit >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final currentRadiusX = radiusX * (1 - 0.62 * pull);
    final currentRadiusY = radiusY * (1 - 0.62 * pull);

    for (var index = 0; index < _nodes.length; index++) {
      final reveal = EcosystemAnimation._nodeProgress(progress, index);
      if (reveal <= 0) continue;

      final angle = EcosystemAnimation._angles[index];
      final node = center +
          Offset(
            math.cos(angle) * currentRadiusX,
            math.sin(angle) * currentRadiusY,
          );
      final end = Offset.lerp(center, node, reveal)!;
      final middle = Offset.lerp(center, node, 0.5)!;
      final delta = node - center;
      final bow = Offset(-delta.dy, delta.dx) * 0.035;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          middle.dx + bow.dx,
          middle.dy + bow.dy,
          end.dx,
          end.dy,
        );

      final alpha = (0.30 * reveal * (1 - pull) * (1 - exit)).clamp(0.0, 1.0);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            lineColor.withValues(alpha: alpha * 0.5),
            accentColor.withValues(alpha: alpha),
          ],
        ).createShader(Rect.fromPoints(center, node));

      canvas.drawPath(path, paint);

      // A tiny accent mote marks the growing tip of each connection.
      canvas.drawCircle(
        end,
        2.1 * reveal,
        Paint()..color = accentColor.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionsPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        pull != oldDelegate.pull ||
        exit != oldDelegate.exit ||
        radiusX != oldDelegate.radiusX ||
        radiusY != oldDelegate.radiusY ||
        lineColor != oldDelegate.lineColor ||
        accentColor != oldDelegate.accentColor;
  }
}
