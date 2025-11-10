import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'dependencies.dart';
import 'authorization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFormatting();

  // Initialize image cache config
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      1024 * 1024 * 100; // 100 MB

  Dependencies.instance.init();

  final masterId = Dependencies.getMasterIdFromUrl();
  logger.info('[main] Starting app with masterId: $masterId');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = AppTheme(
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textPlaceholder: AppColors.textPlaceholder,
      textDisabled: AppColors.textDisabled,
      borderSubtle: AppColors.borderSubtle,
      borderDefault: AppColors.borderDefault,
      borderStrong: AppColors.borderStrong,
      backgroundDefault: AppColors.backgroundDefault,
      backgroundSubtle: AppColors.backgroundSubtle,
      backgroundHover: AppColors.backgroundHover,
      backgroundDisabled: AppColors.backgroundDisabled,
      iconsDefault: AppColors.iconsDefault,
      iconsMuted: AppColors.iconsMuted,
      error: AppColors.error,
      errorLight: AppColors.error,
      success: AppColors.success,
      successLight: AppColors.successLight,
      accent: AppColors.accent,
      accentLight: AppColors.accentLight,
      buttonPrimary: Colors.black,
    );

    return AppThemeScope(
      initialTheme: theme,
      themes: const {'default': theme},
      child: MaterialApp(
        title: 'Polka Online',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final masterId = Dependencies.getMasterIdFromUrl() ?? '1';
          logger.info(
            '[Router] Routing to: ${settings.name}, masterId: $masterId',
          );

          return MaterialPageRoute(
            builder: (context) => AuthorizationPage(masterId: masterId),
            settings: settings,
          );
        },
      ),
    );
  }
}
