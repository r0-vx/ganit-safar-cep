part of 'main.dart';

/// Shared classroom visual language. Dashboard colours and layouts stay separate.
abstract final class LearningPalette {
  static const paper = Color(0xFFF6F2E9);
  static const surface = Color(0xFFFFFDF8);
  static const ink = Color(0xFF263E38);
  static const teal = Color(0xFF216653);
  static const blue = Color(0xFF315E92);
  static const amber = Color(0xFFAA6B12);
  static const clay = Color(0xFFA54D32);
  static const line = Color(0xFFD9DFD3);
}

ThemeData learningTheme(ThemeData base) {
  if (store.contrast) return base;
  final primary = LearningPalette.teal;
  return base.copyWith(
    scaffoldBackgroundColor: LearningPalette.paper,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: LearningPalette.clay,
      surface: LearningPalette.surface,
      onSurface: LearningPalette.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: base.filledButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? primary.withValues(alpha: .12)
              : primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? LearningPalette.ink.withValues(alpha: .4)
              : Colors.white,
        ),
      ),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: LearningPalette.paper,
      foregroundColor: LearningPalette.ink,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(
      selectedColor: primary,
      selectedTileColor: const Color(0xFFE5ECDD),
      iconColor: LearningPalette.ink,
      textColor: LearningPalette.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData ganitAppTheme() {
  final base = boardTheme(
    contrast: store.contrast,
    largeText: store.largeText,
    smartboard: store.smartboard,
  );
  return portalSurface == 'dashboard' ? base : learningTheme(base);
}

class LearningSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const LearningSurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });
  @override
  Widget build(BuildContext context) => Material(
    clipBehavior: Clip.antiAlias,
    color: store.contrast ? Colors.white : color ?? LearningPalette.surface,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: store.contrast ? Colors.black : LearningPalette.line,
        width: store.contrast ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(padding: padding ?? const EdgeInsets.all(24), child: child),
  );
}

class LearningArtwork extends StatelessWidget {
  final String asset;
  final double? width, height;
  final BoxFit fit;
  const LearningArtwork({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });
  @override
  Widget build(BuildContext context) {
    final logicalWidth = width?.isFinite == true
        ? width!
        : height?.isFinite == true
        ? height! * 1.5
        : 640.0;
    final decodeWidth =
        (logicalWidth * MediaQuery.devicePixelRatioOf(context).clamp(1, 2))
            .round()
            .clamp(64, 1536);
    return ExcludeSemantics(
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        cacheWidth: decodeWidth,
        errorBuilder: (_, _, _) => SizedBox(
          width: width,
          height: height,
          child: Icon(
            Icons.auto_stories_outlined,
            size: min(width ?? height ?? 64, 100),
            color: LearningPalette.teal,
          ),
        ),
      ),
    );
  }
}

class LearningModeHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  const LearningModeHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6ECDD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: LearningPalette.teal, size: 28),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width < 600 ? 25 : 32,
                  fontWeight: FontWeight.w900,
                  color: store.contrast ? Colors.black : LearningPalette.ink,
                  height: 1.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 17, height: 1.5),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

class AnswerFeedback extends StatefulWidget {
  final bool correct, playSound;
  final String explanation;
  final VoidCallback? onNext;
  const AnswerFeedback({
    super.key,
    required this.correct,
    required this.explanation,
    this.onNext,
    this.playSound = true,
  });
  @override
  State<AnswerFeedback> createState() => _AnswerFeedbackState();
}

class _AnswerFeedbackState extends State<AnswerFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  @override
  void initState() {
    super.initState();
    _respond();
  }

  void _respond() {
    if (widget.correct && widget.playSound && store.sound)
      SystemSound.play(SystemSoundType.click);
    if (store.reducedMotion) {
      animation.value = 1;
    } else {
      animation.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(AnswerFeedback old) {
    super.didUpdateWidget(old);
    if (old.correct != widget.correct) _respond();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colour = store.contrast
        ? Colors.black
        : widget.correct
        ? LearningPalette.teal
        : LearningPalette.blue;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              0,
              store.reducedMotion
                  ? 0
                  : 6 * (1 - Curves.easeOut.transform(animation.value)),
            ),
            child: child,
          ),
          child: LearningSurface(
            color: widget.correct
                ? const Color(0xFFEDF3E5)
                : const Color(0xFFECF1F6),
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.correct)
                  const LearningArtwork(
                    asset: 'assets/art/mascot.png',
                    width: 64,
                    height: 74,
                  )
                else
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colour,
                    size: 34,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.correct
                                ? Icons.verified_rounded
                                : Icons.favorite_outline,
                            color: colour,
                            size: 23,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.correct
                                  ? tr('Well done!', 'शाब्बास!')
                                  : tr(
                                      'Let’s try together',
                                      'आपण मिळून प्रयत्न करूया',
                                    ),
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: colour,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.explanation,
                        style: const TextStyle(fontSize: 18, height: 1.5),
                      ),
                      if (widget.correct)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ExcludeSemantics(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                3,
                                (_) => const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: LearningPalette.amber,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.onNext != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FilledButton.icon(
                            onPressed: widget.onNext,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(tr('Continue', 'पुढे चला')),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
