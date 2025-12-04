import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/client_onboarding.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: switch (Theme.brightnessOf(context)) {
          Brightness.light => Colors.white,
          Brightness.dark => Colors.black,
        },
        body: FadeInTransition(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFFBB9D6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 96),
                Center(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.all(64),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.loose(const Size.fromWidth(280)),
                      child: Image.asset('assets/logo/logo.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Text(
                    'Маркетплейс красоты\nрядом с тобой',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF52443E)),
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
