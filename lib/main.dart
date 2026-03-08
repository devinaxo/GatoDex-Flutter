import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/main_wrapper.dart';
import 'screens/backup_screen.dart';
import 'services/theme_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _seedColor = Colors.orange;

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        if (themeService.useDynamicColor) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final lightScheme = lightDynamic?.harmonized() ??
                  ColorScheme.fromSeed(seedColor: _seedColor);
              final darkScheme = darkDynamic?.harmonized() ??
                  ColorScheme.fromSeed(
                    seedColor: _seedColor,
                    brightness: Brightness.dark,
                  );

              return _buildMaterialApp(
                theme: _buildTheme(lightScheme),
                darkTheme: _buildTheme(darkScheme),
                themeMode: themeService.themeMode,
              );
            },
          );
        }

        final lightScheme = ColorScheme.fromSeed(seedColor: _seedColor);
        final darkScheme = ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        );

        return _buildMaterialApp(
          theme: _buildTheme(lightScheme),
          darkTheme: _buildTheme(darkScheme),
          themeMode: themeService.themeMode,
        );
      },
    );
  }

  MaterialApp _buildMaterialApp({
    required ThemeData theme,
    required ThemeData darkTheme,
    required ThemeMode themeMode,
  }) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: const MainWrapper(),
      routes: {
        '/backup': (context) => const BackupScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
