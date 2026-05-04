// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  SHARED PRIMITIVES — minimal, reusable components
// ═══════════════════════════════════════════════════════════════════════

/// Premium glass card — surface + 1dp border + soft top-edge highlight.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.tone,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Optional tone tint that bleeds gently into the top-edge highlight
  /// (positive/negative/caution/info). Pass `null` for neutral.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlight = (tone ?? c.text).withValues(alpha: isDark ? 0.06 : 0.04);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          children: [
            // Soft inner top-edge highlight — the "glass" feel.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [highlight, highlight.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.tone,
    this.animateNumeric,
    this.formatNumeric,
  });
  final String label;
  final String value;
  final Color tone;

  /// Optional numeric value that, when supplied, drives a count-up/down
  /// animation in place of [value] using [formatNumeric] for rendering.
  final double? animateNumeric;
  final String Function(double)? formatNumeric;

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      color: tone,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: -0.3,
      fontFeatures: kTabularNumerals,
    );
    final valueWidget = (animateNumeric != null && formatNumeric != null)
        ? _AnimatedNumber(
            value: animateNumeric!,
            builder: (ctx, current) =>
                Text(formatNumeric!(current), style: valueStyle),
          )
        : Text(value, style: valueStyle);

    return _Card(
      tone: tone,
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.c.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          valueWidget,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone, this.dense = false});
  final String label;
  final Color tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: tone.withValues(alpha: 0.28), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: dense ? 10 : 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.tone);
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: context.c.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Radial score ring — thicker stroke and gradient sweep for premium feel.
class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter(this.score, this.color, this.bgColor);
  final int score;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(4);
    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(inset)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(inset, -math.pi / 2, 2 * math.pi, false, bg);
    canvas.drawArc(inset, -math.pi / 2, 2 * math.pi * (score / 100), false, fg);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.score != score || old.color != color || old.bgColor != bgColor;
}

// ══════════════════════════════════════════════════════════════════════
//  PREMIUM ADD-ONS — section headers, sparkline, equity curve, win-loss bar,
//                    pulse-dots, divider.
// ══════════════════════════════════════════════════════════════════════

/// Tracked-out caps section header used to introduce groups of cards.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xs,
        Spacing.lg,
        Spacing.xs,
        Spacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: context.c.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// Cumulative-PnL sparkline. Pass the last N trade pnls.
class _Sparkline extends StatelessWidget {
  const _Sparkline({
    required this.values,
    required this.color,
    this.height = 40,
  });
  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(values, color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    // Build cumulative.
    final cum = <double>[];
    double sum = 0;
    for (final v in values) {
      sum += v;
      cum.add(sum);
    }
    final minV = cum.reduce(math.min);
    final maxV = cum.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    Path linePath = Path();
    Path fillPath = Path();
    for (var i = 0; i < cum.length; i++) {
      final x = cum.length == 1
          ? size.width / 2
          : i / (cum.length - 1) * size.width;
      final norm = (cum[i] - minV) / range;
      final y = size.height - (norm * (size.height - 4)) - 2;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fill);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

/// Horizontal split bar — wins (positive tone) vs losses (negative tone).
class _WinLossBar extends StatelessWidget {
  const _WinLossBar({required this.winRate, required this.tradeCount});
  final double winRate; // 0–1
  final int tradeCount;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (tradeCount == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
      );
    }
    final winFlex = (winRate * 1000).round().clamp(1, 999);
    final lossFlex = (1000 - winFlex).clamp(1, 999);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.pill),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Expanded(
              flex: winFlex,
              child: Container(color: c.positive),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: lossFlex,
              child: Container(color: c.negative),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3-dot pulsing skeleton — minimal premium loading indicator.
class _PulseDots extends StatefulWidget {
  const _PulseDots();

  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.c.info;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_ctrl.value + i * 0.15) % 1.0);
            final opacity = 0.3 + 0.7 * (math.sin(t * 2 * math.pi) * 0.5 + 0.5);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
