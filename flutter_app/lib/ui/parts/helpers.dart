// GENERATED-BY-SPLIT - do not import this file directly.
part of '../trading_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════

Color _sessionTone(BuildContext context, String type) {
  switch (type) {
    case 'green':
      return AppTheme.green;
    case 'red':
      return AppTheme.red;
    case 'amber':
      return AppTheme.amber;
    default:
      return context.c.textTertiary;
  }
}

String _eatTime(DateTime dt) {
  return '${dt.toUtc().hour.toString().padLeft(2, '0')}:'
      '${dt.toUtc().minute.toString().padLeft(2, '0')}:'
      '${dt.toUtc().second.toString().padLeft(2, '0')}';
}

String _compact(double v) {
  if (v.abs() >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  return '\$${v.toStringAsFixed(0)}';
}

String _signed(double v) {
  final s = v >= 0 ? '+' : '';
  return '$s\$${v.toStringAsFixed(0)}';
}

// -----------------------------------------------------------------------
//  THEME TOGGLE
// -----------------------------------------------------------------------

/// Quick icon button that cycles System ? Light ? Dark.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.controller});
  final TradingScreenViewModel controller;

  IconData _iconFor(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _labelFor(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'System theme';
    }
  }

  ThemeMode _next(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = controller.themeMode;
    return IconButton(
      onPressed: () => controller.setThemeMode(_next(mode)),
      icon: Icon(_iconFor(mode), color: context.c.textTertiary, size: 22),
      tooltip: _labelFor(mode),
    );
  }
}

/// 3-way segmented control for ThemeMode (Settings screen).
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.controller});
  final TradingScreenViewModel controller;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {controller.themeMode},
      onSelectionChanged: (s) => controller.setThemeMode(s.first),
      showSelectedIcon: false,
    );
  }
}

// -----------------------------------------------------------------------
//  IMAGE VIEWER (Hero target for journal chart screenshots)
// -----------------------------------------------------------------------

class _ImageViewerScreen extends StatelessWidget {
  const _ImageViewerScreen({required this.path, required this.heroTag});

  final String path;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white70,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
//  ANIMATED NUMBER � tweens between values for snappy KPI updates
// -----------------------------------------------------------------------

class _AnimatedNumber extends StatefulWidget {
  const _AnimatedNumber({
    required this.value,
    required this.builder,
    // ignore: unused_element_parameter
    this.duration = const Duration(milliseconds: 600),
    // ignore: unused_element_parameter
    this.curve = Curves.easeOutCubic,
  });

  final double value;
  final Widget Function(BuildContext context, double current) builder;
  final Duration duration;
  final Curve curve;

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber> {
  late double _from = widget.value;

  @override
  void didUpdateWidget(covariant _AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _from, end: widget.value),
      duration: widget.duration,
      curve: widget.curve,
      builder: (ctx, current, _) => widget.builder(ctx, current),
    );
  }
}
