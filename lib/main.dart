import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';
import 'faro_widgets.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: FaroColors.night,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Keep the browser version keyboard/screen-reader accessible as well.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final preferences = await SharedPreferences.getInstance();
  runApp(FaroApp(game: GameController(preferences)));
}

class FaroApp extends StatelessWidget {
  const FaroApp({super.key, required this.game});
  final GameController game;
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FaroColors.gold,
        brightness: Brightness.dark,
        surface: FaroColors.deep,
      ),
      scaffoldBackgroundColor: FaroColors.night,
      fontFamily: 'Manrope',
      iconTheme: const IconThemeData(color: FaroColors.gold),
      splashColor: FaroColors.gold.withValues(alpha: .12),
      highlightColor: FaroColors.gold.withValues(alpha: .06),
    );
    return MaterialApp(
      title: 'El Faro de los Dos',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(
          bodyColor: FaroColors.cream,
          displayColor: FaroColors.cream,
        ),
      ),
      scrollBehavior: const FaroScrollBehavior(),
      builder: (context, child) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [Color(0xFF183F44), Color(0xFF040F17)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRect(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
      home: TitleScreen(game: game),
    );
  }
}

class FaroScrollBehavior extends MaterialScrollBehavior {
  const FaroScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
