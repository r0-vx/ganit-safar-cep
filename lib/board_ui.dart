part of 'main.dart';

/// Builds the shared app theme for touch-first boards and regular devices.
///
/// In smartboard mode, the default Material buttons and icon buttons get
/// generous tap targets and an obvious keyboard/remote focus outline. Phones
/// can use the same theme without enabling the larger controls.
ThemeData boardTheme({
  required bool contrast,
  required bool largeText,
  required bool smartboard,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: green,
    contrastLevel: contrast ? 1 : 0,
  );
  final target = smartboard ? 72.0 : 56.0;
  final targetHeight = smartboard ? 64.0 : 52.0;
  final baseTextSize = smartboard ? 19.0 : 16.0;
  // GanitApp applies the user's text scale once at the app boundary.
  const scale = 1.0;
  final onFocusDark = contrast ? Colors.black : ink;
  final focusOverlay = contrast ? Colors.black : green;

  ButtonStyle sizedButton({
    required Color foreground,
    Color? background,
    required Color restingOutline,
    required Color focusedOutline,
    required double minWidth,
    required double minHeight,
    required EdgeInsetsGeometry padding,
    required BorderRadius radius,
    bool showRestingOutline = false,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: .38);
        }
        return foreground;
      }),
      backgroundColor: background == null
          ? null
          : WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return scheme.onSurface.withValues(alpha: .12);
              }
              return background;
            }),
      minimumSize: WidgetStatePropertyAll(Size(minWidth, minHeight)),
      padding: WidgetStatePropertyAll(padding),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: focusedOutline, width: 3);
        }
        if (states.contains(WidgetState.disabled) && showRestingOutline) {
          return BorderSide(
            color: scheme.onSurface.withValues(alpha: .12),
            width: 1,
          );
        }
        if (showRestingOutline) {
          return BorderSide(color: restingOutline, width: smartboard ? 2 : 1);
        }
        return null;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.focused)) {
          return focusOverlay.withValues(alpha: .18);
        }
        if (states.contains(WidgetState.pressed)) {
          return foreground.withValues(alpha: .12);
        }
        return null;
      }),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: (smartboard ? 18 : 16) * scale),
      ),
    );
  }

  final radius = BorderRadius.circular(smartboard ? 20 : 16);
  final textTheme =
      ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSans',
        fontFamilyFallback: const ['NotoDevanagari', 'NotoEmoji'],
      ).textTheme.copyWith(
        bodyMedium: TextStyle(fontSize: baseTextSize * scale, color: ink),
        bodyLarge: TextStyle(
          fontSize: (smartboard ? 22 : 18) * scale,
          color: ink,
        ),
        labelLarge: TextStyle(fontSize: (smartboard ? 18 : 16) * scale),
        titleMedium: TextStyle(fontSize: (smartboard ? 21 : 18) * scale),
        titleLarge: TextStyle(fontSize: (smartboard ? 27 : 22) * scale),
      );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: contrast ? Colors.white : cream,
    fontFamily: 'NotoSans',
    fontFamilyFallback: const ['NotoDevanagari', 'NotoEmoji'],
    colorScheme: scheme,
    textTheme: textTheme,
    focusColor: onFocusDark.withValues(alpha: .16),
    hoverColor: scheme.primary.withValues(alpha: .10),
    visualDensity: VisualDensity.standard,
    filledButtonTheme: FilledButtonThemeData(
      style: sizedButton(
        foreground: Colors.white,
        background: green,
        restingOutline: green,
        focusedOutline: Colors.white,
        minWidth: target,
        minHeight: targetHeight,
        padding: EdgeInsets.symmetric(
          horizontal: smartboard ? 24 : 20,
          vertical: smartboard ? 18 : 15,
        ),
        radius: radius,
        showRestingOutline: smartboard,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: sizedButton(
        foreground: green,
        restingOutline: contrast ? Colors.black : green,
        focusedOutline: onFocusDark,
        minWidth: target,
        minHeight: targetHeight,
        padding: EdgeInsets.symmetric(
          horizontal: smartboard ? 22 : 18,
          vertical: smartboard ? 18 : 15,
        ),
        radius: radius,
        showRestingOutline: true,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: sizedButton(
        foreground: green,
        restingOutline: green,
        focusedOutline: onFocusDark,
        minWidth: smartboard ? 64 : 48,
        minHeight: smartboard ? 64 : 48,
        padding: EdgeInsets.symmetric(
          horizontal: smartboard ? 20 : 14,
          vertical: smartboard ? 16 : 12,
        ),
        radius: radius,
        showRestingOutline: false,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: sizedButton(
        foreground: contrast ? Colors.black : ink,
        restingOutline: contrast ? Colors.black : scheme.outline,
        focusedOutline: onFocusDark,
        minWidth: smartboard ? 72 : 48,
        minHeight: smartboard ? 72 : 48,
        padding: EdgeInsets.all(smartboard ? 20 : 12),
        radius: radius,
        showRestingOutline: false,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(
        horizontal: smartboard ? 20 : 16,
        vertical: smartboard ? 20 : 14,
      ),
      labelStyle: TextStyle(fontSize: (smartboard ? 18 : 16) * scale),
      border: OutlineInputBorder(borderRadius: radius),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: onFocusDark, width: 3),
      ),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: smartboard ? 16 : 8,
      contentPadding: EdgeInsets.symmetric(horizontal: smartboard ? 20 : 16),
      titleTextStyle: TextStyle(
        fontSize: (smartboard ? 19 : 16) * scale,
        color: ink,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: (smartboard ? 16 : 14) * scale,
        color: ink,
      ),
    ),
  );
}

/// A bilingual setting for enabling large board controls and visible focus.
///
/// Buttons retain standard Flutter focus and activation behavior, so a TV
/// remote, keyboard, or mouse can still operate the same visible actions.
class BoardTouchSettings extends StatelessWidget {
  const BoardTouchSettings({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: store.smartboard ? 10 : 4),
        child: SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(
            tr(
              'Smartboard / Android TV controls',
              'स्मार्टबोर्ड / Android TV नियंत्रणे',
            ),
          ),
          subtitle: Text(
            tr(
              'Use larger controls and clear focus highlights for touch, remote, mouse, and keyboard navigation.',
              'स्पर्श, रिमोट, माउस आणि कीबोर्ड वापरताना मोठी नियंत्रणे आणि स्पष्ट फोकस हायलाइट वापरा.',
            ),
          ),
          value: store.smartboard,
          onChanged: (enabled) {
            store.smartboard = enabled;
            store.save();
          },
        ),
      ),
    ),
  );
}
