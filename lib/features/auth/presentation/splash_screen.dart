import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/auth_destination.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../application/auth_controller.dart';
import 'splash/dukavo_logo_animation.dart';
import 'splash/ecosystem_animation.dart';
import 'splash/splash_timeline.dart';
import 'splash/splash_transition.dart';

/// The branded Dukavo introduction.
///
/// The animation and the auth bootstrap run in parallel. When both are ready the
/// composition fades into the correct destination: the permission-aware
/// dashboard, the platform console, onboarding or the login screen. If the
/// session takes longer than the 3-second storyboard, the finished brand frame
/// stays on screen with a quiet loader and never restarts.
class DukavoSplashScreen extends ConsumerStatefulWidget {
  const DukavoSplashScreen({super.key, this.reduceMotion});

  /// The intended length of the introduction when initialization keeps up.
  static const Duration totalDuration = SplashTimeline.total;

  /// Overrides the platform reduced-motion flag. Tests inject this directly;
  /// production reads `MediaQuery.disableAnimations`.
  final bool? reduceMotion;

  @override
  ConsumerState<DukavoSplashScreen> createState() => _DukavoSplashScreenState();
}

class _DukavoSplashScreenState extends ConsumerState<DukavoSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _exit;

  late final CurvedAnimation _logoReveal;
  late final CurvedAnimation _glow;
  late final CurvedAnimation _ecosystem;
  late final CurvedAnimation _collapse;
  late final CurvedAnimation _tagline;
  late final CurvedAnimation _highlightCurve;
  late final Animation<double> _highlight;

  ProviderSubscription<AuthState>? _authSubscription;

  bool _started = false;
  bool _waiting = false;
  bool _exiting = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: SplashTimeline.intro,
    );
    _exit = AnimationController(
      vsync: this,
      duration: SplashTimeline.exit,
    );

    _logoReveal = CurvedAnimation(
      parent: _intro,
      curve: SplashTimeline.logoReveal,
    );
    _glow = CurvedAnimation(parent: _intro, curve: SplashTimeline.glow);
    _ecosystem = CurvedAnimation(
      parent: _intro,
      curve: SplashTimeline.ecosystem,
    );
    _collapse = CurvedAnimation(
      parent: _intro,
      curve: SplashTimeline.collapse,
    );
    _tagline = CurvedAnimation(parent: _intro, curve: SplashTimeline.tagline);
    _highlightCurve = CurvedAnimation(
      parent: _intro,
      curve: SplashTimeline.highlight,
    );
    _highlight = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 62,
      ),
    ]).animate(_highlightCurve);

    _intro.addStatusListener(_onIntroStatus);
    _exit.addStatusListener(_onExitStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final reduceMotion = widget.reduceMotion ??
        MediaQuery.maybeOf(context)?.disableAnimations ??
        false;
    if (reduceMotion) {
      _intro.duration = const Duration(milliseconds: 1);
      _exit.duration = const Duration(milliseconds: 1);
    }

    _authSubscription = ref.listenManual<AuthState>(
      authControllerProvider,
      (previous, next) => _handleAuth(next),
    );

    _intro.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleAuth(ref.read(authControllerProvider));
    });
  }

  void _onIntroStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _handleAuth(ref.read(authControllerProvider));
  }

  void _handleAuth(AuthState auth) {
    if (!mounted || _navigated || _exiting) return;
    if (_intro.status != AnimationStatus.completed) return;

    final destination = splashDestination(auth);
    if (destination == null) {
      if (!_waiting) setState(() => _waiting = true);
      return;
    }

    if (_waiting) setState(() => _waiting = false);
    _startExit();
  }

  void _startExit() {
    if (_exiting || _navigated) return;
    _exiting = true;
    _exit.forward();
  }

  void _onExitStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _navigate();
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    final destination =
        splashDestination(ref.read(authControllerProvider)) ?? RoutePaths.login;
    _navigated = true;
    context.go(destination);
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _intro
      ..removeStatusListener(_onIntroStatus)
      ..dispose();
    _exit
      ..removeStatusListener(_onExitStatus)
      ..dispose();
    _logoReveal.dispose();
    _glow.dispose();
    _ecosystem.dispose();
    _collapse.dispose();
    _tagline.dispose();
    _highlightCurve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The branded backdrop fades out during phase 4 so the destination
          // screen arrives on the app's own background instead of a hard cut.
          AnimatedBuilder(
            animation: _exit,
            builder: (context, child) {
              return Opacity(
                opacity: 1 - _exit.value.clamp(0.0, 1.0),
                child: child,
              );
            },
            child: _SplashBackdrop(isDark: isDark),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final nodeSize = (width * 0.12).clamp(38.0, 52.0);
                final logoSize = (width * 0.21).clamp(58.0, 86.0);
                final radiusX = math.min(width * 0.40, 168.0);
                final radiusY = math.min(height * 0.19, 150.0);
                final compositionWidth =
                    math.min(width, radiusX * 2 + nodeSize + 24);
                final compositionHeight = radiusY * 2 + nodeSize + 24;

                return Center(
                  child: SplashTransition(
                    exit: _exit,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: compositionWidth,
                          height: compositionHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              EcosystemAnimation(
                                progress: _ecosystem,
                                collapse: _collapse,
                                exit: _exit,
                                radiusX: radiusX,
                                radiusY: radiusY,
                                nodeSize: nodeSize,
                              ),
                              DukavoLogoAnimation(
                                reveal: _logoReveal,
                                glow: _glow,
                                highlight: _highlight,
                                exit: _exit,
                                size: logoSize,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SplashTagline(animation: _tagline, exit: _exit),
                        const SizedBox(height: 22),
                        if (_waiting) const _SplashLoader(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The final tagline, rising and fading in during phase 3.
class _SplashTagline extends StatelessWidget {
  const _SplashTagline({required this.animation, required this.exit});

  final Animation<double> animation;
  final Animation<double> exit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([animation, exit]),
      builder: (context, _) {
        final reveal = animation.value.clamp(0.0, 1.0);
        final exitValue = exit.value.clamp(0.0, 1.0);
        final opacity = (reveal * (1 - exitValue)).clamp(0.0, 1.0);
        final offset = (1 - reveal) * 14;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('splashTagline'),
                  key: const ValueKey('splash-tagline'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 46 * reveal,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shown only when the session is still initializing after the storyboard.
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.tr('splashPreparing'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A calm brand backdrop: no heavy gradients or particles, only a soft teal
/// light behind the mark and a faint lime warmth in one corner.
class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? AppColors.darkBackground : AppColors.background;

    return DecoratedBox(
      decoration: BoxDecoration(color: base),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.08),
                radius: 0.95,
                colors: [
                  AppColors.primary.withValues(
                    alpha: isDark ? 0.22 : 0.13,
                  ),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.85, 0.9),
                radius: 0.7,
                colors: [
                  AppColors.accent.withValues(
                    alpha: isDark ? 0.06 : 0.10,
                  ),
                  AppColors.accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
